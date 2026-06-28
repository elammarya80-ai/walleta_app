import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/db_constants.dart';
import '../database/database_helper.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<String> createBackup() async {
    try {
      await _dbHelper.closeDatabase();

      final dbPath = await _dbHelper.getDatabasePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception('ملف قاعدة البيانات غير موجود');
      }

      final downloadsDir = await _getBackupDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final backupName =
          '${AppConstants.backupFileName}_$timestamp${AppConstants.backupExtension}';
      final backupPath = join(downloadsDir.path, backupName);

      await dbFile.copy(backupPath);
      await _dbHelper.reopenDatabase();

      return backupPath;
    } catch (e) {
      await _dbHelper.reopenDatabase();
      rethrow;
    }
  }

  Future<void> shareBackup() async {
    final backupPath = await createBackup();
    final file = XFile(backupPath);
    await Share.shareXFiles(
      [file],
      subject: 'نسخة احتياطية - محفظة أبو عمير',
      text: 'نسخة احتياطية من تطبيق محفظة أبو عمير',
    );
  }

  Future<void> restoreBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        throw Exception('ملف النسخة الاحتياطية غير موجود');
      }

      await _dbHelper.closeDatabase();

      final dbPath = await _dbHelper.getDatabasePath();
      await backupFile.copy(dbPath);
      await _dbHelper.reopenDatabase();
    } catch (e) {
      await _dbHelper.reopenDatabase();
      rethrow;
    }
  }

  Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first.path;
  }

  Future<Directory> _getBackupDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory ?? await getApplicationDocumentsDirectory();
  }

  Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final dir = await _getBackupDirectory();
      if (!await dir.exists()) return [];
      final files = dir.listSync().where((f) {
        return f is File &&
            basename(f.path).startsWith(AppConstants.backupFileName) &&
            f.path.endsWith(AppConstants.backupExtension);
      }).toList();
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return files;
    } catch (_) {
      return [];
    }
  }

  Future<bool> deleteBackupFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

import '../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/wallet_model.dart';

class WalletService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> createWallet(WalletModel wallet) async {
    final now = DateTime.now();
    final model = wallet.copyWith(createdAt: now, updatedAt: now);
    return await _db.insert(DbConstants.tableWallets, model.toMap());
  }

  Future<List<WalletModel>> getAllWallets() async {
    final maps = await _db.query(
      DbConstants.tableWallets,
      orderBy: '${DbConstants.walletCreatedAt} DESC',
    );
    return maps.map((m) => WalletModel.fromMap(m)).toList();
  }

  Future<WalletModel?> getWalletById(int id) async {
    final maps = await _db.query(
      DbConstants.tableWallets,
      where: '${DbConstants.walletId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WalletModel.fromMap(maps.first);
  }

  Future<List<WalletModel>> searchWallets(String query) async {
    final maps = await _db.query(
      DbConstants.tableWallets,
      where:
          '${DbConstants.walletName} LIKE ? OR ${DbConstants.walletNumber} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '${DbConstants.walletCreatedAt} DESC',
    );
    return maps.map((m) => WalletModel.fromMap(m)).toList();
  }

  Future<int> updateWallet(WalletModel wallet) async {
    final model = wallet.copyWith(updatedAt: DateTime.now());
    return await _db.update(
      DbConstants.tableWallets,
      model.toMap(),
      '${DbConstants.walletId} = ?',
      [wallet.id],
    );
  }

  Future<int> updateWalletBalance(int walletId, double newBalance) async {
    return await _db.update(
      DbConstants.tableWallets,
      {
        DbConstants.walletBalance: newBalance,
        DbConstants.walletUpdatedAt: DateTime.now().toIso8601String(),
      },
      '${DbConstants.walletId} = ?',
      [walletId],
    );
  }

  Future<int> adjustWalletBalance(int walletId, double delta) async {
    return await _db.rawUpdate(
      '''UPDATE ${DbConstants.tableWallets} 
         SET ${DbConstants.walletBalance} = ${DbConstants.walletBalance} + ?,
             ${DbConstants.walletUpdatedAt} = ?
         WHERE ${DbConstants.walletId} = ?''',
      [delta, DateTime.now().toIso8601String(), walletId],
    );
  }

  Future<int> deleteWallet(int id) async {
    return await _db.delete(
      DbConstants.tableWallets,
      '${DbConstants.walletId} = ?',
      [id],
    );
  }

  Future<double> getTotalBalance() async {
    return await _db.sum(DbConstants.tableWallets, DbConstants.walletBalance);
  }

  Future<int> getWalletsCount() async {
    return await _db.count(DbConstants.tableWallets);
  }
}

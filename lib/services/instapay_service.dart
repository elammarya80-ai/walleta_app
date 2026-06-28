import '../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/instapay_model.dart';

class InstapayService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> createAccount(InstapayModel account) async {
    final now = DateTime.now();
    final model = account.copyWith(createdAt: now, updatedAt: now);
    return await _db.insert(DbConstants.tableInstapay, model.toMap());
  }

  Future<List<InstapayModel>> getAllAccounts() async {
    final maps = await _db.query(
      DbConstants.tableInstapay,
      orderBy: '${DbConstants.instapayCreatedAt} DESC',
    );
    return maps.map((m) => InstapayModel.fromMap(m)).toList();
  }

  Future<InstapayModel?> getAccountById(int id) async {
    final maps = await _db.query(
      DbConstants.tableInstapay,
      where: '${DbConstants.instapayId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return InstapayModel.fromMap(maps.first);
  }

  Future<List<InstapayModel>> searchAccounts(String query) async {
    final maps = await _db.query(
      DbConstants.tableInstapay,
      where:
          '${DbConstants.instapayName} LIKE ? OR ${DbConstants.instapayAccountNumber} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '${DbConstants.instapayCreatedAt} DESC',
    );
    return maps.map((m) => InstapayModel.fromMap(m)).toList();
  }

  Future<int> updateAccount(InstapayModel account) async {
    final model = account.copyWith(updatedAt: DateTime.now());
    return await _db.update(
      DbConstants.tableInstapay,
      model.toMap(),
      '${DbConstants.instapayId} = ?',
      [account.id],
    );
  }

  Future<int> updateAccountBalance(int accountId, double newBalance) async {
    return await _db.update(
      DbConstants.tableInstapay,
      {
        DbConstants.instapayBalance: newBalance,
        DbConstants.instapayUpdatedAt: DateTime.now().toIso8601String(),
      },
      '${DbConstants.instapayId} = ?',
      [accountId],
    );
  }

  Future<int> adjustAccountBalance(int accountId, double delta) async {
    return await _db.rawUpdate(
      '''UPDATE ${DbConstants.tableInstapay}
         SET ${DbConstants.instapayBalance} = ${DbConstants.instapayBalance} + ?,
             ${DbConstants.instapayUpdatedAt} = ?
         WHERE ${DbConstants.instapayId} = ?''',
      [delta, DateTime.now().toIso8601String(), accountId],
    );
  }

  Future<int> deleteAccount(int id) async {
    return await _db.delete(
      DbConstants.tableInstapay,
      '${DbConstants.instapayId} = ?',
      [id],
    );
  }

  Future<double> getTotalBalance() async {
    return await _db.sum(DbConstants.tableInstapay, DbConstants.instapayBalance);
  }

  Future<int> getAccountsCount() async {
    return await _db.count(DbConstants.tableInstapay);
  }
}

import 'package:sqflite/sqflite.dart';
import '../core/constants/db_constants.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _runMigration(db, version);
    }
  }

  static Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        await _migrateV2(db);
        break;
      default:
        break;
    }
  }

  // Placeholder for future migrations
  static Future<void> _migrateV2(Database db) async {
    // Example: Add new column to wallets
    // await db.execute('ALTER TABLE ${DbConstants.tableWallets} ADD COLUMN new_field TEXT');
  }

  static Future<void> resetDatabase(Database db) async {
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableTransactions}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableInstapay}');
    await db.execute('DROP TABLE IF EXISTS ${DbConstants.tableWallets}');
    await db.execute(DbConstants.createWalletsTable);
    await db.execute(DbConstants.createInstapayTable);
    await db.execute(DbConstants.createTransactionsTable);
  }
}

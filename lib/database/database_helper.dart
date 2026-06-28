import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants/db_constants.dart';
import 'database_migrations.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.dbName);

    return await openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DbConstants.createWalletsTable);
    await db.execute(DbConstants.createInstapayTable);
    await db.execute(DbConstants.createTransactionsTable);
    await _createIndexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await DatabaseMigrations.migrate(db, oldVersion, newVersion);
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_type 
      ON ${DbConstants.tableTransactions}(${DbConstants.txType})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_created_at 
      ON ${DbConstants.tableTransactions}(${DbConstants.txCreatedAt})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_source 
      ON ${DbConstants.tableTransactions}(${DbConstants.txSourceId}, ${DbConstants.txSourceType})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_status 
      ON ${DbConstants.tableTransactions}(${DbConstants.txStatus})
    ''');
  }

  // ── Generic CRUD ──────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> sum(
    String table,
    String column, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM($column) as total FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    final val = result.first['total'];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  // ── Database Management ───────────────────────────────────────

  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, DbConstants.dbName);
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final path = await getDatabasePath();
    await closeDatabase();
    await databaseFactory.deleteDatabase(path);
  }

  Future<void> reopenDatabase() async {
    await closeDatabase();
    _database = await _initDatabase();
  }
}

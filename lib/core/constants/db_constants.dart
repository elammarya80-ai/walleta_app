class DbConstants {
  DbConstants._();

  static const String dbName = 'mohafzat_abu_omayr.db';
  static const int dbVersion = 1;

  // Table Names
  static const String tableWallets = 'wallets';
  static const String tableInstapay = 'instapay_accounts';
  static const String tableTransactions = 'transactions';

  // Wallets Table Columns
  static const String walletId = 'id';
  static const String walletName = 'name';
  static const String walletNumber = 'number';
  static const String walletBalance = 'balance';
  static const String walletColor = 'color';
  static const String walletNotes = 'notes';
  static const String walletCreatedAt = 'created_at';
  static const String walletUpdatedAt = 'updated_at';

  // InstaPay Table Columns
  static const String instapayId = 'id';
  static const String instapayName = 'name';
  static const String instapayAccountNumber = 'account_number';
  static const String instapayBalance = 'balance';
  static const String instapayNotes = 'notes';
  static const String instapayCreatedAt = 'created_at';
  static const String instapayUpdatedAt = 'updated_at';

  // Transactions Table Columns
  static const String txId = 'id';
  static const String txType = 'type';
  static const String txSourceType = 'source_type';
  static const String txSourceId = 'source_id';
  static const String txDestType = 'dest_type';
  static const String txDestId = 'dest_id';
  static const String txAmount = 'amount';
  static const String txCommission = 'commission';
  static const String txProfit = 'profit';
  static const String txClientName = 'client_name';
  static const String txClientNumber = 'client_number';
  static const String txNotes = 'notes';
  static const String txStatus = 'status';
  static const String txCreatedAt = 'created_at';
  static const String txUpdatedAt = 'updated_at';

  // Create Tables SQL
  static const String createWalletsTable = '''
    CREATE TABLE IF NOT EXISTS $tableWallets (
      $walletId INTEGER PRIMARY KEY AUTOINCREMENT,
      $walletName TEXT NOT NULL,
      $walletNumber TEXT NOT NULL,
      $walletBalance REAL NOT NULL DEFAULT 0.0,
      $walletColor INTEGER NOT NULL DEFAULT 0xFF6C63FF,
      $walletNotes TEXT,
      $walletCreatedAt TEXT NOT NULL,
      $walletUpdatedAt TEXT NOT NULL
    )
  ''';

  static const String createInstapayTable = '''
    CREATE TABLE IF NOT EXISTS $tableInstapay (
      $instapayId INTEGER PRIMARY KEY AUTOINCREMENT,
      $instapayName TEXT NOT NULL,
      $instapayAccountNumber TEXT NOT NULL,
      $instapayBalance REAL NOT NULL DEFAULT 0.0,
      $instapayNotes TEXT,
      $instapayCreatedAt TEXT NOT NULL,
      $instapayUpdatedAt TEXT NOT NULL
    )
  ''';

  static const String createTransactionsTable = '''
    CREATE TABLE IF NOT EXISTS $tableTransactions (
      $txId INTEGER PRIMARY KEY AUTOINCREMENT,
      $txType TEXT NOT NULL,
      $txSourceType TEXT NOT NULL,
      $txSourceId INTEGER,
      $txDestType TEXT,
      $txDestId INTEGER,
      $txAmount REAL NOT NULL DEFAULT 0.0,
      $txCommission REAL NOT NULL DEFAULT 0.0,
      $txProfit REAL NOT NULL DEFAULT 0.0,
      $txClientName TEXT,
      $txClientNumber TEXT,
      $txNotes TEXT,
      $txStatus TEXT NOT NULL DEFAULT 'completed',
      $txCreatedAt TEXT NOT NULL,
      $txUpdatedAt TEXT NOT NULL
    )
  ''';
}

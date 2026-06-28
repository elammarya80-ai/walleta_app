class AppConstants {
  AppConstants._();

  static const String appName = 'محفظة أبو عمير';
  static const String appVersion = '1.0.0';

  // Transaction Types
  static const String txTransfer = 'transfer';
  static const String txWithdraw = 'withdraw';
  static const String txDeposit = 'deposit';

  // Transaction Status
  static const String statusCompleted = 'completed';
  static const String statusPending = 'pending';
  static const String statusFailed = 'failed';

  // Source Types
  static const String sourceWallet = 'wallet';
  static const String sourceInstapay = 'instapay';
  static const String sourceCash = 'cash';

  // Report Periods
  static const String periodDaily = 'daily';
  static const String periodWeekly = 'weekly';
  static const String periodMonthly = 'monthly';
  static const String periodYearly = 'yearly';

  // SharedPreferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyPrimaryColor = 'primary_color';
  static const String keyLanguage = 'language';
  static const String keyFirstRun = 'first_run';

  // Wallet Colors
  static const List<int> walletColors = [
    0xFF6C63FF,
    0xFFE53935,
    0xFF00897B,
    0xFF1E88E5,
    0xFFFF6F00,
    0xFF8E24AA,
    0xFF43A047,
    0xFFD81B60,
    0xFF546E7A,
    0xFFFF7043,
  ];

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 700);

  // Pagination
  static const int pageSize = 20;

  // Backup
  static const String backupFileName = 'mohafzat_backup';
  static const String backupExtension = '.db';

  static String get transactionTypeLabel {
    return '';
  }

  static String getTransactionTypeAr(String type) {
    switch (type) {
      case txTransfer:
        return 'تحويل';
      case txWithdraw:
        return 'سحب';
      case txDeposit:
        return 'إيداع';
      default:
        return 'غير معروف';
    }
  }

  static String getStatusAr(String status) {
    switch (status) {
      case statusCompleted:
        return 'مكتملة';
      case statusPending:
        return 'معلقة';
      case statusFailed:
        return 'فاشلة';
      default:
        return 'غير معروف';
    }
  }

  static String getSourceAr(String source) {
    switch (source) {
      case sourceWallet:
        return 'محفظة';
      case sourceInstapay:
        return 'انستاباي';
      case sourceCash:
        return 'نقدي';
      default:
        return source;
    }
  }
}

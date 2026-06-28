import '../core/constants/app_constants.dart';
import '../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/report_model.dart';
import '../models/wallet_model.dart';
import '../models/instapay_model.dart';
import 'wallet_service.dart';
import 'instapay_service.dart';
import 'transaction_service.dart';

class ReportService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final WalletService _walletService = WalletService();
  final InstapayService _instapayService = InstapayService();
  final TransactionService _txService = TransactionService();

  Future<ReportModel> generateReport(DateTime from, DateTime to) async {
    final toEnd = DateTime(to.year, to.month, to.day, 23, 59, 59);

    final wallets = await _walletService.getAllWallets();
    final instapayAccounts = await _instapayService.getAllAccounts();

    final totalWalletBalance = wallets.fold<double>(0, (s, w) => s + w.balance);
    final totalInstapayBalance = instapayAccounts.fold<double>(0, (s, a) => s + a.balance);
    final totalBalance = totalWalletBalance + totalInstapayBalance;

    final totalTransfers = await _txService.getTotalAmount(
      type: AppConstants.txTransfer, from: from, to: toEnd,
    );
    final totalWithdraws = await _txService.getTotalAmount(
      type: AppConstants.txWithdraw, from: from, to: toEnd,
    );
    final totalDeposits = await _txService.getTotalAmount(
      type: AppConstants.txDeposit, from: from, to: toEnd,
    );
    final totalProfit = await _txService.getTotalProfit(from: from, to: toEnd);

    final totalCommission = await _db.sum(
      DbConstants.tableTransactions,
      DbConstants.txCommission,
      where: '${DbConstants.txCreatedAt} >= ? AND ${DbConstants.txCreatedAt} <= ?',
      whereArgs: [from.toIso8601String(), toEnd.toIso8601String()],
    );

    final txCount = await _txService.getTransactionsCount(from: from, to: toEnd);
    final transferCount = await _txService.getTransactionsCount(
      type: AppConstants.txTransfer, from: from, to: toEnd,
    );
    final withdrawCount = await _txService.getTransactionsCount(
      type: AppConstants.txWithdraw, from: from, to: toEnd,
    );
    final depositCount = await _txService.getTransactionsCount(
      type: AppConstants.txDeposit, from: from, to: toEnd,
    );

    final walletBalances = <String, double>{};
    for (final w in wallets) {
      walletBalances[w.name] = w.balance;
    }

    final instapayBalances = <String, double>{};
    for (final a in instapayAccounts) {
      instapayBalances[a.name] = a.balance;
    }

    final dailyStats = await _getDailyStats(from, toEnd);

    return ReportModel(
      totalBalance: totalBalance,
      totalTransfers: totalTransfers,
      totalWithdraws: totalWithdraws,
      totalDeposits: totalDeposits,
      totalProfit: totalProfit,
      totalCommission: totalCommission,
      transactionCount: txCount,
      transferCount: transferCount,
      withdrawCount: withdrawCount,
      depositCount: depositCount,
      walletBalances: walletBalances,
      instapayBalances: instapayBalances,
      dailyStats: dailyStats,
      from: from,
      to: toEnd,
    );
  }

  Future<List<DailyStats>> _getDailyStats(DateTime from, DateTime to) async {
    final rows = await _db.rawQuery('''
      SELECT 
        DATE(${DbConstants.txCreatedAt}) as day,
        SUM(CASE WHEN ${DbConstants.txType} = '${AppConstants.txTransfer}' THEN ${DbConstants.txAmount} ELSE 0 END) as transfers,
        SUM(CASE WHEN ${DbConstants.txType} = '${AppConstants.txWithdraw}' THEN ${DbConstants.txAmount} ELSE 0 END) as withdraws,
        SUM(CASE WHEN ${DbConstants.txType} = '${AppConstants.txDeposit}' THEN ${DbConstants.txAmount} ELSE 0 END) as deposits,
        SUM(${DbConstants.txProfit}) as profit,
        COUNT(*) as count
      FROM ${DbConstants.tableTransactions}
      WHERE ${DbConstants.txCreatedAt} >= ? AND ${DbConstants.txCreatedAt} <= ?
      GROUP BY day
      ORDER BY day ASC
    ''', [from.toIso8601String(), to.toIso8601String()]);

    return rows.map((row) {
      return DailyStats(
        date: DateTime.parse(row['day'] as String),
        transfers: (row['transfers'] as num?)?.toDouble() ?? 0,
        withdraws: (row['withdraws'] as num?)?.toDouble() ?? 0,
        deposits: (row['deposits'] as num?)?.toDouble() ?? 0,
        profit: (row['profit'] as num?)?.toDouble() ?? 0,
        count: (row['count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<ReportModel> generateDailyReport(DateTime date) async {
    return generateReport(
      DateTime(date.year, date.month, date.day),
      DateTime(date.year, date.month, date.day, 23, 59, 59),
    );
  }

  Future<ReportModel> generateWeeklyReport(DateTime weekStart) async {
    final from = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final to = from.add(const Duration(days: 6));
    return generateReport(from, to);
  }

  Future<ReportModel> generateMonthlyReport(int year, int month) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    return generateReport(from, to);
  }

  Future<ReportModel> generateYearlyReport(int year) async {
    final from = DateTime(year, 1, 1);
    final to = DateTime(year, 12, 31, 23, 59, 59);
    return generateReport(from, to);
  }
}

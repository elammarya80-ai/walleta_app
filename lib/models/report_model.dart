class ReportModel {
  final double totalBalance;
  final double totalTransfers;
  final double totalWithdraws;
  final double totalDeposits;
  final double totalProfit;
  final double totalCommission;
  final int transactionCount;
  final int transferCount;
  final int withdrawCount;
  final int depositCount;
  final Map<String, double> walletBalances;
  final Map<String, double> instapayBalances;
  final List<DailyStats> dailyStats;
  final DateTime from;
  final DateTime to;

  ReportModel({
    required this.totalBalance,
    required this.totalTransfers,
    required this.totalWithdraws,
    required this.totalDeposits,
    required this.totalProfit,
    required this.totalCommission,
    required this.transactionCount,
    required this.transferCount,
    required this.withdrawCount,
    required this.depositCount,
    required this.walletBalances,
    required this.instapayBalances,
    required this.dailyStats,
    required this.from,
    required this.to,
  });

  factory ReportModel.empty() {
    final now = DateTime.now();
    return ReportModel(
      totalBalance: 0,
      totalTransfers: 0,
      totalWithdraws: 0,
      totalDeposits: 0,
      totalProfit: 0,
      totalCommission: 0,
      transactionCount: 0,
      transferCount: 0,
      withdrawCount: 0,
      depositCount: 0,
      walletBalances: {},
      instapayBalances: {},
      dailyStats: [],
      from: now,
      to: now,
    );
  }
}

class DailyStats {
  final DateTime date;
  final double profit;
  final double transfers;
  final double withdraws;
  final double deposits;
  final int count;

  DailyStats({
    required this.date,
    required this.profit,
    required this.transfers,
    required this.withdraws,
    required this.deposits,
    required this.count,
  });
}

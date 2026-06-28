import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        title: Text(
          'التقارير',
          style: AppTextStyles.headlineMedium.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildPeriodSelector(provider),
              _buildDateNavigator(provider, isDark),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.report == null
                        ? const Center(child: Text('لا توجد بيانات'))
                        : RefreshIndicator(
                            onRefresh: () => provider.loadReport(),
                            color: AppColors.primary,
                            child:
                                _buildReportContent(provider.report!, isDark),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(ReportProvider provider) {
    final periods = [
      AppConstants.periodDaily,
      AppConstants.periodWeekly,
      AppConstants.periodMonthly,
      AppConstants.periodYearly,
    ];
    final labels = ['يومي', 'أسبوعي', 'شهري', 'سنوي'];

    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final isSelected = provider.period == periods[index];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => provider.setPeriod(periods[index]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient:
                      isSelected ? AppColors.primaryGradient : null,
                  color: isSelected
                      ? null
                      : Theme.of(context).brightness == Brightness.dark
                          ? AppColors.cardDark
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.w700 : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateNavigator(ReportProvider provider, bool isDark) {
    String label = '';
    switch (provider.period) {
      case AppConstants.periodDaily:
        label = Formatters.date(provider.selectedDate);
        break;
      case AppConstants.periodWeekly:
        label = 'أسبوع ${Formatters.date(provider.selectedDate)}';
        break;
      case AppConstants.periodMonthly:
        label = Formatters.monthYear(provider.selectedDate);
        break;
      case AppConstants.periodYearly:
        label = '${provider.selectedDate.year}';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: provider.nextPeriod,
            icon: const Icon(Icons.chevron_right_rounded),
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: provider.previousPeriod,
            icon: const Icon(Icons.chevron_left_rounded),
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ReportModel report, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        _buildTotalBalanceCard(report, isDark),
        const SizedBox(height: 16),
        _buildStatsGrid(report),
        const SizedBox(height: 16),
        if (report.dailyStats.isNotEmpty) _buildChart(report, isDark),
        const SizedBox(height: 16),
        _buildWalletBreakdown(report, isDark),
      ],
    );
  }

  Widget _buildTotalBalanceCard(ReportModel report, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.balanceCardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('الرصيد الإجمالي الحالي',
              style: AppTextStyles.bodyMediumLight),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(report.totalBalance),
            style: AppTextStyles.balanceLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat(
                  'العمليات', '${report.transactionCount}', Colors.white70),
              _miniStat('إجمالي الأرباح',
                  Formatters.compactCurrency(report.totalProfit), AppColors.success),
              _miniStat('العمولات',
                  Formatters.compactCurrency(report.totalCommission), Colors.orange),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.labelLarge.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white54)),
      ],
    );
  }

  Widget _buildStatsGrid(ReportModel report) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'إجمالي التحويلات',
          value: report.totalTransfers,
          icon: Icons.swap_horiz_rounded,
          color: AppColors.transferColor,
          subtitle: '${report.transferCount} عملية',
        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
        StatCard(
          title: 'إجمالي السحب',
          value: report.totalWithdraws,
          icon: Icons.arrow_upward_rounded,
          color: AppColors.withdrawColor,
          subtitle: '${report.withdrawCount} عملية',
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
        StatCard(
          title: 'إجمالي الإيداع',
          value: report.totalDeposits,
          icon: Icons.arrow_downward_rounded,
          color: AppColors.depositColor,
          subtitle: '${report.depositCount} عملية',
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
        StatCard(
          title: 'صافي الربح',
          value: report.totalProfit,
          icon: Icons.trending_up_rounded,
          color: AppColors.success,
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildChart(ReportModel report, bool isDark) {
    final stats = report.dailyStats;
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الأرباح اليومية', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: stats.isEmpty ? 100 : (stats
                        .map((s) => s.profit)
                        .reduce((a, b) => a > b ? a : b) *
                    1.3),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= stats.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '${stats[idx].date.day}',
                          style: AppTextStyles.caption,
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: stats.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.profit,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 500.ms);
  }

  Widget _buildWalletBreakdown(ReportModel report, bool isDark) {
    if (report.walletBalances.isEmpty && report.instapayBalances.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تفاصيل الأرصدة', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          if (report.walletBalances.isNotEmpty) ...[
            Text('المحافظ',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            ...report.walletBalances.entries.map(
              (e) => _BalanceRow(
                name: e.key,
                balance: e.value,
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
          ],
          if (report.instapayBalances.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('انستاباي',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.info)),
            const SizedBox(height: 8),
            ...report.instapayBalances.entries.map(
              (e) => _BalanceRow(
                name: e.key,
                balance: e.value,
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 500.ms);
  }
}

class _BalanceRow extends StatelessWidget {
  final String name;
  final double balance;
  final Color color;
  final bool isDark;

  const _BalanceRow({
    required this.name,
    required this.balance,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textPrimary,
                  )),
            ],
          ),
          Text(
            Formatters.currency(balance),
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

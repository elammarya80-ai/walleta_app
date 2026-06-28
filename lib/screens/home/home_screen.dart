import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/instapay_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/app_constants.dart';
import '../wallets/wallets_screen.dart';
import '../instapay/instapay_screen.dart';
import '../transactions/transactions_screen.dart';
import '../transactions/transaction_form_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    WalletsScreen(),
    InstapayScreen(),
    TransactionsScreen(),
    ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'المحافظ',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.payment_rounded,
                label: 'انستاباي',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'العمليات',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'التقارير',
                isSelected: _currentIndex == 4,
                onTap: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<WalletProvider>().loadWallets(),
      context.read<InstapayProvider>().loadAccounts(),
      context.read<TransactionProvider>().loadRecentTransactions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(isDark),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ).then((_) => _refresh()),
        icon: const Icon(Icons.add_rounded),
        label:
            const Text('عملية جديدة', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'مرحباً 👋',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    'محفظة أبو عمير',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ).then((_) => setState(() {})),
                    icon: Icon(
                      Icons.settings_rounded,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer3<WalletProvider, InstapayProvider, TransactionProvider>(
      builder: (context, walletP, instapayP, txP, _) {
        final totalWallet = walletP.totalBalance;
        final totalInstapay = instapayP.totalBalance;

        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              BalanceCard(
                totalBalance: totalWallet + totalInstapay,
                walletBalance: totalWallet,
                instapayBalance: totalInstapay,
                walletsCount: walletP.count,
                instapayCount: instapayP.count,
              ),
              const SizedBox(height: 24),
              _buildQuickStats(walletP, instapayP, txP),
              const SizedBox(height: 24),
              _buildRecentTransactions(txP),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(
    WalletProvider walletP,
    InstapayProvider instapayP,
    TransactionProvider txP,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'إحصائيات سريعة',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                title: 'إجمالي المحافظ',
                value: walletP.totalBalance,
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
              StatCard(
                title: 'حسابات انستاباي',
                value: instapayP.totalBalance,
                icon: Icons.payment_rounded,
                color: AppColors.info,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
              StatCard(
                title: 'عدد المحافظ',
                value: walletP.count.toDouble(),
                icon: Icons.wallet_rounded,
                color: AppColors.success,
                showCurrency: false,
                subtitle: 'محفظة نشطة',
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
              StatCard(
                title: 'عدد العمليات',
                value: txP.recentTransactions.length.toDouble(),
                icon: Icons.receipt_long_rounded,
                color: AppColors.warning,
                showCurrency: false,
                subtitle: 'آخر العمليات',
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(TransactionProvider txP) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر العمليات',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل',
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (txP.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (txP.recentTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'لا توجد عمليات',
              subtitle: 'ابدأ بإضافة عملية جديدة',
              actionLabel: 'إضافة عملية',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TransactionFormScreen()),
              ).then((_) => _refresh()),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: txP.recentTransactions
                  .take(5)
                  .map((tx) => TransactionTile(transaction: tx))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

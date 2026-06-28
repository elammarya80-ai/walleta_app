import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/empty_state.dart';
import '../../core/extensions/extensions.dart';
import 'wallet_form_screen.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWallets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن محفظة...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                ),
                onChanged: (v) =>
                    context.read<WalletProvider>().search(v),
              )
            : Text(
                'المحافظ',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<WalletProvider>().search('');
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadWallets(),
            color: AppColors.primary,
            child: provider.wallets.isEmpty
                ? EmptyState(
                    icon: Icons.account_balance_wallet_rounded,
                    title: _isSearching
                        ? 'لا توجد نتائج'
                        : 'لا توجد محافظ',
                    subtitle: _isSearching
                        ? 'جرب كلمة بحث مختلفة'
                        : 'أضف محفظتك الأولى الآن',
                    actionLabel: _isSearching ? null : 'إضافة محفظة',
                    onAction: _isSearching ? null : _openAddWallet,
                  )
                : Column(
                    children: [
                      _buildSummary(provider, isDark),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: provider.wallets.length,
                          itemBuilder: (context, index) {
                            final wallet = provider.wallets[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: SizedBox(
                                height: 160,
                                child: WalletCard(
                                  wallet: wallet,
                                  index: index,
                                  onEdit: () => _openEditWallet(wallet),
                                  onDelete: () => _confirmDelete(wallet.id!),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'wallets_fab',
        onPressed: _openAddWallet,
        icon: const Icon(Icons.add_rounded),
        label:
            const Text('إضافة محفظة', style: TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }

  Widget _buildSummary(WalletProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجمالي رصيد المحافظ',
                style: AppTextStyles.bodySmallLight,
              ),
              const SizedBox(height: 4),
              Text(
                provider.totalBalance.formatCurrency,
                style: AppTextStyles.headlineMedium
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${provider.count} محفظة',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  void _openAddWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletFormScreen()),
    ).then((_) => context.read<WalletProvider>().loadWallets());
  }

  void _openEditWallet(wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WalletFormScreen(wallet: wallet)),
    ).then((_) => context.read<WalletProvider>().loadWallets());
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await context.showConfirmDialog(
      title: 'حذف المحفظة',
      content: 'هل أنت متأكد من حذف هذه المحفظة؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDestructive: true,
    );
    if (confirm == true && mounted) {
      final success = await context.read<WalletProvider>().deleteWallet(id);
      if (mounted) {
        context.showSnackBar(
          success ? 'تم حذف المحفظة بنجاح' : 'فشل الحذف',
          isError: !success,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/instapay_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/instapay_card.dart';
import '../../widgets/empty_state.dart';
import '../../core/extensions/extensions.dart';
import 'instapay_form_screen.dart';

class InstapayScreen extends StatefulWidget {
  const InstapayScreen({super.key});

  @override
  State<InstapayScreen> createState() => _InstapayScreenState();
}

class _InstapayScreenState extends State<InstapayScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstapayProvider>().loadAccounts();
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
                  hintText: 'ابحث عن حساب...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                ),
                onChanged: (v) =>
                    context.read<InstapayProvider>().search(v),
              )
            : Text(
                'حسابات انستاباي',
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
                  context.read<InstapayProvider>().search('');
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: Consumer<InstapayProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadAccounts(),
            color: AppColors.primary,
            child: provider.accounts.isEmpty
                ? EmptyState(
                    icon: Icons.payment_rounded,
                    title: _isSearching
                        ? 'لا توجد نتائج'
                        : 'لا توجد حسابات انستاباي',
                    subtitle: _isSearching
                        ? 'جرب كلمة بحث مختلفة'
                        : 'أضف حسابك الأول الآن',
                    actionLabel: _isSearching ? null : 'إضافة حساب',
                    onAction: _isSearching ? null : _openAddAccount,
                  )
                : Column(
                    children: [
                      _buildSummary(provider),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: provider.accounts.length,
                          itemBuilder: (context, index) {
                            final account = provider.accounts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: SizedBox(
                                height: 150,
                                child: InstapayCard(
                                  account: account,
                                  index: index,
                                  onEdit: () => _openEditAccount(account),
                                  onDelete: () =>
                                      _confirmDelete(account.id!),
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
        heroTag: 'instapay_fab',
        onPressed: _openAddAccount,
        icon: const Icon(Icons.add_rounded),
        label:
            const Text('إضافة حساب', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildSummary(InstapayProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.instapayGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
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
              Text('إجمالي رصيد انستاباي',
                  style: AppTextStyles.bodySmallLight),
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
              '${provider.count} حساب',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  void _openAddAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InstapayFormScreen()),
    ).then((_) => context.read<InstapayProvider>().loadAccounts());
  }

  void _openEditAccount(account) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => InstapayFormScreen(account: account)),
    ).then((_) => context.read<InstapayProvider>().loadAccounts());
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await context.showConfirmDialog(
      title: 'حذف الحساب',
      content: 'هل أنت متأكد من حذف هذا الحساب؟',
      confirmText: 'حذف',
      isDestructive: true,
    );
    if (confirm == true && mounted) {
      final success =
          await context.read<InstapayProvider>().deleteAccount(id);
      if (mounted) {
        context.showSnackBar(
          success ? 'تم حذف الحساب بنجاح' : 'فشل الحذف',
          isError: !success,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/instapay_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../../core/extensions/extensions.dart';
import 'transaction_form_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedType;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
                  hintText: 'ابحث في العمليات...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                ),
                onChanged: (v) =>
                    context.read<TransactionProvider>().search(v),
              )
            : Text(
                'سجل العمليات',
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
                  context.read<TransactionProvider>().search('');
                }
              });
            },
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(
              Icons.filter_list_rounded,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeFilter(),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.transactions.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'لا توجد عمليات',
                    subtitle: provider.hasActiveFilters
                        ? 'لا توجد نتائج مطابقة للفلتر'
                        : 'ابدأ بإضافة عملية جديدة',
                    actionLabel: provider.hasActiveFilters
                        ? 'إلغاء الفلتر'
                        : 'إضافة عملية',
                    onAction: provider.hasActiveFilters
                        ? () => provider.clearFilters()
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const TransactionFormScreen()),
                            ).then((_) => _refresh()),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => provider.loadTransactions(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: provider.transactions.length +
                        (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.transactions.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final tx = provider.transactions[index];
                      return TransactionTile(
                        transaction: tx,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailScreen(transaction: tx),
                          ),
                        ).then((_) => _refresh()),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionFormScreen(transaction: tx),
                          ),
                        ).then((_) => _refresh()),
                        onDelete: () => _confirmDelete(tx),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tx_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ).then((_) => _refresh()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('عملية جديدة',
            style: TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }

  Widget _buildTypeFilter() {
    final types = [
      null,
      AppConstants.txTransfer,
      AppConstants.txWithdraw,
      AppConstants.txDeposit,
    ];
    final labels = ['الكل', 'تحويل', 'سحب', 'إيداع'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedType == types[index];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedType = types[index]);
                context.read<TransactionProvider>().setFilter(
                      type: types[index],
                    );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.primaryGradient
                      : null,
                  color: isSelected
                      ? null
                      : isDark
                          ? AppColors.cardDark
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        onApply: (from, to, status) {
          context.read<TransactionProvider>().setFilter(
                type: _selectedType,
                from: from,
                to: to,
                status: status,
              );
        },
        onClear: () => context.read<TransactionProvider>().clearFilters(),
      ),
    );
  }

  Future<void> _confirmDelete(tx) async {
    final confirm = await context.showConfirmDialog(
      title: 'حذف العملية',
      content: 'هل أنت متأكد من حذف هذه العملية؟ سيتم عكس تأثيرها على الرصيد.',
      confirmText: 'حذف',
      isDestructive: true,
    );
    if (confirm == true && mounted) {
      final success =
          await context.read<TransactionProvider>().deleteTransaction(tx);
      if (mounted) {
        context.read<WalletProvider>().loadWallets();
        context.read<InstapayProvider>().loadAccounts();
        context.showSnackBar(
          success ? 'تم حذف العملية بنجاح' : 'فشل الحذف',
          isError: !success,
        );
      }
    }
  }

  void _refresh() {
    context.read<TransactionProvider>().loadTransactions();
    context.read<WalletProvider>().loadWallets();
    context.read<InstapayProvider>().loadAccounts();
  }
}

class _FilterSheet extends StatefulWidget {
  final void Function(DateTime? from, DateTime? to, String? status) onApply;
  final VoidCallback onClear;

  const _FilterSheet({required this.onApply, required this.onClear});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  DateTime? _from;
  DateTime? _to;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('فلترة العمليات', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 20),
          Text('الحالة', style: AppTextStyles.labelLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _statusChip(null, 'الكل'),
              _statusChip(AppConstants.statusCompleted, 'مكتملة'),
              _statusChip(AppConstants.statusPending, 'معلقة'),
              _statusChip(AppConstants.statusFailed, 'فاشلة'),
            ],
          ),
          const SizedBox(height: 16),
          Text('الفترة الزمنية', style: AppTextStyles.labelLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _from ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _from = d);
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(
                    _from != null ? Formatters2.date(_from!) : 'من تاريخ',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _to ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _to = d);
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(
                    _to != null ? Formatters2.date(_to!) : 'إلى تاريخ',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: const Text('مسح الفلتر',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_from, _to, _status);
                    Navigator.pop(context);
                  },
                  child: const Text('تطبيق',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String? value, String label) {
    final isSelected = _status == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
      selected: isSelected,
      onSelected: (_) => setState(() => _status = value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary),
    );
  }
}

class Formatters2 {
  static String date(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

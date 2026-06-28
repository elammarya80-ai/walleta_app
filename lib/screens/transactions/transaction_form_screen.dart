import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../models/wallet_model.dart';
import '../../models/instapay_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/instapay_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../core/extensions/extensions.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _commissionCtrl;
  late TextEditingController _profitCtrl;
  late TextEditingController _clientNameCtrl;
  late TextEditingController _clientNumberCtrl;
  late TextEditingController _notesCtrl;

  String _selectedType = AppConstants.txTransfer;
  String _sourceType = AppConstants.sourceWallet;
  int? _sourceId;
  String? _destType;
  int? _destId;
  String _selectedStatus = AppConstants.statusCompleted;
  bool _isLoading = false;

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountCtrl = TextEditingController(
        text: tx != null ? tx.amount.toStringAsFixed(2) : '');
    _commissionCtrl = TextEditingController(
        text: tx != null ? tx.commission.toStringAsFixed(2) : '');
    _profitCtrl = TextEditingController(
        text: tx != null ? tx.profit.toStringAsFixed(2) : '');
    _clientNameCtrl =
        TextEditingController(text: tx?.clientName ?? '');
    _clientNumberCtrl =
        TextEditingController(text: tx?.clientNumber ?? '');
    _notesCtrl = TextEditingController(text: tx?.notes ?? '');

    if (tx != null) {
      _selectedType = tx.type;
      _sourceType = tx.sourceType;
      _sourceId = tx.sourceId;
      _destType = tx.destType;
      _destId = tx.destId;
      _selectedStatus = tx.status;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _commissionCtrl.dispose();
    _profitCtrl.dispose();
    _clientNameCtrl.dispose();
    _clientNumberCtrl.dispose();
    _notesCtrl.dispose();
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
        title: Text(
          _isEdit ? 'تعديل العملية' : 'عملية جديدة',
          style: AppTextStyles.headlineMedium.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildSourceSelector(),
            if (_selectedType == AppConstants.txTransfer) ...[
              const SizedBox(height: 16),
              _buildDestSelector(),
            ],
            const SizedBox(height: 20),
            AmountTextField(
              controller: _amountCtrl,
              label: 'المبلغ',
              validator: Validators.amount,
              onChanged: _autoCalcProfit,
            ),
            const SizedBox(height: 16),
            AmountTextField(
              controller: _commissionCtrl,
              label: 'العمولة',
              onChanged: _autoCalcProfit,
            ),
            const SizedBox(height: 16),
            AmountTextField(
              controller: _profitCtrl,
              label: 'الربح',
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('بيانات العميل'),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _clientNameCtrl,
              label: 'اسم العميل (اختياري)',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _clientNumberCtrl,
              label: 'رقم العميل (اختياري)',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v != null && v.isNotEmpty ? Validators.phone(v) : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('تفاصيل إضافية'),
            const SizedBox(height: 12),
            _buildStatusSelector(),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesCtrl,
              label: 'ملاحظات (اختياري)',
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: _isEdit ? 'حفظ التعديلات' : 'حفظ العملية',
              icon: Icons.save_rounded,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'إلغاء',
                onPressed: () => Navigator.pop(context),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: AppTextStyles.labelMedium,
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      AppConstants.txTransfer,
      AppConstants.txWithdraw,
      AppConstants.txDeposit,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نوع العملية', style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        Row(
          children: types.map((type) {
            final isSelected = _selectedType == type;
            final color = Helpers.getTransactionColor(type);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedType = type;
                    if (type != AppConstants.txTransfer) {
                      _destType = null;
                      _destId = null;
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Helpers.getTransactionIcon(type),
                          color: isSelected ? color : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.getTransactionTypeAr(type),
                          style: AppTextStyles.labelSmall.copyWith(
                            color:
                                isSelected ? color : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSourceSelector() {
    return Consumer2<WalletProvider, InstapayProvider>(
      builder: (context, walletP, instapayP, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedType == AppConstants.txDeposit
                  ? 'الحساب المستهدف'
                  : 'المصدر',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 10),
            _buildAccountDropdown(
              sourceType: _sourceType,
              sourceId: _sourceId,
              wallets: walletP.allWallets,
              instapayAccounts: instapayP.allAccounts,
              onTypeChanged: (type) => setState(() {
                _sourceType = type!;
                _sourceId = null;
              }),
              onIdChanged: (id) => setState(() => _sourceId = id),
              label: 'نوع المصدر',
            ),
          ],
        );
      },
    );
  }

  Widget _buildDestSelector() {
    return Consumer2<WalletProvider, InstapayProvider>(
      builder: (context, walletP, instapayP, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الوجهة', style: AppTextStyles.labelLarge),
            const SizedBox(height: 10),
            _buildAccountDropdown(
              sourceType: _destType ?? AppConstants.sourceWallet,
              sourceId: _destId,
              wallets: walletP.allWallets,
              instapayAccounts: instapayP.allAccounts,
              onTypeChanged: (type) => setState(() {
                _destType = type;
                _destId = null;
              }),
              onIdChanged: (id) => setState(() => _destId = id),
              label: 'نوع الوجهة',
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountDropdown({
    required String sourceType,
    required int? sourceId,
    required List<WalletModel> wallets,
    required List<InstapayModel> instapayAccounts,
    required void Function(String?) onTypeChanged,
    required void Function(int?) onIdChanged,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _TypeChip(
                label: 'محفظة',
                icon: Icons.account_balance_wallet_rounded,
                isSelected: sourceType == AppConstants.sourceWallet,
                onTap: () => onTypeChanged(AppConstants.sourceWallet),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TypeChip(
                label: 'انستاباي',
                icon: Icons.payment_rounded,
                isSelected: sourceType == AppConstants.sourceInstapay,
                onTap: () => onTypeChanged(AppConstants.sourceInstapay),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TypeChip(
                label: 'نقدي',
                icon: Icons.money_rounded,
                isSelected: sourceType == AppConstants.sourceCash,
                onTap: () => onTypeChanged(AppConstants.sourceCash),
              ),
            ),
          ],
        ),
        if (sourceType != AppConstants.sourceCash) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color:
                      isDark ? AppColors.borderDark : AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: sourceId,
                isExpanded: true,
                hint: Text(
                  sourceType == AppConstants.sourceWallet
                      ? 'اختر المحفظة'
                      : 'اختر الحساب',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                ),
                items: sourceType == AppConstants.sourceWallet
                    ? wallets
                        .map((w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                '${w.name} - ${w.balance.toStringAsFixed(2)} ج.م',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ))
                        .toList()
                    : instapayAccounts
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                '${a.name} - ${a.balance.toStringAsFixed(2)} ج.م',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ))
                        .toList(),
                onChanged: onIdChanged,
                dropdownColor:
                    isDark ? AppColors.surfaceDark : AppColors.surface,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSelector() {
    final statuses = [
      AppConstants.statusCompleted,
      AppConstants.statusPending,
      AppConstants.statusFailed,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('حالة العملية', style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: statuses.map((status) {
            final isSelected = _selectedStatus == status;
            final color = Helpers.getStatusColor(status);
            return GestureDetector(
              onTap: () => setState(() => _selectedStatus = status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.12) : null,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  AppConstants.getStatusAr(status),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _autoCalcProfit(String _) {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final commission = double.tryParse(_commissionCtrl.text) ?? 0;
    if (commission > 0 && amount > 0) {
      final profit = commission;
      _profitCtrl.text = profit.toStringAsFixed(2);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sourceType != AppConstants.sourceCash && _sourceId == null) {
      context.showSnackBar('الرجاء اختيار المصدر', isError: true);
      return;
    }
    if (_selectedType == AppConstants.txTransfer) {
      if (_destType == null) {
        context.showSnackBar('الرجاء اختيار نوع الوجهة', isError: true);
        return;
      }
      if (_destType != AppConstants.sourceCash && _destId == null) {
        context.showSnackBar('الرجاء اختيار الوجهة', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final newTx = TransactionModel(
      id: widget.transaction?.id,
      type: _selectedType,
      sourceType: _sourceType,
      sourceId: _sourceType != AppConstants.sourceCash ? _sourceId : null,
      destType: _selectedType == AppConstants.txTransfer ? _destType : null,
      destId: _selectedType == AppConstants.txTransfer &&
              _destType != AppConstants.sourceCash
          ? _destId
          : null,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      commission: double.tryParse(_commissionCtrl.text) ?? 0,
      profit: double.tryParse(_profitCtrl.text) ?? 0,
      clientName: _clientNameCtrl.text.trim().isEmpty
          ? null
          : _clientNameCtrl.text.trim(),
      clientNumber: _clientNumberCtrl.text.trim().isEmpty
          ? null
          : _clientNumberCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      status: _selectedStatus,
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<TransactionProvider>();
    bool success;

    if (_isEdit) {
      success = await provider.updateTransaction(widget.transaction!, newTx);
    } else {
      success = await provider.addTransaction(newTx);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        context.read<WalletProvider>().loadWallets();
        context.read<InstapayProvider>().loadAccounts();
      }
      context.showSnackBar(
        success
            ? (_isEdit ? 'تم تعديل العملية بنجاح' : 'تم حفظ العملية بنجاح')
            : 'حدث خطأ، حاول مجدداً',
        isError: !success,
      );
      if (success) Navigator.pop(context);
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

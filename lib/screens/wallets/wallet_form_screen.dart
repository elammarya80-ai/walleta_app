import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../core/extensions/extensions.dart';

class WalletFormScreen extends StatefulWidget {
  final WalletModel? wallet;
  const WalletFormScreen({super.key, this.wallet});

  @override
  State<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends State<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _numberCtrl;
  late TextEditingController _balanceCtrl;
  late TextEditingController _notesCtrl;
  late int _selectedColor;
  bool _isLoading = false;

  bool get _isEdit => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.wallet?.name ?? '');
    _numberCtrl =
        TextEditingController(text: widget.wallet?.number ?? '');
    _balanceCtrl = TextEditingController(
        text: widget.wallet != null
            ? widget.wallet!.balance.toStringAsFixed(2)
            : '');
    _notesCtrl =
        TextEditingController(text: widget.wallet?.notes ?? '');
    _selectedColor =
        widget.wallet?.color ?? AppConstants.walletColors.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _balanceCtrl.dispose();
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
          _isEdit ? 'تعديل المحفظة' : 'إضافة محفظة',
          style: AppTextStyles.headlineMedium.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildColorPreview(),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameCtrl,
              label: 'اسم المحفظة',
              hint: 'مثال: فودافون كاش',
              prefixIcon: Icons.label_rounded,
              validator: Validators.walletName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _numberCtrl,
              label: 'رقم المحفظة',
              hint: 'أدخل رقم المحفظة',
              prefixIcon: Icons.numbers_rounded,
              keyboardType: TextInputType.phone,
              validator: Validators.walletNumber,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AmountTextField(
              controller: _balanceCtrl,
              label: 'الرصيد الابتدائي',
              validator: Validators.nonNegativeAmount,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesCtrl,
              label: 'ملاحظات (اختياري)',
              hint: 'أضف أي ملاحظات...',
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildColorPicker(),
            const SizedBox(height: 32),
            PrimaryButton(
              label: _isEdit ? 'حفظ التعديلات' : 'إضافة المحفظة',
              icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
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
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    final color = Color(_selectedColor);
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Helpers.getWalletGradient(_selectedColor),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              _nameCtrl.text.isEmpty ? 'اسم المحفظة' : _nameCtrl.text,
              style: AppTextStyles.headlineSmall
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'لون المحفظة',
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.walletColors.map((colorValue) {
            final isSelected = _selectedColor == colorValue;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = colorValue),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(colorValue),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(colorValue).withOpacity(0.4),
                      blurRadius: isSelected ? 12 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 22)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final wallet = WalletModel(
      id: widget.wallet?.id,
      name: _nameCtrl.text.trim(),
      number: _numberCtrl.text.trim(),
      balance: double.tryParse(_balanceCtrl.text) ?? 0.0,
      color: _selectedColor,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.wallet?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<WalletProvider>();
    bool success;

    if (_isEdit) {
      success = await provider.updateWallet(wallet);
    } else {
      success = await provider.addWallet(wallet);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      context.showSnackBar(
        success
            ? (_isEdit ? 'تم تعديل المحفظة بنجاح' : 'تمت إضافة المحفظة بنجاح')
            : 'حدث خطأ، حاول مجدداً',
        isError: !success,
      );
      if (success) Navigator.pop(context);
    }
  }
}

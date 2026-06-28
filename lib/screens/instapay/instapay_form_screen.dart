import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/instapay_model.dart';
import '../../providers/instapay_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../core/extensions/extensions.dart';

class InstapayFormScreen extends StatefulWidget {
  final InstapayModel? account;
  const InstapayFormScreen({super.key, this.account});

  @override
  State<InstapayFormScreen> createState() => _InstapayFormScreenState();
}

class _InstapayFormScreenState extends State<InstapayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _numberCtrl;
  late TextEditingController _balanceCtrl;
  late TextEditingController _notesCtrl;
  bool _isLoading = false;

  bool get _isEdit => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.account?.name ?? '');
    _numberCtrl =
        TextEditingController(text: widget.account?.accountNumber ?? '');
    _balanceCtrl = TextEditingController(
        text: widget.account != null
            ? widget.account!.balance.toStringAsFixed(2)
            : '');
    _notesCtrl =
        TextEditingController(text: widget.account?.notes ?? '');
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
          _isEdit ? 'تعديل الحساب' : 'إضافة حساب انستاباي',
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
            _buildPreviewCard(),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameCtrl,
              label: 'اسم الحساب',
              hint: 'مثال: حساب العمل',
              prefixIcon: Icons.person_rounded,
              validator: (v) => Validators.required(v, 'اسم الحساب'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _numberCtrl,
              label: 'رقم الحساب',
              hint: 'أدخل رقم الحساب أو رقم الهاتف',
              prefixIcon: Icons.numbers_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) => Validators.required(v, 'رقم الحساب'),
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
            const SizedBox(height: 32),
            PrimaryButton(
              label: _isEdit ? 'حفظ التعديلات' : 'إضافة الحساب',
              icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
              isLoading: _isLoading,
              onPressed: _submit,
              backgroundColor: const Color(0xFF1565C0),
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

  Widget _buildPreviewCard() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: AppColors.instapayGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment_rounded, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              _nameCtrl.text.isEmpty ? 'اسم الحساب' : _nameCtrl.text,
              style: AppTextStyles.headlineSmall
                  .copyWith(color: Colors.white),
            ),
            const Text(
              'InstaPay',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white60,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final account = InstapayModel(
      id: widget.account?.id,
      name: _nameCtrl.text.trim(),
      accountNumber: _numberCtrl.text.trim(),
      balance: double.tryParse(_balanceCtrl.text) ?? 0.0,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.account?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<InstapayProvider>();
    final success = _isEdit
        ? await provider.updateAccount(account)
        : await provider.addAccount(account);

    setState(() => _isLoading = false);

    if (mounted) {
      context.showSnackBar(
        success
            ? (_isEdit ? 'تم التعديل بنجاح' : 'تمت الإضافة بنجاح')
            : 'حدث خطأ، حاول مجدداً',
        isError: !success,
      );
      if (success) Navigator.pop(context);
    }
  }
}

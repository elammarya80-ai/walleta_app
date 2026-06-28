class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'هذا الحقل']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'المبلغ مطلوب';
    final num = double.tryParse(value.replaceAll(',', ''));
    if (num == null) return 'أدخل مبلغاً صحيحاً';
    if (num <= 0) return 'يجب أن يكون المبلغ أكبر من صفر';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? nonNegativeAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final num = double.tryParse(value.replaceAll(',', ''));
    if (num == null) return 'أدخل رقماً صحيحاً';
    if (num < 0) return 'لا يمكن أن يكون القيمة سالبة';
    return null;
  }

  static String? walletName(String? value) {
    if (value == null || value.trim().isEmpty) return 'اسم المحفظة مطلوب';
    if (value.trim().length < 2) return 'الاسم قصير جداً';
    return null;
  }

  static String? walletNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم المحفظة مطلوب';
    return null;
  }
}

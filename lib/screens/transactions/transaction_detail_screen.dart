import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../core/constants/app_constants.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Helpers.getTransactionColor(transaction.type);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        title: Text(
          'تفاصيل العملية',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(color, isDark),
            const SizedBox(height: 24),
            _buildInfoCard(isDark),
            const SizedBox(height: 16),
            if (transaction.clientName != null ||
                transaction.clientNumber != null)
              _buildClientCard(isDark),
            const SizedBox(height: 16),
            if (transaction.notes != null) _buildNotesCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.3) ?? color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Helpers.getTransactionIcon(transaction.type),
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            transaction.typeAr,
            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(transaction.amount),
            style: AppTextStyles.balanceLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Helpers.getStatusIcon(transaction.status),
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  transaction.statusAr,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.dateTime(transaction.createdAt),
            style: AppTextStyles.bodySmallLight,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return _Card(
      isDark: isDark,
      title: 'تفاصيل العملية',
      children: [
        _DetailRow(
            label: 'نوع العملية', value: transaction.typeAr, isDark: isDark),
        _DetailRow(
            label: 'المبلغ',
            value: Formatters.currency(transaction.amount),
            isDark: isDark),
        _DetailRow(
            label: 'العمولة',
            value: Formatters.currency(transaction.commission),
            isDark: isDark),
        _DetailRow(
            label: 'الربح',
            value: Formatters.currency(transaction.profit),
            isDark: isDark,
            valueColor: AppColors.success),
        _DetailRow(
            label: 'المصدر',
            value: transaction.sourceTypeAr,
            isDark: isDark),
        if (transaction.destType != null)
          _DetailRow(
              label: 'الوجهة',
              value: transaction.destTypeAr,
              isDark: isDark),
        _DetailRow(
            label: 'الحالة',
            value: transaction.statusAr,
            isDark: isDark,
            valueColor: Helpers.getStatusColor(transaction.status)),
        _DetailRow(
            label: 'رقم العملية',
            value: '#${transaction.id}',
            isDark: isDark),
      ],
    );
  }

  Widget _buildClientCard(bool isDark) {
    return _Card(
      isDark: isDark,
      title: 'بيانات العميل',
      children: [
        if (transaction.clientName != null)
          _DetailRow(
              label: 'اسم العميل',
              value: transaction.clientName!,
              isDark: isDark),
        if (transaction.clientNumber != null)
          _DetailRow(
              label: 'رقم العميل',
              value: transaction.clientNumber!,
              isDark: isDark),
      ],
    );
  }

  Widget _buildNotesCard(bool isDark) {
    return _Card(
      isDark: isDark,
      title: 'ملاحظات',
      children: [
        Text(
          transaction.notes!,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final bool isDark;
  final String title;
  final List<Widget> children;

  const _Card(
      {required this.isDark, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: valueColor ??
                  (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

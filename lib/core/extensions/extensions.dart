import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  bool get isValidPhone {
    final regex = RegExp(r'^[0-9]{10,15}$');
    return regex.hasMatch(this);
  }

  bool get isNotEmptyOrNull => trim().isNotEmpty;

  String get trimmed => trim();
}

extension DoubleExtensions on double {
  String get formatCurrency {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(this)} ج.م';
  }

  String get formatAmount {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return formatter.format(this);
  }

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
}

extension DateTimeExtensions on DateTime {
  String get formatDate {
    return DateFormat('dd/MM/yyyy', 'ar').format(this);
  }

  String get formatDateTime {
    return DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(this);
  }

  String get formatTime {
    return DateFormat('hh:mm a', 'ar').format(this);
  }

  String get formatDateShort {
    return DateFormat('d MMM', 'ar').format(this);
  }

  String get formatMonthYear {
    return DateFormat('MMMM yyyy', 'ar').format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameWeek(DateTime other) {
    final diff = difference(other).inDays.abs();
    return diff < 7 && weekday >= other.weekday;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  DateTime get startOfDay => DateTime(year, month, day, 0, 0, 0);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  DateTime get startOfMonth => DateTime(year, month, 1, 0, 0, 0);
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  DateTime get startOfYear => DateTime(year, 1, 1, 0, 0, 0);
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59);

  DateTime get startOfWeek {
    final diff = weekday - DateTime.saturday;
    return subtract(Duration(days: diff < 0 ? diff + 7 : diff)).startOfDay;
  }

  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6)).endOfDay;
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(fontFamily: 'Cairo')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText, style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : null,
              foregroundColor: isDestructive ? Colors.white : null,
            ),
            child: Text(confirmText, style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

extension IntExtensions on int {
  Color get toColor => Color(this);
}

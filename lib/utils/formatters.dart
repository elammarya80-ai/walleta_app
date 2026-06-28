import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String currency(double amount) {
    final f = NumberFormat('#,##0.00', 'ar');
    return '${f.format(amount)} ج.م';
  }

  static String amount(double amount) {
    final f = NumberFormat('#,##0.00', 'ar');
    return f.format(amount);
  }

  static String compactCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} م ج.م';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} ألف ج.م';
    }
    return currency(amount);
  }

  static String date(DateTime dt) =>
      DateFormat('dd/MM/yyyy', 'ar').format(dt);

  static String dateTime(DateTime dt) =>
      DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(dt);

  static String time(DateTime dt) =>
      DateFormat('hh:mm a', 'ar').format(dt);

  static String monthYear(DateTime dt) =>
      DateFormat('MMMM yyyy', 'ar').format(dt);

  static String shortDate(DateTime dt) =>
      DateFormat('d MMM', 'ar').format(dt);

  static String phoneNumber(String number) {
    if (number.length == 11) {
      return '${number.substring(0, 4)}-${number.substring(4, 7)}-${number.substring(7)}';
    }
    return number;
  }
}

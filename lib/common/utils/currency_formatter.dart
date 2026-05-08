import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vnd = NumberFormat.decimalPattern('vi_VN');

  static String format(double value) {
    return '${_vnd.format(value.round())} đ';
  }

  static String formatSigned(double value, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(value.abs())}';
  }
}

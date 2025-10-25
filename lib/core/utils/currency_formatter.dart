// lib/core/utils/currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(amount).trim();
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₺';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₺';
    } else {
      return format(amount);
    }
  }
}
import 'package:intl/intl.dart';

/// Pulni formatlash uchun yordamchi klass
class CurrencyFormatter {
  /// O'zbekiston so'mi belgisi
  static const String uzsSymbol = 'so\'m';

  /// Pulni formatlash
  /// Misol: 1000000 -> "1,000,000 so'm"
  static String format(double amount, {String symbol = uzsSymbol}) {
    final formatter = NumberFormat('#,##0.##', 'uz_UZ');
    return '${formatter.format(amount)} $symbol';
  }

  /// Faqat sonni formatlash (belgisiz)
  /// Misol: 1000000 -> "1,000,000"
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##0.##', 'uz_UZ');
    return formatter.format(amount);
  }

  /// Qisqartirilgan format
  /// Misol: 1500000 -> "1.5M so'm"
  static String formatCompact(double amount, {String symbol = uzsSymbol}) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B $symbol';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $symbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $symbol';
    }
    return format(amount, symbol: symbol);
  }

  /// String'dan double'ga o'girish
  /// Misol: "1,000,000" -> 1000000.0
  static double? parse(String amountString) {
    try {
      // Vergul va bo'sh joylarni olib tashlash
      final cleaned = amountString.replaceAll(',', '').replaceAll(' ', '');
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Musbat yoki manfiy belgisini qo'shish
  /// Misol: (1000, true) -> "+1,000 so'm"
  ///        (1000, false) -> "-1,000 so'm"
  static String formatWithSign(double amount, bool isIncome, {String symbol = uzsSymbol}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(amount.abs(), symbol: symbol)}';
  }
}
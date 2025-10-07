import 'package:intl/intl.dart';

/// Sanalarni formatlash uchun yordamchi klass
class DateFormatter {
  /// dd/MM/yyyy formatda qaytaradi
  /// Misol: 07/10/2025
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// dd MMM yyyy formatda qaytaradi
  /// Misol: 07 Oct 2025
  static String formatDateWithMonth(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Faqat oyni qaytaradi
  /// Misol: October 2025
  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Faqat yilni qaytaradi
  /// Misol: 2025
  static String formatYear(DateTime date) {
    return DateFormat('yyyy').format(date);
  }

  /// Bugunmi yoki kechami yoki boshqa kun
  /// Misol: "Bugun", "Kecha", "07/10/2025"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Bugun';
    } else if (dateToCheck == yesterday) {
      return 'Kecha';
    } else {
      return formatDate(date);
    }
  }

  /// Oyning boshlanish kunini qaytaradi
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Oyning oxirgi kunini qaytaradi
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Haftaning boshlanish kunini qaytaradi (Dushanba)
  static DateTime getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  /// Haftaning oxirgi kunini qaytaradi (Yakshanba)
  static DateTime getWeekEnd(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.add(Duration(days: 7 - dayOfWeek, hours: 23, minutes: 59, seconds: 59));
  }
}
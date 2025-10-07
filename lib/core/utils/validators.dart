/// Input ma'lumotlarni tekshirish (validation) uchun
class Validators {
  /// Bo'sh matn tekshirish
  /// null yoki bo'sh bo'lsa xatolik qaytaradi
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName kiritilishi shart';
    }
    return null;
  }

  /// Summani tekshirish
  /// null, bo'sh yoki nol/manfiy bo'lsa xatolik qaytaradi
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Summa kiritilishi shart';
    }

    // String'dan double'ga o'girishga harakat
    final amount = double.tryParse(value.replaceAll(',', '').replaceAll(' ', ''));

    if (amount == null) {
      return 'Noto\'g\'ri summa formati';
    }

    if (amount <= 0) {
      return 'Summa noldan katta bo\'lishi kerak';
    }

    return null; // Xatolik yo'q
  }

  /// Matn uzunligini tekshirish
  static String? validateLength(
      String? value,
      String fieldName, {
        int minLength = 1,
        int? maxLength,
      }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName kiritilishi shart';
    }

    if (value.length < minLength) {
      return '$fieldName kamida $minLength ta belgidan iborat bo\'lishi kerak';
    }

    if (maxLength != null && value.length > maxLength) {
      return '$fieldName ko\'pi bilan $maxLength ta belgidan iborat bo\'lishi kerak';
    }

    return null;
  }

  /// Sanani tekshirish
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Sana tanlanishi shart';
    }

    // Kelajak sanasini taqiqlash
    if (date.isAfter(DateTime.now())) {
      return 'Kelajak sanasini tanlay olmaysiz';
    }

    return null;
  }

  /// Kategoriya tekshirish
  static String? validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return 'Kategoriya tanlanishi shart';
    }
    return null;
  }

  /// Budjetni tekshirish
  static String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budjet summasi kiritilishi shart';
    }

    final amount = double.tryParse(value.replaceAll(',', '').replaceAll(' ', ''));

    if (amount == null) {
      return 'Noto\'g\'ri summa formati';
    }

    if (amount < 0) {
      return 'Budjet manfiy bo\'lishi mumkin emas';
    }

    return null;
  }
}
/// Budget - Oylik yoki yillik budjet
/// Foydalanuvchi o'ziga budjet belgilashi mumkin

class Budget {
  /// Noyob identifikator
  final String id;

  /// Budjet summasi
  final double amount;

  /// Qaysi oy uchun (yil + oy)
  final DateTime month;

  /// Kategoriya ID (ixtiyoriy - umumiy budjet yoki kategoriya bo'yicha)
  final String? categoryId;

  /// Yaratilgan vaqt
  final DateTime createdAt;

  /// Oxirgi yangilanish vaqti
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.amount,
    required this.month,
    this.categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// CopyWith
  Budget copyWith({
    String? id,
    double? amount,
    DateTime? month,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Umumiy budjetmi (barcha kategoriyalar uchun)
  bool get isGeneral => categoryId == null;

  /// Kategoriya bo'yicha budjetmi
  bool get isCategoryBudget => categoryId != null;

  /// Budjet foizi (sarflangan/budjet * 100)
  double getPercentage(double spent) {
    if (amount == 0) return 0;
    return (spent / amount) * 100;
  }

  /// Budjet oshib ketganmi
  bool isExceeded(double spent) {
    return spent > amount;
  }

  /// Qolgan budjet
  double getRemaining(double spent) {
    return amount - spent;
  }

  @override
  String toString() {
    return 'Budget(id: $id, amount: $amount, month: $month, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Budjet holati - UI uchun foydali
class BudgetStatus {
  final Budget budget;
  final double spent;  // Sarflangan summa

  BudgetStatus({
    required this.budget,
    required this.spent,
  });

  /// Qolgan summa
  double get remaining => budget.getRemaining(spent);

  /// Foiz
  double get percentage => budget.getPercentage(spent);

  /// Oshib ketganmi
  bool get isExceeded => budget.isExceeded(spent);

  /// Ogohlantirish kerakmi (80% dan oshsa)
  bool get needsWarning => percentage >= 80 && !isExceeded;

  /// Status rangi
  BudgetStatusColor get statusColor {
    if (isExceeded) return BudgetStatusColor.danger;
    if (needsWarning) return BudgetStatusColor.warning;
    return BudgetStatusColor.safe;
  }
}

/// Budjet status ranglari
enum BudgetStatusColor {
  safe,      // Yaxshi holat (yashil)
  warning,   // Ogohlantirish (sariq)
  danger,    // Xavfli (qizil)
}
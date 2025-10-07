/// Transaction - Moliyaviy operatsiya (tranzaksiya)
/// Bu bizning asosiy biznes modelimiz (entity)
/// Domain layer'da - faqat biznes logika, texnik detaillar yo'q

class Transaction {
  /// Noyob identifikator (UUID)
  final String id;

  /// Summa (pul miqdori)
  final double amount;

  /// Kategoriya ID (qaysi kategoriyaga tegishli)
  final String categoryId;

  /// Turi: daromad yoki xarajat
  final TransactionType type;

  /// Tranzaksiya sanasi va vaqti
  final DateTime date;

  /// Izoh (ixtiyoriy)
  final String? note;

  /// Yaratilgan vaqt (kelajakda kerak bo'lishi mumkin)
  final DateTime createdAt;

  /// Constructor
  Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// CopyWith - o'zgarishlar bilan yangi nusxa yaratish
  /// Immutable pattern - obyektni o'zgartirish o'rniga yangi yaratamiz
  Transaction copyWith({
    String? id,
    double? amount,
    String? categoryId,
    TransactionType? type,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Daromadmi yoki xarajatmi tekshirish
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Tranzaksiya turi: Daromad yoki Xarajat
enum TransactionType {
  income,   // Daromad (kirim)
  expense,  // Xarajat (chiqim)
}

/// Enum'ni string'ga va string'dan enum'ga o'girish uchun
extension TransactionTypeExtension on TransactionType {
  String toStringValue() {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  static TransactionType fromString(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw Exception('Noma\'lum tranzaksiya turi: $value');
    }
  }
}
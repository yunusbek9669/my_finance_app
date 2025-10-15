import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

/// Hive adapter ID: 0
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String type; // 'income' yoki 'expense'

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Entity'dan Model'ga o'girish
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      type: transaction.type.toStringValue(),
      date: transaction.date,
      note: transaction.note,
      createdAt: transaction.createdAt,
    );
  }

  /// Model'dan Entity'ga o'girish
  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      categoryId: categoryId,
      type: TransactionTypeExtension.fromString(type),
      date: date,
      note: note,
      createdAt: createdAt,
    );
  }

  /// JSON'dan yaratish (backup uchun)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// JSON'ga o'girish (backup uchun)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
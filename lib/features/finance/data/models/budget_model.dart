import 'package:hive/hive.dart';
import '../../domain/entities/budget.dart';

/// Hive adapter ID: 2
part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime month;

  @HiveField(3)
  final String? categoryId;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.month,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Entity'dan Model'ga o'girish
  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      amount: budget.amount,
      month: budget.month,
      categoryId: budget.categoryId,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  /// Model'dan Entity'ga o'girish
  Budget toEntity() {
    return Budget(
      id: id,
      amount: amount,
      month: month,
      categoryId: categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// JSON'dan yaratish
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: DateTime.parse(json['month'] as String),
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSON'ga o'girish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'month': month.toIso8601String(),
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
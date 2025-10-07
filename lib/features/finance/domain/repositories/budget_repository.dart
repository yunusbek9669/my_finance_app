import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget.dart';

/// Budget Repository Interface
/// Budjet bilan ishlash uchun shartnoma

abstract class BudgetRepository {
  /// Yangi budjet belgilash
  Future<Either<Failure, Budget>> setBudget(Budget budget);

  /// Budjetni yangilash
  Future<Either<Failure, Budget>> updateBudget(Budget budget);

  /// Budjetni o'chirish
  Future<Either<Failure, void>> deleteBudget(String id);

  /// Bitta budjetni ID bo'yicha olish
  Future<Either<Failure, Budget>> getBudgetById(String id);

  /// Oy bo'yicha umumiy budjetni olish
  Future<Either<Failure, Budget?>> getMonthlyBudget(DateTime month);

  /// Oy va kategoriya bo'yicha budjetni olish
  Future<Either<Failure, Budget?>> getCategoryBudget({
    required DateTime month,
    required String categoryId,
  });

  /// Barcha budjetlarni olish
  Future<Either<Failure, List<Budget>>> getAllBudgets();

  /// Oy bo'yicha barcha budjetlarni olish
  Future<Either<Failure, List<Budget>>> getMonthlyBudgets(DateTime month);
}
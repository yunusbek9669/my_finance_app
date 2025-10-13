import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/budget.dart';
import '../../entities/transaction.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/transaction_repository.dart';

/// Budjet holatini olish UseCase
/// Budjet va sarflangan summani hisoblab, BudgetStatus qaytaradi
/// Bu UI uchun juda foydali - qancha sarflangani, qancha qolgani ko'rsatadi
class GetBudgetStatus implements UseCase<BudgetStatus, GetBudgetStatusParams> {
  final BudgetRepository budgetRepository;
  final TransactionRepository transactionRepository;

  GetBudgetStatus({
    required this.budgetRepository,
    required this.transactionRepository,
  });

  @override
  Future<Either<Failure, BudgetStatus>> call(GetBudgetStatusParams params) async {
    // 1. Budjetni olish
    final budgetResult = await budgetRepository.getMonthlyBudget(params.month);

    return budgetResult.fold(
          (failure) => Left(failure),
          (budget) async {
        // Agar budjet yo'q bo'lsa
        if (budget == null) {
          return const Left(NotFoundFailure('Bu oy uchun budjet belgilanmagan'));
        }

        // 2. Oylik tranzaksiyalarni olish
        final transactionsResult = await transactionRepository.getMonthlyTransactions(params.month);

        return transactionsResult.fold(
              (failure) => Left(failure),
              (transactions) {
            // 3. Agar kategoriya bo'yicha budjet bo'lsa
            double totalSpent = 0.0;

            if (budget.isCategoryBudget) {
              // Faqat shu kategoriya xarajatlarini hisoblash
              final categoryExpenses = transactions
                  .where((t) =>
              t.type == TransactionType.expense &&
                  t.categoryId == budget.categoryId)
                  .toList();

              totalSpent = categoryExpenses.fold<double>(
                0.0,
                    (sum, transaction) => sum + transaction.amount,
              );
            } else {
              // Umumiy budjet - barcha xarajatlarni hisoblash
              final expenses = transactions
                  .where((t) => t.type == TransactionType.expense)
                  .toList();

              totalSpent = expenses.fold<double>(
                0.0,
                    (sum, transaction) => sum + transaction.amount,
              );
            }

            // 4. BudgetStatus yaratish va qaytarish
            final status = BudgetStatus(
              budget: budget,
              spent: totalSpent,
            );

            return Right(status);
          },
        );
      },
    );
  }
}

/// Parameters - qaysi oy uchun
class GetBudgetStatusParams {
  final DateTime month;

  GetBudgetStatusParams({required this.month});

  /// Joriy oy uchun
  factory GetBudgetStatusParams.currentMonth() {
    final now = DateTime.now();
    return GetBudgetStatusParams(month: DateTime(now.year, now.month));
  }

  /// O'tgan oy uchun
  factory GetBudgetStatusParams.previousMonth() {
    final now = DateTime.now();
    return GetBudgetStatusParams(
      month: DateTime(now.year, now.month - 1),
    );
  }
}
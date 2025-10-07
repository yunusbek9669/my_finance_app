import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Kategoriya bo'yicha xarajatlarni olish UseCase
/// Qaysi kategoriyaga qancha pul sarflanganini ko'rsatadi
class GetExpenseByCategory implements UseCase<Map<String, double>, GetExpenseByCategoryParams> {
  final TransactionRepository repository;

  GetExpenseByCategory(this.repository);

  @override
  Future<Either<Failure, Map<String, double>>> call(GetExpenseByCategoryParams params) async {
    // Oylik tranzaksiyalarni olish
    final result = await repository.getMonthlyTransactions(params.month);

    return result.fold(
          (failure) => Left(failure),
          (transactions) {
        // Faqat xarajatlarni filtrlash
        final expenses = transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();

        // Kategoriya bo'yicha guruhlash va summalarni hisoblash
        final Map<String, double> categoryExpenses = {};

        for (var transaction in expenses) {
          final categoryId = transaction.categoryId;

          if (categoryExpenses.containsKey(categoryId)) {
            categoryExpenses[categoryId] = categoryExpenses[categoryId]! + transaction.amount;
          } else {
            categoryExpenses[categoryId] = transaction.amount;
          }
        }

        return Right(categoryExpenses);
      },
    );
  }
}

/// Parameters
class GetExpenseByCategoryParams {
  final DateTime month;

  GetExpenseByCategoryParams({required this.month});
}
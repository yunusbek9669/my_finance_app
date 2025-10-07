import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Oylik tranzaksiyalarni olish UseCase
/// Berilgan oydagi barcha tranzaksiyalarni qaytaradi
class GetMonthlyTransactions implements UseCase<List<Transaction>, GetMonthlyTransactionsParams> {
  final TransactionRepository repository;

  GetMonthlyTransactions(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(GetMonthlyTransactionsParams params) async {
    // Repository'dan oylik tranzaksiyalarni olish
    return await repository.getMonthlyTransactions(params.month);
  }
}

/// Parameters - oy parametri
class GetMonthlyTransactionsParams {
  final DateTime month;

  GetMonthlyTransactionsParams({required this.month});

  /// Joriy oy uchun
  factory GetMonthlyTransactionsParams.currentMonth() {
    final now = DateTime.now();
    return GetMonthlyTransactionsParams(
      month: DateTime(now.year, now.month),
    );
  }

  /// O'tgan oy uchun
  factory GetMonthlyTransactionsParams.previousMonth() {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);
    return GetMonthlyTransactionsParams(month: previousMonth);
  }

  /// Maxsus oy uchun
  factory GetMonthlyTransactionsParams.forMonth(int year, int month) {
    return GetMonthlyTransactionsParams(
      month: DateTime(year, month),
    );
  }
}
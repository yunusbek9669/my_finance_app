import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Sanalar oralig'idagi tranzaksiyalarni olish UseCase
/// Masalan: 1-Oktabrdan 31-Oktabrgacha
class GetTransactionsByPeriod implements UseCase<List<Transaction>, GetTransactionsByPeriodParams> {
  final TransactionRepository repository;

  GetTransactionsByPeriod(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(GetTransactionsByPeriodParams params) async {
    // Sanalarni tekshirish
    if (params.startDate.isAfter(params.endDate)) {
      return const Left(
        ValidationFailure('Boshlanish sanasi tugash sanasidan katta bo\'lishi mumkin emas'),
      );
    }

    // Juda uzoq davr uchun ogohlantirish (1 yildan ko'p)
    final daysDifference = params.endDate.difference(params.startDate).inDays;
    if (daysDifference > 365) {
      return const Left(
        ValidationFailure('Maksimal 1 yillik davr tanlay olasiz'),
      );
    }

    // Repository orqali olish
    return await repository.getTransactionsByDateRange(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Parameters - boshlanish va tugash sanasi
class GetTransactionsByPeriodParams {
  final DateTime startDate;
  final DateTime endDate;

  GetTransactionsByPeriodParams({
    required this.startDate,
    required this.endDate,
  });

  /// Haftalik davr uchun
  factory GetTransactionsByPeriodParams.thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    return GetTransactionsByPeriodParams(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: endOfWeek,
    );
  }

  /// Oylik davr uchun
  factory GetTransactionsByPeriodParams.thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return GetTransactionsByPeriodParams(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Yillik davr uchun
  factory GetTransactionsByPeriodParams.thisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    return GetTransactionsByPeriodParams(
      startDate: startOfYear,
      endDate: endOfYear,
    );
  }
}
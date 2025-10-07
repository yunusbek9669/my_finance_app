import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

/// Transaction Repository Interface
/// Bu faqat shartnoma (contract) - nimalar bo'lishi kerakligini ko'rsatadi
/// Amaliy amalga oshirish (implementation) data layer'da bo'ladi
///
/// Either<Failure, Type> - natija yoki xatolik qaytaradi
/// Left(Failure) - xatolik
/// Right(Type) - muvaffaqiyat

abstract class TransactionRepository {
  /// Yangi tranzaksiya qo'shish
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);

  /// Tranzaksiyani yangilash
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);

  /// Tranzaksiyani o'chirish
  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Bitta tranzaksiyani ID bo'yicha olish
  Future<Either<Failure, Transaction>> getTransactionById(String id);

  /// Barcha tranzaksiyalarni olish
  Future<Either<Failure, List<Transaction>>> getAllTransactions();

  /// Sanalar oralig'idagi tranzaksiyalarni olish
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Kategoriya bo'yicha tranzaksiyalarni olish
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
      String categoryId,
      );

  /// Turi bo'yicha tranzaksiyalarni olish (daromad/xarajat)
  Future<Either<Failure, List<Transaction>>> getTransactionsByType(
      TransactionType type,
      );

  /// Oylik tranzaksiyalarni olish
  Future<Either<Failure, List<Transaction>>> getMonthlyTransactions(
      DateTime month,
      );

  /// Yillik tranzaksiyalarni olish
  Future<Either<Failure, List<Transaction>>> getYearlyTransactions(
      int year,
      );
}
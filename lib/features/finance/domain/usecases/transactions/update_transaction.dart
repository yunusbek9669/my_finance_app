import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Tranzaksiyani yangilash UseCase
/// Mavjud tranzaksiyani tahrirlash uchun
class UpdateTransaction implements UseCase<Transaction, UpdateTransactionParams> {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(UpdateTransactionParams params) async {
    // Validation - ma'lumotlarni tekshirish
    if (params.transaction.id.isEmpty) {
      return const Left(ValidationFailure('Transaction ID bo\'sh bo\'lishi mumkin emas'));
    }

    if (params.transaction.amount <= 0) {
      return const Left(ValidationFailure('Summa noldan katta bo\'lishi kerak'));
    }

    if (params.transaction.categoryId.isEmpty) {
      return const Left(ValidationFailure('Kategoriya tanlanishi shart'));
    }

    // Repository orqali yangilash
    return await repository.updateTransaction(params.transaction);
  }
}

/// Parameters - kiritma parametrlar
class UpdateTransactionParams {
  final Transaction transaction;

  UpdateTransactionParams({required this.transaction});
}
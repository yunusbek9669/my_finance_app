import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Yangi tranzaksiya qo'shish UseCase
/// Bu biznes logika - repository orqali ma'lumotni saqlaydi
class AddTransaction implements UseCase<Transaction, AddTransactionParams> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(AddTransactionParams params) async {
    // Validation - tekshirish
    if (params.transaction.amount <= 0) {
      return const Left(ValidationFailure('Summa noldan katta bo\'lishi kerak'));
    }

    if (params.transaction.categoryId.isEmpty) {
      return const Left(ValidationFailure('Kategoriya tanlanishi shart'));
    }

    // Repository orqali saqlash
    return await repository.addTransaction(params.transaction);
  }
}

/// Parameters - kiritma parametrlar
class AddTransactionParams {
  final Transaction transaction;

  AddTransactionParams({required this.transaction});
}
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/transaction_repository.dart';

/// Tranzaksiyani o'chirish UseCase
/// ID bo'yicha tranzaksiyani o'chiradi
class DeleteTransaction implements UseCase<void, DeleteTransactionParams> {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) async {
    // ID tekshirish
    if (params.id.isEmpty) {
      return const Left(ValidationFailure('Transaction ID bo\'sh bo\'lishi mumkin emas'));
    }

    // Repository orqali o'chirish
    return await repository.deleteTransaction(params.id);
  }
}

/// Parameters - ID parametr sifatida kerak
class DeleteTransactionParams {
  final String id;

  DeleteTransactionParams({required this.id});
}
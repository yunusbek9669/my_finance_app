import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/budget.dart';
import '../../repositories/budget_repository.dart';

/// Budjet belgilash UseCase
class SetBudget implements UseCase<Budget, SetBudgetParams> {
  final BudgetRepository repository;

  SetBudget(this.repository);

  @override
  Future<Either<Failure, Budget>> call(SetBudgetParams params) async {
    // Validation
    if (params.budget.amount < 0) {
      return const Left(ValidationFailure('Budjet manfiy bo\'lishi mumkin emas'));
    }

    if (params.budget.amount == 0) {
      return const Left(ValidationFailure('Budjet noldan katta bo\'lishi kerak'));
    }

    // Repository orqali saqlash
    return await repository.setBudget(params.budget);
  }
}

/// Parameters
class SetBudgetParams {
  final Budget budget;

  SetBudgetParams({required this.budget});
}
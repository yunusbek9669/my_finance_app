import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local/budget_local_datasource.dart';
import '../models/budget_model.dart';

/// Budget Repository Implementation
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Budget>> setBudget(Budget budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final result = await localDataSource.setBudget(model);
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final result = await localDataSource.updateBudget(model);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await localDataSource.deleteBudget(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> getBudgetById(String id) async {
    try {
      final result = await localDataSource.getBudgetById(id);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget?>> getMonthlyBudget(DateTime month) async {
    try {
      final result = await localDataSource.getMonthlyBudget(month);
      return Right(result?.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget?>> getCategoryBudget({
    required DateTime month,
    required String categoryId,
  }) async {
    try {
      final result = await localDataSource.getCategoryBudget(month, categoryId);
      return Right(result?.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Budget>>> getAllBudgets() async {
    try {
      final results = await localDataSource.getAllBudgets();
      final budgets = results.map((model) => model.toEntity()).toList();
      return Right(budgets);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Budget>>> getMonthlyBudgets(DateTime month) async {
    try {
      final results = await localDataSource.getMonthlyBudgets(month);
      final budgets = results.map((model) => model.toEntity()).toList();
      return Right(budgets);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
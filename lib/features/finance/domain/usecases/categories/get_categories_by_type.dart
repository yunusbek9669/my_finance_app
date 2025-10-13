import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Turi bo'yicha kategoriyalarni olish UseCase
/// Masalan: faqat xarajat kategoriyalari yoki faqat daromad kategoriyalari
class GetCategoriesByType implements UseCase<List<Category>, GetCategoriesByTypeParams> {
  final CategoryRepository repository;

  GetCategoriesByType(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(GetCategoriesByTypeParams params) async {
    // Repository'dan turi bo'yicha kategoriyalarni olish
    return await repository.getCategoriesByType(params.type);
  }
}

/// Parameters - kategoriya turi
class GetCategoriesByTypeParams {
  final CategoryType type;

  GetCategoriesByTypeParams({required this.type});

  /// Daromad kategoriyalari uchun
  factory GetCategoriesByTypeParams.income() {
    return GetCategoriesByTypeParams(type: CategoryType.income);
  }

  /// Xarajat kategoriyalari uchun
  factory GetCategoriesByTypeParams.expense() {
    return GetCategoriesByTypeParams(type: CategoryType.expense);
  }
}
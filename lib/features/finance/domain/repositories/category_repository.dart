import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

/// Category Repository Interface
/// Kategoriyalar bilan ishlash uchun shartnoma

abstract class CategoryRepository {
  /// Yangi kategoriya qo'shish
  Future<Either<Failure, Category>> addCategory(Category category);

  /// Kategoriyani yangilash
  Future<Either<Failure, Category>> updateCategory(Category category);

  /// Kategoriyani o'chirish
  /// Standart kategoriyalarni o'chirish mumkin emas
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Bitta kategoriyani ID bo'yicha olish
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Barcha kategoriyalarni olish
  Future<Either<Failure, List<Category>>> getAllCategories();

  /// Turi bo'yicha kategoriyalarni olish (daromad/xarajat)
  Future<Either<Failure, List<Category>>> getCategoriesByType(
      CategoryType type,
      );

  /// Standart kategoriyalarni yaratish (ilk bor ishlatilganda)
  Future<Either<Failure, void>> createDefaultCategories();
}
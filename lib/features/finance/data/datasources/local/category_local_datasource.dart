import '../../../../../core/errors/exceptions.dart';
import '../../models/category_model.dart';
import '../default_categories.dart';
import 'database_helper.dart';

/// Category Local DataSource
abstract class CategoryLocalDataSource {
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<CategoryModel> getCategoryById(String id);
  Future<List<CategoryModel>> getAllCategories();
  Future<List<CategoryModel>> getCategoriesByType(String type);
  Future<void> createDefaultCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      final box = DatabaseHelper.getCategoryBox();
      await box.put(category.id, category);
      return category;
    } catch (e) {
      throw DatabaseException('Kategoriyani saqlashda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final box = DatabaseHelper.getCategoryBox();

      if (!box.containsKey(category.id)) {
        throw NotFoundException('Kategoriya topilmadi');
      }

      await box.put(category.id, category);
      return category;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Kategoriyani yangilashda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final box = DatabaseHelper.getCategoryBox();

      final category = box.get(id);
      if (category == null) {
        throw NotFoundException('Kategoriya topilmadi');
      }

      // Standart kategoriyalarni o'chirish mumkin emas
      if (category.isDefault) {
        throw ValidationException('Standart kategoriyalarni o\'chirish mumkin emas');
      }

      await box.delete(id);
    } catch (e) {
      if (e is NotFoundException || e is ValidationException) rethrow;
      throw DatabaseException('Kategoriyani o\'chirishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final box = DatabaseHelper.getCategoryBox();
      final category = box.get(id);

      if (category == null) {
        throw NotFoundException('Kategoriya topilmadi');
      }

      return category;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Kategoriyani olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final box = DatabaseHelper.getCategoryBox();

      // Agar kategoriyalar bo'sh bo'lsa, standart kategoriyalarni yaratish
      if (box.isEmpty) {
        await createDefaultCategories();
      }

      return box.values.toList();
    } catch (e) {
      throw DatabaseException('Kategoriyalarni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    try {
      final box = DatabaseHelper.getCategoryBox();

      // Agar bo'sh bo'lsa, standart kategoriyalarni yaratish
      if (box.isEmpty) {
        await createDefaultCategories();
      }

      final categories = box.values.where((category) {
        return category.type == type;
      }).toList();

      return categories;
    } catch (e) {
      throw DatabaseException('Kategoriyalarni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<void> createDefaultCategories() async {
    try {
      final box = DatabaseHelper.getCategoryBox();

      // Standart kategoriyalarni qo'shish
      for (var category in DefaultCategories.allCategories) {
        final model = CategoryModel.fromEntity(category);
        await box.put(model.id, model);
      }
    } catch (e) {
      throw DatabaseException('Standart kategoriyalarni yaratishda xatolik: ${e.toString()}');
    }
  }
}
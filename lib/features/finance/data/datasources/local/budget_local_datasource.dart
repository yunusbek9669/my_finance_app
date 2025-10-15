import '../../../../../core/errors/exceptions.dart';
import '../../models/budget_model.dart';
import 'database_helper.dart';

/// Budget Local DataSource
abstract class BudgetLocalDataSource {
  Future<BudgetModel> setBudget(BudgetModel budget);
  Future<BudgetModel> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
  Future<BudgetModel> getBudgetById(String id);
  Future<BudgetModel?> getMonthlyBudget(DateTime month);
  Future<BudgetModel?> getCategoryBudget(DateTime month, String categoryId);
  Future<List<BudgetModel>> getAllBudgets();
  Future<List<BudgetModel>> getMonthlyBudgets(DateTime month);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  @override
  Future<BudgetModel> setBudget(BudgetModel budget) async {
    try {
      final box = DatabaseHelper.getBudgetBox();
      await box.put(budget.id, budget);
      return budget;
    } catch (e) {
      throw DatabaseException('Budjetni saqlashda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    try {
      final box = DatabaseHelper.getBudgetBox();

      if (!box.containsKey(budget.id)) {
        throw NotFoundException('Budjet topilmadi');
      }

      await box.put(budget.id, budget);
      return budget;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Budjetni yangilashda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      final box = DatabaseHelper.getBudgetBox();

      if (!box.containsKey(id)) {
        throw NotFoundException('Budjet topilmadi');
      }

      await box.delete(id);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Budjetni o\'chirishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<BudgetModel> getBudgetById(String id) async {
    try {
      final box = DatabaseHelper.getBudgetBox();
      final budget = box.get(id);

      if (budget == null) {
        throw NotFoundException('Budjet topilmadi');
      }

      return budget;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Budjetni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<BudgetModel?> getMonthlyBudget(DateTime month) async {
    try {
      final box = DatabaseHelper.getBudgetBox();
      final monthKey = DateTime(month.year, month.month);

      // Umumiy budjetni topish (categoryId == null)
      final budget = box.values.firstWhere(
            (b) => b.month.year == monthKey.year &&
            b.month.month == monthKey.month &&
            b.categoryId == null,
        orElse: () => throw NotFoundException('Budjet topilmadi'),
      );

      return budget;
    } on NotFoundException {
      return null; // Bu holatda null qaytaramiz
    } catch (e) {
      throw DatabaseException('Budjetni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<BudgetModel?> getCategoryBudget(DateTime month, String categoryId) async {
    try {
      final box = DatabaseHelper.getBudgetBox();
      final monthKey = DateTime(month.year, month.month);

      final budget = box.values.firstWhere(
            (b) => b.month.year == monthKey.year &&
            b.month.month == monthKey.month &&
            b.categoryId == categoryId,
        orElse: () => throw NotFoundException('Budjet topilmadi'),
      );

      return budget;
    } on NotFoundException {
      return null;
    } catch (e) {
      throw DatabaseException('Budjetni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<List<BudgetModel>> getAllBudgets() async {
    try {
      final box = DatabaseHelper.getBudgetBox();
      return box.values.toList();
    } catch (e) {
      throw DatabaseException('Budjetlarni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<List<BudgetModel>> getMonthlyBudgets(DateTime month) async {
    try {
      final box = DatabaseHelper.getBudgetBox();
      final monthKey = DateTime(month.year, month.month);

      final budgets = box.values.where((b) {
        return b.month.year == monthKey.year && b.month.month == monthKey.month;
      }).toList();

      return budgets;
    } catch (e) {
      throw DatabaseException('Budjetlarni olishda xatolik: ${e.toString()}');
    }
  }
}
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/budget_model.dart';

/// Hive Database yordamchisi
/// Database'ni ishga tushirish va boshqarish
class DatabaseHelper {
  // Box nomlari
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String budgetsBox = 'budgets';

  /// Database'ni ishga tushirish
  static Future<void> init() async {
    // Hive'ni ishga tushirish
    await Hive.initFlutter();

    // Adapter'larni ro'yxatdan o'tkazish
    // DIQQAT: Bu faqat bir marta ishlatilishi kerak
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }

    // Box'larni ochish
    await Hive.openBox<TransactionModel>(transactionsBox);
    await Hive.openBox<CategoryModel>(categoriesBox);
    await Hive.openBox<BudgetModel>(budgetsBox);
  }

  /// Transaction Box'ni olish
  static Box<TransactionModel> getTransactionBox() {
    return Hive.box<TransactionModel>(transactionsBox);
  }

  /// Category Box'ni olish
  static Box<CategoryModel> getCategoryBox() {
    return Hive.box<CategoryModel>(categoriesBox);
  }

  /// Budget Box'ni olish
  static Box<BudgetModel> getBudgetBox() {
    return Hive.box<BudgetModel>(budgetsBox);
  }

  /// Barcha ma'lumotlarni o'chirish (reset)
  static Future<void> clearAll() async {
    await getTransactionBox().clear();
    await getCategoryBox().clear();
    await getBudgetBox().clear();
  }

  /// Database'ni yopish
  static Future<void> close() async {
    await Hive.close();
  }
}
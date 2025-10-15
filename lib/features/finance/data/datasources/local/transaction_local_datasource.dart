import '../../../../../core/errors/exceptions.dart';
import '../../models/transaction_model.dart';
import 'database_helper.dart';

/// Transaction Local DataSource
/// Hive database bilan bevosita ishlaydi
abstract class TransactionLocalDataSource {
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<TransactionModel> getTransactionById(String id);
  Future<List<TransactionModel>> getAllTransactions();
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate,
      DateTime endDate,
      );
  Future<List<TransactionModel>> getMonthlyTransactions(DateTime month);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final box = DatabaseHelper.getTransactionBox();
      // ID'ni kalit sifatida ishlatamiz
      await box.put(transaction.id, transaction);
      return transaction;
    } catch (e) {
      throw DatabaseException('Tranzaksiyani saqlashda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      final box = DatabaseHelper.getTransactionBox();

      // Mavjudligini tekshirish
      if (!box.containsKey(transaction.id)) {
        throw NotFoundException('Tranzaksiya topilmadi');
      }

      await box.put(transaction.id, transaction);
      return transaction;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Tranzaksiyani yangilashda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final box = DatabaseHelper.getTransactionBox();

      if (!box.containsKey(id)) {
        throw NotFoundException('Tranzaksiya topilmadi');
      }

      await box.delete(id);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Tranzaksiyani o\'chirishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final box = DatabaseHelper.getTransactionBox();
      final transaction = box.get(id);

      if (transaction == null) {
        throw NotFoundException('Tranzaksiya topilmadi');
      }

      return transaction;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Tranzaksiyani olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final box = DatabaseHelper.getTransactionBox();
      final transactions = box.values.toList();

      // Sana bo'yicha teskari tartibda saralash (yangilari birinchi)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return transactions;
    } catch (e) {
      throw DatabaseException('Tranzaksiyalarni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final box = DatabaseHelper.getTransactionBox();
      final transactions = box.values.where((transaction) {
        return transaction.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            transaction.date.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();

      // Sana bo'yicha saralash
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return transactions;
    } catch (e) {
      throw DatabaseException('Tranzaksiyalarni olishda xatolik: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionModel>> getMonthlyTransactions(DateTime month) async {
    try {
      // Oyning boshlanish va tugash sanasi
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      return await getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw DatabaseException('Oylik tranzaksiyalarni olishda xatolik: ${e.toString()}');
    }
  }
}
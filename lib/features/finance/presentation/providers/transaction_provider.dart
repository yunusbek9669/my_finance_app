import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transactions/add_transaction.dart';
import '../../domain/usecases/transactions/delete_transaction.dart';
import '../../domain/usecases/transactions/get_monthly_transactions.dart';
import '../../domain/usecases/transactions/get_transactions.dart';
import '../../domain/usecases/transactions/update_transaction.dart';

/// Transaction Provider State
/// UI'da ko'rsatiladigan ma'lumotlar va holat
class TransactionState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;

  TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Transaction Provider (StateNotifier)
/// Tranzaksiyalar bilan ishlash uchun
class TransactionNotifier extends StateNotifier<TransactionState> {
  final GetTransactions getTransactions;
  final GetMonthlyTransactions getMonthlyTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;

  TransactionNotifier({
    required this.getTransactions,
    required this.getMonthlyTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
  }) : super(TransactionState());

  /// Barcha tranzaksiyalarni yuklash
  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getTransactions(NoParams());

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
          (transactions) {
        state = state.copyWith(
          transactions: transactions,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  /// Oylik tranzaksiyalarni yuklash
  Future<void> loadMonthlyTransactions(DateTime month) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getMonthlyTransactions(
      GetMonthlyTransactionsParams(month: month),
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
          (transactions) {
        state = state.copyWith(
          transactions: transactions,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  /// Yangi tranzaksiya qo'shish
  Future<bool> addNewTransaction(Transaction transaction) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await addTransaction(
      AddTransactionParams(transaction: transaction),
    );

    return result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
          (newTransaction) {
        // State'ga yangi tranzaksiyani qo'shish
        final updatedList = [...state.transactions, newTransaction];
        state = state.copyWith(
          transactions: updatedList,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Tranzaksiyani yangilash
  Future<bool> updateExistingTransaction(Transaction transaction) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await updateTransaction(
      UpdateTransactionParams(transaction: transaction),
    );

    return result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
          (updatedTransaction) {
        // State'da tranzaksiyani yangilash
        final updatedList = state.transactions.map((t) {
          return t.id == updatedTransaction.id ? updatedTransaction : t;
        }).toList();

        state = state.copyWith(
          transactions: updatedList,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Tranzaksiyani o'chirish
  Future<bool> removeTransaction(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await deleteTransaction(
      DeleteTransactionParams(id: id),
    );

    return result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
          (_) {
        // State'dan tranzaksiyani o'chirish
        final updatedList = state.transactions.where((t) => t.id != id).toList();
        state = state.copyWith(
          transactions: updatedList,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Xatolikni tozalash
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider - DI uchun (keyinchalik to'ldiramiz)
/// Bu yerda UseCase'larni inject qilamiz
final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  // TODO: DI - Dependency Injection qo'shiladi
  throw UnimplementedError('DI container setup qilish kerak');
});
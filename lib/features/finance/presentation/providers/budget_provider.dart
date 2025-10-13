import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/budget/get_budget_status.dart';
import '../../domain/usecases/budget/set_budget.dart';

/// Budget Provider State
class BudgetState {
  final BudgetStatus? budgetStatus;
  final bool isLoading;
  final String? errorMessage;

  BudgetState({
    this.budgetStatus,
    this.isLoading = false,
    this.errorMessage,
  });

  BudgetState copyWith({
    BudgetStatus? budgetStatus,
    bool? isLoading,
    String? errorMessage,
    bool clearBudgetStatus = false,
  }) {
    return BudgetState(
      budgetStatus: clearBudgetStatus ? null : (budgetStatus ?? this.budgetStatus),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Budjet bormi
  bool get hasBudget => budgetStatus != null;

  /// Budjet summasi
  double get budgetAmount => budgetStatus?.budget.amount ?? 0.0;

  /// Sarflangan summa
  double get spentAmount => budgetStatus?.spent ?? 0.0;

  /// Qolgan summa
  double get remainingAmount => budgetStatus?.remaining ?? 0.0;

  /// Foiz
  double get percentage => budgetStatus?.percentage ?? 0.0;

  /// Oshib ketganmi
  bool get isExceeded => budgetStatus?.isExceeded ?? false;

  /// Ogohlantirish kerakmi
  bool get needsWarning => budgetStatus?.needsWarning ?? false;
}

/// Budget Provider (StateNotifier)
class BudgetNotifier extends StateNotifier<BudgetState> {
  final GetBudgetStatus getBudgetStatus;
  final SetBudget setBudget;

  BudgetNotifier({
    required this.getBudgetStatus,
    required this.setBudget,
  }) : super(BudgetState());

  /// Budjet holatini yuklash
  Future<void> loadBudgetStatus(DateTime month) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getBudgetStatus(
      GetBudgetStatusParams(month: month),
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          clearBudgetStatus: true,
        );
      },
          (budgetStatus) {
        state = state.copyWith(
          budgetStatus: budgetStatus,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  /// Joriy oy budjetini yuklash
  Future<void> loadCurrentMonthBudget() async {
    final now = DateTime.now();
    await loadBudgetStatus(DateTime(now.year, now.month));
  }

  /// Yangi budjet belgilash
  Future<bool> setNewBudget(Budget budget) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await setBudget(
      SetBudgetParams(budget: budget),
    );

    return result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
          (newBudget) {
        // Budjet holatini qayta yuklash
        loadBudgetStatus(newBudget.month);
        return true;
      },
    );
  }

  /// Xatolikni tozalash
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// State'ni tozalash
  void clear() {
    state = BudgetState();
  }
}

/// Provider - DI uchun
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  // TODO: DI - Dependency Injection qo'shiladi
  throw UnimplementedError('DI container setup qilish kerak');
});
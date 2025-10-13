import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/analytics/get_expense_by_category.dart';
import '../../domain/usecases/analytics/get_income_expense_summary.dart';

/// Analytics Provider State
class AnalyticsState {
  final FinancialSummary? summary;
  final Map<String, double>? expenseByCategory;
  final bool isLoading;
  final String? errorMessage;

  AnalyticsState({
    this.summary,
    this.expenseByCategory,
    this.isLoading = false,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    FinancialSummary? summary,
    Map<String, double>? expenseByCategory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnalyticsState(
      summary: summary ?? this.summary,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Ma'lumot bormi
  bool get hasData => summary != null || expenseByCategory != null;

  /// Jami daromad
  double get totalIncome => summary?.totalIncome ?? 0.0;

  /// Jami xarajat
  double get totalExpense => summary?.totalExpense ?? 0.0;

  /// Balans
  double get balance => summary?.balance ?? 0.0;

  /// Xarajat foizi
  double get expensePercentage => summary?.expensePercentage ?? 0.0;

  /// Tejash foizi
  double get savingsPercentage => summary?.savingsPercentage ?? 0.0;

  /// Kategoriya foizini hisoblash
  double getCategoryPercentage(String categoryId) {
    if (expenseByCategory == null || totalExpense == 0) return 0;

    final categoryExpense = expenseByCategory![categoryId] ?? 0;
    return (categoryExpense / totalExpense) * 100;
  }

  /// Eng ko'p sarflangan kategoriyalarni olish (top 5)
  List<MapEntry<String, double>> getTopExpenseCategories({int limit = 5}) {
    if (expenseByCategory == null) return [];

    final entries = expenseByCategory!.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return entries.take(limit).toList();
  }
}

/// Analytics Provider (StateNotifier)
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final GetIncomeExpenseSummary getIncomeExpenseSummary;
  final GetExpenseByCategory getExpenseByCategory;

  AnalyticsNotifier({
    required this.getIncomeExpenseSummary,
    required this.getExpenseByCategory,
  }) : super(AnalyticsState());

  /// Moliyaviy xulosani yuklash
  Future<void> loadFinancialSummary(DateTime month) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getIncomeExpenseSummary(
      GetIncomeExpenseSummaryParams(month: month),
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
          (summary) {
        state = state.copyWith(
          summary: summary,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  /// Kategoriya bo'yicha xarajatlarni yuklash
  Future<void> loadExpenseByCategory(DateTime month) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getExpenseByCategory(
      GetExpenseByCategoryParams(month: month),
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
          (expenseByCategory) {
        state = state.copyWith(
          expenseByCategory: expenseByCategory,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  /// Barcha analytics ma'lumotlarini yuklash
  Future<void> loadAllAnalytics(DateTime month) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // 1. Moliyaviy xulosani yuklash
    final summaryResult = await getIncomeExpenseSummary(
      GetIncomeExpenseSummaryParams(month: month),
    );

    // 2. Kategoriya bo'yicha xarajatni yuklash
    final expenseResult = await getExpenseByCategory(
      GetExpenseByCategoryParams(month: month),
    );

    // Natijalarni birlashtirish
    summaryResult.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
          (summary) {
        expenseResult.fold(
              (failure) {
            state = state.copyWith(
              summary: summary,
              isLoading: false,
              errorMessage: failure.message,
            );
          },
              (expenseByCategory) {
            state = state.copyWith(
              summary: summary,
              expenseByCategory: expenseByCategory,
              isLoading: false,
              errorMessage: null,
            );
          },
        );
      },
    );
  }

  /// Joriy oy analytics'ini yuklash
  Future<void> loadCurrentMonthAnalytics() async {
    final now = DateTime.now();
    await loadAllAnalytics(DateTime(now.year, now.month));
  }

  /// Xatolikni tozalash
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// State'ni tozalash
  void clear() {
    state = AnalyticsState();
  }
}

/// Provider - DI uchun
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  // TODO: DI - Dependency Injection qo'shiladi
  throw UnimplementedError('DI container setup qilish kerak');
});
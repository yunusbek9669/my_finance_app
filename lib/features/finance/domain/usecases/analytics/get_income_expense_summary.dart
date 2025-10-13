import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Daromad va xarajat xulosasini olish UseCase
/// Jami daromad, jami xarajat va balansni hisoblaydi
/// Bu Home Screen'da ko'rsatish uchun juda foydali
class GetIncomeExpenseSummary implements UseCase<FinancialSummary, GetIncomeExpenseSummaryParams> {
  final TransactionRepository repository;

  GetIncomeExpenseSummary(this.repository);

  @override
  Future<Either<Failure, FinancialSummary>> call(GetIncomeExpenseSummaryParams params) async {
    // Oylik tranzaksiyalarni olish
    final result = await repository.getMonthlyTransactions(params.month);

    return result.fold(
          (failure) => Left(failure),
          (transactions) {
        // Daromad va xarajatlarni ajratish va hisoblash
        double totalIncome = 0.0;
        double totalExpense = 0.0;
        int incomeCount = 0;
        int expenseCount = 0;

        for (var transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            totalIncome += transaction.amount;
            incomeCount++;
          } else {
            totalExpense += transaction.amount;
            expenseCount++;
          }
        }

        // Balans = Daromad - Xarajat
        final balance = totalIncome - totalExpense;

        final summary = FinancialSummary(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          balance: balance,
          transactionCount: transactions.length,
          incomeCount: incomeCount,
          expenseCount: expenseCount,
          month: params.month,
        );

        return Right(summary);
      },
    );
  }
}

/// Parameters - qaysi oy uchun
class GetIncomeExpenseSummaryParams {
  final DateTime month;

  GetIncomeExpenseSummaryParams({required this.month});

  /// Joriy oy uchun
  factory GetIncomeExpenseSummaryParams.currentMonth() {
    final now = DateTime.now();
    return GetIncomeExpenseSummaryParams(month: DateTime(now.year, now.month));
  }

  /// O'tgan oy uchun
  factory GetIncomeExpenseSummaryParams.previousMonth() {
    final now = DateTime.now();
    return GetIncomeExpenseSummaryParams(
      month: DateTime(now.year, now.month - 1),
    );
  }

  /// Maxsus oy uchun
  factory GetIncomeExpenseSummaryParams.forMonth(int year, int month) {
    return GetIncomeExpenseSummaryParams(month: DateTime(year, month));
  }
}

/// Moliyaviy xulosa modeli
/// UI'da ko'rsatish uchun barcha kerakli ma'lumotlar
class FinancialSummary {
  final double totalIncome;     // Jami daromad
  final double totalExpense;    // Jami xarajat
  final double balance;         // Balans (daromad - xarajat)
  final int transactionCount;   // Jami tranzaksiyalar soni
  final int incomeCount;        // Daromad tranzaksiyalari soni
  final int expenseCount;       // Xarajat tranzaksiyalari soni
  final DateTime month;         // Qaysi oy

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.incomeCount,
    required this.expenseCount,
    required this.month,
  });

  /// Xarajat foizi (xarajat / daromad * 100)
  /// Agar daromad bo'lmasa 0 qaytaradi
  double get expensePercentage {
    if (totalIncome == 0) return 0;
    return (totalExpense / totalIncome) * 100;
  }

  /// Tejash foizi (100 - xarajat foizi)
  double get savingsPercentage {
    if (totalIncome == 0) return 0;
    return 100 - expensePercentage;
  }

  /// Tejash summasi (balance bilan bir xil)
  double get savings => balance;

  /// Manfiy balansmi (xarajat daromaddan ko'p)
  bool get isNegative => balance < 0;

  /// Musbat balansmi (tejash bor)
  bool get isPositive => balance > 0;

  /// Muvozanatli (balans nolga yaqin)
  bool get isBalanced => balance.abs() < 1000;

  /// O'rtacha daromad (agar daromad tranzaksiyalari bo'lsa)
  double get averageIncome {
    if (incomeCount == 0) return 0;
    return totalIncome / incomeCount;
  }

  /// O'rtacha xarajat (agar xarajat tranzaksiyalari bo'lsa)
  double get averageExpense {
    if (expenseCount == 0) return 0;
    return totalExpense / expenseCount;
  }

  /// Bo'shmi (hech qanday tranzaksiya yo'q)
  bool get isEmpty => transactionCount == 0;

  @override
  String toString() {
    return 'FinancialSummary(income: $totalIncome, expense: $totalExpense, balance: $balance)';
  }

  /// CopyWith
  FinancialSummary copyWith({
    double? totalIncome,
    double? totalExpense,
    double? balance,
    int? transactionCount,
    int? incomeCount,
    int? expenseCount,
    DateTime? month,
  }) {
    return FinancialSummary(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      incomeCount: incomeCount ?? this.incomeCount,
      expenseCount: expenseCount ?? this.expenseCount,
      month: month ?? this.month,
    );
  }
}
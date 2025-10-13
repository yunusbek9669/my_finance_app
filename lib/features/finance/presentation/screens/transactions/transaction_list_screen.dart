import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import 'add_transaction_screen.dart';

/// Tranzaksiyalar ro'yxati ekrani
class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  TransactionType? _filterType; // Filtrlash uchun

  @override
  void initState() {
    super.initState();
    // Ekran ochilganda ma'lumotlarni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    ref.read(transactionProvider.notifier).loadMonthlyTransactions(currentMonth);
    ref.read(categoryProvider.notifier).loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tranzaksiyalar'),
        actions: [
          // Filtrlash tugmasi
          PopupMenuButton<TransactionType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _filterType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text(AppStrings.all),
              ),
              const PopupMenuItem(
                value: TransactionType.income,
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: AppColors.income, size: 20),
                    SizedBox(width: 8),
                    Text(AppStrings.income),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TransactionType.expense,
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: AppColors.expense, size: 20),
                    SizedBox(width: 8),
                    Text(AppStrings.expense),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: _buildBody(transactionState, categoryState),
      ),
    );
  }

  Widget _buildBody(TransactionState transactionState, CategoryState categoryState) {
    if (transactionState.isLoading || categoryState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactionState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              transactionState.errorMessage!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text(AppStrings.tryAgain),
            ),
          ],
        ),
      );
    }

    // Filtrlash
    var transactions = transactionState.transactions;
    if (_filterType != null) {
      transactions = transactions.where((t) => t.type == _filterType).toList();
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              AppStrings.noData,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Sanalar bo'yicha guruhlash
    final groupedTransactions = _groupTransactionsByDate(transactions);

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final entry = groupedTransactions.entries.elementAt(index);
        final date = entry.key;
        final dayTransactions = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sana sarlavhasi
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingSmall,
              ),
              child: Text(
                DateFormatter.formatRelativeDate(date),
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Shu kundagi tranzaksiyalar
            ...dayTransactions.map((transaction) {
              final category = categoryState.getCategoryById(transaction.categoryId);
              return _buildTransactionCard(transaction, category);
            }).toList(),

            const SizedBox(height: AppDimensions.spaceMedium),
          ],
        );
      },
    );
  }

  /// Tranzaksiya kartasi
  Widget _buildTransactionCard(Transaction transaction, category) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isIncome
              ? AppColors.income.withOpacity(0.2)
              : AppColors.expense.withOpacity(0.2),
          child: Icon(
            category?.getIcon() ?? Icons.category,
            color: category?.getColor() ??
                (transaction.isIncome ? AppColors.income : AppColors.expense),
          ),
        ),
        title: Text(
          category?.name ?? 'Noma\'lum',
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: transaction.note != null
            ? Text(
          transaction.note!,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.formatWithSign(
                transaction.amount,
                transaction.isIncome,
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                color: transaction.isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              DateFormatter.formatDate(transaction.date),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        onTap: () => _showTransactionOptions(transaction),
      ),
    );
  }

  /// Tranzaksiyalarni sanalar bo'yicha guruhlash
  Map<DateTime, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (grouped.containsKey(date)) {
        grouped[date]!.add(transaction);
      } else {
        grouped[date] = [transaction];
      }
    }

    // Sanalarni teskari tartibda saralash (yangilari birinchi)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMap = <DateTime, List<Transaction>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  /// Tranzaksiya variantlarini ko'rsatish (tahrirlash, o'chirish)
  void _showTransactionOptions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text(AppStrings.edit),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text(
                  AppStrings.delete,
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(transaction);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// O'chirishni tasdiqlash
  void _confirmDelete(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('O\'chirishni tasdiqlang'),
          content: const Text('Bu tranzaksiyani o\'chirmoqchimisiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await ref
                    .read(transactionProvider.notifier)
                    .removeTransaction(transaction.id);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tranzaksiya o\'chirildi')),
                  );
                }
              },
              child: const Text(
                AppStrings.delete,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/category_provider.dart';

/// Statistika (Analytics) ekrani
/// Daromad, xarajat, kategoriya bo'yicha grafiklar
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(analyticsProvider.notifier).loadAllAnalytics(_selectedMonth);
    ref.read(categoryProvider.notifier).loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.analytics),
        actions: [
          // Oy tanlash
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectMonth,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: analyticsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tanlangan oy
              _buildMonthHeader(),
              const SizedBox(height: AppDimensions.spaceLarge),

              // Umumiy xulosa
              _buildOverallSummary(analyticsState),
              const SizedBox(height: AppDimensions.spaceLarge),

              // Daromad vs Xarajat grafigi
              _buildIncomeExpenseChart(analyticsState),
              const SizedBox(height: AppDimensions.spaceLarge),

              // Kategoriya bo'yicha xarajat
              if (analyticsState.expenseByCategory != null &&
                  analyticsState.expenseByCategory!.isNotEmpty) ...[
                Text(
                  AppStrings.expenseByCategory,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppDimensions.spaceMedium),
                _buildExpenseByCategoryList(analyticsState, categoryState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Oy sarlavhasi
  Widget _buildMonthHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spaceSmall),
                Text(
                  '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                    _loadData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Umumiy xulosa kartasi
  Widget _buildOverallSummary(AnalyticsState analyticsState) {
    final summary = analyticsState.summary;

    return Card(
      elevation: AppDimensions.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            // Balans
            Text(
              AppStrings.balance,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              CurrencyFormatter.format(summary?.balance ?? 0),
              style: AppTextStyles.amountLarge.copyWith(
                color: (summary?.isNegative ?? false)
                    ? AppColors.expense
                    : AppColors.income,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLarge),

            // Daromad va Xarajat
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    label: AppStrings.income,
                    amount: summary?.totalIncome ?? 0,
                    color: AppColors.income,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: _buildSummaryBox(
                    label: AppStrings.expense,
                    amount: summary?.totalExpense ?? 0,
                    color: AppColors.expense,
                    icon: Icons.trending_down,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconLarge),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTextStyles.h4.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  /// Daromad vs Xarajat grafigi (oddiy progress bar)
  Widget _buildIncomeExpenseChart(AnalyticsState analyticsState) {
    final summary = analyticsState.summary;
    if (summary == null || summary.totalIncome == 0) {
      return const SizedBox.shrink();
    }

    final expensePercentage = summary.expensePercentage;
    final savingsPercentage = summary.savingsPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daromad taqsimoti',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: LinearProgressIndicator(
                value: expensePercentage / 100,
                minHeight: 24,
                backgroundColor: AppColors.income.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.expense),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMedium),

            // Foizlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.expense,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                    Text(
                      'Xarajat: ${expensePercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.income,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                    Text(
                      'Tejash: ${savingsPercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Kategoriya bo'yicha xarajat ro'yxati
  Widget _buildExpenseByCategoryList(
      AnalyticsState analyticsState,
      CategoryState categoryState,
      ) {
    final topCategories = analyticsState.expenseByCategory!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: topCategories.map((entry) {
        final categoryId = entry.key;
        final amount = entry.value;
        final category = categoryState.getCategoryById(categoryId);
        final percentage = analyticsState.getCategoryPercentage(categoryId);

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category?.getColor().withOpacity(0.2) ??
                  AppColors.primary.withOpacity(0.2),
              child: Icon(
                category?.getIcon() ?? Icons.category,
                color: category?.getColor() ?? AppColors.primary,
              ),
            ),
            title: Text(
              category?.name ?? 'Noma\'lum',
              style: AppTextStyles.bodyMedium,
            ),
            subtitle: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                category?.getColor() ?? AppColors.primary,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Oy nomini olish
  String _getMonthName(int month) {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return months[month - 1];
  }

  /// Oy tanlash
  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _loadData();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/transaction_provider.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../analytics/analytics_screen.dart';
import '../budget/budget_screen.dart';
import '../settings/settings_screen.dart';

/// Home Screen - Asosiy ekran
/// Moliyaviy xulosa, so'nggi tranzaksiyalar va tez harakatlar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

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

    // Joriy oy tranzaksiyalarini yuklash
    ref.read(transactionProvider.notifier).loadMonthlyTransactions(currentMonth);

    // Analytics'ni yuklash
    ref.read(analyticsProvider.notifier).loadCurrentMonthAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    // Bottom Navigation uchun ekranlar ro'yxati
    final screens = [
      _buildHomeContent(),
      const TransactionListScreen(),
      const AnalyticsScreen(),
      const BudgetScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Asosiy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tranzaksiyalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistika',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budjet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Sozlamalar',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              floating: true,
              title: const Text(AppStrings.appName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Bildirishnomalar
                  },
                ),
              ],
            ),

            // Moliyaviy xulosa kartasi
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: _buildFinancialSummaryCard(),
              ),
            ),

            // Tez harakatlar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                child: _buildQuickActions(),
              ),
            ),

            // So'nggi tranzaksiyalar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.recentTransactions,
                      style: AppTextStyles.h3,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: const Text(AppStrings.viewAll),
                    ),
                  ],
                ),
              ),
            ),

            // Tranzaksiyalar ro'yxati
            _buildRecentTransactionsList(),
          ],
        ),
      ),
    );
  }

  /// Moliyaviy xulosa kartasi
  Widget _buildFinancialSummaryCard() {
    final analyticsState = ref.watch(analyticsProvider);
    final summary = analyticsState.summary;

    if (analyticsState.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: AppDimensions.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: _buildSummaryItem(
                    label: AppStrings.income,
                    amount: summary?.totalIncome ?? 0,
                    color: AppColors.income,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: _buildSummaryItem(
                    label: AppStrings.expense,
                    amount: summary?.totalExpense ?? 0,
                    color: AppColors.expense,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppDimensions.iconSmall, color: color),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.h4.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  /// Tez harakatlar
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            label: 'Daromad\nqo\'shish',
            icon: Icons.add_circle_outline,
            color: AppColors.income,
            onTap: () {
              // TODO: Daromad qo'shish ekraniga o'tish
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Expanded(
          child: _buildQuickActionButton(
            label: 'Xarajat\nqo\'shish',
            icon: Icons.remove_circle_outline,
            color: AppColors.expense,
            onTap: () {
              // TODO: Xarajat qo'shish ekraniga o'tish
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(icon, size: AppDimensions.iconLarge, color: color),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// So'nggi tranzaksiyalar ro'yxati
  Widget _buildRecentTransactionsList() {
    final transactionState = ref.watch(transactionProvider);

    if (transactionState.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLarge),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (transactionState.transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Text(
              AppStrings.noData,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    // Faqat oxirgi 5 ta tranzaksiyani ko'rsatish
    final recentTransactions = transactionState.transactions.take(5).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final transaction = recentTransactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.isIncome
                  ? AppColors.income.withOpacity(0.2)
                  : AppColors.expense.withOpacity(0.2),
              child: Icon(
                transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: transaction.isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
            title: Text(
              transaction.categoryId, // TODO: Kategoriya nomini ko'rsatish
              style: AppTextStyles.bodyMedium,
            ),
            subtitle: Text(
              DateFormatter.formatRelativeDate(transaction.date),
              style: AppTextStyles.caption,
            ),
            trailing: Text(
              CurrencyFormatter.formatWithSign(
                transaction.amount,
                transaction.isIncome,
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                color: transaction.isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
        childCount: recentTransactions.length,
      ),
    );
  }
}
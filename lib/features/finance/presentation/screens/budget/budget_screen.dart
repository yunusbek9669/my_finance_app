import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/validators.dart';
import '../../../domain/entities/budget.dart';
import '../../providers/budget_provider.dart';

/// Budjet ekrani
/// Budjet belgilash va kuzatish
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetProvider.notifier).loadCurrentMonthBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.budget),
        actions: [
          if (budgetState.hasBudget)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showSetBudgetDialog(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(budgetProvider.notifier).loadCurrentMonthBudget();
        },
        child: budgetState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : budgetState.hasBudget
            ? _buildBudgetContent(budgetState)
            : _buildNoBudget(),
      ),
    );
  }

  /// Budjet mavjud bo'lganda
  Widget _buildBudgetContent(BudgetState budgetState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asosiy budjet kartasi
          _buildBudgetCard(budgetState),
          const SizedBox(height: AppDimensions.spaceLarge),

          // Budjet holati
          _buildBudgetStatus(budgetState),
          const SizedBox(height: AppDimensions.spaceLarge),

          // Maslahatlar
          _buildTips(budgetState),
        ],
      ),
    );
  }

  /// Asosiy budjet kartasi
  Widget _buildBudgetCard(BudgetState budgetState) {
    final percentage = budgetState.percentage.clamp(0.0, 100.0);
    final statusColor = budgetState.isExceeded
        ? AppColors.error
        : budgetState.needsWarning
        ? AppColors.warning
        : AppColors.success;

    return Card(
      elevation: AppDimensions.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sarlavha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.monthlyBudget,
                  style: AppTextStyles.h3,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceLarge),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 20,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLarge),

            // Raqamlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetAmount(
                  label: 'Sarflangan',
                  amount: budgetState.spentAmount,
                  color: AppColors.expense,
                ),
                _buildBudgetAmount(
                  label: 'Qolgan',
                  amount: budgetState.remainingAmount,
                  color: budgetState.isExceeded ? AppColors.error : AppColors.success,
                ),
                _buildBudgetAmount(
                  label: 'Budjet',
                  amount: budgetState.budgetAmount,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetAmount({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Text(
          CurrencyFormatter.formatCompact(amount),
          style: AppTextStyles.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Budjet holati
  Widget _buildBudgetStatus(BudgetState budgetState) {
    IconData icon;
    String message;
    Color color;

    if (budgetState.isExceeded) {
      icon = Icons.warning;
      message = AppStrings.budgetExceeded;
      color = AppColors.error;
    } else if (budgetState.needsWarning) {
      icon = Icons.info;
      message = 'Ehtiyot bo\'ling! Budjetingiz tugashiga oz qoldi.';
      color = AppColors.warning;
    } else {
      icon = Icons.check_circle;
      message = 'Ajoyib! Budjetni yaxshi boshqaryapsiz.';
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconLarge),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  /// Maslahatlar
  Widget _buildTips(BudgetState budgetState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.warning),
                const SizedBox(width: AppDimensions.spaceSmall),
                Text(
                  'Maslahatlar',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            _buildTipItem('Kunlik xarajatlaringizni kuzatib boring'),
            _buildTipItem('Keraksiz xarajatlardan qoching'),
            _buildTipItem('Oylik budjetni realistik belgilang'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.success),
          const SizedBox(width: AppDimensions.spaceSmall),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Budjet yo'q bo'lganda
  Widget _buildNoBudget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 100,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            Text(
              'Budjet belgilanmagan',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              'Oylik budjet belgilab, xarajatlaringizni boshqaring',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            ElevatedButton.icon(
              onPressed: () => _showSetBudgetDialog(),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.setBudget),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Budjet belgilash dialogini ko'rsatish
  void _showSetBudgetDialog() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final budgetController = TextEditingController(
      text: ref.read(budgetProvider).budgetAmount > 0
          ? ref.read(budgetProvider).budgetAmount.toString()
          : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.setBudget),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.amount,
                  hintText: 'Masalan: 5000000',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMedium),
              Text(
                'Bu oylik budjetingiz bo\'ladi',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final amountStr = budgetController.text.trim();
                final validation = Validators.validateBudget(amountStr);

                if (validation != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(validation)),
                  );
                  return;
                }

                final amount = double.parse(amountStr);
                final budget = Budget(
                  id: const Uuid().v4(),
                  amount: amount,
                  month: currentMonth,
                );

                Navigator.pop(context);

                final success = await ref
                    .read(budgetProvider.notifier)
                    .setNewBudget(budget);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budjet belgilandi')),
                  );
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );
  }
}
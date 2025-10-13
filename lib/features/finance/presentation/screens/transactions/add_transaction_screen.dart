import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

/// Tranzaksiya qo'shish ekrani
class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction; // Tahrirlash uchun

  const AddTransactionScreen({
    super.key,
    this.transaction,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Kategoriyalarni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
    });

    // Agar tahrirlash rejimida bo'lsa, ma'lumotlarni to'ldirish
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note ?? '';
      _selectedType = widget.transaction!.type;
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? AppStrings.addTransaction
              : AppStrings.edit,
        ),
      ),
      body: categoryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Turi tanlash (Daromad/Xarajat)
              _buildTypeSelector(),
              const SizedBox(height: AppDimensions.spaceLarge),

              // Summa kiritish
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.amount,
                  hintText: AppStrings.enterAmount,
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: AppDimensions.spaceMedium),

              // Kategoriya tanlash
              _buildCategorySelector(categoryState),
              const SizedBox(height: AppDimensions.spaceMedium),

              // Sana tanlash
              _buildDateSelector(),
              const SizedBox(height: AppDimensions.spaceMedium),

              // Izoh
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: AppStrings.note,
                  hintText: 'Ixtiyoriy',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              // Saqlash tugmasi
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Turi tanlash (Daromad/Xarajat)
  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.income;
                  _selectedCategoryId = null; // Kategoriyani reset qilish
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
                decoration: BoxDecoration(
                  color: _selectedType == TransactionType.income
                      ? AppColors.income
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: _selectedType == TransactionType.income
                          ? Colors.white
                          : AppColors.income,
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                    Text(
                      AppStrings.income,
                      style: TextStyle(
                        color: _selectedType == TransactionType.income
                            ? Colors.white
                            : AppColors.income,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.expense;
                  _selectedCategoryId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMedium,
                ),
                decoration: BoxDecoration(
                  color: _selectedType == TransactionType.expense
                      ? AppColors.expense
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _selectedType == TransactionType.expense
                          ? Colors.white
                          : AppColors.expense,
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                    Text(
                      AppStrings.expense,
                      style: TextStyle(
                        color: _selectedType == TransactionType.expense
                            ? Colors.white
                            : AppColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kategoriya tanlash
  Widget _buildCategorySelector(CategoryState categoryState) {
    final categories = _selectedType == TransactionType.income
        ? categoryState.incomeCategories
        : categoryState.expenseCategories;

    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: AppStrings.category,
        prefixIcon: Icon(Icons.category),
      ),
      hint: const Text(AppStrings.selectCategory),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Row(
            children: [
              Icon(category.getIcon(), size: 20, color: category.getColor()),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: Validators.validateCategory,
    );
  }

  /// Sana tanlash
  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: AppStrings.date,
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormatter.formatDate(_selectedDate),
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }

  /// Sana tanlash dialogini ko'rsatish
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Tranzaksiyani saqlash
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.categoryRequired)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      type: _selectedType,
      date: _selectedDate,
      note: note.isEmpty ? null : note,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
    );

    final success = widget.transaction == null
        ? await ref.read(transactionProvider.notifier).addNewTransaction(transaction)
        : await ref.read(transactionProvider.notifier).updateExistingTransaction(transaction);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction == null
                ? 'Tranzaksiya qo\'shildi'
                : 'Tranzaksiya yangilandi',
          ),
        ),
      );
    } else if (mounted) {
      final errorMessage = ref.read(transactionProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? AppStrings.errorOccurred)),
      );
    }
  }
}
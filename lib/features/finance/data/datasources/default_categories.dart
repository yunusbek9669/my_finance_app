import '../../domain/entities/category.dart';

/// Standart kategoriyalar ro'yxati
/// Ilova birinchi marta ishga tushganda avtomatik yaratiladi
class DefaultCategories {
  /// Xarajat kategoriyalari
  static List<Category> get expenseCategories => [
    Category(
      id: 'exp_food',
      name: 'Ovqat',
      iconName: 'restaurant',
      color: '#FF5722',
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'exp_transport',
      name: 'Transport',
      iconName: 'directions_car',
      color: '#2196F3',
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'exp_shopping',
      name: 'Xarid',
      iconName: 'shopping_cart',
      color: '#9C27B0',
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'exp_home',
      name: 'Uy-joy',
      iconName: 'home',
      color: '#4CAF50',
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'exp_health',
      name: 'Sog\'liq',
      iconName: 'medical_services',
      color: '#F44336',
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'exp_education',
      name: 'Ta\'lim',
      iconName: 'school',
      color: '#FF9800',
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'exp_entertainment',
      name: 'Ko\'ngilochar',
      iconName: 'movie',
      color: '#E91E63',
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'exp_sport',
      name: 'Sport',
      iconName: 'fitness_center',
      color: '#00BCD4',
      type: CategoryType.expense,
      isDefault: true,
    ),
  ];

  /// Daromad kategoriyalari
  static List<Category> get incomeCategories => [
    Category(
      id: 'inc_salary',
      name: 'Maosh',
      iconName: 'account_balance_wallet',
      color: '#4CAF50',
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'inc_business',
      name: 'Biznes',
      iconName: 'payment',
      color: '#2196F3',
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'inc_investment',
      name: 'Investitsiya',
      iconName: 'trending_up',
      color: '#FF9800',
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'inc_gift',
      name: 'Sovg\'a',
      iconName: 'card_giftcard',
      color: '#E91E63',
      type: CategoryType.income,
      isDefault: true,
    ),
  ];

  /// Barcha standart kategoriyalar
  static List<Category> get allCategories => [
    ...expenseCategories,
    ...incomeCategories,
  ];
}
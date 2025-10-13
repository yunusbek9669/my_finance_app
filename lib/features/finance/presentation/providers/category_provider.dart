import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/categories/add_category.dart';
import '../../domain/usecases/categories/get_categories.dart';
import '../../domain/usecases/categories/get_categories_by_type.dart';

/// Category Provider State
class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? errorMessage;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Daromad kategoriyalari
  List<Category> get incomeCategories {
    return categories.where((c) => c.type == CategoryType.income).toList();
  }

  /// Xarajat kategoriyalari
  List<Category> get expenseCategories {
    return categories.where((c) => c.type == CategoryType.expense).toList();
  }

  /// ID bo'yicha kategoriya topish
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Category Provider (StateNotifier)
class CategoryNotifier extends StateNotifier<CategoryState> {
  final GetCategories getCategories;
  final GetCategoriesByType getCategoriesByType;
  final AddCategory addCategory;

  CategoryNotifier({
    required this.getCategories,
    required this.getCategoriesByType,
    required this.addCategory,
  }) : super(CategoryState());

  /// Barcha kategoriyalarni yuklash
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getCategories(NoParams());

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
          (categories) {
        state = state.copyWith(
          categories: categories,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  /// Turi bo'yicha kategoriyalarni yuklash
  Future<void> loadCategoriesByType(CategoryType type) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getCategoriesByType(
      GetCategoriesByTypeParams(type: type),
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
          (categories) {
        state = state.copyWith(
          categories: categories,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }

  /// Yangi kategoriya qo'shish
  Future<bool> addNewCategory(Category category) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await addCategory(
      AddCategoryParams(category: category),
    );

    return result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
          (newCategory) {
        // State'ga yangi kategoriya qo'shish
        final updatedList = [...state.categories, newCategory];
        state = state.copyWith(
          categories: updatedList,
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

/// Provider - DI uchun
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  // TODO: DI - Dependency Injection qo'shiladi
  throw UnimplementedError('DI container setup qilish kerak');
});
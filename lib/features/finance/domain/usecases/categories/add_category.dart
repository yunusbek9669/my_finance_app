import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Yangi kategoriya qo'shish UseCase
/// Foydalanuvchi o'z kategoriyalarini yarata oladi
class AddCategory implements UseCase<Category, AddCategoryParams> {
  final CategoryRepository repository;

  AddCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(AddCategoryParams params) async {
    // Validation - ma'lumotlarni tekshirish
    if (params.category.name.trim().isEmpty) {
      return const Left(ValidationFailure('Kategoriya nomi bo\'sh bo\'lishi mumkin emas'));
    }

    if (params.category.name.length < 2) {
      return const Left(
        ValidationFailure('Kategoriya nomi kamida 2 ta belgidan iborat bo\'lishi kerak'),
      );
    }

    if (params.category.name.length > 50) {
      return const Left(
        ValidationFailure('Kategoriya nomi 50 ta belgidan oshmasligi kerak'),
      );
    }

    // Rang validatsiyasi
    if (!_isValidHexColor(params.category.color)) {
      return const Left(ValidationFailure('Noto\'g\'ri rang formati'));
    }

    // Repository orqali saqlash
    return await repository.addCategory(params.category);
  }

  /// Hex rang formatini tekshirish
  /// Masalan: #FF5252 yoki #f00
  bool _isValidHexColor(String color) {
    final hexColorRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexColorRegex.hasMatch(color);
  }
}

/// Parameters - yangi kategoriya
class AddCategoryParams {
  final Category category;

  AddCategoryParams({required this.category});
}
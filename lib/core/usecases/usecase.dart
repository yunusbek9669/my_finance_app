import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// UseCase - biznes logikani ajratib turish uchun
/// Har bir amal (action) uchun alohida UseCase bo'ladi
///
/// Type - qaytariladigan natija turi
/// Params - kiritma parametrlar turi
///
/// Either<Failure, Type> - Failure yoki Type qaytaradi
/// Left(Failure) - xatolik holati
/// Right(Type) - muvaffaqiyatli holat

abstract class UseCase<Type, Params> {
  /// UseCase'ni chaqirish
  Future<Either<Failure, Type>> call(Params params);
}

/// Parametr kerak bo'lmagan UseCase'lar uchun
class NoParams {
  const NoParams();
}
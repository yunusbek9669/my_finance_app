/// Failure - muvaffaqiyatsizlik (xatolik) klasslar
/// Clean Architecture'da xatolarni boshqarish uchun
/// Exception'larni Failure'larga o'girish kerak

abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Database bilan bog'liq xatoliklar
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Validation (tekshirish) xatoliklari
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Ma'lumot topilmadi xatoligi
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Umumiy xatolik
class GeneralFailure extends Failure {
  const GeneralFailure(super.message);
}

/// Cache (kesh) bilan bog'liq xatoliklar
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
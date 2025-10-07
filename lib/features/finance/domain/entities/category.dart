import 'package:flutter/material.dart';

/// Category - Kategoriya (Ovqat, Transport, Maosh va h.k.)
/// Har bir tranzaksiya biror kategoriyaga tegishli

class Category {
  /// Noyob identifikator
  final String id;

  /// Kategoriya nomi (masalan: "Ovqat", "Transport")
  final String name;

  /// Kategoriya ikonkasi nomi (masalan: "restaurant", "directions_car")
  /// Flutter'ning Icons klasidagi nomlari
  final String iconName;

  /// Kategoriya rangi (hex formatda: "#FF5252")
  final String color;

  /// Kategoriya turi: daromad yoki xarajat uchun
  final CategoryType type;

  /// Standart kategoriyami (o'chirib bo'lmaydigan)
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    required this.type,
    this.isDefault = false,
  });

  /// CopyWith method
  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    String? color,
    CategoryType? type,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// String color'ni Flutter Color'ga o'girish
  Color getColor() {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey; // Xatolik bo'lsa default rang
    }
  }

  /// IconData olish
  IconData getIcon() {
    // Bu yerda icon nomidan IconData yasash kerak
    // Oddiy misol:
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'payment':
        return Icons.payment;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'movie':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Kategoriya turi
enum CategoryType {
  income,   // Daromad kategoriyalari
  expense,  // Xarajat kategoriyalari
}

/// Extension
extension CategoryTypeExtension on CategoryType {
  String toStringValue() {
    switch (this) {
      case CategoryType.income:
        return 'income';
      case CategoryType.expense:
        return 'expense';
    }
  }

  static CategoryType fromString(String value) {
    switch (value) {
      case 'income':
        return CategoryType.income;
      case 'expense':
        return CategoryType.expense;
      default:
        throw Exception('Noma\'lum kategoriya turi: $value');
    }
  }
}
import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';

/// Hive adapter ID: 1
part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String iconName;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final String type; // 'income' yoki 'expense'

  @HiveField(5)
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    required this.type,
    required this.isDefault,
  });

  /// Entity'dan Model'ga o'girish
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconName: category.iconName,
      color: category.color,
      type: category.type.toStringValue(),
      isDefault: category.isDefault,
    );
  }

  /// Model'dan Entity'ga o'girish
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      iconName: iconName,
      color: color,
      type: CategoryTypeExtension.fromString(type),
      isDefault: isDefault,
    );
  }

  /// JSON'dan yaratish
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      color: json['color'] as String,
      type: json['type'] as String,
      isDefault: json['isDefault'] as bool,
    );
  }

  /// JSON'ga o'girish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'color': color,
      'type': type,
      'isDefault': isDefault,
    };
  }
}
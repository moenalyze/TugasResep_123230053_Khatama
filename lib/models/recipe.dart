import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final String? area;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.category,
    this.area,
  });
}
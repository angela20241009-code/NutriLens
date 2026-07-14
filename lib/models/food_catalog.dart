import 'package:nutrilens/models/nutrition_entry.dart';

/// A single food item from the local catalog (USDA + Open Food Facts sourced).
class FoodCatalogItem {
  const FoodCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.dataSource,
    required this.nutritionPer100g,
    this.imageUrl,
    this.imageSource,
    this.sourceId,
    this.defaultServingG,
    this.defaultServingLabel,
    this.tags = const [],
    this.mealSlots = const [],
  });

  final String id;
  final String name;
  final String category;
  final String dataSource;
  final NutritionEntry nutritionPer100g;
  final String? imageUrl;
  final String? imageSource;
  final String? sourceId;
  final double? defaultServingG;
  final String? defaultServingLabel;
  final List<String> tags;
  final List<String> mealSlots;

  factory FoodCatalogItem.fromMap(Map<String, dynamic> map) {
    final nutritionRaw = map['nutritionPer100g'];
    return FoodCatalogItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'other',
      dataSource: map['dataSource'] as String? ?? 'unknown',
      nutritionPer100g: NutritionEntry.fromMap(
        nutritionRaw != null
            ? Map<String, dynamic>.from(nutritionRaw as Map)
            : null,
      ),
      imageUrl: map['imageUrl'] as String?,
      imageSource: map['imageSource'] as String?,
      sourceId: map['sourceId'] as String?,
      defaultServingG: (map['defaultServingG'] as num?)?.toDouble(),
      defaultServingLabel: map['defaultServingLabel'] as String?,
      tags: (map['tags'] as List? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      mealSlots: (map['mealSlots'] as List? ?? const [])
          .map((slot) => slot.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'dataSource': dataSource,
    'nutritionPer100g': nutritionPer100g.toMap(),
    'imageUrl': imageUrl,
    'imageSource': imageSource,
    'sourceId': sourceId,
    'defaultServingG': defaultServingG,
    'defaultServingLabel': defaultServingLabel,
    'tags': tags,
    'mealSlots': mealSlots,
  };
}

class FoodCatalog {
  const FoodCatalog({
    required this.version,
    required this.sources,
    required this.categories,
    required this.foods,
  });

  final String version;
  final List<Map<String, dynamic>> sources;
  final List<Map<String, dynamic>> categories;
  final List<FoodCatalogItem> foods;

  factory FoodCatalog.fromMap(Map<String, dynamic> map) {
    return FoodCatalog(
      version: map['version'] as String? ?? '1.0',
      sources: (map['sources'] as List? ?? const [])
          .map((source) => Map<String, dynamic>.from(source as Map))
          .toList(),
      categories: (map['categories'] as List? ?? const [])
          .map((category) => Map<String, dynamic>.from(category as Map))
          .toList(),
      foods: (map['foods'] as List? ?? const [])
          .map(
            (food) => FoodCatalogItem.fromMap(
              Map<String, dynamic>.from(food as Map),
            ),
          )
          .toList(),
    );
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nutrilens/models/food_catalog.dart';

class FoodCatalogService {
  FoodCatalogService._();

  static final FoodCatalogService instance = FoodCatalogService._();

  FoodCatalog? _catalog;
  Future<FoodCatalog>? _loading;

  Future<FoodCatalog> load() {
    return _loading ??= _loadCatalog();
  }

  Future<FoodCatalog> _loadCatalog() async {
    final raw = await rootBundle.loadString('assets/data/food_catalog.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _catalog = FoodCatalog.fromMap(decoded);
    return _catalog!;
  }

  Future<List<FoodCatalogItem>> search(String query, {int limit = 25}) async {
    final catalog = await load();
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return catalog.foods.take(limit).toList();
    }

    return catalog.foods
        .where((food) {
          if (food.name.toLowerCase().contains(normalized)) {
            return true;
          }
          return food.tags.any((tag) => tag.toLowerCase().contains(normalized));
        })
        .take(limit)
        .toList();
  }

  Future<List<FoodCatalogItem>> foodsForCategory(
    String category, {
    int limit = 50,
  }) async {
    final catalog = await load();
    return catalog.foods
        .where((food) => food.category == category)
        .take(limit)
        .toList();
  }

  Future<List<FoodCatalogItem>> foodsForMealSlot(
    String mealSlot, {
    int limit = 50,
  }) async {
    final catalog = await load();
    return catalog.foods
        .where((food) => food.mealSlots.contains(mealSlot))
        .take(limit)
        .toList();
  }
}

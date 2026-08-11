import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';

/// Free recipe API used when the RapidAPI Tasty quota is unavailable.
///
/// Recipe ids are encoded as negative integers so detail lookups can route
/// back to TheMealDB without colliding with Tasty ids.
class TheMealDbRecipeClient implements TastyRecipeClient {
  TheMealDbRecipeClient({http.Client? httpClient})
    : _client = httpClient ?? http.Client();

  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  final http.Client _client;

  static int encodeId(String idMeal) => -int.parse(idMeal);

  static String decodeId(int id) => '${-id}';

  @override
  Future<TastyRecipeSearchResult> searchRecipes({
    String query = '',
    int from = 0,
    int size = 20,
  }) async {
    final trimmed = query.trim();
    final recipes = trimmed.isEmpty
        ? await _popularRecipes(size: size)
        : await _searchByName(trimmed);

    final start = from.clamp(0, recipes.length);
    final end = (from + size).clamp(0, recipes.length);
    final page = recipes.sublist(start, end);

    return TastyRecipeSearchResult(
      recipes: page,
      totalCount: recipes.length,
    );
  }

  @override
  Future<TastyRecipeDetail> fetchRecipeDetail(int recipeId) async {
    if (recipeId >= 0) {
      throw StateError('TheMealDB client cannot load Tasty recipe $recipeId.');
    }

    final uri = Uri.parse('$_baseUrl/lookup.php?i=${decodeId(recipeId)}');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw StateError(
        'TheMealDB recipe detail request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected TheMealDB detail response shape.');
    }

    final meals = decoded['meals'];
    if (meals is! List || meals.isEmpty || meals.first is! Map<String, dynamic>) {
      throw StateError('TheMealDB recipe was not found.');
    }

    return _detailFromMap(meals.first as Map<String, dynamic>);
  }

  Future<List<TastyRecipe>> _popularRecipes({required int size}) async {
    const categories = [
      'Chicken',
      'Pasta',
      'Seafood',
      'Vegetarian',
      'Beef',
      'Breakfast',
    ];

    final recipes = <TastyRecipe>[];
    final seen = <int>{};

    for (final category in categories) {
      if (recipes.length >= size) {
        break;
      }
      final batch = await _filterByCategory(category);
      for (final recipe in batch) {
        if (seen.add(recipe.id)) {
          recipes.add(recipe);
          if (recipes.length >= size) {
            break;
          }
        }
      }
    }

    return recipes;
  }

  Future<List<TastyRecipe>> _searchByName(String query) async {
    final uri = Uri.parse('$_baseUrl/search.php?s=${Uri.encodeQueryComponent(query)}');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw StateError(
        'TheMealDB search request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected TheMealDB search response shape.');
    }

    return _recipesFromMeals(decoded['meals']);
  }

  Future<List<TastyRecipe>> _filterByCategory(String category) async {
    final uri = Uri.parse(
      '$_baseUrl/filter.php?c=${Uri.encodeQueryComponent(category)}',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw StateError(
        'TheMealDB filter request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected TheMealDB filter response shape.');
    }

    return _recipesFromMeals(decoded['meals']);
  }

  List<TastyRecipe> _recipesFromMeals(Object? meals) {
    if (meals is! List) {
      return const [];
    }

    return meals
        .whereType<Map<String, dynamic>>()
        .map(_recipeFromMap)
        .where((recipe) => recipe.id < 0)
        .toList(growable: false);
  }

  TastyRecipe _recipeFromMap(Map<String, dynamic> map) {
    final idMeal = map['idMeal']?.toString();
    return TastyRecipe(
      id: idMeal == null ? 0 : encodeId(idMeal),
      name: map['strMeal'] as String? ?? 'Untitled recipe',
      thumbnailUrl: map['strMealThumb'] as String?,
    );
  }

  TastyRecipeDetail _detailFromMap(Map<String, dynamic> map) {
    final recipe = _recipeFromMap(map);
    final ingredients = <String>[];

    for (var i = 1; i <= 20; i++) {
      final ingredient = map['strIngredient$i'] as String?;
      final measure = map['strMeasure$i'] as String?;
      final parts = <String>[
        if (measure != null && measure.trim().isNotEmpty) measure.trim(),
        if (ingredient != null && ingredient.trim().isNotEmpty) ingredient.trim(),
      ];
      if (parts.isNotEmpty) {
        ingredients.add(parts.join(' '));
      }
    }

    final instructions = <String>[];
    final rawInstructions = map['strInstructions'] as String?;
    if (rawInstructions != null && rawInstructions.trim().isNotEmpty) {
      for (final line in rawInstructions.split(RegExp(r'\r?\n+'))) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          instructions.add(trimmed);
        }
      }
      if (instructions.isEmpty) {
        instructions.add(rawInstructions.trim());
      }
    }

    return TastyRecipeDetail(
      recipe: recipe.copyWithDescription(
        description: map['strArea'] != null && map['strCategory'] != null
            ? '${map['strCategory']} · ${map['strArea']}'
            : map['strCategory'] as String? ?? map['strArea'] as String?,
      ),
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}

extension on TastyRecipe {
  TastyRecipe copyWithDescription({String? description}) {
    return TastyRecipe(
      id: id,
      name: name,
      thumbnailUrl: thumbnailUrl,
      description: description,
      totalTimeMinutes: totalTimeMinutes,
      numServings: numServings,
      slug: slug,
    );
  }
}

import 'package:http/http.dart' as http;
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';
import 'package:nutrilens/services/themealdb_recipe_client.dart';

/// Tries the RapidAPI Tasty client first, then falls back to TheMealDB.
class ResilientTastyRecipeClient implements TastyRecipeClient {
  ResilientTastyRecipeClient({
    required TastyRecipeClient primary,
    TastyRecipeClient? fallback,
  }) : _primary = primary,
       _fallback = fallback ?? TheMealDbRecipeClient();

  factory ResilientTastyRecipeClient.fromEnvironment({http.Client? httpClient}) {
    return ResilientTastyRecipeClient(
      primary: RapidApiTastyRecipeClient.fromEnvironment(httpClient: httpClient),
      fallback: TheMealDbRecipeClient(httpClient: httpClient),
    );
  }

  final TastyRecipeClient _primary;
  final TastyRecipeClient _fallback;

  @override
  Future<TastyRecipeSearchResult> searchRecipes({
    String query = '',
    int from = 0,
    int size = 20,
  }) async {
    try {
      final result = await _primary.searchRecipes(
        query: query,
        from: from,
        size: size,
      );
      if (result.recipes.isNotEmpty) {
        return result;
      }
    } catch (_) {}

    return _fallback.searchRecipes(query: query, from: from, size: size);
  }

  @override
  Future<TastyRecipeDetail> fetchRecipeDetail(int recipeId) async {
    if (recipeId < 0) {
      return _fallback.fetchRecipeDetail(recipeId);
    }

    try {
      return await _primary.fetchRecipeDetail(recipeId);
    } catch (_) {
      return _fallback.fetchRecipeDetail(recipeId);
    }
  }
}

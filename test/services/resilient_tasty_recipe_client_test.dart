import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/services/resilient_tasty_recipe_client.dart';
import 'package:nutrilens/services/themealdb_recipe_client.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';

void main() {
  group('TheMealDbRecipeClient', () {
    test('maps search results to negative recipe ids', () async {
      final client = TheMealDbRecipeClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/json/v1/1/search.php');
          return http.Response(
            jsonEncode({
              'meals': [
                {
                  'idMeal': '52772',
                  'strMeal': 'Teriyaki Chicken Casserole',
                  'strMealThumb': 'https://example.com/thumb.jpg',
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await client.searchRecipes(query: 'chicken', size: 10);
      expect(result.recipes, hasLength(1));
      expect(result.recipes.single.id, -52772);
      expect(result.recipes.single.name, 'Teriyaki Chicken Casserole');
    });

    test('loads recipe detail with ingredients and instructions', () async {
      final client = TheMealDbRecipeClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/json/v1/1/lookup.php');
          return http.Response(
            jsonEncode({
              'meals': [
                {
                  'idMeal': '52772',
                  'strMeal': 'Teriyaki Chicken Casserole',
                  'strMealThumb': 'https://example.com/thumb.jpg',
                  'strCategory': 'Chicken',
                  'strArea': 'Japanese',
                  'strIngredient1': 'soy sauce',
                  'strMeasure1': '3/4 cup',
                  'strIngredient2': 'water',
                  'strMeasure2': '1/2 cup',
                  'strInstructions': 'Preheat oven to 350F.\r\nBake until done.',
                },
              ],
            }),
            200,
          );
        }),
      );

      final detail = await client.fetchRecipeDetail(-52772);
      expect(detail.recipe.name, 'Teriyaki Chicken Casserole');
      expect(detail.ingredients, ['3/4 cup soy sauce', '1/2 cup water']);
      expect(detail.instructions, ['Preheat oven to 350F.', 'Bake until done.']);
    });
  });

  group('ResilientTastyRecipeClient', () {
    test('falls back when primary search fails', () async {
      final client = ResilientTastyRecipeClient(
        primary: _FailingTastyClient(),
        fallback: TheMealDbRecipeClient(
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'meals': [
                  {
                    'idMeal': '52804',
                    'strMeal': 'Poutine',
                    'strMealThumb': 'https://example.com/poutine.jpg',
                  },
                ],
              }),
              200,
            );
          }),
        ),
      );

      final result = await client.searchRecipes(query: 'poutine');
      expect(result.recipes.single.name, 'Poutine');
    });
  });
}

class _FailingTastyClient implements TastyRecipeClient {
  @override
  Future<TastyRecipeSearchResult> searchRecipes({
    String query = '',
    int from = 0,
    int size = 20,
  }) {
    throw StateError('Tasty API request failed (429): quota exceeded');
  }

  @override
  Future<TastyRecipeDetail> fetchRecipeDetail(int recipeId) {
    throw StateError('Tasty API request failed (429): quota exceeded');
  }
}

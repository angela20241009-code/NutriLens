import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/edamam_meal_plan_client.dart';

void main() {
  test('EdamamMealPlanClient maps user profile into the expected request and parses recipes',
      () async {
    var recipeHits = 0;
    Map<String, dynamic>? requestBody;

    final client = EdamamMealPlanClient(
      appId: 'app_id',
      appKey: 'app_key',
      accountUser: 'angela',
      httpClient: MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/select')) {
          expect(request.method, 'POST');
          expect(path, '/api/meal-planner/v1/app_id/select');
          expect(request.headers['Edamam-Account-User'], 'angela');
          expect(request.headers['Authorization'], startsWith('Basic '));

          requestBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'selection': List.generate(7, (dayIndex) {
                return {
                  'sections': {
                    'Breakfast': {
                      'assigned':
                          'http://www.edamam.com/ontologies/edamam.owl#recipe_breakfast_$dayIndex',
                      '_links': {
                        'self': {
                          'href':
                              'https://api.edamam.com/api/recipes/v2/breakfast_$dayIndex',
                        },
                      },
                    },
                    'Lunch': {
                      'assigned':
                          'http://www.edamam.com/ontologies/edamam.owl#recipe_lunch_$dayIndex',
                      '_links': {
                        'self': {
                          'href':
                              'https://api.edamam.com/api/recipes/v2/lunch_$dayIndex',
                        },
                      },
                    },
                    'Dinner': {
                      'assigned':
                          'http://www.edamam.com/ontologies/edamam.owl#recipe_dinner_$dayIndex',
                      '_links': {
                        'self': {
                          'href':
                              'https://api.edamam.com/api/recipes/v2/dinner_$dayIndex',
                        },
                      },
                    },
                  },
                };
              }),
            }),
            200,
          );
        }

        if (path.contains('/api/recipes/v2/')) {
          recipeHits += 1;
          expect(request.url.queryParameters['app_id'], 'app_id');
          expect(request.url.queryParameters['app_key'], 'app_key');
          expect(request.url.queryParameters['type'], 'public');
          expect(request.headers['Edamam-Account-User'], 'angela');

          return http.Response(
            jsonEncode({
              'recipe': {
                'uri': 'http://www.edamam.com/ontologies/edamam.owl#recipe_123',
                'label': 'Heart-Shaped Ravioli',
                'image':
                    'https://edamam-product-images.s3.amazonaws.com/web-img/fd9/fd93fa0dca2677288697aa9f5c6c226c.jpg',
                'source': 'Allrecipes',
                'url': 'https://www.allrecipes.com/recipe/269594/homemade-ravioli',
                'totalNutrients': {
                  'ENERC_KCAL': {'quantity': 2055.433375},
                  'PROCNT': {'quantity': 104.724909375},
                  'CHOCDF': {'quantity': 214.2661415625},
                  'FAT': {'quantity': 83.269765625},
                },
              },
            }),
            200,
          );
        }

        return http.Response('Not found', 404);
      }),
    );

    final profile = UserProfile.demoAngela(
      userId: 'uid_123',
      now: DateTime(2026, 4, 14),
    ).copyWith(
      dietaryProfile: const DietaryProfile(
        allergens: ['dairy free'],
        restrictions: ['gluten free'],
        preferences: ['vegetarian'],
      ),
    );

    final plan = await client.fetchWeeklyPlan(
      profile: profile,
      startDate: DateTime(2026, 4, 14),
    );

    expect(requestBody, isNotNull);
    expect(requestBody!['size'], 7);

    final requestPlan = requestBody!['plan'] as Map<String, dynamic>;
    final fit = requestPlan['fit'] as Map<String, dynamic>;
    expect((fit['ENERC_KCAL'] as Map)['min'], 2880);
    expect((fit['ENERC_KCAL'] as Map)['max'], 3360);

    final accept = requestPlan['accept'] as Map<String, dynamic>;
    final all = accept['all'] as List<dynamic>;
    expect(all.single['health'], containsAll(['dairy-free', 'gluten-free', 'vegetarian']));

    expect(plan.days, hasLength(7));
    expect(plan.days.first.meals, hasLength(3));
    expect(plan.days.first.meals.first.recipe.title, 'Heart-Shaped Ravioli');
    expect(plan.days.first.totals.caloriesKcal, 6165);
    expect(recipeHits, 21);
  });
}

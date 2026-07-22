import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/tasty_recipe.dart';

void main() {
  test('TastyRecipe.fromMap parses list response fields', () {
    final recipe = TastyRecipe.fromMap({
      'id': 42,
      'name': 'Garlic Butter Chicken',
      'thumbnail_url': 'https://example.com/chicken.jpg',
      'total_time_minutes': 35,
      'num_servings': 4,
      'slug': 'garlic-butter-chicken',
    });

    expect(recipe.id, 42);
    expect(recipe.name, 'Garlic Butter Chicken');
    expect(recipe.thumbnailUrl, 'https://example.com/chicken.jpg');
    expect(recipe.totalTimeMinutes, 35);
    expect(recipe.numServings, 4);
    expect(recipe.slug, 'garlic-butter-chicken');
  });

  test('TastyRecipeDetail.fromMap parses ingredients and instructions', () {
    final detail = TastyRecipeDetail.fromMap({
      'id': 7,
      'name': 'Garlic Butter Chicken',
      'description': 'Quick skillet chicken.',
      'sections': [
        {
          'components': [
            {'raw_text': '2 chicken breasts'},
            {'raw_text': '2 tbsp butter'},
          ],
        },
      ],
      'instructions': [
        {'display_text': 'Season the chicken.'},
        {'display_text': 'Cook until golden.'},
      ],
    });

    expect(detail.recipe.name, 'Garlic Butter Chicken');
    expect(detail.ingredients, ['2 chicken breasts', '2 tbsp butter']);
    expect(detail.instructions, ['Season the chicken.', 'Cook until golden.']);
  });
}

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
}

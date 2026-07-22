class TastyRecipe {
  const TastyRecipe({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.description,
    this.totalTimeMinutes,
    this.numServings,
    this.slug,
  });

  final int id;
  final String name;
  final String? thumbnailUrl;
  final String? description;
  final int? totalTimeMinutes;
  final int? numServings;
  final String? slug;

  factory TastyRecipe.fromMap(Map<String, dynamic> map) {
    return TastyRecipe(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? 'Untitled recipe',
      thumbnailUrl: map['thumbnail_url'] as String?,
      description: map['description'] as String?,
      totalTimeMinutes: map['total_time_minutes'] as int?,
      numServings: map['num_servings'] as int?,
      slug: map['slug'] as String?,
    );
  }
}

class TastyRecipeSearchResult {
  const TastyRecipeSearchResult({
    required this.recipes,
    required this.totalCount,
  });

  final List<TastyRecipe> recipes;
  final int totalCount;
}

class TastyRecipeDetail {
  const TastyRecipeDetail({
    required this.recipe,
    required this.ingredients,
    required this.instructions,
  });

  final TastyRecipe recipe;
  final List<String> ingredients;
  final List<String> instructions;

  factory TastyRecipeDetail.fromMap(Map<String, dynamic> map) {
    final recipe = TastyRecipe.fromMap(map);
    final ingredients = <String>[];
    final sections = map['sections'];
    if (sections is List) {
      for (final section in sections) {
        if (section is! Map<String, dynamic>) {
          continue;
        }
        final components = section['components'];
        if (components is! List) {
          continue;
        }
        for (final component in components) {
          if (component is! Map<String, dynamic>) {
            continue;
          }
          final rawText = component['raw_text'] as String?;
          if (rawText != null && rawText.trim().isNotEmpty) {
            ingredients.add(rawText.trim());
            continue;
          }
          final ingredient = component['ingredient'];
          final ingredientName = ingredient is Map<String, dynamic>
              ? ingredient['name'] as String?
              : null;
          if (ingredientName != null && ingredientName.trim().isNotEmpty) {
            ingredients.add(ingredientName.trim());
          }
        }
      }
    }

    final instructions = <String>[];
    final instructionItems = map['instructions'];
    if (instructionItems is List) {
      for (final item in instructionItems) {
        if (item is Map<String, dynamic>) {
          final text = item['display_text'] as String?;
          if (text != null && text.trim().isNotEmpty) {
            instructions.add(text.trim());
          }
        } else if (item is String && item.trim().isNotEmpty) {
          instructions.add(item.trim());
        }
      }
    }

    return TastyRecipeDetail(
      recipe: recipe,
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}

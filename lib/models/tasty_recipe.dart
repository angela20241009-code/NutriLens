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

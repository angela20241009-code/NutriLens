import 'package:flutter/material.dart';
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';
import 'package:nutrilens/theme/app_colors.dart';

Future<void> showRecipeDetailSheet({
  required BuildContext context,
  required TastyRecipeClient client,
  required TastyRecipe recipe,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardDark,
    showDragHandle: true,
    builder: (context) {
      return _RecipeDetailSheet(client: client, recipe: recipe);
    },
  );
}

class _RecipeDetailSheet extends StatefulWidget {
  const _RecipeDetailSheet({
    required this.client,
    required this.recipe,
  });

  final TastyRecipeClient client;
  final TastyRecipe recipe;

  @override
  State<_RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<_RecipeDetailSheet> {
  late Future<TastyRecipeDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.client.fetchRecipeDetail(widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
        child: FutureBuilder<TastyRecipeDetail>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 280,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Unable to load recipe details',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _detailFuture = widget.client.fetchRecipeDetail(
                            widget.recipe.id,
                          );
                        });
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }

            final detail = snapshot.data!;
            final recipe = detail.recipe;
            final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: ListView(
                shrinkWrap: true,
                children: [
                    if (recipe.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            recipe.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.lime.withValues(alpha: 0.08),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: AppColors.lime,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (recipe.totalTimeMinutes != null)
                          _MetaChip(
                            icon: Icons.schedule_rounded,
                            label: '${recipe.totalTimeMinutes} min',
                          ),
                        if (recipe.numServings != null)
                          _MetaChip(
                            icon: Icons.people_outline_rounded,
                            label: '${recipe.numServings} servings',
                          ),
                      ],
                    ),
                    if (recipe.description?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      Text(
                        recipe.description!.trim(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (detail.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      for (final ingredient in detail.ingredients)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  '),
                              Expanded(child: Text(ingredient)),
                            ],
                          ),
                        ),
                    ],
                    if (detail.instructions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < detail.instructions.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.lime.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: AppColors.lime,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(detail.instructions[i]),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              );
          },
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDarker,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.lime),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

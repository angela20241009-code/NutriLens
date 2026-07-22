import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutrilens/app/tasty_recipe_scope.dart';
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _loading = true;
  String? _error;
  List<TastyRecipe> _recipes = const [];
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search(query: ''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  TastyRecipeClient _client(BuildContext context) {
    return TastyRecipeScope.maybeOf(context)?.client ??
        RapidApiTastyRecipeClient.fromEnvironment();
  }

  Future<void> _search({required String query}) async {
    setState(() {
      _loading = true;
      _error = null;
      _activeQuery = query.trim();
    });

    try {
      final result = await _client(context).searchRecipes(
        query: query,
        size: 24,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _recipes = result.recipes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _recipes = const [];
        _loading = false;
        _error = '$error';
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query: value);
    });
  }

  Future<void> _openRecipe(TastyRecipe recipe) async {
    final slug = recipe.slug;
    if (slug == null || slug.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe link is unavailable.')),
      );
      return;
    }

    final uri = Uri.parse('https://tasty.co/recipe/$slug');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open recipe.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find dishes',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search Tasty recipes for meal inspiration.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _searchController,
                      onSubmitted: (value) => _search(query: value),
                      onChanged: (value) {
                        setState(() {});
                        _onQueryChanged(value);
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search chicken, pasta, salad...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _search(query: '');
                                },
                              ),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppColors.lime.withValues(alpha: 0.35),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.lime,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_activeQuery.isNotEmpty)
                      Text(
                        'Results for "$_activeQuery"',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    else
                      Text(
                        'Popular dishes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Unable to load dishes',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _search(query: _searchController.text),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_recipes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No dishes found. Try another search.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = _recipes[index];
                      return _DishCard(
                        recipe: recipe,
                        onTap: () => _openRecipe(recipe),
                      );
                    },
                    childCount: _recipes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.recipe, required this.onTap});

  final TastyRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.lime.withValues(alpha: 0.08),
                child: recipe.thumbnailUrl == null
                    ? const Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.lime,
                        size: 36,
                      )
                    : Image.network(
                        recipe.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.lime,
                          size: 36,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (recipe.totalTimeMinutes != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${recipe.totalTimeMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

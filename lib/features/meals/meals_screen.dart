import 'package:flutter/material.dart';
import 'package:nutrilens/app/meals_search_scope.dart';
import 'package:nutrilens/app/tasty_recipe_scope.dart';
import 'package:nutrilens/features/meals/widgets/recipe_detail_sheet.dart';
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';
import 'package:nutrilens/theme/app_colors.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _loading = true;
  bool _hasSearched = false;
  String? _error;
  List<TastyRecipe> _recipes = const [];
  String _activeQuery = '';
  int _lastSearchGeneration = 0;
  MealsSearchController? _mealsSearchController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search(query: ''));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = MealsSearchScope.maybeOf(context);
    if (controller == _mealsSearchController) {
      return;
    }
    _mealsSearchController?.removeListener(_handleExternalSearchRequest);
    _mealsSearchController = controller;
    _mealsSearchController?.addListener(_handleExternalSearchRequest);
    _handleExternalSearchRequest();
  }

  void _handleExternalSearchRequest() {
    final controller = _mealsSearchController;
    if (controller == null ||
        controller.generation == _lastSearchGeneration ||
        controller.query.isEmpty) {
      return;
    }

    _lastSearchGeneration = controller.generation;
    _searchController.text = controller.query;
    _search(query: controller.query);
  }

  @override
  void dispose() {
    _mealsSearchController?.removeListener(_handleExternalSearchRequest);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  TastyRecipeClient _client(BuildContext context) {
    return TastyRecipeScope.maybeOf(context)?.client ??
        RapidApiTastyRecipeClient.fromEnvironment();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _search({required String query}) async {
    _dismissKeyboard();
    setState(() {
      _loading = true;
      _error = null;
      _activeQuery = query.trim();
      _hasSearched = true;
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

  Future<void> _openRecipe(TastyRecipe recipe) async {
    _dismissKeyboard();
    if (!mounted) {
      return;
    }

    await showRecipeDetailSheet(
      context: context,
      client: _client(context),
      recipe: recipe,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _search(query: '');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        'Search recipes and view ingredients and steps in the app.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSubmitted: (value) => _search(query: value),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search chicken, pasta, salad...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: _clearSearch,
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
                        onChanged: (_) => setState(() {}),
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _hasSearched
                            ? 'No dishes found. Try another search.'
                            : 'Enter a dish name and tap Search on your keyboard.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
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

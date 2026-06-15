import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/theme/app_colors.dart';

enum FavoriteMealSheetResult { logged, edit }

class FavoriteMealSheet extends StatefulWidget {
  const FavoriteMealSheet({super.key});

  static Future<FavoriteMealSheetResult?> show(BuildContext context) {
    return showModalBottomSheet<FavoriteMealSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const FavoriteMealSheet(),
    );
  }

  @override
  State<FavoriteMealSheet> createState() => _FavoriteMealSheetState();
}

class _FavoriteMealSheetState extends State<FavoriteMealSheet> {
  static const _starterFavorites = [
    _FavoriteMeal(
      name: 'Berry yogurt bowl',
      imagePath: 'assets/images/meal_capture_yogurt.png',
      nutrition: NutritionEntry(
        caloriesKcal: 480,
        proteinG: 28,
        carbsG: 58,
        fatsG: 14,
      ),
    ),
    _FavoriteMeal(
      name: 'Salmon bowl',
      imagePath: 'assets/images/meal_capture_salmon.png',
      nutrition: NutritionEntry(
        caloriesKcal: 520,
        proteinG: 34,
        carbsG: 48,
        fatsG: 16,
      ),
    ),
    _FavoriteMeal(
      name: 'Chicken bowl',
      imagePath: 'assets/images/meal_capture_chicken.png',
      nutrition: NutritionEntry(
        caloriesKcal: 480,
        proteinG: 42,
        carbsG: 38,
        fatsG: 12,
      ),
    ),
  ];

  Future<UserProfile?>? _profileFuture;
  UserProfile? _profile;
  int _selectedIndex = 1;
  int _servings = 1;
  bool _isSaving = false;
  String? _error;

  List<_FavoriteMeal> get _favorites {
    final profileFavorites = _profile?.favoriteMeals ?? const [];
    if (profileFavorites.isEmpty) {
      return _starterFavorites;
    }

    return profileFavorites
        .map(
          (favorite) => _FavoriteMeal(
            name: favorite.name,
            imagePath: favorite.imagePath ?? _fallbackImageFor(favorite.name),
            nutrition: favorite.nutrition,
          ),
        )
        .toList(growable: false);
  }

  _FavoriteMeal get _selectedFavorite {
    final favorites = _favorites;
    final safeIndex = _selectedIndex.clamp(0, favorites.length - 1);
    return favorites[safeIndex];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    _profileFuture ??= scope.repository.getProfile(scope.uid);
  }

  Future<void> _logFavorite() async {
    if (_isSaving || _profile == null) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final scope = UserScope.of(context);
    final favorite = _selectedFavorite;
    final meal = Meal(
      name: favorite.name,
      nutrition: favorite.nutrition.scaledBy(_servings),
      source: MealSource.manual,
      loggedAt: DateTime.now().toUtc(),
    );

    try {
      await scope.repository.logMeal(scope.uid, meal, _profile!.timezone);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${favorite.name} logged')));
      Navigator.of(context).pop(FavoriteMealSheetResult.logged);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to log favorite: $error';
        _isSaving = false;
      });
    }
  }

  void _editBeforeLogging() {
    Navigator.of(context).pop(FavoriteMealSheetResult.edit);
  }

  void _changeServings(int delta) {
    setState(() {
      _servings = (_servings + delta).clamp(1, 9);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: FutureBuilder<UserProfile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              _profile = snapshot.data;
              if (_selectedIndex >= _favorites.length) {
                _selectedIndex = _favorites.length - 1;
              }
            }

            final isLoadingProfile =
                snapshot.connectionState != ConnectionState.done;
            final profileError =
                !isLoadingProfile &&
                    (snapshot.hasError || snapshot.data == null)
                ? 'Unable to load your profile. Try again in a moment.'
                : null;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 58,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.fitnessWhite.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Log favorite',
                          style: TextStyle(
                            color: AppColors.fitnessWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.fitnessWhite.withValues(
                            alpha: 0.08,
                          ),
                          foregroundColor: AppColors.fitnessWhite,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 236,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _favorites.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final favorite = _favorites[index];
                        return _FavoriteMealCard(
                          favorite: favorite,
                          selected: index == _selectedIndex,
                          onTap: () => setState(() => _selectedIndex = index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FavoriteDetailsPanel(
                    favorite: _selectedFavorite,
                    servings: _servings,
                    onDecrement: _servings == 1
                        ? null
                        : () => _changeServings(-1),
                    onIncrement: _servings == 9
                        ? null
                        : () => _changeServings(1),
                  ),
                  if (profileError != null || _error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error ?? profileError!,
                      style: const TextStyle(
                        color: AppColors.fitnessPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed:
                        isLoadingProfile || profileError != null || _isSaving
                        ? null
                        : _logFavorite,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.fitnessGreen,
                      foregroundColor: AppColors.fitnessBlack,
                      disabledBackgroundColor: AppColors.fitnessGreen
                          .withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoadingProfile || _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.fitnessBlack,
                            ),
                          )
                        : const Text(
                            'Log favorite',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                  TextButton(
                    onPressed: _isSaving ? null : _editBeforeLogging,
                    child: const Text(
                      'Edit before logging',
                      style: TextStyle(
                        color: AppColors.fitnessWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.fitnessPurple,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Saved to profile',
                        style: TextStyle(
                          color: AppColors.fitnessPurple,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String _fallbackImageFor(String name) {
  final lowerName = name.toLowerCase();
  if (lowerName.contains('yogurt') || lowerName.contains('berry')) {
    return 'assets/images/meal_capture_yogurt.png';
  }
  if (lowerName.contains('chicken')) {
    return 'assets/images/meal_capture_chicken.png';
  }
  return 'assets/images/meal_capture_salmon.png';
}

class _FavoriteMealCard extends StatelessWidget {
  const _FavoriteMealCard({
    required this.favorite,
    required this.selected,
    required this.onTap,
  });

  final _FavoriteMeal favorite;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 138,
        decoration: BoxDecoration(
          color: AppColors.fitnessBlack,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.fitnessPurple
                : AppColors.fitnessWhite.withValues(alpha: 0.16),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(favorite.imagePath, fit: BoxFit.cover),
                ),
                if (selected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.fitnessPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.fitnessWhite,
                        size: 19,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text(
                favorite.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.fitnessWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${favorite.nutrition.caloriesKcal} kcal',
                style: TextStyle(
                  color: selected
                      ? AppColors.fitnessPurple
                      : AppColors.fitnessWhite.withValues(alpha: 0.55),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteDetailsPanel extends StatelessWidget {
  const _FavoriteDetailsPanel({
    required this.favorite,
    required this.servings,
    required this.onDecrement,
    required this.onIncrement,
  });

  final _FavoriteMeal favorite;
  final int servings;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final nutrition = favorite.nutrition.scaledBy(servings);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fitnessBlack,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.fitnessWhite.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  favorite.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.fitnessWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _ServingStepper(
                servings: servings,
                onDecrement: onDecrement,
                onIncrement: onIncrement,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NutritionTile(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: AppColors.fitnessWhite,
                  label: 'kcal',
                  value: '${nutrition.caloriesKcal}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutritionTile(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppColors.fitnessPurple,
                  label: 'Protein',
                  value: '${nutrition.proteinG}g',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutritionTile(
                  icon: Icons.eco_outlined,
                  iconColor: AppColors.fitnessGreen,
                  label: 'Carbs',
                  value: '${nutrition.carbsG}g',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutritionTile(
                  icon: Icons.water_drop_outlined,
                  iconColor: AppColors.fitnessGreen,
                  label: 'Fats',
                  value: '${nutrition.fatsG}g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServingStepper extends StatelessWidget {
  const _ServingStepper({
    required this.servings,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int servings;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.fitnessWhite.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded),
            color: AppColors.fitnessWhite,
            disabledColor: AppColors.fitnessWhite.withValues(alpha: 0.28),
          ),
          Text(
            '$servings serving',
            style: const TextStyle(
              color: AppColors.fitnessWhite,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded),
            color: AppColors.fitnessWhite,
          ),
        ],
      ),
    );
  }
}

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.fitnessWhite.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.fitnessWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.fitnessWhite,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.fitnessWhite,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteMeal {
  const _FavoriteMeal({
    required this.name,
    required this.imagePath,
    required this.nutrition,
  });

  final String name;
  final String imagePath;
  final NutritionEntry nutrition;
}

extension on NutritionEntry {
  NutritionEntry scaledBy(int servings) {
    return NutritionEntry(
      caloriesKcal: caloriesKcal * servings,
      proteinG: proteinG * servings,
      carbsG: carbsG * servings,
      fatsG: fatsG * servings,
    );
  }
}

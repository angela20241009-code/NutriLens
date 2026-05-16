class MacroProgress {
  const MacroProgress({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
  });

  final String label;
  final int current;
  final int target;
  final String unit;

  double get progress => current / target;
}

class MealPlanItem {
  const MealPlanItem({
    required this.mealType,
    required this.name,
    required this.calories,
    required this.protein,
    required this.imageAsset,
    this.logged = false,
  });

  final String mealType;
  final String name;
  final int calories;
  final int protein;
  final String imageAsset;
  final bool logged;
}

class MockHomeData {
  static const greeting = 'Good Morning';
  static const userName = 'Angela';
  static const programName = 'Lincoln High Tennis Program';
  static const programBadge = 'FREE';

  static const caloriesCurrent = 2840;
  static const caloriesTarget = 3200;
  static const sport = 'Tennis';

  static const macros = [
    MacroProgress(label: 'PROTEIN', current: 142, target: 180, unit: 'g'),
    MacroProgress(label: 'CARBS', current: 385, target: 440, unit: 'g'),
    MacroProgress(label: 'FATS', current: 72, target: 90, unit: 'g'),
  ];

  static const sessionTitle = 'Serve & Rally Drills';
  static const sessionSubtitle = 'Today · 4:30 PM · Eat carbs in 2h';

  static const meals = [
    MealPlanItem(
      mealType: 'BREAKFAST',
      name: 'Power Oats Bowl',
      calories: 620,
      protein: 32,
      imageAsset: 'assets/images/meal_oats.png',
      logged: true,
    ),
    MealPlanItem(
      mealType: 'LUNCH',
      name: 'Chicken Power Bowl',
      calories: 780,
      protein: 48,
      imageAsset: 'assets/images/meal_chicken.png',
      logged: true,
    ),
  ];

  static const hydrationCurrent = 2.4;
  static const hydrationTarget = 3.5;
}

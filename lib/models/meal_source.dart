/// Source of a meal entry — how it was created.
enum MealSource {
  manual('manual'),
  scan('scan'),
  mealPlan('mealPlan');

  const MealSource(this.firestoreValue);
  final String firestoreValue;

  static MealSource fromFirestore(String? value) {
    return MealSource.values.firstWhere(
      (e) => e.firestoreValue == value,
      orElse: () => MealSource.manual,
    );
  }
}

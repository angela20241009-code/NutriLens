import 'package:nutrilens/models/meal_analysis_result.dart';

/// Analyzes meal photos and returns estimated nutrition data.
abstract class MealAnalysisClient {
  Future<MealAnalysisResult> analyzeMealPhoto({
    required List<int> imageBytes,
    required String mimeType,
  });
}

class MealAnalysisException implements Exception {
  MealAnalysisException(this.message);

  final String message;

  @override
  String toString() => message;
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/meal_plan_client.dart';

class OpenAiMealPlanClient implements MealPlanClient {
  OpenAiMealPlanClient({
    required String apiKey,
    http.Client? httpClient,
    this.model = 'gpt-4o-mini',
  }) : _apiKey = apiKey,
       _client = httpClient ?? http.Client();

  factory OpenAiMealPlanClient.fromEnvironment({http.Client? httpClient}) {
    final apiKey = (dotenv.get('OPENAI_API_KEY', fallback: '')).trim();

    assert(() {
      debugPrint('OpenAI meal plan env loaded: apiKey=${apiKey.isNotEmpty}');
      return true;
    }());

    return OpenAiMealPlanClient(apiKey: apiKey, httpClient: httpClient);
  }

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  final String _apiKey;
  final http.Client _client;
  final String model;

  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  }) async {
    final normalizedStart = DateUtils.dateOnly(startDate);
    final content = await _completeJson(
      systemPrompt: _weeklySystemPrompt,
      userPrompt: _weeklyUserPrompt(profile, normalizedStart),
    );
    return _parseWeeklyPlan(content, normalizedStart);
  }

  @override
  Future<MealPlanMeal> regenerateMeal({
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) async {
    final normalizedDate = DateUtils.dateOnly(date);
    final content = await _completeJson(
      systemPrompt: _singleMealSystemPrompt,
      userPrompt: _singleMealUserPrompt(profile, normalizedDate, slot),
    );
    return _parseSingleMeal(content, slot);
  }

  Future<String> _completeJson({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError(
        'OpenAI API key is missing. Add OPENAI_API_KEY to assets/.env.',
      );
    }

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      final body = response.body.trim();
      throw StateError(
        body.isEmpty
            ? 'OpenAI meal plan request failed (${response.statusCode}).'
            : 'OpenAI meal plan request failed: $body',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (((decoded['choices'] as List?)?.first as Map?)?['message']
                as Map?)?['content']
            as String?;

    if (content == null || content.trim().isEmpty) {
      throw StateError('OpenAI returned an empty meal plan.');
    }

    return content.trim();
  }

  MealPlanWeek _parseWeeklyPlan(String content, DateTime startDate) {
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final daysRaw = parsed['days'];
    if (daysRaw is! List || daysRaw.length != 7) {
      throw StateError('OpenAI meal plan must include exactly 7 days.');
    }

    final days = <MealPlanDay>[];
    for (var i = 0; i < 7; i++) {
      final dayRaw = daysRaw[i];
      if (dayRaw is! Map<String, dynamic>) {
        throw StateError('Invalid meal plan day at index $i.');
      }

      final mealsRaw = dayRaw['meals'];
      if (mealsRaw is! List || mealsRaw.isEmpty) {
        throw StateError('Each day must include meals.');
      }

      final meals = mealsRaw
          .whereType<Map<String, dynamic>>()
          .map(_parseMeal)
          .toList(growable: false);

      if (meals.length < 3) {
        throw StateError('Each day must include breakfast, lunch, and dinner.');
      }

      days.add(
        MealPlanDay(
          date: startDate.add(Duration(days: i)),
          meals: meals,
        ),
      );
    }

    return MealPlanWeek(generatedAt: DateTime.now().toUtc(), days: days);
  }

  MealPlanMeal _parseSingleMeal(String content, MealSlot slot) {
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final mealRaw = parsed['meal'];
    if (mealRaw is! Map<String, dynamic>) {
      throw StateError('OpenAI did not return a meal object.');
    }
    return _parseMeal(mealRaw, fallbackSlot: slot);
  }

  MealPlanMeal _parseMeal(
    Map<String, dynamic> mealRaw, {
    MealSlot? fallbackSlot,
  }) {
    final slotName = mealRaw['slot'] as String? ?? fallbackSlot?.name ?? 'breakfast';
    final slot = _slotFromName(slotName, fallback: fallbackSlot ?? MealSlot.breakfast);
    final title = (mealRaw['title'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      throw StateError('Meal plan meal is missing a title.');
    }

    final calories = _readNumber(mealRaw['calories']);
    final proteinG = _readInt(mealRaw['proteinG']);
    final carbsG = _readInt(mealRaw['carbsG']);
    final fatsG = _readInt(mealRaw['fatsG']);

    return MealPlanMeal(
      slot: slot,
      timeLabel: (mealRaw['timeLabel'] as String?)?.trim() ?? slot.label,
      badgeLabel: slot.label.toUpperCase(),
      recipe: MealPlanRecipe(
        recipeId: '${slot.name}-${title.hashCode}',
        title: title,
        imageUrl: null,
        sourceName: 'NutriLens',
        sourceUrl: '',
        calories: calories,
        nutrition: NutritionEntry(
          caloriesKcal: calories.round(),
          proteinG: proteinG,
          carbsG: carbsG,
          fatsG: fatsG,
        ),
      ),
    );
  }

  static MealSlot _slotFromName(String value, {required MealSlot fallback}) {
    return switch (value.toLowerCase()) {
      'breakfast' => MealSlot.breakfast,
      'lunch' => MealSlot.lunch,
      'dinner' => MealSlot.dinner,
      _ => fallback,
    };
  }

  static int _readInt(Object? value) {
    if (value is num) {
      return value.round();
    }
    return int.tryParse('$value') ?? 0;
  }

  static double _readNumber(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }

  static const _weeklySystemPrompt =
      'You are a sports nutrition meal planner. Create realistic athlete-friendly meals '
      'that respect dietary restrictions and daily macro targets.\n\n'
      'Respond with ONLY valid JSON in this exact shape:\n'
      '{\n'
      '  "days": [\n'
      '    {\n'
      '      "meals": [\n'
      '        {\n'
      '          "slot": "breakfast",\n'
      '          "title": "string",\n'
      '          "timeLabel": "8:00 AM",\n'
      '          "calories": 500,\n'
      '          "proteinG": 30,\n'
      '          "carbsG": 55,\n'
      '          "fatsG": 15\n'
      '        }\n'
      '      ]\n'
      '    }\n'
      '  ]\n'
      '}\n\n'
      'Return exactly 7 day objects. Each day must include breakfast, lunch, and dinner. '
      'Use non-negative integers for macros. Keep titles concise.';

  static const _singleMealSystemPrompt =
      'You are a sports nutrition meal planner. Respond with ONLY valid JSON:\n'
      '{\n'
      '  "meal": {\n'
      '    "slot": "breakfast|lunch|dinner",\n'
      '    "title": "string",\n'
      '    "timeLabel": "8:00 AM",\n'
      '    "calories": 500,\n'
      '    "proteinG": 30,\n'
      '    "carbsG": 55,\n'
      '    "fatsG": 15\n'
      '  }\n'
      '}';

  static String _weeklyUserPrompt(UserProfile profile, DateTime startDate) {
    return _profileContext(profile) +
        '\nCreate a 7-day meal plan starting on ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}.';
  }

  static String _singleMealUserPrompt(
    UserProfile profile,
    DateTime date,
    MealSlot slot,
  ) {
    return _profileContext(profile) +
        '\nCreate one ${slot.name} meal for ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}.';
  }

  static String _profileContext(UserProfile profile) {
    final dietary = profile.dietaryProfile;
    final targets = profile.dailyTargets;
    final buffer = StringBuffer()
      ..writeln('Athlete profile:')
      ..writeln('- Sport: ${profile.primarySportName}')
      ..writeln('- Daily calories target: ${targets.caloriesKcal} kcal')
      ..writeln('- Daily protein target: ${targets.proteinG} g')
      ..writeln('- Daily carbs target: ${targets.carbsG} g')
      ..writeln('- Daily fats target: ${targets.fatsG} g')
      ..writeln('- Food preferences: ${dietary.preferences.join(', ')}')
      ..writeln('- Allergens to avoid: ${dietary.allergens.join(', ')}')
      ..writeln('- Dietary restrictions: ${dietary.restrictions.join(', ')}');
    return buffer.toString();
  }
}

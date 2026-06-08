import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/meal_plan_client.dart';

class EdamamMealPlanClient implements MealPlanClient {
  EdamamMealPlanClient({
    required String appId,
    required String appKey,
    required String accountUser,
    http.Client? httpClient,
  })  : _appId = appId,
        _appKey = appKey,
        _accountUser = accountUser,
        _client = httpClient ?? http.Client();

  factory EdamamMealPlanClient.fromEnvironment({http.Client? httpClient}) {
    return EdamamMealPlanClient(
      appId: dotenv.env['EDAMAM_APP_ID'] ?? '',
      appKey: dotenv.env['EDAMAM_APP_KEY'] ?? '',
      accountUser: dotenv.env['EDAMAM_ACCOUNT_USER'] ?? '',
      httpClient: httpClient,
    );
  }

  final String _appId;
  final String _appKey;
  final String _accountUser;
  final http.Client _client;

  static final Uri _mealPlannerBaseUri = Uri.parse(
    'https://api.edamam.com/api/meal-planner/v1',
  );

  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  }) async {
    _ensureConfigured();

    final normalizedStart = DateUtils.dateOnly(startDate);
    final requestBody = _buildPlanRequest(profile);
    final selection = await _loadSelections(requestBody);

    final dayCount = selection.length;
    final days = <MealPlanDay>[];
    for (var i = 0; i < dayCount; i++) {
      final daySelection = selection[i];
      final meals = await Future.wait(
        _mealSlots.map((slot) async {
          final section = daySelection.sections[slot];
          if (section == null) {
            throw StateError('Meal planner response is missing $slot.');
          }
          return _loadMeal(section: section, slot: MealSlot.fromSection(slot));
        }),
      );

      days.add(
        MealPlanDay(
          date: normalizedStart.add(Duration(days: i)),
          meals: meals,
        ),
      );
    }

    return MealPlanWeek(
      generatedAt: DateTime.now().toUtc(),
      days: days,
    );
  }

  Future<List<_SelectionDay>> _loadSelections(
    Map<String, dynamic> requestBody,
  ) async {
    final response = await _client.post(
      _mealPlannerBaseUri.resolve('/${Uri.encodeComponent(_appId)}/select'),
      headers: _mealPlannerHeaders,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Edamam meal planner request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawSelections = decoded['selection'];
    if (rawSelections is! List) {
      throw StateError('Edamam meal planner response did not include a plan.');
    }

    return rawSelections
        .map((entry) {
          final map = Map<String, dynamic>.from(entry as Map);
          return _SelectionDay.fromMap(map);
        })
        .toList(growable: false);
  }

  Future<MealPlanMeal> _loadMeal({
    required _SelectionSection section,
    required MealSlot slot,
  }) async {
    final href = section.selfHref;
    if (href == null || href.isEmpty) {
      throw StateError('Edamam meal planner did not return a recipe href.');
    }

    final response = await _client.get(
      Uri.parse(href).replace(
        queryParameters: {
          'app_id': _appId,
          'app_key': _appKey,
          'type': 'public',
        },
      ),
      headers: {
        'Accept': 'application/json',
        'Edamam-Account-User': _accountUser,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Edamam recipe request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final recipeRaw = decoded['recipe'];
    if (recipeRaw is! Map) {
      throw StateError('Edamam recipe response did not contain recipe data.');
    }

    return MealPlanMeal(
      slot: slot,
      timeLabel: _timeLabelFor(slot),
      badgeLabel: _badgeLabelFor(slot),
      recipe: _parseRecipe(Map<String, dynamic>.from(recipeRaw)),
    );
  }

  MealPlanRecipe _parseRecipe(Map<String, dynamic> recipe) {
    final recipeId = _recipeIdFromUri(recipe['uri'] as String? ?? '');
    final totalNutrients = Map<String, dynamic>.from(
      recipe['totalNutrients'] as Map? ?? const {},
    );
    final images = recipe['images'];
    final imageUrl = _pickImageUrl(
      recipe['image'] as String?,
      images is Map ? Map<String, dynamic>.from(images) : null,
    );

    return MealPlanRecipe(
      recipeId: recipeId,
      title: recipe['label'] as String? ?? 'Untitled meal',
      imageUrl: imageUrl,
      sourceName: recipe['source'] as String? ?? 'Edamam',
      sourceUrl: recipe['url'] as String? ?? '',
      calories: _doubleFromNutrient(totalNutrients, 'ENERC_KCAL'),
      nutrition: NutritionEntry(
        caloriesKcal: _intFromNutrient(totalNutrients, 'ENERC_KCAL'),
        proteinG: _intFromNutrient(totalNutrients, 'PROCNT'),
        carbsG: _intFromNutrient(totalNutrients, 'CHOCDF'),
        fatsG: _intFromNutrient(totalNutrients, 'FAT'),
      ),
    );
  }

  Map<String, dynamic> _buildPlanRequest(UserProfile profile) {
    final healthLabels = <String>{
      ...profile.dietaryProfile.allergens,
      ...profile.dietaryProfile.restrictions,
      ...profile.dietaryProfile.preferences,
    }.map(_normalizeLabel).where((label) => label.isNotEmpty).toList();

    final calories = profile.dailyTargets.caloriesKcal;
    final protein = profile.dailyTargets.proteinG;
    final carbs = profile.dailyTargets.carbsG;
    final fats = profile.dailyTargets.fatsG;

    return {
      'size': 7,
      'plan': {
        if (healthLabels.isNotEmpty)
          'accept': {
            'all': [
              {'health': healthLabels},
            ],
          },
        'fit': {
          'ENERC_KCAL': _fitRange(calories, minFactor: 0.9, maxFactor: 1.05),
          'PROCNT': _fitRange(protein, minFactor: 0.9, maxFactor: 1.1),
          'CHOCDF': _fitRange(carbs, minFactor: 0.9, maxFactor: 1.1),
          'FAT': _fitRange(fats, minFactor: 0.9, maxFactor: 1.1),
        },
        'sections': {
          'Breakfast': _sectionRequest(
            minCalories: calories * 0.18,
            maxCalories: calories * 0.28,
            mealTypes: ['breakfast'],
            dishTypes: ['drinks', 'egg', 'biscuits and cookies', 'bread', 'pancake', 'cereals'],
          ),
          'Lunch': _sectionRequest(
            minCalories: calories * 0.28,
            maxCalories: calories * 0.4,
            mealTypes: ['lunch/dinner'],
            dishTypes: ['main course', 'pasta', 'egg', 'salad', 'soup', 'sandwiches', 'pizza', 'seafood'],
          ),
          'Dinner': _sectionRequest(
            minCalories: calories * 0.3,
            maxCalories: calories * 0.42,
            mealTypes: ['lunch/dinner'],
            dishTypes: ['main course', 'seafood', 'salad', 'pizza', 'pasta', 'soup'],
          ),
        },
      },
    };
  }

  Map<String, dynamic> _sectionRequest({
    required double minCalories,
    required double maxCalories,
    required List<String> mealTypes,
    required List<String> dishTypes,
  }) {
    return {
      'accept': {
        'all': [
          {'dish': dishTypes},
          {'meal': mealTypes},
        ],
      },
      'fit': {
        'ENERC_KCAL': {
          'min': minCalories.round(),
          'max': maxCalories.round(),
        },
      },
    };
  }

  Map<String, num> _fitRange(
    int target, {
    required double minFactor,
    required double maxFactor,
  }) {
    return {
      'min': (target * minFactor).round(),
      'max': (target * maxFactor).round(),
    };
  }

  String _normalizeLabel(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]+'), '');
    return normalized;
  }

  String _recipeIdFromUri(String uri) {
    final marker = '#recipe_';
    final index = uri.indexOf(marker);
    if (index == -1) {
      return uri;
    }
    return uri.substring(index + marker.length);
  }

  int _intFromNutrient(Map<String, dynamic> nutrients, String key) {
    final raw = nutrients[key];
    if (raw is Map) {
      final quantity = raw['quantity'];
      if (quantity is num) {
        return quantity.round();
      }
    }
    return 0;
  }

  double _doubleFromNutrient(Map<String, dynamic> nutrients, String key) {
    final raw = nutrients[key];
    if (raw is Map) {
      final quantity = raw['quantity'];
      if (quantity is num) {
        return quantity.toDouble();
      }
    }
    return 0;
  }

  String? _pickImageUrl(String? image, Map<String, dynamic>? images) {
    final regular = images?['REGULAR'];
    if (regular is Map) {
      final url = regular['url'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }

    final small = images?['SMALL'];
    if (small is Map) {
      final url = small['url'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }

    if (image != null && image.isNotEmpty) {
      return image;
    }

    return null;
  }

  String _timeLabelFor(MealSlot slot) {
    switch (slot) {
      case MealSlot.breakfast:
        return '7:00 AM';
      case MealSlot.lunch:
        return '12:30 PM';
      case MealSlot.dinner:
        return '6:30 PM';
    }
  }

  String _badgeLabelFor(MealSlot slot) {
    return slot.label.toUpperCase();
  }

  void _ensureConfigured() {
    if (_appId.isEmpty || _appKey.isEmpty || _accountUser.isEmpty) {
      throw StateError(
        'Edamam environment variables are missing. Check .env setup.',
      );
    }
  }

  Map<String, String> get _mealPlannerHeaders {
    final token = base64Encode(utf8.encode('$_appId:$_appKey'));
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Basic $token',
      'Edamam-Account-User': _accountUser,
    };
  }

  static const _mealSlots = ['Breakfast', 'Lunch', 'Dinner'];
}

class _SelectionDay {
  const _SelectionDay({required this.sections});

  final Map<String, _SelectionSection> sections;

  factory _SelectionDay.fromMap(Map<String, dynamic> map) {
    final rawSections = Map<String, dynamic>.from(
      map['sections'] as Map? ?? const {},
    );
    return _SelectionDay(
      sections: {
        for (final entry in rawSections.entries)
          entry.key: _SelectionSection.fromMap(
            Map<String, dynamic>.from(entry.value as Map),
          ),
      },
    );
  }
}

class _SelectionSection {
  const _SelectionSection({
    required this.assigned,
    required this.selfHref,
  });

  final String? assigned;
  final String? selfHref;

  factory _SelectionSection.fromMap(Map<String, dynamic> map) {
    final links = map['_links'];
    String? selfHref;
    if (links is Map) {
      final self = links['self'];
      if (self is Map) {
        final href = self['href'];
        if (href is String) {
          selfHref = href;
        }
      }
    }

    return _SelectionSection(
      assigned: map['assigned'] as String?,
      selfHref: selfHref,
    );
  }
}

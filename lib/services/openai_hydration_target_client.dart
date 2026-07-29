import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/services/hydration_target_client.dart';

class OpenAiHydrationTargetClient implements HydrationTargetClient {
  OpenAiHydrationTargetClient({
    required String apiKey,
    http.Client? httpClient,
    this.model = 'gpt-4o-mini',
  }) : _apiKey = apiKey,
       _client = httpClient ?? http.Client();

  factory OpenAiHydrationTargetClient.fromEnvironment({
    http.Client? httpClient,
  }) {
    final apiKey = dotenv.isInitialized
        ? (dotenv.get('OPENAI_API_KEY', fallback: '')).trim()
        : '';
    return OpenAiHydrationTargetClient(apiKey: apiKey, httpClient: httpClient);
  }

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  final String _apiKey;
  final http.Client _client;
  final String model;

  @override
  Future<double> fetchDailyTargetLiters(UserProfile profile) async {
    final fallback = _fallbackTarget(profile);
    if (_apiKey.isEmpty) {
      return fallback;
    }

    try {
      final content = await _completeJson(
        systemPrompt: _systemPrompt,
        userPrompt: _userPrompt(profile),
      );
      return _parseTargetLiters(content, fallback: fallback);
    } catch (error) {
      debugPrint('OpenAI hydration target unavailable: $error');
      return fallback;
    }
  }

  Future<String> _completeJson({
    required String systemPrompt,
    required String userPrompt,
  }) async {
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
            ? 'OpenAI hydration request failed (${response.statusCode}).'
            : 'OpenAI hydration request failed: $body',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (((decoded['choices'] as List?)?.first as Map?)?['message']
                as Map?)?['content']
            as String?;

    if (content == null || content.trim().isEmpty) {
      throw StateError('OpenAI returned an empty hydration target.');
    }

    return content.trim();
  }

  static double _parseTargetLiters(
    String content, {
    required double fallback,
  }) {
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final raw = parsed['hydrationLiters'];
    final value = switch (raw) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };

    if (value == null || value <= 0) {
      return fallback;
    }

    return value.clamp(1.5, 6.0);
  }

  static double _fallbackTarget(UserProfile profile) {
    final stored = profile.dailyTargets.hydrationLiters;
    if (stored > 0) {
      return stored;
    }
    return 3.0;
  }

  static const _systemPrompt =
      'You are a sports nutrition coach. Recommend a daily water intake target in liters '
      'for an athlete based on their profile and preferences.\n\n'
      'Respond with ONLY valid JSON in this exact shape:\n'
      '{"hydrationLiters": 3.5}\n\n'
      'Use one decimal place when helpful. Keep the value between 1.5 and 6.0 liters.';

  static String _userPrompt(UserProfile profile) {
    final dietary = profile.dietaryProfile;
    final targets = profile.dailyTargets;
    final buffer = StringBuffer()
      ..writeln('Athlete profile:')
      ..writeln('- Sport: ${_sportLabel(profile.primarySportName)}')
      ..writeln('- Height cm: ${profile.heightCm ?? 'unknown'}')
      ..writeln('- Weight kg: ${profile.weightKg ?? 'unknown'}')
      ..writeln('- Daily calories target: ${targets.caloriesKcal} kcal')
      ..writeln('- Daily protein target: ${targets.proteinG} g')
      ..writeln('- Food preferences: ${dietary.preferences.join(', ')}')
      ..writeln('- Allergens to avoid: ${dietary.allergens.join(', ')}')
      ..writeln('- Dietary restrictions: ${dietary.restrictions.join(', ')}')
      ..writeln('- Meals per day: ${profile.nutritionSettings.mealsPerDay}')
      ..writeln(
        '- Current hydration baseline: ${targets.hydrationLiters} L',
      );
    buffer.writeln(
      '\nRecommend one daily hydration target in liters for this athlete today.',
    );
    return buffer.toString();
  }

  static String _sportLabel(String sportName) {
    final trimmed = sportName.trim();
    return trimmed.isEmpty ? 'None' : trimmed;
  }
}

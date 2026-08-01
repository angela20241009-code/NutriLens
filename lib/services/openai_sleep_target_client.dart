import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens/models/daily_summary.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/services/sleep_target_client.dart';

class OpenAiSleepTargetClient implements SleepTargetClient {
  OpenAiSleepTargetClient({
    required String apiKey,
    http.Client? httpClient,
    this.model = 'gpt-4o-mini',
  }) : _apiKey = apiKey,
       _client = httpClient ?? http.Client();

  factory OpenAiSleepTargetClient.fromEnvironment({
    http.Client? httpClient,
  }) {
    final apiKey = dotenv.isInitialized
        ? (dotenv.get('OPENAI_API_KEY', fallback: '')).trim()
        : '';
    return OpenAiSleepTargetClient(apiKey: apiKey, httpClient: httpClient);
  }

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  final String _apiKey;
  final http.Client _client;
  final String model;

  @override
  Future<double> fetchDailyTargetHours(
    UserProfile profile, {
    required List<DailySummary> recentSleep,
  }) async {
    final fallback = _fallbackTarget(profile, recentSleep);
    if (_apiKey.isEmpty) {
      return fallback;
    }

    try {
      final content = await _completeJson(
        systemPrompt: _systemPrompt,
        userPrompt: _userPrompt(profile, recentSleep),
      );
      return _parseTargetHours(content, fallback: fallback);
    } catch (error) {
      debugPrint('OpenAI sleep target unavailable: $error');
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
            ? 'OpenAI sleep target request failed (${response.statusCode}).'
            : 'OpenAI sleep target request failed: $body',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (((decoded['choices'] as List?)?.first as Map?)?['message']
                as Map?)?['content']
            as String?;

    if (content == null || content.trim().isEmpty) {
      throw StateError('OpenAI returned an empty sleep target.');
    }

    return content.trim();
  }

  static double _parseTargetHours(
    String content, {
    required double fallback,
  }) {
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final raw = parsed['sleepHours'];
    final value = switch (raw) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };

    if (value == null || value <= 0) {
      return fallback;
    }

    return value.clamp(6.0, 10.0);
  }

  static double _fallbackTarget(
    UserProfile profile,
    List<DailySummary> recentSleep,
  ) {
    final stored = profile.dailyTargets.sleepHours;
    final logged = recentSleep
        .where((summary) => summary.sleepHours > 0)
        .map((summary) => summary.sleepHours)
        .toList(growable: false);

    if (logged.isNotEmpty) {
      final average =
          logged.reduce((a, b) => a + b) / logged.length;
      final adjusted = average < stored ? stored : average;
      return adjusted.clamp(6.0, 10.0);
    }

    if (stored > 0) {
      return stored.clamp(6.0, 10.0);
    }

    return 8.0;
  }

  static const _systemPrompt =
      'You are a sports recovery coach. Recommend a nightly sleep target in hours '
      'for an athlete based on their profile and recent sleep history.\n\n'
      'Respond with ONLY valid JSON in this exact shape:\n'
      '{"sleepHours": 8.5}\n\n'
      'Use one decimal place when helpful. Keep the value between 6.0 and 10.0 hours.';

  static String _userPrompt(
    UserProfile profile,
    List<DailySummary> recentSleep,
  ) {
    final targets = profile.dailyTargets;
    final logged = recentSleep
        .where((summary) => summary.sleepHours > 0)
        .toList(growable: false);
    final averageLogged = logged.isEmpty
        ? null
        : logged
                  .map((summary) => summary.sleepHours)
                  .reduce((a, b) => a + b) /
              logged.length;

    final buffer = StringBuffer()
      ..writeln('Athlete profile:')
      ..writeln('- Sport: ${_sportLabel(profile.primarySportName)}')
      ..writeln('- Height cm: ${profile.heightCm ?? 'unknown'}')
      ..writeln('- Weight kg: ${profile.weightKg ?? 'unknown'}')
      ..writeln('- Training days per week: ${profile.trainingDaysPerWeek ?? 'unknown'}')
      ..writeln('- Activity level: ${profile.activityLevel ?? 'unknown'}')
      ..writeln('- Current sleep target: ${targets.sleepHours} h')
      ..writeln('- Sleep mode enabled: ${profile.sleepModeEnabled}')
      ..writeln(
        '- Usual bedtime: ${_minutesLabel(profile.usualBedtimeMinutes)}',
      )
      ..writeln(
        '- Usual wake time: ${_minutesLabel(profile.usualWakeTimeMinutes)}',
      )
      ..writeln('\nRecent sleep history (most recent first):');

    if (logged.isEmpty) {
      buffer.writeln('- No logged sleep in the recent window.');
    } else {
      for (final summary in logged.take(14)) {
        buffer.writeln('- ${summary.dateKey}: ${summary.sleepHours} h');
      }
      buffer.writeln('- Average logged sleep: ${averageLogged!.toStringAsFixed(1)} h');
    }

    buffer.writeln(
      '\nRecommend one nightly sleep target in hours for this athlete today.',
    );
    return buffer.toString();
  }

  static String _sportLabel(String sportName) {
    final trimmed = sportName.trim();
    return trimmed.isEmpty ? 'None' : trimmed;
  }

  static String _minutesLabel(int? minutes) {
    if (minutes == null) {
      return 'unknown';
    }
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

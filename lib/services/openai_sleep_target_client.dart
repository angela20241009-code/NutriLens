import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/models/daily_summary.dart';
import 'package:nutrilens/models/sleep_personalization_result.dart';
import 'package:nutrilens/models/sleep_questionnaire_answers.dart';
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

  Future<SleepPersonalizationResult> fetchPersonalizedSleepPlan(
    UserProfile profile, {
    required List<DailySummary> recentSleep,
    required List<WeeklySleepDay> weeklyDays,
    required SleepQuestionnaireAnswers answers,
  }) async {
    final fallback = _fallbackPersonalization(profile, recentSleep);
    if (_apiKey.isEmpty) {
      return fallback;
    }

    try {
      final content = await _completeJson(
        systemPrompt: _personalizationSystemPrompt,
        userPrompt: _personalizationUserPrompt(
          profile,
          recentSleep: recentSleep,
          weeklyDays: weeklyDays,
          answers: answers,
        ),
      );
      return _parsePersonalization(content, fallback: fallback);
    } catch (error) {
      debugPrint('OpenAI sleep personalization unavailable: $error');
      return fallback;
    }
  }

  static SleepPersonalizationResult _fallbackPersonalization(
    UserProfile profile,
    List<DailySummary> recentSleep,
  ) {
    final sleepHours = _fallbackTarget(profile, recentSleep);
    final bedtime = profile.usualBedtimeMinutes ?? 22 * 60 + 30;
    final wakeTime =
        profile.usualWakeTimeMinutes ??
        normalizeMinutes(bedtime + (sleepHours * 60).round());
    return SleepPersonalizationResult(
      sleepHours: sleepHours,
      bedtimeMinutes: bedtime,
      wakeTimeMinutes: wakeTime,
      summary:
          'Aim for about ${sleepHours.toStringAsFixed(1)} hours of sleep with a steady bedtime and wake time.',
    );
  }

  static int normalizeMinutes(int minutes) {
    const day = 24 * 60;
    final normalized = minutes % day;
    return normalized < 0 ? normalized + day : normalized;
  }

  static SleepPersonalizationResult _parsePersonalization(
    String content, {
    required SleepPersonalizationResult fallback,
  }) {
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final sleepHours = _parseTargetHours(
      jsonEncode({'sleepHours': parsed['sleepHours']}),
      fallback: fallback.sleepHours,
    );
    final bedtime = _parseMinutes(parsed['bedtimeMinutes']) ??
        fallback.bedtimeMinutes;
    final wakeTime = _parseMinutes(parsed['wakeTimeMinutes']) ??
        fallback.wakeTimeMinutes;
    final summary = parsed['summary'] as String?;

    return SleepPersonalizationResult(
      sleepHours: sleepHours,
      bedtimeMinutes: bedtime,
      wakeTimeMinutes: wakeTime,
      summary: summary?.trim().isNotEmpty == true
          ? summary!.trim()
          : fallback.summary,
    );
  }

  @visibleForTesting
  static SleepPersonalizationResult parsePersonalizationForTest(
    String content, {
    required SleepPersonalizationResult fallback,
  }) {
    return _parsePersonalization(content, fallback: fallback);
  }

  static int? _parseMinutes(Object? raw) {
    final value = switch (raw) {
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
    if (value == null || value < 0 || value >= 24 * 60) {
      return null;
    }
    return value;
  }

  static const _personalizationSystemPrompt =
      'You are a sports recovery coach. Recommend an ideal nightly sleep schedule '
      'for an athlete based on their profile, recent sleep history, weekly sleep '
      'pattern, and questionnaire answers.\n\n'
      'Respond with ONLY valid JSON in this exact shape:\n'
      '{"sleepHours": 8.5, "bedtimeMinutes": 1365, "wakeTimeMinutes": 420, '
      '"summary": "One short paragraph explaining the recommendation."}\n\n'
      'Use minutes after midnight for bedtimeMinutes and wakeTimeMinutes '
      '(for example 22:30 = 1350). Keep sleepHours between 6.0 and 10.0.';

  static String _personalizationUserPrompt(
    UserProfile profile, {
    required List<DailySummary> recentSleep,
    required List<WeeklySleepDay> weeklyDays,
    required SleepQuestionnaireAnswers answers,
  }) {
    final base = _userPrompt(profile, recentSleep);
    final buffer = StringBuffer(base)
      ..writeln('\nCurrent week sleep (Mon-Sun):');

    for (final day in weeklyDays) {
      buffer.writeln(
        '- ${day.dateKey}: ${day.sleepHours > 0 ? '${day.sleepHours} h logged' : 'not logged'}',
      );
    }

    buffer
      ..writeln('\nQuestionnaire answers:')
      ..writeln('- Wake up tired: ${answers.wakeTired}')
      ..writeln('- Bedtime changes a lot: ${answers.bedtimeConsistency}')
      ..writeln(
        '\nRecommend the athlete\'s ideal nightly sleep target, bedtime, and wake time.',
      );

    return buffer.toString();
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

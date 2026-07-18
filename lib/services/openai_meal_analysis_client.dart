import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens/models/meal_analysis_result.dart';
import 'package:nutrilens/services/meal_analysis_client.dart';

class OpenAiMealAnalysisClient implements MealAnalysisClient {
  OpenAiMealAnalysisClient({
    required String apiKey,
    http.Client? httpClient,
    this.model = 'gpt-4o-mini',
  }) : _apiKey = apiKey,
       _client = httpClient ?? http.Client();

  factory OpenAiMealAnalysisClient.fromEnvironment({http.Client? httpClient}) {
    final apiKey = (dotenv.get('OPENAI_API_KEY', fallback: '')).trim();

    assert(() {
      debugPrint('OpenAI env loaded: apiKey=${apiKey.isNotEmpty}');
      return true;
    }());

    return OpenAiMealAnalysisClient(apiKey: apiKey, httpClient: httpClient);
  }

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static const _systemPrompt =
      'You are a nutrition assistant. Analyze the food in the image and estimate '
      'nutrition for a typical single serving.\n\n'
      'Respond with ONLY valid JSON in this exact shape:\n'
      '{\n'
      '  "mealName": "string",\n'
      '  "caloriesKcal": integer,\n'
      '  "proteinG": integer,\n'
      '  "carbsG": integer,\n'
      '  "fatsG": integer\n'
      '}\n\n'
      'Use non-negative integers. Round reasonably. If unsure, give your best estimate.';

  final String _apiKey;
  final http.Client _client;
  final String model;

  @override
  Future<MealAnalysisResult> analyzeMealPhoto({
    required List<int> imageBytes,
    required String mimeType,
  }) async {
    if (_apiKey.isEmpty) {
      throw MealAnalysisException(
        'OpenAI API key is missing. Add OPENAI_API_KEY to assets/.env.',
      );
    }

    final base64Image = base64Encode(imageBytes);
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
          {'role': 'system', 'content': _systemPrompt},
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'Analyze this meal photo and return the JSON nutrition estimate.',
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      final body = response.body.trim();
      throw MealAnalysisException(
        body.isEmpty
            ? 'OpenAI request failed (${response.statusCode}).'
            : 'OpenAI request failed: $body',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (((decoded['choices'] as List?)?.first as Map?)?['message']
                as Map?)?['content']
            as String?;

    if (content == null || content.trim().isEmpty) {
      throw MealAnalysisException('OpenAI returned an empty analysis.');
    }

    final parsed = jsonDecode(content.trim()) as Map<String, dynamic>;
    final result = MealAnalysisResult.fromJson(parsed);

    if (result.name.isEmpty) {
      throw MealAnalysisException('OpenAI could not identify the meal.');
    }

    return result;
  }
}

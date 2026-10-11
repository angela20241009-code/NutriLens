/// Sends a received JPEG to the OpenAI Chat Completions API and returns a
/// short description of it.
///
/// Configuration comes from `.env` (see `.env.example`). If OPENAI_API_KEY is
/// blank the app still works as a plain camera viewer - descriptions are just
/// skipped, so you can run the demo without a key.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VisionException implements Exception {
  VisionException(this.message);
  final String message;
  @override
  String toString() => message;
}

class Vision {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static String get _key => dotenv.env['OPENAI_API_KEY']?.trim() ?? '';
  static String get _model =>
      dotenv.env['OPENAI_MODEL']?.trim().isNotEmpty == true
      ? dotenv.env['OPENAI_MODEL']!.trim()
      : 'gpt-4o-mini';
  static String get _prompt =>
      dotenv.env['OPENAI_PROMPT']?.trim().isNotEmpty == true
      ? dotenv.env['OPENAI_PROMPT']!.trim()
      : 'Identify the main food in this photo and estimate nutrition for one serving. Return ONLY JSON with keys: item, calories, fat_g, carbohydrate_g, protein_g, high_salt (Yes or No).';

  /// True when a key is present, so the UI can hide the feature entirely
  /// rather than showing an error on every photo.
  static bool get isConfigured => _key.isNotEmpty;

  /// Describes [jpeg]. Throws [VisionException] with a readable message.
  static Future<String> describe(Uint8List jpeg) async {
    if (!isConfigured) {
      throw VisionException('No OPENAI_API_KEY in .env');
    }

    final dataUrl = 'data:image/jpeg;base64,${base64Encode(jpeg)}';

    final http.Response res;
    try {
      res = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_key',
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 150,
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {'type': 'text', 'text': _prompt},
                    {
                      'type': 'image_url',
                      // "low" detail is plenty for an 800x600 frame and keeps
                      // the token cost down; the board fires every 20 s.
                      'image_url': {'url': dataUrl, 'detail': 'low'},
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw VisionException('Network error: $e');
    }

    if (res.statusCode != 200) {
      throw VisionException(_errorFor(res));
    }

    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = body['choices'] as List<dynamic>;
      final text =
          (choices.first as Map)['message']['content'] as String? ?? '';
      final trimmed = text.trim();
      if (trimmed.isEmpty) throw VisionException('Empty response');
      return trimmed;
    } on VisionException {
      rethrow;
    } catch (e) {
      throw VisionException('Unexpected response shape: $e');
    }
  }

  /// Turn the API's error body into something readable on a phone screen.
  static String _errorFor(http.Response res) {
    String detail = '';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      detail = (body['error']?['message'] as String?)?.trim() ?? '';
    } catch (_) {}

    switch (res.statusCode) {
      case 401:
        return 'Invalid API key - check OPENAI_API_KEY in .env';
      case 429:
        return 'Rate limited or out of quota';
      case 404:
        return 'Model "$_model" not available to this key';
      default:
        return detail.isEmpty
            ? 'OpenAI error ${res.statusCode}'
            : 'OpenAI ${res.statusCode}: $detail';
    }
  }
}

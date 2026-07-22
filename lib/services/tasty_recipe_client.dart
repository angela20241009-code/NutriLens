import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens/models/tasty_recipe.dart';

abstract class TastyRecipeClient {
  Future<TastyRecipeSearchResult> searchRecipes({
    String query = '',
    int from = 0,
    int size = 20,
  });

  Future<TastyRecipeDetail> fetchRecipeDetail(int recipeId);
}

class RapidApiTastyRecipeClient implements TastyRecipeClient {
  RapidApiTastyRecipeClient({
    required String apiKey,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _client = httpClient ?? http.Client();

  factory RapidApiTastyRecipeClient.fromEnvironment({http.Client? httpClient}) {
    final apiKey = (dotenv.get('RAPIDAPI_KEY', fallback: '')).trim();
    return RapidApiTastyRecipeClient(apiKey: apiKey, httpClient: httpClient);
  }

  static const _host = 'tasty.p.rapidapi.com';

  final String _apiKey;
  final http.Client _client;

  Map<String, String> get _headers => {
    'x-rapidapi-key': _apiKey,
    'x-rapidapi-host': _host,
  };

  void _ensureConfigured() {
    if (_apiKey.isEmpty) {
      throw StateError(
        'RAPIDAPI_KEY is missing. Add it to assets/.env to search Tasty recipes.',
      );
    }
  }

  @override
  Future<TastyRecipeSearchResult> searchRecipes({
    String query = '',
    int from = 0,
    int size = 20,
  }) async {
    _ensureConfigured();

    final uri = Uri.https(_host, '/recipes/list', {
      'from': '$from',
      'size': '$size',
      if (query.trim().isNotEmpty) 'q': query.trim(),
    });

    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw StateError(
        'Tasty API request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected Tasty API response shape.');
    }

    final results = decoded['results'];
    final recipes = results is List
        ? results
              .whereType<Map<String, dynamic>>()
              .map(TastyRecipe.fromMap)
              .where((recipe) => recipe.id > 0)
              .toList(growable: false)
        : const <TastyRecipe>[];

    final totalCount = decoded['count'];
    return TastyRecipeSearchResult(
      recipes: recipes,
      totalCount: totalCount is num ? totalCount.toInt() : recipes.length,
    );
  }

  @override
  Future<TastyRecipeDetail> fetchRecipeDetail(int recipeId) async {
    _ensureConfigured();

    final uri = Uri.https(_host, '/recipes/get-more-info', {
      'id': '$recipeId',
    });

    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw StateError(
        'Tasty recipe detail request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected Tasty recipe detail response shape.');
    }

    return TastyRecipeDetail.fromMap(decoded);
  }
}

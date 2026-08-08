/// Builds Tasty.co search queries from a meal title, broadest last.
List<String> tastySearchQueriesFor(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return const [];
  }

  final queries = <String>[];
  void add(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return;
    }
    final key = normalized.toLowerCase();
    if (queries.any((query) => query.toLowerCase() == key)) {
      return;
    }
    queries.add(normalized);
  }

  add(trimmed);

  final withoutParens = trimmed.replaceAll(RegExp(r'\([^)]*\)'), ' ').trim();
  add(withoutParens);

  final simplified = _stripFillerWords(withoutParens);
  add(simplified);

  final words = simplified
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.length > 4) {
    add(words.take(4).join(' '));
  }
  if (words.length > 3) {
    add(words.take(3).join(' '));
  }
  if (words.length >= 3) {
    add(words.take(2).join(' '));
  }

  return queries;
}

/// Returns a token overlap score in `[0, 1]` for picking the best Tasty match.
double tastyTitleSimilarityScore(String query, String candidate) {
  final queryTokens = _tokenize(query);
  final candidateTokens = _tokenize(candidate);
  if (queryTokens.isEmpty || candidateTokens.isEmpty) {
    return 0;
  }

  final overlap = queryTokens.where(candidateTokens.contains).length;
  return overlap / queryTokens.length;
}

const _fillerWords = {
  'power',
  'recovery',
  'performance',
  'athlete',
  'athletic',
  'fuel',
  'protein',
  'packed',
  'energy',
  'super',
  'ultimate',
  'classic',
  'homemade',
  'healthy',
  'nutritious',
  'balanced',
  'with',
  'and',
};

String _stripFillerWords(String title) {
  final words = title
      .replaceAll('&', ' and ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);

  final filtered = words.where((word) {
    final normalized = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return normalized.isNotEmpty && !_fillerWords.contains(normalized);
  });

  return filtered.join(' ');
}

Set<String> _tokenize(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((token) => token.length > 1)
      .toSet();
}

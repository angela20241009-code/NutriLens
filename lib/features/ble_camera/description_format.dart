library;

import 'dart:convert';

String formatAiDescription(String? raw) {
  final input = _stripCodeFence((raw ?? '').trim());
  if (input.isEmpty) return '';

  dynamic parsed;
  try {
    parsed = jsonDecode(input);
  } catch (_) {
    return input;
  }

  final nutrition = _formatNutrition(parsed);
  if (nutrition != null) return nutrition;

  if (parsed is String) return parsed.trim();

  final lines = <String>[];
  _appendValue(parsed, lines, 0);
  return lines.isEmpty ? input : lines.join('\n');
}

void _appendValue(dynamic value, List<String> lines, int depth) {
  if (value is Map) {
    _appendMap(value, lines, depth);
    return;
  }

  if (value is List) {
    _appendList(value, lines, depth);
    return;
  }

  lines.add('${_indent(depth)}• ${_primitive(value)}');
}

void _appendMap(Map<dynamic, dynamic> map, List<String> lines, int depth) {
  if (map.isEmpty) {
    lines.add('${_indent(depth)}• None');
    return;
  }

  for (final entry in map.entries) {
    final key = _humanize('${entry.key}');
    final value = entry.value;
    if (value is Map || value is List) {
      lines.add('${_indent(depth)}• $key:');
      _appendValue(value, lines, depth + 1);
    } else {
      lines.add('${_indent(depth)}• $key: ${_primitive(value)}');
    }
  }
}

void _appendList(List<dynamic> list, List<String> lines, int depth) {
  if (list.isEmpty) {
    lines.add('${_indent(depth)}• None');
    return;
  }

  for (final item in list) {
    if (item is Map || item is List) {
      _appendValue(item, lines, depth);
    } else {
      lines.add('${_indent(depth)}• ${_primitive(item)}');
    }
  }
}

String _primitive(dynamic value) {
  if (value == null) return 'n/a';
  if (value is bool) return value ? 'Yes' : 'No';
  return '$value';
}

String _indent(int depth) => '  ' * depth;

String _stripCodeFence(String input) {
  final match = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$').firstMatch(input);
  return (match?.group(1) ?? input).trim();
}

String _humanize(String key) {
  final spaced = key
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'(?<=[a-z0-9])([A-Z])'), ' \$1')
      .trim();
  if (spaced.isEmpty) return key;
  return spaced[0].toUpperCase() + spaced.substring(1);
}

String? _formatNutrition(dynamic parsed) {
  if (parsed is! Map) return null;

  final map = parsed.cast<dynamic, dynamic>();
  final item = _firstText(map, const [
    'item',
    'food',
    'name',
    'title',
    'label',
  ]);
  final calories = _firstNumber(map, const [
    'calories',
    'calories_kcal',
    'kcal',
    'energy_kcal',
  ]);
  final fat = _firstNumber(map, const ['fat_g', 'fat', 'total_fat_g']);
  final carbs = _firstNumber(map, const [
    'carbohydrate_g',
    'carbs_g',
    'carbs',
    'carbohydrate',
  ]);
  final protein = _firstNumber(map, const [
    'protein_g',
    'protein',
    'protein_grams',
  ]);
  final highSalt = _firstBoolLike(map, const [
    'high_salt',
    'is_high_salt',
    'high_sodium',
    'salt_high',
  ]);

  final hasAny =
      item != null ||
      calories != null ||
      fat != null ||
      carbs != null ||
      protein != null ||
      highSalt != null;
  if (!hasAny) return null;

  return [
    item?.trim().isNotEmpty == true ? item!.trim() : 'Unknown food',
    'Calories:',
    '  ${_fmtNumber(calories)}',
    'Fat:',
    '  ${_fmtGrams(fat)}',
    'Carbohydrate:',
    '  ${_fmtGrams(carbs)}',
    'Protein:',
    '  ${_fmtGrams(protein)}',
    'High Salt:',
    '  ${_fmtBoolLike(highSalt)}',
  ].join('\n');
}

String? _firstText(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (!map.containsKey(key)) continue;
    final value = map[key];
    if (value == null) continue;
    final text = '$value'.trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

num? _firstNumber(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (!map.containsKey(key)) continue;
    final number = _asNum(map[key]);
    if (number != null) return number;
  }
  return null;
}

bool? _firstBoolLike(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (!map.containsKey(key)) continue;
    final value = map[key];
    if (value is bool) return value;
    if (value == null) continue;
    final s = '$value'.trim().toLowerCase();
    if (s == 'yes' || s == 'true' || s == 'high') return true;
    if (s == 'no' || s == 'false' || s == 'low') return false;
  }
  return null;
}

num? _asNum(dynamic value) {
  if (value is num) return value;
  if (value == null) return null;
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch('$value');
  if (match == null) return null;
  return num.tryParse(match.group(0)!);
}

String _fmtNumber(num? value) {
  if (value == null) return 'n/a';
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _fmtGrams(num? value) {
  if (value == null) return 'n/a';
  return '${_fmtNumber(value)}g';
}

String _fmtBoolLike(bool? value) {
  if (value == null) return 'n/a';
  return value ? 'Yes' : 'No';
}

library;

import 'dart:convert';

String formatAiDescription(String? raw, {String languageCode = 'en'}) {
  final input = _stripCodeFence((raw ?? '').trim());
  if (input.isEmpty) return '';
  final strings = _DescriptionStrings.forLanguage(languageCode);

  dynamic parsed;
  try {
    parsed = jsonDecode(input);
  } catch (_) {
    return input;
  }

  final nutrition = _formatNutrition(parsed, strings);
  if (nutrition != null) return nutrition;

  if (parsed is String) return parsed.trim();

  final lines = <String>[];
  _appendValue(parsed, lines, 0, strings);
  return lines.isEmpty ? input : lines.join('\n');
}

void _appendValue(
  dynamic value,
  List<String> lines,
  int depth,
  _DescriptionStrings strings,
) {
  if (value is Map) {
    _appendMap(value, lines, depth, strings);
    return;
  }

  if (value is List) {
    _appendList(value, lines, depth, strings);
    return;
  }

  lines.add('${_indent(depth)}• ${_primitive(value, strings)}');
}

void _appendMap(
  Map<dynamic, dynamic> map,
  List<String> lines,
  int depth,
  _DescriptionStrings strings,
) {
  if (map.isEmpty) {
    lines.add('${_indent(depth)}• ${strings.none}');
    return;
  }

  for (final entry in map.entries) {
    final key = _humanize('${entry.key}');
    final value = entry.value;
    if (value is Map || value is List) {
      lines.add('${_indent(depth)}• $key:');
      _appendValue(value, lines, depth + 1, strings);
    } else {
      lines.add('${_indent(depth)}• $key: ${_primitive(value, strings)}');
    }
  }
}

void _appendList(
  List<dynamic> list,
  List<String> lines,
  int depth,
  _DescriptionStrings strings,
) {
  if (list.isEmpty) {
    lines.add('${_indent(depth)}• ${strings.none}');
    return;
  }

  for (final item in list) {
    if (item is Map || item is List) {
      _appendValue(item, lines, depth, strings);
    } else {
      lines.add('${_indent(depth)}• ${_primitive(item, strings)}');
    }
  }
}

String _primitive(dynamic value, _DescriptionStrings strings) {
  if (value == null) return strings.notAvailable;
  if (value is bool) return value ? strings.yes : strings.no;
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

String? _formatNutrition(dynamic parsed, _DescriptionStrings strings) {
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
    item?.trim().isNotEmpty == true ? item!.trim() : strings.unknownFood,
    '${strings.calories}:',
    '  ${_fmtNumber(calories, strings)}',
    '${strings.fat}:',
    '  ${_fmtGrams(fat, strings)}',
    '${strings.carbohydrate}:',
    '  ${_fmtGrams(carbs, strings)}',
    '${strings.protein}:',
    '  ${_fmtGrams(protein, strings)}',
    '${strings.highSalt}:',
    '  ${_fmtBoolLike(highSalt, strings)}',
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

String _fmtNumber(num? value, [_DescriptionStrings? strings]) {
  if (value == null) return strings?.notAvailable ?? 'n/a';
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _fmtGrams(num? value, [_DescriptionStrings? strings]) {
  if (value == null) return strings?.notAvailable ?? 'n/a';
  return '${_fmtNumber(value, strings)}g';
}

String _fmtBoolLike(bool? value, _DescriptionStrings strings) {
  if (value == null) return strings.notAvailable;
  return value ? strings.yes : strings.no;
}

class _DescriptionStrings {
  const _DescriptionStrings._({required this.languageCode});

  final String languageCode;

  static _DescriptionStrings forLanguage(String languageCode) {
    return _DescriptionStrings._(
      languageCode: languageCode.trim().toLowerCase(),
    );
  }

  String get yes => switch (languageCode) {
    'es' => 'Sí',
    'zh' => '是',
    _ => 'Yes',
  };

  String get no => switch (languageCode) {
    'es' => 'No',
    'zh' => '否',
    _ => 'No',
  };

  String get none => switch (languageCode) {
    'es' => 'Ninguno',
    'zh' => '无',
    _ => 'None',
  };

  String get notAvailable => switch (languageCode) {
    'es' => 'n/d',
    'zh' => '无数据',
    _ => 'n/a',
  };

  String get unknownFood => switch (languageCode) {
    'es' => 'Comida desconocida',
    'zh' => '未知食物',
    _ => 'Unknown food',
  };

  String get calories => switch (languageCode) {
    'es' => 'Calorías',
    'zh' => '卡路里',
    _ => 'Calories',
  };

  String get fat => switch (languageCode) {
    'es' => 'Grasa',
    'zh' => '脂肪',
    _ => 'Fat',
  };

  String get carbohydrate => switch (languageCode) {
    'es' => 'Carbohidrato',
    'zh' => '碳水化合物',
    _ => 'Carbohydrate',
  };

  String get protein => switch (languageCode) {
    'es' => 'Proteína',
    'zh' => '蛋白质',
    _ => 'Protein',
  };

  String get highSalt => switch (languageCode) {
    'es' => 'Alto en sal',
    'zh' => '高盐',
    _ => 'High Salt',
  };
}

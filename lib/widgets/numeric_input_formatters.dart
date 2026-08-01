import 'package:flutter/services.dart';

/// Input formatters that restrict fields to valid numeric characters.
abstract final class NumericInputFormatters {
  static final digitsOnly = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];

  static final decimal = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    _DecimalInputFormatter(),
  ];

  static List<TextInputFormatter>? forKeyboard(
    TextInputType keyboardType, {
    bool allowDecimal = false,
  }) {
    if (keyboardType == TextInputType.phone) {
      return digitsOnly;
    }
    if (!_isNumericKeyboard(keyboardType, allowDecimal: allowDecimal)) {
      return null;
    }
    return _keyboardAllowsDecimal(keyboardType, allowDecimal: allowDecimal)
        ? decimal
        : digitsOnly;
  }

  static bool _isNumericKeyboard(
    TextInputType keyboardType, {
    bool allowDecimal = false,
  }) {
    if (keyboardType == TextInputType.number ||
        keyboardType == TextInputType.phone) {
      return true;
    }
    if (allowDecimal) {
      return true;
    }
    return keyboardType == const TextInputType.numberWithOptions() ||
        keyboardType == const TextInputType.numberWithOptions(signed: true) ||
        keyboardType ==
            const TextInputType.numberWithOptions(decimal: true) ||
        keyboardType ==
            const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            );
  }

  static bool _keyboardAllowsDecimal(
    TextInputType keyboardType, {
    required bool allowDecimal,
  }) {
    if (allowDecimal) {
      return true;
    }
    return keyboardType ==
            const TextInputType.numberWithOptions(decimal: true) ||
        keyboardType ==
            const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty || RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

import 'package:flutter/services.dart';

/// Input formatters that restrict fields to valid numeric characters.
abstract final class NumericInputFormatters {
  static final digitsOnly = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];

  static final decimal = <TextInputFormatter>[
    _DecimalInputFormatter(),
  ];

  static List<TextInputFormatter>? forKeyboard(
    TextInputType keyboardType, {
    bool allowDecimal = false,
  }) {
    if (keyboardType == TextInputType.phone) {
      return digitsOnly;
    }
    if (keyboardType == TextInputType.number) {
      return allowDecimal ? decimal : digitsOnly;
    }
    return null;
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

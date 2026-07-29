import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/widgets/numeric_input_formatters.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.allowDecimal = false,
    this.inputFormatters,
    this.maxLines = 1,
    this.helperText,
    this.enabled = true,
    this.validator,
    this.suffix,
    this.limeBorder = false,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool allowDecimal;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? helperText;
  final bool enabled;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final bool limeBorder;

  static const _enabledLimeWidth = 1.5;
  static const _focusedLimeWidth = 3.0;
  static const _defaultBorderColor = Color(0x66B8FF3C);

  OutlineInputBorder _outlineBorder({
    required Color color,
    required double width,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  OutlineInputBorder _limeOutline(double width) {
    return _outlineBorder(color: AppColors.lime, width: width);
  }

  OutlineInputBorder get _defaultEnabledBorder =>
      _outlineBorder(color: _defaultBorderColor, width: _enabledLimeWidth);

  OutlineInputBorder get _defaultFocusedBorder =>
      _outlineBorder(color: AppColors.lime, width: _focusedLimeWidth);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters ??
              NumericInputFormatters.forKeyboard(
                keyboardType,
                allowDecimal: allowDecimal,
              ),
          maxLines: maxLines,
          enabled: enabled,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardDarker,
            helperText: helperText,
            helperStyle: const TextStyle(color: AppColors.textMuted),
            suffixIcon: suffix == null ? null : Padding(
              padding: const EdgeInsets.only(right: 8),
              child: suffix,
            ),
            border: limeBorder ? _limeOutline(_enabledLimeWidth) : _defaultEnabledBorder,
            enabledBorder:
                limeBorder ? _limeOutline(_enabledLimeWidth) : _defaultEnabledBorder,
            focusedBorder:
                limeBorder ? _limeOutline(_focusedLimeWidth) : _defaultFocusedBorder,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

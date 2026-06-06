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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.cardDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.cardDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.lime),
            ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/theme/app_colors.dart';

enum SleepCheckInAction { saved, skipped }

class SleepCheckInResult {
  const SleepCheckInResult._({required this.action, this.sleepHours});

  const SleepCheckInResult.saved(double sleepHours)
    : this._(action: SleepCheckInAction.saved, sleepHours: sleepHours);

  const SleepCheckInResult.skipped()
    : this._(action: SleepCheckInAction.skipped, sleepHours: null);

  final SleepCheckInAction action;
  final double? sleepHours;

  bool get skipped => action == SleepCheckInAction.skipped;
}

class SleepCheckInDialog extends StatefulWidget {
  const SleepCheckInDialog({
    super.key,
    required this.profile,
    required this.title,
    required this.description,
    required this.allowDismiss,
    this.initialSleepHours,
  });

  final UserProfile profile;
  final String title;
  final String description;
  final bool allowDismiss;
  final double? initialSleepHours;

  static Future<SleepCheckInResult?> show({
    required BuildContext context,
    required UserProfile profile,
    required String title,
    required String description,
    bool allowDismiss = true,
    double? initialSleepHours,
  }) {
    return showDialog<SleepCheckInResult>(
      context: context,
      barrierDismissible: allowDismiss,
      builder: (context) {
        return SleepCheckInDialog(
          profile: profile,
          title: title,
          description: description,
          allowDismiss: allowDismiss,
          initialSleepHours: initialSleepHours,
        );
      },
    );
  }

  @override
  State<SleepCheckInDialog> createState() => _SleepCheckInDialogState();
}

class _SleepCheckInDialogState extends State<SleepCheckInDialog> {
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initialMinutes = ((widget.initialSleepHours ?? 0) * 60).round();
    final hours = initialMinutes > 0 ? initialMinutes ~/ 60 : 8;
    final minutes = initialMinutes > 0 ? initialMinutes % 60 : 0;
    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  int? _durationMinutes() {
    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    if (hours < 0 || minutes < 0 || minutes >= 60) {
      return null;
    }
    return hours * 60 + minutes;
  }

  void _save() {
    final durationMinutes = _durationMinutes();
    if (durationMinutes == null) {
      setState(() {
        _error = 'Enter valid hours and minutes (0–59 for minutes).';
      });
      return;
    }
    if (durationMinutes < 120 || durationMinutes > 960) {
      setState(() {
        _error = 'Sleep duration should be between 2 and 16 hours.';
      });
      return;
    }

    Navigator.of(context).pop(
      SleepCheckInResult.saved(durationMinutes / 60),
    );
  }

  void _skip() {
    Navigator.of(context).pop(const SleepCheckInResult.skipped());
  }

  @override
  Widget build(BuildContext context) {
    final targetHours = widget.profile.dailyTargets.sleepHours;
    final durationMinutes = _durationMinutes();

    return PopScope(
      canPop: widget.allowDismiss,
      child: AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DurationField(
                    label: 'Hours',
                    controller: _hoursController,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DurationField(
                    label: 'Minutes',
                    controller: _minutesController,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ),
              ],
            ),
            if (durationMinutes != null && durationMinutes > 0) ...[
              const SizedBox(height: 14),
              Text(
                'Total: ${formatDurationMinutes(durationMinutes)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.sleepAccent,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Target: ${targetHours.toStringAsFixed(1)}h',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.orange)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip for now'),
          ),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sleepAccent,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Save sleep'),
          ),
        ],
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.sleepAccent.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sleepAccent, width: 2),
        ),
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

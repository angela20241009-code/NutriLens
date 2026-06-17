import 'package:flutter/material.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/theme/app_colors.dart';

class SleepCheckInResult {
  const SleepCheckInResult({
    required this.bedtimeMinutes,
    required this.wakeTimeMinutes,
    required this.sleepHours,
  });

  final int bedtimeMinutes;
  final int wakeTimeMinutes;
  final double sleepHours;
}

class SleepCheckInDialog extends StatefulWidget {
  const SleepCheckInDialog({
    super.key,
    required this.profile,
    required this.title,
    required this.description,
    required this.allowDismiss,
  });

  final UserProfile profile;
  final String title;
  final String description;
  final bool allowDismiss;

  static Future<SleepCheckInResult?> show({
    required BuildContext context,
    required UserProfile profile,
    required String title,
    required String description,
    bool allowDismiss = true,
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
        );
      },
    );
  }

  @override
  State<SleepCheckInDialog> createState() => _SleepCheckInDialogState();
}

class _SleepCheckInDialogState extends State<SleepCheckInDialog> {
  late int _bedtimeMinutes;
  late int _wakeTimeMinutes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bedtimeMinutes = widget.profile.usualBedtimeMinutes ?? 22 * 60;
    _wakeTimeMinutes = widget.profile.usualWakeTimeMinutes ?? 7 * 60;
  }

  int get _durationMinutes => sleepDurationMinutes(
    bedtimeMinutes: _bedtimeMinutes,
    wakeTimeMinutes: _wakeTimeMinutes,
  );

  Future<void> _pickTime({
    required int currentMinutes,
    required ValueChanged<int> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: normalizeMinutes(currentMinutes) ~/ 60,
        minute: normalizeMinutes(currentMinutes) % 60,
      ),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _error = null;
      onPicked(picked.hour * 60 + picked.minute);
    });
  }

  void _save() {
    if (_durationMinutes < 120 || _durationMinutes > 960) {
      setState(() {
        _error = 'Sleep duration should be between 2 and 16 hours.';
      });
      return;
    }

    Navigator.of(context).pop(
      SleepCheckInResult(
        bedtimeMinutes: _bedtimeMinutes,
        wakeTimeMinutes: _wakeTimeMinutes,
        sleepHours: _durationMinutes / 60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetHours = widget.profile.dailyTargets.sleepHours;

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
            _TimePickerButton(
              label: 'Bedtime',
              value: formatMinutesAsClock(_bedtimeMinutes),
              onTap: () => _pickTime(
                currentMinutes: _bedtimeMinutes,
                onPicked: (value) => _bedtimeMinutes = value,
              ),
            ),
            const SizedBox(height: 10),
            _TimePickerButton(
              label: 'Wake time',
              value: formatMinutesAsClock(_wakeTimeMinutes),
              onTap: () => _pickTime(
                currentMinutes: _wakeTimeMinutes,
                onPicked: (value) => _wakeTimeMinutes = value,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Estimated sleep: ${formatDurationMinutes(_durationMinutes)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.sleepAccent,
              ),
            ),
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
          if (widget.allowDismiss)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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

class _TimePickerButton extends StatelessWidget {
  const _TimePickerButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.sleepAccent.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

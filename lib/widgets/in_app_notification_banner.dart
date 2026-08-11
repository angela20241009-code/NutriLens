import 'package:flutter/material.dart';
import 'package:nutrilens/models/in_app_notification.dart';
import 'package:nutrilens/models/reminder_kind.dart';
import 'package:nutrilens/theme/app_colors.dart';

class InAppNotificationBanner extends StatelessWidget {
  const InAppNotificationBanner({
    super.key,
    required this.notification,
    required this.onAction,
    required this.onDismiss,
  });

  final InAppNotification notification;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(notification.kind);
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(notification.kind), color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted.withValues(alpha: 0.72),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      notification.actionLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textMuted.withValues(alpha: 0.55),
              ),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ],
        ),
      ),
    );
  }

  static Color _accentFor(ReminderKind kind) {
    return switch (kind) {
      ReminderKind.event => AppColors.orange,
      ReminderKind.hydration => AppColors.hydrationBlue,
      ReminderKind.meal => AppColors.lime,
      ReminderKind.bedtime => AppColors.sleepAccent,
      ReminderKind.wake => AppColors.sleepAccent,
    };
  }

  static IconData _iconFor(ReminderKind kind) {
    return switch (kind) {
      ReminderKind.event => Icons.event_rounded,
      ReminderKind.hydration => Icons.water_drop_rounded,
      ReminderKind.meal => Icons.restaurant_rounded,
      ReminderKind.bedtime => Icons.nightlight_round,
      ReminderKind.wake => Icons.wb_sunny_rounded,
    };
  }
}

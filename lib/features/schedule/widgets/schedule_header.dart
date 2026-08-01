import 'package:flutter/material.dart';
import 'package:nutrilens/features/schedule/schedule_calendar_mode.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({
    super.key,
    required this.selectedDate,
    required this.calendarMode,
    required this.onCalendarModeToggle,
    required this.onAddTap,
  });

  final DateTime selectedDate;
  final ScheduleCalendarMode calendarMode;
  final VoidCallback onCalendarModeToggle;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthLabel = formatLocalizedMonth(context, selectedDate.month);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: onCalendarModeToggle,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: Icon(
                  calendarMode == ScheduleCalendarMode.week
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_left_rounded,
                  size: 24,
                ),
                label: Text(
                  calendarMode == ScheduleCalendarMode.week
                      ? monthLabel
                      : '$monthLabel ${selectedDate.year}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                calendarMode == ScheduleCalendarMode.week
                    ? l10n.scheduleThisWeek
                    : l10n.scheduleFullMonth,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAddTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.onLime,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

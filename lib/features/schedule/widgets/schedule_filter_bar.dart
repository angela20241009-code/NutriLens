import 'package:flutter/material.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScheduleFilterBar extends StatelessWidget {
  const ScheduleFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  final ScheduleViewFilter filter;
  final ValueChanged<ScheduleViewFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<ScheduleViewFilter>(
          segments: [
            for (final option in ScheduleViewFilter.values)
              ButtonSegment(
                value: option,
                label: Text(option.label),
              ),
          ],
          selected: {filter},
          onSelectionChanged: (selection) => onFilterChanged(selection.first),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: const [
            _LegendDot(color: scheduleLoggedMealColor, label: 'Logged meals'),
            _LegendDot(color: scheduleEventColor, label: 'Events'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

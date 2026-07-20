import 'package:flutter/material.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/theme/app_colors.dart';

class WeekDateSelector extends StatelessWidget {
  const WeekDateSelector({
    super.key,
    required this.selectedDate,
    required this.hasEventsOn,
    required this.hasLoggedMealsOn,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final DateTime selectedDate;
  final bool Function(DateTime date) hasEventsOn;
  final bool Function(DateTime date) hasLoggedMealsOn;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _startOfWeek(selectedDate);
    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    return Row(
      children: [
        _WeekNavButton(icon: Icons.chevron_left_rounded, onTap: onPreviousWeek),
        Expanded(
          child: Row(
            children: [
              for (final date in weekDays)
                Expanded(
                  child: _WeekDayCell(
                    date: date,
                    selected: _isSameDay(date, selectedDate),
                    hasEvents: hasEventsOn(date),
                    hasLoggedMeals: hasLoggedMealsOn(date),
                    onTap: () => onDateSelected(date),
                  ),
                ),
            ],
          ),
        ),
        _WeekNavButton(icon: Icons.chevron_right_rounded, onTap: onNextWeek),
      ],
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.date,
    required this.selected,
    required this.hasEvents,
    required this.hasLoggedMeals,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool hasEvents;
  final bool hasLoggedMeals;
  final VoidCallback onTap;

  static const _weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('calendar_date_${date.year}_${date.month}_${date.day}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Text(
              _weekdayLabels[date.weekday - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AppColors.lime
                    : AppColors.textMuted.withValues(alpha: 0.72),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? AppColors.lime : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.onLime : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasLoggedMeals)
                    _CalendarDot(
                      color: selected
                          ? AppColors.onLime
                          : scheduleLoggedMealColor,
                    ),
                  if (hasLoggedMeals && hasEvents) const SizedBox(width: 3),
                  if (hasEvents)
                    _CalendarDot(
                      color: selected ? AppColors.onLime : scheduleEventColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarDot extends StatelessWidget {
  const _CalendarDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _WeekNavButton extends StatelessWidget {
  const _WeekNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}

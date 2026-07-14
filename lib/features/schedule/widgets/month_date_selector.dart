import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class MonthDateSelector extends StatelessWidget {
  const MonthDateSelector({
    super.key,
    required this.selectedDate,
    required this.hasEventsOn,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final bool Function(DateTime date) hasEventsOn;
  final ValueChanged<DateTime> onDateSelected;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    // weekday is 1-7 (Mon-Sun).
    int daysBefore = firstDayOfMonth.weekday - 1;
    final startDate = firstDayOfMonth.subtract(Duration(days: daysBefore));

    int totalDaysShown = daysBefore + lastDayOfMonth.day;
    int rows = (totalDaysShown / 7).ceil();
    int itemCount = rows * 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_monthName(selectedDate.month)} ${selectedDate.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                _MonthNavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () {
                    onDateSelected(DateTime(selectedDate.year, selectedDate.month - 1, 1));
                  },
                ),
                const SizedBox(width: 8),
                _MonthNavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () {
                    onDateSelected(DateTime(selectedDate.year, selectedDate.month + 1, 1));
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final date = startDate.add(Duration(days: index));
            final isCurrentMonth = date.month == selectedDate.month;
            final selected = _isSameDay(date, selectedDate);
            final hasEvents = hasEventsOn(date);

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.lime
                      : isCurrentMonth
                          ? AppColors.cardDark
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: !selected && isCurrentMonth
                    ? Border.all(color: AppColors.cardDark, width: 1)
                    : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.onLime
                            : isCurrentMonth
                                ? AppColors.textPrimary
                                : AppColors.textMuted.withOpacity(0.5),
                      ),
                    ),
                    if (hasEvents) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.onLime : AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

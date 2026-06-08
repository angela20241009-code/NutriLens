import 'package:flutter/material.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/data/mock_schedule_data.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/edamam_meal_plan_client.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  static final DateTime _weekStart =
      MockScheduleData.anchorDate.subtract(const Duration(days: 1));

  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  UserProfile? _profile;
  MealPlanWeek? _plan;
  DateTime _selectedDate = MockScheduleData.defaultSelectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlan();
    });
  }

  Future<void> _loadPlan({bool regenerate = false}) async {
    if (regenerate) {
      setState(() {
        _refreshing = true;
        _error = null;
      });
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final scope = UserScope.of(context);
      final repository = scope.repository;
      final uid = scope.uid;
      final client =
          MealPlanScope.maybeOf(context)?.client ??
          EdamamMealPlanClient.fromEnvironment();

      final profile = await repository.getProfile(uid);
      if (profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final plan = await client.fetchWeeklyPlan(
        profile: profile,
        startDate: _weekStart,
      );

      if (!mounted) {
        return;
      }

      final previousSelectedDate = _selectedDate;
      setState(() {
        _profile = profile;
        _plan = plan;
        _selectedDate = plan.days.any(
              (day) => _isSameDay(day.date, previousSelectedDate),
            )
            ? previousSelectedDate
            : plan.days.firstOrNull?.date ?? previousSelectedDate;
        _loading = false;
        _refreshing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _refreshing = false;
        _error = '$error';
      });
    }
  }

  Future<void> _regenerate() async {
    await _loadPlan(regenerate: true);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  MealPlanDay? get _selectedDay {
    final plan = _plan;
    if (plan == null) {
      return null;
    }

    for (final day in plan.days) {
      if (_isSameDay(day.date, _selectedDate)) {
        return day;
      }
    }
    return plan.days.isNotEmpty ? plan.days.first : null;
  }

  List<DateTime> get _displayDays =>
      _plan?.days.map((day) => day.date).toList(growable: false) ??
      List.generate(7, (index) => _weekStart.add(Duration(days: index)));

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get _heroLabel {
    final profile = _profile;
    final sport = profile?.primarySportName ?? 'sport';
    return MockScheduleData.matchFor(_selectedDate) != null
        ? 'MATCH DAY NUTRITION'
        : '$sport TRAINING NUTRITION'.toUpperCase();
  }

  String get _heroHeadline {
    final profile = _profile;
    final sport = profile?.primarySportName.toLowerCase() ?? 'sport';
    final match = MockScheduleData.matchFor(_selectedDate);

    if (match != null) {
      return 'High-carb loading for your $sport match at ${MockScheduleData.formatTimeOfDay(match.time)}';
    }

    return 'Balanced fueling for your $sport training day';
  }

  String _badgeFor(MealSlot slot) {
    final match = MockScheduleData.matchFor(_selectedDate);
    if (match != null && slot == MealSlot.lunch) {
      return 'PRE-MATCH • 3H';
    }

    switch (slot) {
      case MealSlot.breakfast:
        return 'BREAKFAST';
      case MealSlot.lunch:
        return 'LUNCH';
      case MealSlot.dinner:
        return 'DINNER';
    }
  }

  String _timeFor(MealSlot slot) {
    final match = MockScheduleData.matchFor(_selectedDate);
    if (match != null) {
      switch (slot) {
        case MealSlot.breakfast:
          return '7:00 AM';
        case MealSlot.lunch:
          return '3:00 PM';
        case MealSlot.dinner:
          return '7:30 PM';
      }
    }

    switch (slot) {
      case MealSlot.breakfast:
        return '7:00 AM';
      case MealSlot.lunch:
        return '12:30 PM';
      case MealSlot.dinner:
        return '6:30 PM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final selectedDay = _selectedDay;

    return ColoredBox(
      color: const Color(0xFFF5F4EE),
      child: SafeArea(
        bottom: false,
        child: _loading && plan == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meal Plan',
                              style: TextStyle(
                                fontSize: 28,
                                height: 1.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Powered by AI • Sport-specific',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8A8A8A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _refreshing ? null : _regenerate,
                        icon: _refreshing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onLime,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Regenerate'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.lime,
                          foregroundColor: AppColors.onLime,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _DateStrip(
                    days: _displayDays,
                    selectedDate: _selectedDate,
                    onSelected: _selectDate,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 18),
                    _InlineErrorCard(
                      message: _error!,
                      onRetry: _regenerate,
                    ),
                  ],
                  if (selectedDay != null) ...[
                    const SizedBox(height: 18),
                    _HeroCard(
                      title: _heroLabel,
                      headline: _heroHeadline,
                      calories: selectedDay.totals.caloriesKcal,
                      carbs: selectedDay.totals.carbsG,
                      protein: selectedDay.totals.proteinG,
                      water: _profile?.dailyTargets.hydrationLiters ?? 0,
                    ),
                    const SizedBox(height: 18),
                    ...selectedDay.meals.map(
                      (meal) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _MealCard(
                          meal: meal,
                          badge: _badgeFor(meal.slot),
                          timeLabel: _timeFor(meal.slot),
                        ),
                      ),
                    ),
                  ],
                  if (selectedDay == null && _error == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 28),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.days,
    required this.selectedDate,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < days.length; index++) ...[
            _DayChip(
              day: days[index],
              selected: _isSameDay(days[index], selectedDate),
              onTap: () => onSelected(days[index]),
            ),
            if (index != days.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  static const _dayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final isSelected = selected;
    final dayLabel = _dayLabels[day.weekday - 1];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 64,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE4E0D8),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.lime : const Color(0xFF7B7B7B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.headline,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.water,
  });

  final String title;
  final String headline;
  final int calories;
  final int carbs;
  final int protein;
  final double water;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF101010),
            Color(0xFF050505),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: 0.18),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: AppColors.lime,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.lime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      value: calories.toString(),
                      label: 'kcal',
                    ),
                  ),
                  Expanded(
                    child: _HeroStat(
                      value: '${carbs}g',
                      label: 'Carbs',
                      valueColor: AppColors.lime,
                    ),
                  ),
                  Expanded(
                    child: _HeroStat(
                      value: '${protein}g',
                      label: 'Protein',
                    ),
                  ),
                  Expanded(
                    child: _HeroStat(
                      value: '${water.toStringAsFixed(1)}L',
                      label: 'Water',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFA1A1A1),
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.badge,
    required this.timeLabel,
  });

  final MealPlanMeal meal;
  final String badge;
  final String timeLabel;

  Color get _accentColor {
    switch (meal.slot) {
      case MealSlot.breakfast:
        return AppColors.orange;
      case MealSlot.lunch:
        return AppColors.lime;
      case MealSlot.dinner:
        return AppColors.electricBlue;
    }
  }

  String get _macroCalories => meal.recipe.calories.round().toString();

  Future<void> _openSource(BuildContext context) async {
    final sourceUrl = meal.recipe.sourceUrl;
    if (sourceUrl.isEmpty) {
      return;
    }

    final uri = Uri.parse(sourceUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the recipe source.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openSource(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _MealImage(
                    imageUrl: meal.recipe.imageUrl,
                    slot: meal.slot,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x10000000),
                          Color(0x0A000000),
                          Color(0xA0000000),
                        ],
                        stops: [0.0, 0.48, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _MealBadge(
                      label: badge,
                      backgroundColor: _accentColor,
                      textColor: badge == 'BREAKFAST' ? Colors.black : Colors.white,
                      icon: meal.slot == MealSlot.breakfast
                          ? Icons.wb_sunny_rounded
                          : Icons.local_fire_department_rounded,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _MealBadge(
                      label: timeLabel,
                      backgroundColor: Colors.black.withValues(alpha: 0.72),
                      textColor: Colors.white,
                      icon: Icons.schedule_rounded,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Text(
                      meal.recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.02,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xCC000000),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MacroPill(
                          value: _macroCalories,
                          label: 'KCAL',
                          highlighted: true,
                        ),
                      ),
                      Expanded(
                        child: _MacroValue(
                          value: '${meal.recipe.nutrition.proteinG}g',
                          label: 'PROTEIN',
                        ),
                      ),
                      Expanded(
                        child: _MacroValue(
                          value: '${meal.recipe.nutrition.carbsG}g',
                          label: 'CARBS',
                        ),
                      ),
                      Expanded(
                        child: _MacroValue(
                          value: '${meal.recipe.nutrition.fatsG}g',
                          label: 'FATS',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.link_rounded,
                        size: 16,
                        color: Color(0xFF8A8A8A),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Source: ${meal.recipe.sourceName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A8A8A),
                          ),
                        ),
                      ),
                    ],
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

class _MealImage extends StatelessWidget {
  const _MealImage({
    required this.imageUrl,
    required this.slot,
  });

  final String? imageUrl;
  final MealSlot slot;

  @override
  Widget build(BuildContext context) {
    final fallback = _PlaceholderMealImage(slot: slot);
    if (imageUrl == null || imageUrl!.isEmpty) {
      return fallback;
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            fallback,
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlaceholderMealImage extends StatelessWidget {
  const _PlaceholderMealImage({required this.slot});

  final MealSlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = switch (slot) {
      MealSlot.breakfast => [const Color(0xFFF0B54A), const Color(0xFF915D12)],
      MealSlot.lunch => [const Color(0xFF87D64C), const Color(0xFF315E12)],
      MealSlot.dinner => [const Color(0xFF5DA2FF), const Color(0xFF143E7B)],
    };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          slot == MealSlot.breakfast
              ? Icons.ramen_dining_rounded
              : slot == MealSlot.lunch
                  ? Icons.lunch_dining_rounded
                  : Icons.dinner_dining_rounded,
          size: 54,
          color: Colors.white.withValues(alpha: 0.42),
        ),
      ),
    );
  }
}

class _MealBadge extends StatelessWidget {
  const _MealBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.value,
    required this.label,
    required this.highlighted,
  });

  final String value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? AppColors.lime : const Color(0xFFF3F1EA);
    final fg = highlighted ? Colors.black : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8C8C8C),
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _MacroValue extends StatelessWidget {
  const _MacroValue({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8C8C8C),
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC7AD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meal plan unavailable',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B5B5B),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

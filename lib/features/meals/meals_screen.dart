import 'package:flutter/material.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/data/mock_schedule_data.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/edamam_meal_plan_client.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key, DateTime Function()? now}) : _nowProvider = now;

  final DateTime Function()? _nowProvider;

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  bool _foodDashboardLoading = true;
  DailySummary? _dailySummary;
  List<Meal> _loggedMeals = const [];
  UserProfile? _profile;
  MealPlanWeek? _plan;
  final Set<String> _refreshingMealKeys = {};
  late DateTime _selectedDate;

  DateTime get _today =>
      DateUtils.dateOnly(widget._nowProvider?.call() ?? DateTime.now());

  DateTime get _weekStart => _today;

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
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
      final foodDashboard = await _loadFoodDashboardData(
        repository: repository,
        uid: uid,
        profile: profile,
        date: _selectedDate,
      );

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
        _dailySummary = foodDashboard.summary;
        _loggedMeals = foodDashboard.loggedMeals;
        _plan = plan;
        _selectedDate =
            plan.days.any((day) => _isSameDay(day.date, previousSelectedDate))
            ? previousSelectedDate
            : plan.days.firstOrNull?.date ?? previousSelectedDate;
        _loading = false;
        _refreshing = false;
        _foodDashboardLoading = false;
      });
    } catch (error) {
      debugPrint('Meals data unavailable: $error');
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _refreshing = false;
        _foodDashboardLoading = false;
        _error = '$error';
      });
    }
  }

  Future<_FoodDashboardData> _loadFoodDashboardData({
    required UserRepository repository,
    required String uid,
    required UserProfile profile,
    required DateTime date,
  }) async {
    final summaryKey = dateKeyFor(date, profile.timezone);
    final summary = await repository.getDailySummary(uid, summaryKey);
    final loggedMeals = await repository.getMealsForDay(
      uid,
      date,
      profile.timezone,
    );
    return _FoodDashboardData(
      summary:
          summary ??
          DailySummary(
            uid: uid,
            dateKey: summaryKey,
            updatedAt: DateTime.now().toUtc(),
          ),
      loggedMeals: loggedMeals.reversed.toList(growable: false),
    );
  }

  Future<void> _regenerate() async {
    await _loadPlan(regenerate: true);
  }

  Future<void> _regenerateMeal(MealPlanMeal meal) async {
    final profile = _profile;
    final plan = _plan;
    final selectedDay = _selectedDay;
    if (profile == null || plan == null || selectedDay == null) {
      return;
    }

    final key = _mealRefreshKey(selectedDay.date, meal.slot);
    setState(() {
      _refreshingMealKeys.add(key);
    });

    try {
      final client =
          MealPlanScope.maybeOf(context)?.client ??
          EdamamMealPlanClient.fromEnvironment();
      final refreshedMeal = await client.regenerateMeal(
        profile: profile,
        date: selectedDay.date,
        slot: meal.slot,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _plan = _replaceMealInPlan(
          plan: plan,
          date: selectedDay.date,
          meal: refreshedMeal,
        );
        _refreshingMealKeys.remove(key);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _refreshingMealKeys.remove(key);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to refresh meal: $error')));
    }
  }

  Future<void> _selectDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _foodDashboardLoading = true;
    });
    final profile = _profile;
    if (profile == null) {
      return;
    }
    try {
      final scope = UserScope.of(context);
      final foodDashboard = await _loadFoodDashboardData(
        repository: scope.repository,
        uid: scope.uid,
        profile: profile,
        date: date,
      );
      if (!mounted) return;
      setState(() {
        _dailySummary = foodDashboard.summary;
        _loggedMeals = foodDashboard.loggedMeals;
        _foodDashboardLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dailySummary = null;
        _loggedMeals = const [];
        _foodDashboardLoading = false;
      });
    }
  }

  MealPlanWeek _replaceMealInPlan({
    required MealPlanWeek plan,
    required DateTime date,
    required MealPlanMeal meal,
  }) {
    return MealPlanWeek(
      generatedAt: plan.generatedAt,
      days: plan.days
          .map((day) {
            if (!_isSameDay(day.date, date)) {
              return day;
            }

            return MealPlanDay(
              date: day.date,
              meals: day.meals
                  .map(
                    (currentMeal) =>
                        currentMeal.slot == meal.slot ? meal : currentMeal,
                  )
                  .toList(growable: false),
            );
          })
          .toList(growable: false),
    );
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

  List<DateTime> get _displayDays {
    final planDays = _plan?.days.map((day) => day.date).toList(growable: false);
    if (planDays != null && planDays.length == 7) {
      return planDays;
    }

    return List.generate(7, (index) => _weekStart.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _mealRefreshKey(DateTime date, MealSlot slot) {
    final normalized = DateUtils.dateOnly(date);
    return '${normalized.toIso8601String()}_${slot.name}';
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
    debugPrint('Meals dashboard count: ${_loggedMeals.length}');

    return ColoredBox(
      color: const Color(0xFFF5F4EE),
      child: SafeArea(
        bottom: false,
        child: _loading && plan == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                cacheExtent: 10000,
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
                    _InlineErrorCard(message: _error!, onRetry: _regenerate),
                  ],
                  if (selectedDay != null) ...[
                    const SizedBox(height: 18),
                    _TodaysFoodDashboard(
                      selectedDate: _selectedDate,
                      targets: _profile?.dailyTargets,
                      summary: _dailySummary,
                      loggedMeals: _loggedMeals,
                      loading: _foodDashboardLoading,
                    ),
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
                          refreshing: _refreshingMealKeys.contains(
                            _mealRefreshKey(selectedDay.date, meal.slot),
                          ),
                          onRefresh: () => _regenerateMeal(meal),
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

class _FoodDashboardData {
  const _FoodDashboardData({
    required this.summary,
    required this.loggedMeals,
  });

  final DailySummary summary;
  final List<Meal> loggedMeals;
}

class _TodaysFoodDashboard extends StatelessWidget {
  const _TodaysFoodDashboard({
    required this.selectedDate,
    required this.targets,
    required this.summary,
    required this.loggedMeals,
    required this.loading,
  });

  final DateTime selectedDate;
  final DailyTargets? targets;
  final DailySummary? summary;
  final List<Meal> loggedMeals;
  final bool loading;

  bool get _isToday => DateUtils.isSameDay(selectedDate, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final totals = summary?.totals ?? const NutritionEntry();
    final dailyTargets = targets;
    final targetCalories = dailyTargets?.caloriesKcal ?? 0;
    final remainingCalories = targetCalories > 0
        ? (targetCalories - totals.caloriesKcal).clamp(0, targetCalories)
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE4E0D8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: loading
          ? const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isToday ? "Today's Food" : 'Food Dashboard',
                            style: const TextStyle(
                              fontSize: 23,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${loggedMeals.length} recently eaten meal${loggedMeals.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7F7F7F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RemainingCaloriesBadge(value: remainingCalories),
                  ],
                ),
                const SizedBox(height: 16),
                _CalorieProgress(
                  eaten: totals.caloriesKcal,
                  target: targetCalories,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MacroProgressTile(
                        label: 'Protein',
                        value: totals.proteinG,
                        target: dailyTargets?.proteinG ?? 0,
                        unit: 'g',
                        color: AppColors.electricBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MacroProgressTile(
                        label: 'Carbs',
                        value: totals.carbsG,
                        target: dailyTargets?.carbsG ?? 0,
                        unit: 'g',
                        color: AppColors.lime,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MacroProgressTile(
                        label: 'Fats',
                        value: totals.fatsG,
                        target: dailyTargets?.fatsG ?? 0,
                        unit: 'g',
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Recently eaten',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                if (loggedMeals.isEmpty)
                  const _EmptyRecentMeals()
                else
                  for (final meal in loggedMeals.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecentMealTile(meal: meal),
                    ),
              ],
            ),
    );
  }
}

class _RemainingCaloriesBadge extends StatelessWidget {
  const _RemainingCaloriesBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.lime,
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'left',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieProgress extends StatelessWidget {
  const _CalorieProgress({required this.eaten, required this.target});

  final int eaten;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (eaten / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$eaten',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 34,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              target > 0 ? 'of $target kcal' : 'kcal eaten',
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFEDEAE2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ],
    );
  }
}

class _MacroProgressTile extends StatelessWidget {
  const _MacroProgressTile({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
  });

  final String label;
  final int value;
  final int target;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$value$unit',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 19,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecentMeals extends StatelessWidget {
  const _EmptyRecentMeals();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'No meals logged yet. Your recent meals will appear here.',
        style: TextStyle(
          color: Color(0xFF777777),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RecentMealTile extends StatelessWidget {
  const _RecentMealTile({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.lime,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatTime(meal.loggedAt)} · ${meal.nutrition.proteinG}g protein',
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${meal.nutrition.caloriesKcal}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour;
    final minute = local.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
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

  static const _dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

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
          colors: [Color(0xFF101010), Color(0xFF050505)],
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
                    child: _HeroStat(value: calories.toString(), label: 'kcal'),
                  ),
                  Expanded(
                    child: _HeroStat(
                      value: '${carbs}g',
                      label: 'Carbs',
                      valueColor: AppColors.lime,
                    ),
                  ),
                  Expanded(
                    child: _HeroStat(value: '${protein}g', label: 'Protein'),
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
  const _HeroStat({required this.value, required this.label, this.valueColor});

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
    required this.refreshing,
    required this.onRefresh,
  });

  final MealPlanMeal meal;
  final String badge;
  final String timeLabel;
  final bool refreshing;
  final VoidCallback onRefresh;

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
                  _MealImage(imageUrl: meal.recipe.imageUrl, slot: meal.slot),
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
                      textColor: badge == 'BREAKFAST'
                          ? Colors.black
                          : Colors.white,
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
                          Shadow(color: Color(0xCC000000), blurRadius: 14),
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
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: refreshing ? null : onRefresh,
                        icon: refreshing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.lime,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(
                          refreshing ? 'Refreshing...' : 'Refresh meal',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.lime,
                          disabledForegroundColor: AppColors.lime.withValues(
                            alpha: 0.7,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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
  const _MealImage({required this.imageUrl, required this.slot});

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
  const _MacroValue({required this.value, required this.label});

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
  const _InlineErrorCard({required this.message, required this.onRetry});

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

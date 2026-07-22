import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';

class WeeklyFuelSummaryScreen extends StatefulWidget {
  const WeeklyFuelSummaryScreen({super.key, DateTime Function()? now})
    : _nowProvider = now;

  final DateTime Function()? _nowProvider;

  @override
  State<WeeklyFuelSummaryScreen> createState() =>
      _WeeklyFuelSummaryScreenState();
}

class _WeeklyFuelSummaryScreenState extends State<WeeklyFuelSummaryScreen> {
  Future<({UserProfile profile, List<WeeklyFuelDay> days})>? _dataFuture;

  DateTime get _today =>
      DateUtils.dateOnly(widget._nowProvider?.call() ?? DateTime.now());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    _dataFuture ??= _loadData(scope.uid, scope.repository);
  }

  Future<({UserProfile profile, List<WeeklyFuelDay> days})> _loadData(
    String uid,
    UserRepository repository,
  ) async {
    final profile = await repository.getProfile(uid);
    if (profile == null) {
      throw StateError('User profile is unavailable.');
    }

    final today = _today;
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final summaries = await repository.getDailySummariesInRange(
      uid,
      startDateKey: dateKeyFor(weekStart, profile.timezone),
      endDateKey: dateKeyFor(weekEnd, profile.timezone),
    );

    final days = List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final key = dateKeyFor(date, profile.timezone);
      return WeeklyFuelDay(
        date: date,
        dateKey: key,
        totals: summaries[key]?.totals ?? const NutritionEntry(),
        isToday: DateUtils.isSameDay(date, today),
      );
    }, growable: false);

    return (profile: profile, days: days);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text("This week's fuel"),
      ),
      body: FutureBuilder<({UserProfile profile, List<WeeklyFuelDay> days})>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load weekly fuel:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.requireData;
          final targets = data.profile.dailyTargets;
          final days = data.days;
          final loggedDays = days.where((day) => day.hasLoggedMeals).length;
          final totalCalories = days.fold<int>(
            0,
            (sum, day) => sum + day.totals.caloriesKcal,
          );
          final weeklyTarget = targets.caloriesKcal * 7;
          final averageCalories = loggedDays == 0
              ? 0
              : (totalCalories / loggedDays).round();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SummaryCard(
                loggedDays: loggedDays,
                totalCalories: totalCalories,
                weeklyTarget: weeklyTarget,
                averageCalories: averageCalories,
              ),
              const SizedBox(height: 16),
              _WeeklyCalorieChart(
                days: days,
                targetCalories: targets.caloriesKcal,
              ),
              const SizedBox(height: 16),
              _DailyBreakdownList(days: days, targets: targets),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.loggedDays,
    required this.totalCalories,
    required this.weeklyTarget,
    required this.averageCalories,
  });

  final int loggedDays;
  final int totalCalories;
  final int weeklyTarget;
  final int averageCalories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loggedDays == 0
                ? 'No meals logged yet this week.'
                : '$loggedDays of 7 days logged',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Total',
                  value: '$totalCalories',
                  suffix: ' kcal',
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Weekly target',
                  value: '$weeklyTarget',
                  suffix: ' kcal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatTile(
            label: 'Daily average',
            value: loggedDays == 0 ? '0' : '$averageCalories',
            suffix: ' kcal',
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(text: value),
              TextSpan(
                text: suffix,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyCalorieChart extends StatelessWidget {
  const _WeeklyCalorieChart({
    required this.days,
    required this.targetCalories,
  });

  final List<WeeklyFuelDay> days;
  final int targetCalories;

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxCalories = [
      targetCalories,
      ...days.map((day) => day.totals.caloriesKcal),
    ].reduce((a, b) => a > b ? a : b).clamp(1, 10000);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily calories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 148,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: _FuelBar(
                      label: _weekdayLabels[i],
                      calories: days[i].totals.caloriesKcal,
                      maxCalories: maxCalories,
                      targetCalories: targetCalories,
                      isToday: days[i].isToday,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelBar extends StatelessWidget {
  const _FuelBar({
    required this.label,
    required this.calories,
    required this.maxCalories,
    required this.targetCalories,
    required this.isToday,
  });

  final String label;
  final int calories;
  final int maxCalories;
  final int targetCalories;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final barHeight = calories <= 0 ? 6.0 : (calories / maxCalories) * 108;
    final targetTop = (1 - (targetCalories / maxCalories).clamp(0.0, 1.0)) * 108;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 108,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: targetTop,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: AppColors.lime.withValues(alpha: 0.35),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: calories > 0
                        ? AppColors.lime.withValues(alpha: isToday ? 1 : 0.72)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.lime, width: 1.5)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isToday
                  ? AppColors.lime
                  : AppColors.textMuted.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyBreakdownList extends StatelessWidget {
  const _DailyBreakdownList({
    required this.days,
    required this.targets,
  });

  final List<WeeklyFuelDay> days;
  final DailyTargets targets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (final day in days) ...[
            _DayRow(day: day, targets: targets),
            if (day != days.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.targets});

  final WeeklyFuelDay day;
  final DailyTargets targets;

  @override
  Widget build(BuildContext context) {
    final totals = day.totals;
    final dateLabel = MaterialLocalizations.of(context).formatFullDate(day.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: day.isToday
            ? AppColors.lime.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: day.isToday
            ? Border.all(color: AppColors.lime.withValues(alpha: 0.35))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.isToday ? 'Today • $dateLabel' : dateLabel,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day.hasLoggedMeals
                ? '${totals.caloriesKcal} / ${targets.caloriesKcal} kcal'
                : 'No meals logged',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (day.hasLoggedMeals) ...[
            const SizedBox(height: 6),
            Text(
              'P ${totals.proteinG}g • C ${totals.carbsG}g • F ${totals.fatsG}g',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

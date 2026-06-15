import 'package:flutter/material.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/features/home/widgets/home_header.dart';
import 'package:nutrilens/features/home/widgets/hydration_card.dart';
import 'package:nutrilens/features/home/widgets/meal_capture_card.dart';
import 'package:nutrilens/features/home/widgets/meal_plan_section.dart';
import 'package:nutrilens/features/home/widgets/next_session_card.dart';
import 'package:nutrilens/features/home/widgets/program_banner.dart';
import 'package:nutrilens/features/home/widgets/todays_fuel_card.dart';
import 'package:nutrilens/features/meals/favorite_meal_sheet.dart';
import 'package:nutrilens/features/meals/log_meal_sheet.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/edamam_meal_plan_client.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/user_repository.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    DateTime Function()? now,
    required this.onProfileTap,
    required this.onMealsTap,
  }) : _nowProvider = now;

  final DateTime Function()? _nowProvider;
  final VoidCallback onProfileTap;
  final VoidCallback onMealsTap;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  Future<HomeDashboardData>? _dataFuture;
  UserRepository? _repository;
  MealPlanClient? _mealPlanClient;
  String? _uid;

  DateTime get _today =>
      DateUtils.dateOnly(widget._nowProvider?.call() ?? DateTime.now());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    final mealPlanClient =
        MealPlanScope.maybeOf(context)?.client ??
        EdamamMealPlanClient.fromEnvironment();

    if (_dataFuture == null ||
        _repository != scope.repository ||
        _uid != scope.uid ||
        _mealPlanClient != mealPlanClient) {
      _repository = scope.repository;
      _uid = scope.uid;
      _mealPlanClient = mealPlanClient;
      _dataFuture = _loadData(
        repository: scope.repository,
        uid: scope.uid,
        mealPlanClient: mealPlanClient,
      );
    }
  }

  Future<HomeDashboardData> _loadData({
    required UserRepository repository,
    required String uid,
    required MealPlanClient mealPlanClient,
  }) async {
    final profile = await repository.getProfile(uid);
    if (profile == null) {
      throw StateError('User profile is unavailable.');
    }

    final today = _today;
    final todayKey = dateKeyFor(today, profile.timezone);
    final summary = await repository.getDailySummary(uid, todayKey);
    final loggedMeals = await repository.getMealsForDay(
      uid,
      today,
      profile.timezone,
    );

    String? mealPlanError;
    var plannedMeals = const <HomeMealPlanItem>[];
    try {
      final plan = await mealPlanClient.fetchWeeklyPlan(
        profile: profile,
        startDate: today,
      );
      final todayPlan = plan.days.firstWhere(
        (day) => DateUtils.isSameDay(day.date, today),
        orElse: () => plan.days.isNotEmpty
            ? plan.days.first
            : MealPlanDay(date: today, meals: const []),
      );
      plannedMeals = todayPlan.meals
          .map(
            (meal) => HomeMealPlanItem.fromMealPlanMeal(
              meal: meal,
              loggedMeals: loggedMeals,
            ),
          )
          .toList(growable: false);
    } catch (error) {
      mealPlanError = '$error';
      debugPrint('Home meal plan unavailable: $error');
    }

    return HomeDashboardData(
      profile: profile,
      summary:
          summary ??
          DailySummary(
            uid: uid,
            dateKey: todayKey,
            updatedAt: DateTime.now().toUtc(),
          ),
      loggedMeals: loggedMeals,
      plannedMeals: plannedMeals,
      mealPlanError: mealPlanError,
    );
  }

  Future<void> _refresh() async {
    final repository = _repository;
    final uid = _uid;
    final mealPlanClient = _mealPlanClient;
    if (repository == null || uid == null || mealPlanClient == null) {
      return;
    }

    final future = _loadData(
      repository: repository,
      uid: uid,
      mealPlanClient: mealPlanClient,
    );
    setState(() {
      _dataFuture = future;
    });
    await future;
  }

  Future<void> _openLogMealSheet() async {
    final didLogMeal = await LogMealSheet.show(context);
    if (!mounted) {
      return;
    }
    if (didLogMeal == true) {
      await _refresh();
    }
  }

  Future<void> _openFavoriteMealSheet() async {
    final result = await FavoriteMealSheet.show(context);
    if (!mounted) {
      return;
    }

    if (result == FavoriteMealSheetResult.logged) {
      await _refresh();
    } else if (result == FavoriteMealSheetResult.edit) {
      await _openLogMealSheet();
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeDashboardData>(
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
                'Failed to load home data:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.requireData;
        final profile = data.profile;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(profile: profile, onProfileTap: widget.onProfileTap),
                const SizedBox(height: 16),
                ProgramBanner(profile: profile),
                const SizedBox(height: 20),
                MealCaptureCard(
                  onManualTap: _openLogMealSheet,
                  onScanTap: () => _showComingSoon('Scan'),
                  onFavoritesTap: _openFavoriteMealSheet,
                ),
                const SizedBox(height: 16),
                TodaysFuelCard(
                  sport: profile.primarySportName,
                  totals: data.summary.totals,
                  targets: profile.dailyTargets,
                  onViewDetailsTap: widget.onMealsTap,
                ),
                const SizedBox(height: 16),
                const NextSessionCard(),
                const SizedBox(height: 24),
                MealPlanSection(
                  meals: data.plannedMeals,
                  error: data.mealPlanError,
                ),
                const SizedBox(height: 20),
                HydrationCard(
                  currentLiters: data.summary.hydrationLiters,
                  targetLiters: profile.dailyTargets.hydrationLiters,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

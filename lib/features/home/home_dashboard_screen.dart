import 'package:flutter/material.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/app/meal_plan_refresh_scope.dart';
import 'package:nutrilens/app/sleep_log_refresh_scope.dart';
import 'package:nutrilens/app/tasty_recipe_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/features/home/weekly_fuel_summary_screen.dart';
import 'package:nutrilens/features/home/widgets/home_header.dart';
import 'package:nutrilens/features/home/widgets/hydration_card.dart';
import 'package:nutrilens/features/home/widgets/meal_capture_card.dart';
import 'package:nutrilens/features/home/widgets/meal_plan_section.dart';
import 'package:nutrilens/features/home/widgets/program_banner.dart';
import 'package:nutrilens/features/home/widgets/todays_fuel_card.dart';
import 'package:nutrilens/features/home/widgets/weekly_sleep_summary_card.dart';
import 'package:nutrilens/features/meals/favorite_meal_sheet.dart';
import 'package:nutrilens/features/profile/meal_preferences_sheet.dart';
import 'package:nutrilens/features/meals/log_meal_sheet.dart';
import 'package:nutrilens/features/sleep/sleep_log_actions.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/openai_hydration_target_client.dart';
import 'package:nutrilens/services/openai_sleep_target_client.dart';
import 'package:nutrilens/services/openai_meal_plan_client.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/meal_plan_serializer.dart';
import 'package:nutrilens/services/tasty_image_meal_plan_client.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';
import 'package:nutrilens/services/user_repository.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    DateTime Function()? now,
    required this.onProfileTap,
    this.onPreferencesTap,
  }) : _nowProvider = now;

  final DateTime Function()? _nowProvider;
  final VoidCallback onProfileTap;
  final VoidCallback? onPreferencesTap;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  Future<HomeDashboardData>? _dataFuture;
  HomeDashboardData? _dashboardData;
  UserRepository? _repository;
  MealPlanClient? _mealPlanClient;
  TastyRecipeClient? _tastyRecipeClient;
  String? _uid;
  SleepLogRefreshNotifier? _sleepLogRefreshNotifier;
  int _lastSleepLogRefreshGeneration = 0;
  MealPlanRefreshNotifier? _mealPlanRefreshNotifier;
  int _lastMealPlanRefreshGeneration = 0;
  double? _cachedHydrationTargetLiters;
  String? _cachedHydrationTargetUid;
  double? _cachedSleepTargetHours;
  String? _cachedSleepTargetUid;

  DateTime get _today =>
      DateUtils.dateOnly(widget._nowProvider?.call() ?? DateTime.now());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    final mealPlanClient =
        MealPlanScope.maybeOf(context)?.client ??
        OpenAiMealPlanClient.fromEnvironment();
    final tastyClient = TastyRecipeScope.maybeOf(context)?.client;

    if (_dataFuture == null ||
        _repository != scope.repository ||
        _uid != scope.uid ||
        _mealPlanClient != mealPlanClient ||
        _tastyRecipeClient != tastyClient) {
      _repository = scope.repository;
      _uid = scope.uid;
      _mealPlanClient = mealPlanClient;
      _tastyRecipeClient = tastyClient;
      if (_cachedHydrationTargetUid != scope.uid) {
        _cachedHydrationTargetLiters = null;
        _cachedHydrationTargetUid = null;
        _cachedSleepTargetHours = null;
        _cachedSleepTargetUid = null;
      }
      _dataFuture = _loadData(
        repository: scope.repository,
        uid: scope.uid,
        mealPlanClient: mealPlanClient,
        tastyClient: tastyClient,
      );
      _trackDashboardFuture(_dataFuture!);
    }

    final sleepLogRefresh = SleepLogRefreshScope.maybeOf(context);
    if (_sleepLogRefreshNotifier != sleepLogRefresh) {
      _sleepLogRefreshNotifier?.removeListener(_handleSleepLogRefreshRequest);
      _sleepLogRefreshNotifier = sleepLogRefresh;
      _lastSleepLogRefreshGeneration = sleepLogRefresh?.generation ?? 0;
      sleepLogRefresh?.addListener(_handleSleepLogRefreshRequest);
    }

    final mealPlanRefresh = MealPlanRefreshScope.maybeOf(context);
    if (_mealPlanRefreshNotifier != mealPlanRefresh) {
      _mealPlanRefreshNotifier?.removeListener(_handleMealPlanRefreshRequest);
      _mealPlanRefreshNotifier = mealPlanRefresh;
      _lastMealPlanRefreshGeneration = mealPlanRefresh?.generation ?? 0;
      mealPlanRefresh?.addListener(_handleMealPlanRefreshRequest);
    }
  }

  @override
  void dispose() {
    _sleepLogRefreshNotifier?.removeListener(_handleSleepLogRefreshRequest);
    _mealPlanRefreshNotifier?.removeListener(_handleMealPlanRefreshRequest);
    super.dispose();
  }

  void _handleMealPlanRefreshRequest() {
    final notifier = _mealPlanRefreshNotifier;
    if (notifier == null ||
        notifier.generation == _lastMealPlanRefreshGeneration) {
      return;
    }
    _lastMealPlanRefreshGeneration = notifier.generation;
    _refresh(forceMealPlan: true);
  }

  void _handleSleepLogRefreshRequest() {
    final notifier = _sleepLogRefreshNotifier;
    if (notifier == null ||
        notifier.generation == _lastSleepLogRefreshGeneration) {
      return;
    }
    _lastSleepLogRefreshGeneration = notifier.generation;
    _refresh();
  }

  Future<HomeDashboardData> _loadData({
    required UserRepository repository,
    required String uid,
    required MealPlanClient mealPlanClient,
    TastyRecipeClient? tastyClient,
    bool forceMealPlan = false,
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

    List<WeeklySleepDay> weeklySleepDays = const [];
    List<DailySummary> recentSleepSummaries = const [];
    if (profile.sleepModeEnabled) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final summaries = await repository.getDailySummariesInRange(
        uid,
        startDateKey: dateKeyFor(weekStart, profile.timezone),
        endDateKey: dateKeyFor(weekEnd, profile.timezone),
      );
      weeklySleepDays = List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        final key = dateKeyFor(date, profile.timezone);
        return WeeklySleepDay(
          date: date,
          dateKey: key,
          sleepHours: summaries[key]?.sleepHours ?? 0,
          isToday: DateUtils.isSameDay(date, today),
        );
      }, growable: false);

      final historyStart = today.subtract(const Duration(days: 13));
      final historySummaries = await repository.getDailySummariesInRange(
        uid,
        startDateKey: dateKeyFor(historyStart, profile.timezone),
        endDateKey: todayKey,
      );
      recentSleepSummaries = historySummaries.values
          .where((summary) => summary.sleepHours > 0)
          .toList(growable: false)
        ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    }

    String? mealPlanError;
    var plannedMeals = const <HomeMealPlanItem>[];
    try {
      var plan = await mealPlanClient.fetchWeeklyPlan(
        uid: uid,
        profile: profile,
        startDate: today,
        forceRefresh: forceMealPlan,
      );
      if (tastyClient != null && plan.mealsFor(today).isNotEmpty) {
        final enriched = await enrichMealPlanWeekWithTastyImages(
          week: plan,
          tastyClient: tastyClient,
        );
        if (enriched.changed) {
          plan = enriched.week;
          await repository.saveMealPlanWeek(uid, plan);
        }
      }
      plannedMeals = plan
          .mealsFor(today)
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

    final hydrationTargetLiters = await _resolveHydrationTarget(profile);
    final sleepTargetHours = profile.sleepModeEnabled
        ? await _resolveSleepTarget(profile, recentSleepSummaries)
        : profile.dailyTargets.sleepHours;

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
      hydrationTargetLiters: hydrationTargetLiters,
      sleepTargetHours: sleepTargetHours,
      mealPlanError: mealPlanError,
      weeklySleepDays: weeklySleepDays,
    );
  }

  Future<double> _resolveSleepTarget(
    UserProfile profile,
    List<DailySummary> recentSleep,
  ) async {
    if (_cachedSleepTargetHours != null &&
        _cachedSleepTargetUid == profile.userId) {
      return _cachedSleepTargetHours!;
    }

    final target = await OpenAiSleepTargetClient.fromEnvironment()
        .fetchDailyTargetHours(profile, recentSleep: recentSleep);
    _cachedSleepTargetHours = target;
    _cachedSleepTargetUid = profile.userId;
    return target;
  }

  Future<double> _resolveHydrationTarget(UserProfile profile) async {
    if (_cachedHydrationTargetLiters != null &&
        _cachedHydrationTargetUid == profile.userId) {
      return _cachedHydrationTargetLiters!;
    }

    final target = await OpenAiHydrationTargetClient.fromEnvironment()
        .fetchDailyTargetLiters(profile);
    _cachedHydrationTargetLiters = target;
    _cachedHydrationTargetUid = profile.userId;
    return target;
  }

  void _trackDashboardFuture(Future<HomeDashboardData> future) {
    future
        .then((data) {
          if (!mounted) {
            return;
          }
          setState(() => _dashboardData = data);
        })
        .catchError((_) {});
  }

  Future<void> _updateHydrationLiters(double liters) async {
    final repository = _repository;
    final uid = _uid;
    final data = _dashboardData;
    if (repository == null || uid == null || data == null) {
      return;
    }

    setState(() {
      _dashboardData = data.copyWith(
        summary: data.summary.copyWith(hydrationLiters: liters),
      );
    });

    try {
      final todayKey = dateKeyFor(_today, data.profile.timezone);
      await repository.updateDailySummary(
        uid,
        todayKey,
        hydrationLiters: liters,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.homeUnableToSaveHydration('$error'),
            ),
          ),
        );
        await _refresh();
      }
    }
  }

  Future<void> _refresh({bool forceMealPlan = false}) async {
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
      tastyClient: _tastyRecipeClient,
      forceMealPlan: forceMealPlan,
    );
    setState(() {
      _dataFuture = future;
    });
    _trackDashboardFuture(future);
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

  Future<void> _openWeeklyFuelSummary() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => WeeklyFuelSummaryScreen(now: widget._nowProvider),
      ),
    );
  }

  Future<void> _openMealPreferencesSheet() async {
    final saved = await MealPreferencesSheet.show(context);
    if (!mounted) {
      return;
    }
    if (saved == true) {
      _cachedHydrationTargetLiters = null;
      _cachedHydrationTargetUid = null;
      await _refresh();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.homeMealPlanRefreshed),
        ),
      );
    }
  }

  Future<void> _openSleepLogDialog() async {
    final data = _dashboardData;
    if (!mounted || data == null) {
      return;
    }

    final todayKey = dateKeyFor(_today, data.profile.timezone);
    final saved = await showSleepLogDialogAndSave(
      context: context,
      profile: data.profile,
      dateKey: todayKey,
      title: AppLocalizations.of(context)!.logSleep,
      initialSleepHours: data.summary.sleepHours > 0
          ? data.summary.sleepHours
          : null,
    );
    if (saved && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _dashboardData;
    final l10n = AppLocalizations.of(context)!;

    if (data == null) {
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
                  l10n.homeFailedToLoadData('${snapshot.error}'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return _buildDashboard(data);
  }

  Widget _buildDashboard(HomeDashboardData data) {
    final profile = data.profile;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('home_dashboard_scroll'),
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
              onPreferencesTap:
                  widget.onPreferencesTap ?? _openMealPreferencesSheet,
              onFavoritesTap: _openFavoriteMealSheet,
            ),
            const SizedBox(height: 16),
            TodaysFuelCard(
              sport: profile.primarySportName,
              totals: data.summary.totals,
              targets: profile.dailyTargets,
              onViewDetailsTap: _openWeeklyFuelSummary,
            ),
            if (profile.sleepModeEnabled) ...[
              const SizedBox(height: 16),
              WeeklySleepSummaryCard(
                days: data.weeklySleepDays,
                targetHours: data.sleepTargetHours,
                onLogSleepTap: _openSleepLogDialog,
              ),
            ],
            const SizedBox(height: 24),
            MealPlanSection(
              meals: data.plannedMeals,
              error: data.mealPlanError,
            ),
            const SizedBox(height: 20),
            HydrationCard(
              currentLiters: data.summary.hydrationLiters,
              targetLiters: data.hydrationTargetLiters,
              onLitersCommitted: _updateHydrationLiters,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

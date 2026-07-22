import 'package:flutter/material.dart';
import 'package:nutrilens/app/meals_search_scope.dart';
import 'package:nutrilens/app/sleep_log_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/shell/meal_tracking_shell.dart';
import 'package:nutrilens/features/sleep/sleep_check_in_dialog.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final MealsSearchController _mealsSearchController;
  int _mealTabIndex = 0;
  bool _sleepCheckInInProgress = false;
  bool _sleepCheckInSkippedThisSession = false;
  String? _sleepCheckInHandledForDateKey;

  @override
  void initState() {
    super.initState();
    _mealsSearchController = MealsSearchController();
  }

  @override
  void dispose() {
    _mealsSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestSleepCheckIn();
    });
  }

  void _openMealsSearch(String query) {
    setState(() => _mealTabIndex = 1);
    _mealsSearchController.openSearch(query);
  }

  Future<void> _requestSleepCheckIn() async {
    if (_sleepCheckInInProgress || _sleepCheckInSkippedThisSession) {
      return;
    }

    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted || profile == null) {
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final dateKey = dateKeyFor(nowUtc, profile.timezone);
    if (_sleepCheckInHandledForDateKey == dateKey) {
      return;
    }

    final summary = await scope.repository.getDailySummary(scope.uid, dateKey);
    if (!mounted) {
      return;
    }

    if (!shouldPromptSleepCheckIn(
      profile: profile,
      todaySummary: summary,
    )) {
      _sleepCheckInHandledForDateKey = dateKey;
      return;
    }

    _sleepCheckInInProgress = true;
    final result = await SleepCheckInDialog.show(
      context: context,
      profile: profile,
      title: 'Sleep check-in',
      description:
          'How long did you sleep last night? Enter hours and minutes, or skip for now and log manually later.',
      allowDismiss: true,
    );
    if (!mounted) {
      _sleepCheckInInProgress = false;
      return;
    }

    if (result == null) {
      _sleepCheckInInProgress = false;
      return;
    }

    if (result.skipped) {
      _sleepCheckInSkippedThisSession = true;
      _sleepCheckInInProgress = false;
      return;
    }

    try {
      await scope.repository.updateDailySummary(
        scope.uid,
        dateKey,
        sleepHours: result.sleepHours,
      );
      SleepLogRefreshScope.maybeOf(context)?.requestRefresh();
      if (!mounted) {
        return;
      }
      final advice = buildSleepAdvice(
        profile: profile,
        sleepHours: result.sleepHours!,
        wakeTimeMinutes: profile.usualWakeTimeMinutes ?? 7 * 60,
        referenceUtc: nowUtc,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged ${formatSleepHours(result.sleepHours!)}. ${advice.shortLine}',
          ),
        ),
      );
      _sleepCheckInHandledForDateKey = dateKey;
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save sleep log: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _sleepCheckInInProgress = false);
      } else {
        _sleepCheckInInProgress = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MealsSearchScope(
      controller: _mealsSearchController,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: MealTrackingShell(
            selectedIndex: _mealTabIndex,
            onIndexChanged: (index) => setState(() => _mealTabIndex = index),
            onMealPlanMealTap: _openMealsSearch,
          ),
        ),
      ),
    );
  }
}

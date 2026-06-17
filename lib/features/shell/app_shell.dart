import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/sleep/sleep_check_in_dialog.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/features/shell/app_mode.dart';
import 'package:nutrilens/features/shell/meal_tracking_shell.dart';
import 'package:nutrilens/features/shell/mode_segmented_control.dart';
import 'package:nutrilens/features/shell/sleep_mode_shell.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppMode _appMode = AppMode.mealTracking;
  int _mealTabIndex = 0;
  int _sleepTabIndex = 0;
  bool _sleepCheckInStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sleepCheckInStarted) {
      return;
    }
    _sleepCheckInStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestSleepCheckIn();
    });
  }

  Future<void> _requestSleepCheckIn() async {
    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted || profile == null) {
      return;
    }

    final result = await SleepCheckInDialog.show(
      context: context,
      profile: profile,
      title: 'Sleep check-in',
      description:
          'Before you start today, log when you slept and woke up so we can adjust your recovery plan.',
      allowDismiss: false,
    );
    if (!mounted || result == null) {
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final dateKey = dateKeyFor(nowUtc, profile.timezone);
    final updatedProfile = profile.copyWith(
      usualBedtimeMinutes: result.bedtimeMinutes,
      usualWakeTimeMinutes: result.wakeTimeMinutes,
    );

    try {
      await scope.repository.updateDailySummary(
        scope.uid,
        dateKey,
        sleepHours: result.sleepHours,
      );
      await scope.repository.saveProfile(updatedProfile);
      if (!mounted) {
        return;
      }
      final advice = buildSleepAdvice(
        profile: updatedProfile,
        sleepHours: result.sleepHours,
        wakeTimeMinutes: result.wakeTimeMinutes,
        referenceUtc: nowUtc,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged ${formatSleepHours(result.sleepHours)}. ${advice.shortLine}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save sleep log: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final sleepModeEnabled = settings.sleepModeEnabled;
    final appMode = sleepModeEnabled ? _appMode : AppMode.mealTracking;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (sleepModeEnabled)
              ModeSegmentedControl(
                mode: appMode,
                style: settings.segmentControlStyle,
                onModeChanged: (mode) => setState(() => _appMode = mode),
              ),
            Expanded(
              child: appMode == AppMode.mealTracking
                  ? MealTrackingShell(
                      selectedIndex: _mealTabIndex,
                      onIndexChanged: (i) => setState(() => _mealTabIndex = i),
                    )
                  : SleepModeShell(
                      selectedIndex: _sleepTabIndex,
                      onIndexChanged: (i) => setState(() => _sleepTabIndex = i),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

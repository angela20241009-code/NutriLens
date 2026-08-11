import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutrilens/app/in_app_notification_scope.dart';
import 'package:nutrilens/app/meals_search_scope.dart';
import 'package:nutrilens/app/notification_action_scope.dart';
import 'package:nutrilens/app/sleep_log_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/shell/meal_tracking_shell.dart';
import 'package:nutrilens/features/sleep/sleep_check_in_dialog.dart';
import 'package:nutrilens/features/sleep/sleep_log_actions.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/in_app_notification.dart';
import 'package:nutrilens/models/reminder_kind.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/in_app_reminder_checker.dart';
import 'package:nutrilens/services/notification_inbox_service.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/services/notification_scheduler.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/widgets/in_app_notification_banner.dart';
import 'package:timezone/timezone.dart' as tz;

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  late final MealsSearchController _mealsSearchController;
  int _mealTabIndex = 0;
  bool _sleepCheckInInProgress = false;
  bool _sleepCheckInSkippedThisSession = false;
  String? _sleepCheckInHandledForDateKey;
  Timer? _reminderTimer;
  final Set<String> _shownReminderKeys = {};
  bool _handlingLaunchNotification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mealsSearchController = MealsSearchController();
    NotificationScheduler.instance.setResponseHandler(_handleNotificationResponse);
    _reminderTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkDueReminders(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNotifications();
      _checkDueReminders();
      _handleLaunchNotification();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderTimer?.cancel();
    NotificationScheduler.instance.setResponseHandler(null);
    _mealsSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDueReminders();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestSleepCheckIn();
    });
  }

  Future<void> _syncNotifications() async {
    try {
      final scope = UserScope.of(context);
      final profile = await scope.repository.getProfile(scope.uid);
      if (!mounted || profile == null) {
        return;
      }
      await NotificationScheduler.instance.initialize();
      await NotificationScheduler.instance.syncFromProfile(profile);
    } catch (error) {
      debugPrint('Notification sync failed: $error');
    }
  }

  Future<void> _handleLaunchNotification() async {
    if (_handlingLaunchNotification) {
      return;
    }
    _handlingLaunchNotification = true;
    try {
      final details = await NotificationScheduler.instance.launchDetails();
      final response = details?.notificationResponse;
      if (details?.didNotificationLaunchApp != true || response == null) {
        return;
      }
      if (!mounted) {
        return;
      }
      _handleNotificationResponse(response);
    } finally {
      _handlingLaunchNotification = false;
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final kind = ReminderKind.fromPayload(response.payload);
    if (kind == null || !mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final notification = _notificationForKind(kind, l10n);
    final scope = UserScope.of(context);
    final profileFuture = scope.repository.getProfile(scope.uid);
    unawaited(
      profileFuture.then((profile) async {
        if (!mounted || profile == null) {
          return;
        }
        final dateKey = dateKeyFor(DateTime.now().toUtc(), profile.timezone);
        final sourceKey = NotificationInboxService.sourceKeyForReminder(
          kind: kind,
          dateKey: dateKey,
          notificationId: response.id,
        );
        await _deliverNotification(
          repository: scope.repository,
          uid: scope.uid,
          notification: notification.copyWith(sourceKey: sourceKey),
          sourceKey: sourceKey,
          showBanner: response.notificationResponseType !=
              NotificationResponseType.selectedNotification,
          executeAction: response.notificationResponseType ==
              NotificationResponseType.selectedNotification,
        );
      }),
    );
  }

  Future<void> _checkDueReminders() async {
    if (!mounted) {
      return;
    }

    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted || profile == null) {
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final currentMinutes = _currentMinutesOfDay(profile.timezone, nowUtc);
    final dateKey = dateKeyFor(nowUtc, profile.timezone);
    final due = InAppReminderChecker.dueReminders(
      profile: profile,
      currentMinutesOfDay: currentMinutes,
      nowUtc: nowUtc,
    );

    if (due.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    for (final reminder in due) {
      final key = reminder.storageKey(dateKey);
      final notification = _notificationForKind(reminder.kind, l10n).copyWith(
        sourceKey: key,
      );
      await _deliverNotification(
        repository: scope.repository,
        uid: scope.uid,
        notification: notification,
        sourceKey: key,
        showBanner: !_shownReminderKeys.contains(key),
      );
      if (!_shownReminderKeys.contains(key)) {
        _shownReminderKeys.add(key);
        break;
      }
    }
  }

  Future<void> _deliverNotification({
    required UserRepository repository,
    required String uid,
    required InAppNotification notification,
    required String sourceKey,
    bool showBanner = true,
    bool executeAction = false,
  }) async {
    await NotificationInboxService.record(
      repository: repository,
      uid: uid,
      title: notification.title,
      body: notification.body,
      sourceKey: sourceKey,
      kind: notification.kind,
    );
    if (!mounted) {
      return;
    }
    if (showBanner) {
      InAppNotificationScope.of(context).show(notification);
    }
    if (executeAction) {
      await _handleReminderKindAction(notification.kind);
    }
  }

  Future<void> _handleReminderKindAction(ReminderKind kind) async {
    InAppNotificationScope.of(context).dismiss();
    switch (kind) {
      case ReminderKind.meal:
        if (mounted) {
          setState(() => _mealTabIndex = 2);
        }
      case ReminderKind.hydration:
        if (mounted) {
          setState(() => _mealTabIndex = 0);
        }
      case ReminderKind.event:
        if (mounted) {
          setState(() => _mealTabIndex = 3);
        }
      case ReminderKind.bedtime:
      case ReminderKind.wake:
        await _openSleepLogFromReminder();
    }
  }

  InAppNotification _notificationForKind(
    ReminderKind kind,
    AppLocalizations l10n,
  ) {
    return switch (kind) {
      ReminderKind.event => InAppNotification(
        kind: kind,
        title: l10n.inAppNotificationEventTitle,
        body: l10n.inAppNotificationEventBody,
        actionLabel: l10n.inAppNotificationEventAction,
      ),
      ReminderKind.hydration => InAppNotification(
        kind: kind,
        title: l10n.inAppNotificationHydrationTitle,
        body: l10n.inAppNotificationHydrationBody,
        actionLabel: l10n.inAppNotificationHydrationAction,
      ),
      ReminderKind.meal => InAppNotification(
        kind: kind,
        title: l10n.inAppNotificationMealTitle,
        body: l10n.inAppNotificationMealBody,
        actionLabel: l10n.inAppNotificationMealAction,
      ),
      ReminderKind.bedtime => InAppNotification(
        kind: kind,
        title: l10n.inAppNotificationBedtimeTitle,
        body: l10n.inAppNotificationBedtimeBody,
        actionLabel: l10n.inAppNotificationBedtimeAction,
      ),
      ReminderKind.wake => InAppNotification(
        kind: kind,
        title: l10n.inAppNotificationWakeTitle,
        body: l10n.inAppNotificationWakeBody,
        actionLabel: l10n.inAppNotificationWakeAction,
      ),
    };
  }

  int _currentMinutesOfDay(String timezone, DateTime instantUtc) {
    try {
      final location = tz.getLocation(timezone);
      final local = tz.TZDateTime.from(instantUtc, location);
      return local.hour * 60 + local.minute;
    } catch (_) {
      final local = instantUtc.toLocal();
      return local.hour * 60 + local.minute;
    }
  }

  void _openMealsSearch(String query) {
    setState(() => _mealTabIndex = 2);
    _mealsSearchController.openSearch(query);
  }

  Future<void> _handleInAppNotificationAction(InAppNotification notification) async {
    if (notification.sourceKey != null) {
      final scope = UserScope.of(context);
      final stored = await NotificationInboxService.record(
        repository: scope.repository,
        uid: scope.uid,
        title: notification.title,
        body: notification.body,
        sourceKey: notification.sourceKey!,
        kind: notification.kind,
      );
      if (stored != null && !stored.read) {
        await NotificationInboxService.markRead(
          repository: scope.repository,
          uid: scope.uid,
          notificationId: stored.id,
        );
      }
    }
    await _handleReminderKindAction(notification.kind);
  }

  Future<void> _openSleepLogFromReminder() async {
    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted || profile == null) {
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final todayKey = dateKeyFor(nowUtc, profile.timezone);
    final summary = await scope.repository.getDailySummary(scope.uid, todayKey);
    if (!mounted) {
      return;
    }

    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    await showSleepLogDialogAndSave(
      context: context,
      profile: profile,
      dateKey: todayKey,
      title: l10n.logSleep,
      initialSleepHours: (summary?.sleepHours ?? 0) > 0 ? summary!.sleepHours : null,
    );
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

    if (!shouldPromptSleepCheckIn(profile: profile, todaySummary: summary)) {
      _sleepCheckInHandledForDateKey = dateKey;
      return;
    }

    _sleepCheckInInProgress = true;
    final l10n = AppLocalizations.of(context)!;
    final result = await SleepCheckInDialog.show(
      context: context,
      profile: profile,
      title: l10n.logSleep,
      description: l10n.sleepCheckInDescription,
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
        l10n: l10n,
        profile: profile,
        sleepHours: result.sleepHours!,
        wakeTimeMinutes: profile.usualWakeTimeMinutes ?? 7 * 60,
        referenceUtc: nowUtc,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.sleepLogged(
              formatSleepHours(result.sleepHours!),
              advice.shortLine,
            ),
          ),
        ),
      );
      _sleepCheckInHandledForDateKey = dateKey;
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToSaveSleepLog('$error'))),
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
    final notification = InAppNotificationScope.of(context).current;

    return NotificationActionScope(
      onReminderOpened: _handleReminderKindAction,
      child: MealsSearchScope(
        controller: _mealsSearchController,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (notification != null)
                  InAppNotificationBanner(
                    notification: notification,
                    onAction: () => _handleInAppNotificationAction(notification),
                    onDismiss: InAppNotificationScope.of(context).dismiss,
                  ),
                Expanded(
                  child: MealTrackingShell(
                    selectedIndex: _mealTabIndex,
                    onIndexChanged: (index) =>
                        setState(() => _mealTabIndex = index),
                    onMealPlanMealTap: _openMealsSearch,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

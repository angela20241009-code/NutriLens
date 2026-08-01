import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/widgets/settings_section.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/notification_scheduler.dart';
import 'package:nutrilens/services/openai_sleep_target_client.dart';
import 'package:nutrilens/theme/app_colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  UserProfile? _profile;
  List<DailySummary> _recentSleep = const [];
  double? _aiSleepTargetHours;
  bool _loading = true;
  bool _saving = false;
  bool _refreshingTarget = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final scope = UserScope.of(context);
      final profile = await scope.repository.getProfile(scope.uid);
      if (!mounted) {
        return;
      }
      if (profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 13));
      final summaries = await scope.repository.getDailySummariesInRange(
        scope.uid,
        startDateKey: dateKeyFor(start, profile.timezone),
        endDateKey: dateKeyFor(end, profile.timezone),
      );

      final recentSleep = summaries.values
          .where((summary) => summary.sleepHours > 0)
          .toList(growable: false)
        ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

      final aiTarget = await OpenAiSleepTargetClient.fromEnvironment()
          .fetchDailyTargetHours(profile, recentSleep: recentSleep);

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
        _recentSleep = recentSleep;
        _aiSleepTargetHours = aiTarget;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _refreshSleepTarget() async {
    final profile = _profile;
    if (profile == null || _refreshingTarget) {
      return;
    }

    setState(() => _refreshingTarget = true);
    try {
      final target = await OpenAiSleepTargetClient.fromEnvironment()
          .fetchDailyTargetHours(profile, recentSleep: _recentSleep);
      if (!mounted) {
        return;
      }
      setState(() {
        _aiSleepTargetHours = target;
        _refreshingTarget = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _refreshingTarget = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> _applySleepTarget() async {
    final profile = _profile;
    final target = _aiSleepTargetHours;
    if (profile == null || target == null || _saving) {
      return;
    }

    setState(() => _saving = true);
    try {
      final scope = UserScope.of(context);
      final updated = profile.copyWith(
        dailyTargets: profile.dailyTargets.copyWith(
          sleepHours: target,
          source: DailyTargetsSource.manual,
          effectiveFrom: DateTime.now().toUtc(),
        ),
      );
      await scope.repository.saveProfile(updated);
      await NotificationScheduler.instance.syncFromProfile(updated);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = updated;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notificationSleepTargetApplied),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.unableToUpdateNotifications('$error'),
          ),
        ),
      );
    }
  }

  Future<void> _updateNotificationSetting({
    bool? mealRemindersEnabled,
    bool? bedtimeReminderEnabled,
    bool? wakeReminderEnabled,
  }) async {
    final profile = _profile;
    if (profile == null || _saving) {
      return;
    }

    final nextSettings = profile.notificationSettings.copyWith(
      mealRemindersEnabled: mealRemindersEnabled,
      bedtimeReminderEnabled: bedtimeReminderEnabled,
      wakeReminderEnabled: wakeReminderEnabled,
    );
    final enablingAny = nextSettings.mealRemindersEnabled ||
        nextSettings.bedtimeReminderEnabled ||
        nextSettings.wakeReminderEnabled;

    setState(() => _saving = true);
    try {
      if (enablingAny) {
        final granted = await NotificationScheduler.instance.requestPermissions();
        if (!granted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.notificationPermissionRequired,
              ),
            ),
          );
        }
      }

      final scope = UserScope.of(context);
      final updated = profile.copyWith(notificationSettings: nextSettings);
      await scope.repository.saveProfile(updated);
      await NotificationScheduler.instance.syncFromProfile(updated);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = updated;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.unableToUpdateNotifications('$error'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.unableToLoadSettings(_error!),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final profile = _profile!;
    final settings = profile.notificationSettings;
    final isBusy = _saving;
    final aiTarget = _aiSleepTargetHours;
    final currentTarget = profile.dailyTargets.sleepHours;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SettingsSection(
          title: l10n.notificationRemindersSection,
          children: [
            SettingsRow(
              label: l10n.notificationMealReminders,
              trailing: Switch(
                value: settings.mealRemindersEnabled,
                activeThumbColor: AppColors.lime,
                onChanged: isBusy
                    ? null
                    : (enabled) => _updateNotificationSetting(
                        mealRemindersEnabled: enabled,
                      ),
              ),
              showChevron: false,
              onTap: isBusy
                  ? null
                  : () => _updateNotificationSetting(
                      mealRemindersEnabled: !settings.mealRemindersEnabled,
                    ),
            ),
            SettingsRow(
              label: l10n.notificationBedtimeReminder,
              trailing: Switch(
                value: settings.bedtimeReminderEnabled,
                activeThumbColor: AppColors.sleepAccent,
                onChanged: isBusy
                    ? null
                    : (enabled) => _updateNotificationSetting(
                        bedtimeReminderEnabled: enabled,
                      ),
              ),
              showChevron: false,
              onTap: isBusy
                  ? null
                  : () => _updateNotificationSetting(
                      bedtimeReminderEnabled: !settings.bedtimeReminderEnabled,
                    ),
            ),
            SettingsRow(
              label: l10n.notificationWakeReminder,
              trailing: Switch(
                value: settings.wakeReminderEnabled,
                activeThumbColor: AppColors.sleepAccent,
                onChanged: isBusy
                    ? null
                    : (enabled) => _updateNotificationSetting(
                        wakeReminderEnabled: enabled,
                      ),
              ),
              showChevron: false,
              showDivider: false,
              onTap: isBusy
                  ? null
                  : () => _updateNotificationSetting(
                      wakeReminderEnabled: !settings.wakeReminderEnabled,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SettingsSection(
          title: l10n.notificationSleepTargetSection,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationSleepTargetDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sleepTarget,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              aiTarget == null
                                  ? '—'
                                  : l10n.notificationSleepTargetValue(
                                      formatSleepHours(aiTarget),
                                    ),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.sleepAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.notificationSleepTargetCurrent(
                                formatSleepHours(currentTarget),
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _refreshingTarget || isBusy
                            ? null
                            : _refreshSleepTarget,
                        tooltip: l10n.notificationSleepTargetRefresh,
                        icon: _refreshingTarget
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: aiTarget == null ||
                              isBusy ||
                              (aiTarget - currentTarget).abs() < 0.05
                          ? null
                          : _applySleepTarget,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sleepAccent,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      child: Text(l10n.notificationSleepTargetApply),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/widgets/settings_section.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/notification_scheduler.dart';
import 'package:nutrilens/theme/app_colors.dart';

class NotificationReminderSwitches extends StatefulWidget {
  const NotificationReminderSwitches({super.key});

  @override
  State<NotificationReminderSwitches> createState() =>
      _NotificationReminderSwitchesState();
}

class _NotificationReminderSwitchesState
    extends State<NotificationReminderSwitches> {
  NotificationSettings? _settings;
  bool _loading = true;
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
      setState(() {
        _settings = profile.notificationSettings;
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

  Future<void> _updateSetting({
    bool? eventRemindersEnabled,
    bool? hydrationRemindersEnabled,
    bool? sleepRemindersEnabled,
    bool? mealRemindersEnabled,
  }) async {
    final previousSettings = _settings;
    if (previousSettings == null) {
      return;
    }

    final nextSettings = previousSettings.copyWith(
      eventRemindersEnabled: eventRemindersEnabled,
      hydrationRemindersEnabled: hydrationRemindersEnabled,
      sleepRemindersEnabled: sleepRemindersEnabled,
      mealRemindersEnabled: mealRemindersEnabled,
    );

    setState(() => _settings = nextSettings);

    try {
      if (nextSettings.anyEnabled) {
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
      final profile = await scope.repository.getProfile(scope.uid);
      if (!mounted || profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final updated = profile.copyWith(notificationSettings: nextSettings);
      await scope.repository.saveProfile(updated);
      await NotificationScheduler.instance.syncFromProfile(updated);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _settings = previousSettings);
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.unableToLoadSettings(_error!),
          textAlign: TextAlign.center,
        ),
      );
    }

    final settings = _settings!;

    return SettingsSection(
      title: l10n.notificationRemindersSection,
      children: [
        SettingsRow(
          label: l10n.notificationEventReminders,
          trailing: _RainbowSwitch(
            value: settings.eventRemindersEnabled,
            onChanged: (enabled) =>
                _updateSetting(eventRemindersEnabled: enabled),
          ),
          showChevron: false,
        ),
        SettingsRow(
          label: l10n.notificationHydrationReminders,
          trailing: Switch(
            value: settings.hydrationRemindersEnabled,
            activeThumbColor: AppColors.hydrationBlue,
            onChanged: (enabled) =>
                _updateSetting(hydrationRemindersEnabled: enabled),
          ),
          showChevron: false,
        ),
        SettingsRow(
          label: l10n.notificationSleepReminders,
          trailing: Switch(
            value: settings.sleepRemindersEnabled,
            activeThumbColor: AppColors.sleepAccent,
            onChanged: (enabled) =>
                _updateSetting(sleepRemindersEnabled: enabled),
          ),
          showChevron: false,
        ),
        SettingsRow(
          label: l10n.notificationMealReminders,
          trailing: Switch(
            value: settings.mealRemindersEnabled,
            activeThumbColor: AppColors.lime,
            onChanged: (enabled) => _updateSetting(mealRemindersEnabled: enabled),
          ),
          showChevron: false,
          showDivider: false,
        ),
      ],
    );
  }
}

class _RainbowSwitch extends StatelessWidget {
  const _RainbowSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _rainbowGradient = LinearGradient(
    colors: [
      AppColors.hydrationBlue,
      AppColors.sleepAccent,
      AppColors.lime,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 2,
            right: 2,
            top: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: value ? _rainbowGradient : null,
                color: value ? null : AppColors.textMuted.withValues(alpha: 0.22),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeThumbColor: AppColors.textPrimary,
            inactiveThumbColor: AppColors.textPrimary.withValues(alpha: 0.75),
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

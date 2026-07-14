import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/features/sleep/sleep_log_screen.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:timezone/timezone.dart' as tz;

class SleepDashboardScreen extends StatefulWidget {
  const SleepDashboardScreen({super.key});

  @override
  State<SleepDashboardScreen> createState() => _SleepDashboardScreenState();
}

class _SleepDashboardScreenState extends State<SleepDashboardScreen> {
  Future<UserProfile?>? _profileFuture;
  int? _draftBedtimeMinutes;
  int? _draftWakeTimeMinutes;
  bool _savingSchedule = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileFuture ??= _loadProfile();
  }

  Future<UserProfile?> _loadProfile() {
    final scope = UserScope.of(context);
    return scope.repository.getProfile(scope.uid);
  }

  Future<void> _pickTime({
    required int? initialMinutes,
    required ValueChanged<int> onSelected,
  }) async {
    final initial = _timeOfDayFromMinutes(initialMinutes ?? 22 * 60);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) {
      return;
    }
    setState(() => onSelected(_minutesFromTimeOfDay(picked)));
  }

  Future<void> _saveSleepSchedule(UserProfile profile) async {
    final bedtime = _draftBedtimeMinutes ?? profile.usualBedtimeMinutes;
    final wakeTime = _draftWakeTimeMinutes ?? profile.usualWakeTimeMinutes;
    if (bedtime == null || wakeTime == null || _savingSchedule) {
      return;
    }

    final scope = UserScope.of(context);
    setState(() => _savingSchedule = true);

    try {
      await scope.repository.saveProfile(
        profile.copyWith(
          usualBedtimeMinutes: bedtime,
          usualWakeTimeMinutes: wakeTime,
        ),
      );
      if (!mounted) return;
      setState(() {
        _draftBedtimeMinutes = null;
        _draftWakeTimeMinutes = null;
        _savingSchedule = false;
        _profileFuture = _loadProfile();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _savingSchedule = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save sleep schedule: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingFor(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${_displayName(profile)} 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Sleep mode',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.sleepAccent.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              if (snapshot.connectionState != ConnectionState.done)
                const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (profile == null)
                const _SleepInfoCard(
                  title: 'Profile unavailable',
                  body: 'We need your profile before planning sleep.',
                )
              else ...[
                _WakeTimePlanningCard(
                  profile: profile,
                  draftBedtimeMinutes: _draftBedtimeMinutes,
                  draftWakeTimeMinutes: _draftWakeTimeMinutes,
                  saving: _savingSchedule,
                  onPickBedtime: () => _pickTime(
                    initialMinutes:
                        _draftBedtimeMinutes ?? profile.usualBedtimeMinutes,
                    onSelected: (value) => _draftBedtimeMinutes = value,
                  ),
                  onPickWakeTime: () => _pickTime(
                    initialMinutes:
                        _draftWakeTimeMinutes ?? profile.usualWakeTimeMinutes,
                    onSelected: (value) => _draftWakeTimeMinutes = value,
                  ),
                  onSave: () => _saveSleepSchedule(profile),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const _SleepSchedulePage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sleepAccent,
                      side: const BorderSide(color: AppColors.sleepAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Log sleep',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _displayName(UserProfile? profile) {
    final firstName = profile?.firstName?.trim();
    if (firstName != null && firstName.isNotEmpty) {
      return firstName;
    }

    final displayName = profile?.displayName.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(RegExp(r'\s+')).first;
    }

    return 'Athlete';
  }

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }
}

class _SleepSchedulePage extends StatelessWidget {
  const _SleepSchedulePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: _SleepScheduleAppBar(),
      body: SafeArea(top: false, child: SleepLogScreen()),
    );
  }
}

class _SleepScheduleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _SleepScheduleAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      title: const Text('Sleep Schedule'),
    );
  }
}

class _WakeTimePlanningCard extends StatelessWidget {
  const _WakeTimePlanningCard({
    required this.profile,
    required this.draftBedtimeMinutes,
    required this.draftWakeTimeMinutes,
    required this.saving,
    required this.onPickBedtime,
    required this.onPickWakeTime,
    required this.onSave,
  });

  final UserProfile profile;
  final int? draftBedtimeMinutes;
  final int? draftWakeTimeMinutes;
  final bool saving;
  final VoidCallback onPickBedtime;
  final VoidCallback onPickWakeTime;
  final VoidCallback onSave;

  bool get _hasSchedule =>
      profile.usualBedtimeMinutes != null &&
      profile.usualWakeTimeMinutes != null;

  @override
  Widget build(BuildContext context) {
    final bedtime = draftBedtimeMinutes ?? profile.usualBedtimeMinutes;
    final wakeTime = draftWakeTimeMinutes ?? profile.usualWakeTimeMinutes;
    final canSave = bedtime != null && wakeTime != null && !saving;
    final plan = _hasSchedule ? _WakePlan.fromProfile(profile) : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sleepAccentMuted,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sleepAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.sleepAccent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.alarm_rounded,
              color: AppColors.sleepAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _hasSchedule ? 'Wake-time planning' : 'Set your sleep schedule',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _hasSchedule
                ? 'We use your usual bedtime and wake time to protect recovery before training and match days.'
                : 'Add your usual bedtime and wake time so Sleep Mode can plan recovery and track sleep statistics.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TimeValueButton(
                  label: 'Bedtime',
                  value: bedtime == null ? 'Add' : _formatMinutes(bedtime),
                  onTap: onPickBedtime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeValueButton(
                  label: 'Wake time',
                  value: wakeTime == null ? 'Add' : _formatMinutes(wakeTime),
                  onTap: onPickWakeTime,
                ),
              ),
            ],
          ),
          if (!_hasSchedule ||
              draftBedtimeMinutes != null ||
              draftWakeTimeMinutes != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSave ? onSave : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sleepAccent,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save sleep schedule'),
              ),
            ),
          ],
          if (plan != null) ...[
            const SizedBox(height: 18),
            _WakePlanSummary(plan: plan),
          ],
        ],
      ),
    );
  }
}

class _TimeValueButton extends StatelessWidget {
  const _TimeValueButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.sleepAccent.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _WakePlanSummary extends StatelessWidget {
  const _WakePlanSummary({required this.plan});

  final _WakePlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.sleepAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanMetric(label: 'Target sleep', value: plan.targetSleepLabel),
          const SizedBox(height: 12),
          _PlanMetric(label: 'Tonight bedtime', value: plan.bedtimeLabel),
          const SizedBox(height: 12),
          _PlanMetric(label: 'Wake time', value: plan.wakeTimeLabel),
          if (plan.reason != null) ...[
            const SizedBox(height: 12),
            Text(
              plan.reason!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.sleepAccent,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SleepInfoCard extends StatelessWidget {
  const _SleepInfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WakePlan {
  const _WakePlan({
    required this.targetSleepLabel,
    required this.bedtimeLabel,
    required this.wakeTimeLabel,
    this.reason,
  });

  final String targetSleepLabel;
  final String bedtimeLabel;
  final String wakeTimeLabel;
  final String? reason;

  factory _WakePlan.fromProfile(UserProfile profile) {
    final targetMinutes = (profile.dailyTargets.sleepHours * 60).round();
    final defaultWake = profile.usualWakeTimeMinutes!;
    final nextEvent = _nextTrainingOrMatch(profile);
    var wakeMinutes = defaultWake;
    String? reason;

    if (nextEvent != null) {
      final eventLocal = _localDateTimeFor(nextEvent.startAt, profile.timezone);
      final eventMinutes = eventLocal.hour * 60 + eventLocal.minute;
      final prepWake = (eventMinutes - 120).clamp(0, 24 * 60 - 1);
      if (prepWake < wakeMinutes) {
        wakeMinutes = prepWake;
        reason =
            'Earlier wake suggested for ${nextEvent.title} at ${_formatMinutes(eventMinutes)}.';
      }
    }

    final bedtime = (wakeMinutes - targetMinutes) % (24 * 60);
    return _WakePlan(
      targetSleepLabel: _formatDurationMinutes(targetMinutes),
      bedtimeLabel: _formatMinutes(bedtime),
      wakeTimeLabel: _formatMinutes(wakeMinutes),
      reason: reason,
    );
  }
}

UserScheduleEvent? _nextTrainingOrMatch(UserProfile profile) {
  final now = DateTime.now().toUtc();
  final cutoff = now.add(const Duration(hours: 36));
  final upcoming =
      profile.scheduleEvents
          .where(
            (event) =>
                (event.type == ScheduleEventType.training ||
                    event.type == ScheduleEventType.match) &&
                event.startAt.isAfter(now) &&
                event.startAt.isBefore(cutoff),
          )
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));
  return upcoming.firstOrNull;
}

DateTime _localDateTimeFor(DateTime instant, String timezone) {
  try {
    final location = tz.getLocation(timezone);
    return tz.TZDateTime.from(instant.toUtc(), location);
  } catch (_) {
    return instant.toLocal();
  }
}

TimeOfDay _timeOfDayFromMinutes(int minutes) {
  final normalized = minutes % (24 * 60);
  return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
}

int _minutesFromTimeOfDay(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

String _formatDurationMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (remainder == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainder}m';
}

String _formatMinutes(int minutes) {
  final time = _timeOfDayFromMinutes(minutes);
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

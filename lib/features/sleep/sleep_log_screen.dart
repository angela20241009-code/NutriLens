import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/sleep/sleep_check_in_dialog.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:timezone/timezone.dart' as tz;

class SleepLogScreen extends StatefulWidget {
  const SleepLogScreen({super.key});

  @override
  State<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends State<SleepLogScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  UserProfile? _profile;
  String? _todayKey;
  List<_SleepLogEntry> _recentEntries = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _profile == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final scope = UserScope.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await scope.repository.getProfile(scope.uid);
      if (profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final nowUtc = DateTime.now().toUtc();
      final todayKey = dateKeyFor(nowUtc, profile.timezone);
      final keys = _recentDateKeys(profile.timezone, nowUtc, count: 7);
      final summaries = await Future.wait(
        keys.map((key) => scope.repository.getDailySummary(scope.uid, key)),
      );

      if (!mounted) {
        return;
      }

      final entries = <_SleepLogEntry>[];
      for (var i = 0; i < keys.length; i++) {
        final key = keys[i];
        entries.add(
          _SleepLogEntry(
            dateKey: key,
            sleepHours: summaries[i]?.sleepHours ?? 0,
            isToday: key == todayKey,
          ),
        );
      }

      setState(() {
        _profile = profile;
        _todayKey = todayKey;
        _recentEntries = entries;
        _loading = false;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = '$error';
        _saving = false;
      });
    }
  }

  Future<void> _updateTodaySleep() async {
    final profile = _profile;
    final todayKey = _todayKey;
    if (profile == null || todayKey == null || _saving) {
      return;
    }

    final result = await SleepCheckInDialog.show(
      context: context,
      profile: profile,
      title: 'Update sleep log',
      description:
          'Enter your bedtime and wake time. We will calculate your sleep hours automatically.',
    );
    if (result == null || !mounted) {
      return;
    }

    final scope = UserScope.of(context);
    final updatedProfile = profile.copyWith(
      usualBedtimeMinutes: result.bedtimeMinutes,
      usualWakeTimeMinutes: result.wakeTimeMinutes,
    );

    setState(() => _saving = true);
    try {
      await scope.repository.updateDailySummary(
        scope.uid,
        todayKey,
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
        referenceUtc: DateTime.now().toUtc(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged ${formatSleepHours(result.sleepHours)}. ${advice.shortLine}',
          ),
        ),
      );
      setState(() => _profile = updatedProfile);
      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update sleep log: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to load sleep log:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const Center(child: Text('Profile unavailable'));
    }

    final todayEntry = _recentEntries.firstWhere(
      (entry) => entry.isToday,
      orElse: () =>
          const _SleepLogEntry(dateKey: '', sleepHours: 0, isToday: true),
    );
    final hasTodaySleep = todayEntry.sleepHours > 0;
    final advice = hasTodaySleep
        ? buildSleepAdvice(
            profile: profile,
            sleepHours: todayEntry.sleepHours,
            wakeTimeMinutes: profile.usualWakeTimeMinutes ?? 7 * 60,
            referenceUtc: DateTime.now().toUtc(),
          )
        : null;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Sleep log', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Each login asks for bedtime and wake time, then computes sleep automatically.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const _AutoTrackingStatusCard(),
          const SizedBox(height: 16),
          _TodaySummaryCard(
            sleepLabel: hasTodaySleep
                ? formatSleepHours(todayEntry.sleepHours)
                : 'Not logged yet',
            advice: advice,
            saving: _saving,
            onUpdatePressed: _updateTodaySleep,
          ),
          const SizedBox(height: 16),
          Text('Last 7 days', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final entry in _recentEntries) ...[
            _HistoryTile(entry: entry),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SleepLogEntry {
  const _SleepLogEntry({
    required this.dateKey,
    required this.sleepHours,
    required this.isToday,
  });

  final String dateKey;
  final double sleepHours;
  final bool isToday;
}

class _AutoTrackingStatusCard extends StatelessWidget {
  const _AutoTrackingStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sleepAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Automatic tracking status',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Clock-only background tracking is not reliable on iOS/Android due background limits. '
            'The robust path is Apple Health or Health Connect sync.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({
    required this.sleepLabel,
    required this.advice,
    required this.saving,
    required this.onUpdatePressed,
  });

  final String sleepLabel;
  final SleepAdvice? advice;
  final bool saving;
  final VoidCallback onUpdatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sleepAccentMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sleepAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            sleepLabel,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          if (advice != null) ...[
            const SizedBox(height: 10),
            Text(
              advice!.title,
              style: const TextStyle(
                color: AppColors.sleepAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(advice!.details, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: saving ? null : onUpdatePressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sleepAccent,
              foregroundColor: AppColors.textPrimary,
            ),
            child: saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update today sleep'),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final _SleepLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final parsedDate = _parseDateKey(entry.dateKey);
    final dateLabel = parsedDate == null
        ? entry.dateKey
        : '${_weekdayLabel(parsedDate)}, ${parsedDate.month}/${parsedDate.day}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.isToday ? '$dateLabel (Today)' : dateLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            entry.sleepHours > 0 ? formatSleepHours(entry.sleepHours) : '--',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

List<String> _recentDateKeys(
  String timezone,
  DateTime nowUtc, {
  required int count,
}) {
  tz.Location? location;
  try {
    location = tz.getLocation(timezone);
  } catch (_) {
    location = null;
  }

  final keys = <String>[];
  if (location != null) {
    final today = tz.TZDateTime.from(nowUtc, location);
    for (var i = 0; i < count; i++) {
      final localMidday = tz.TZDateTime(
        location,
        today.year,
        today.month,
        today.day - i,
        12,
      );
      keys.add(dateKeyFor(localMidday.toUtc(), timezone));
    }
    return keys;
  }

  final localToday = DateTime(nowUtc.year, nowUtc.month, nowUtc.day);
  for (var i = 0; i < count; i++) {
    final day = localToday
        .subtract(Duration(days: i))
        .add(const Duration(hours: 12));
    keys.add(dateKeyFor(day.toUtc(), timezone));
  }
  return keys;
}

DateTime? _parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) {
    return null;
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }
  return DateTime(year, month, day);
}

String _weekdayLabel(DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return '';
  }
}

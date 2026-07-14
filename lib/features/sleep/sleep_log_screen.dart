import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
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
  static const _maxSleepMinutes = 14 * 60 + 55;
  static const _maxCustomBedtimeItems = 3;
  static const _minuteOptions = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
  static const _presetBedtimeMinutes = [
    21 * 60,
    21 * 60 + 30,
    22 * 60,
    22 * 60 + 30,
    23 * 60,
  ];

  bool _loading = true;
  bool _saving = false;
  String? _error;
  UserProfile? _profile;
  List<_SleepCalendarDay> _calendarDays = const [];
  List<int> _customBedtimeMinutes = const [];
  int _selectedDayIndex = 0;
  int _durationMinutes = 8 * 60;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profile == null && _loading) {
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
      final dateKeys = _calendarDateKeys(profile.timezone, nowUtc);
      final summaries = await Future.wait(
        dateKeys.map((key) => scope.repository.getDailySummary(scope.uid, key)),
      );

      if (!mounted) {
        return;
      }

      final days = <_SleepCalendarDay>[];
      for (var i = 0; i < dateKeys.length; i++) {
        final key = dateKeys[i];
        days.add(
          _SleepCalendarDay(
            dateKey: key,
            sleepHours: summaries[i]?.sleepHours ?? 0,
            isToday: i == 6,
          ),
        );
      }

      final todayIndex = days.indexWhere((day) => day.isToday);
      final selectedIndex = todayIndex == -1 ? 0 : todayIndex;
      final initialMinutes = _durationMinutesForDay(
        days[selectedIndex].sleepHours,
        profile.dailyTargets.sleepHours,
      );

      setState(() {
        _profile = profile;
        _calendarDays = days;
        _customBedtimeMinutes = _normalizedBedtimeList(
          profile.customBedtimePresetMinutes,
        );
        _selectedDayIndex = selectedIndex;
        _durationMinutes = initialMinutes;
        _loading = false;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '$error';
        _loading = false;
        _saving = false;
      });
    }
  }

  void _selectDay(int index) {
    final profile = _profile;
    if (profile == null || index < 0 || index >= _calendarDays.length) {
      return;
    }
    final selected = _calendarDays[index];
    setState(() {
      _selectedDayIndex = index;
      _durationMinutes = _durationMinutesForDay(
        selected.sleepHours,
        profile.dailyTargets.sleepHours,
      );
    });
  }

  void _setDurationMinutes(int minutes) {
    setState(() {
      _durationMinutes = _normalizeDurationMinutes(minutes);
    });
  }

  void _applyBedtimeMinutes(int bedtimeMinutes, int wakeTimeMinutes) {
    final duration = sleepDurationMinutes(
      bedtimeMinutes: bedtimeMinutes,
      wakeTimeMinutes: wakeTimeMinutes,
    );
    _setDurationMinutes(duration);
  }

  Future<void> _addCustomBedtimeItem() async {
    if (_customBedtimeMinutes.length >= _maxCustomBedtimeItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add up to 3 custom bedtime items.'),
        ),
      );
      return;
    }

    final chosen = await _showBedtimeEditorDialog();
    if (chosen == null) {
      return;
    }
    await _saveCustomBedtimeItems([..._customBedtimeMinutes, chosen]);
    final wake = _profile?.usualWakeTimeMinutes ?? 7 * 60;
    _applyBedtimeMinutes(chosen, wake);
  }

  Future<void> _editCustomBedtimeItem(int index) async {
    if (index < 0 || index >= _customBedtimeMinutes.length) {
      return;
    }
    final chosen = await _showBedtimeEditorDialog(
      initialMinutes: _customBedtimeMinutes[index],
    );
    if (chosen == null) {
      return;
    }

    final updated = [..._customBedtimeMinutes];
    updated[index] = chosen;
    await _saveCustomBedtimeItems(updated);
    final wake = _profile?.usualWakeTimeMinutes ?? 7 * 60;
    _applyBedtimeMinutes(chosen, wake);
  }

  Future<void> _deleteCustomBedtimeItem(int index) async {
    if (index < 0 || index >= _customBedtimeMinutes.length) {
      return;
    }
    final updated = [..._customBedtimeMinutes]..removeAt(index);
    await _saveCustomBedtimeItems(updated);
  }

  Future<void> _saveCustomBedtimeItems(List<int> candidateItems) async {
    final profile = _profile;
    if (profile == null || _saving) {
      return;
    }
    final normalized = _normalizedBedtimeList(candidateItems);
    final scope = UserScope.of(context);
    setState(() => _saving = true);
    try {
      final updatedProfile = profile.copyWith(
        customBedtimePresetMinutes: normalized,
      );
      await scope.repository.saveProfile(updatedProfile);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = updatedProfile;
        _customBedtimeMinutes = normalized;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save bedtime items: $error')),
      );
    }
  }

  Future<int?> _showBedtimeEditorDialog({int? initialMinutes}) async {
    var selectedMinutes = _normalizeBedtimeMinutes(initialMinutes ?? 22 * 60);
    final controller = TextEditingController(
      text: formatMinutesAsClock(selectedMinutes),
    );
    String? errorMessage;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: selectedMinutes ~/ 60,
                  minute: selectedMinutes % 60,
                ),
              );
              if (picked == null) {
                return;
              }
              final minutes = _normalizeBedtimeMinutes(
                picked.hour * 60 + picked.minute,
              );
              setDialogState(() {
                selectedMinutes = minutes;
                controller.text = formatMinutesAsClock(minutes);
                errorMessage = null;
              });
            }

            void save() {
              final parsed = _parseTimeInput(controller.text);
              if (parsed == null) {
                setDialogState(() {
                  errorMessage = 'Enter a valid time like 10:30 PM or 22:30.';
                });
                return;
              }
              Navigator.of(context).pop(_normalizeBedtimeMinutes(parsed));
            }

            return AlertDialog(
              backgroundColor: AppColors.cardDark,
              title: Text(
                initialMinutes == null
                    ? 'Add custom bedtime'
                    : 'Edit custom bedtime',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Bedtime',
                      hintText: '10:30 PM or 22:30',
                    ),
                    onSubmitted: (_) => save(),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: pickTime,
                    icon: const Icon(Icons.access_time),
                    label: const Text('Pick time'),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: AppColors.orange),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(onPressed: save, child: const Text('Save')),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _saveSelectedDay() async {
    await _saveToDays([_selectedDayIndex]);
  }

  Future<void> _applyToNextWeek() async {
    final start = _selectedDayIndex;
    final end = (start + 6).clamp(0, _calendarDays.length - 1);
    final indices = <int>[];
    for (var i = start; i <= end; i++) {
      indices.add(i);
    }
    await _saveToDays(indices);
  }

  Future<void> _saveToDays(List<int> indices) async {
    final profile = _profile;
    if (profile == null || _saving || indices.isEmpty) {
      return;
    }

    final scope = UserScope.of(context);
    final sleepHours = _durationMinutes / 60;
    final targets = indices
        .where((index) => index >= 0 && index < _calendarDays.length)
        .map((index) => _calendarDays[index])
        .toList(growable: false);
    if (targets.isEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      await Future.wait(
        targets.map(
          (day) => scope.repository.updateDailySummary(
            scope.uid,
            day.dateKey,
            sleepHours: sleepHours,
          ),
        ),
      );
      if (!mounted) {
        return;
      }

      final selectedSet = targets.map((day) => day.dateKey).toSet();
      final updatedDays = _calendarDays
          .map((day) {
            if (!selectedSet.contains(day.dateKey)) {
              return day;
            }
            return day.copyWith(sleepHours: sleepHours);
          })
          .toList(growable: false);

      final selectedDay = updatedDays[_selectedDayIndex];
      final advice = buildSleepAdvice(
        profile: profile,
        sleepHours: sleepHours,
        wakeTimeMinutes: profile.usualWakeTimeMinutes ?? 7 * 60,
        referenceUtc: DateTime.now().toUtc(),
      );

      setState(() {
        _calendarDays = updatedDays;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            indices.length == 1
                ? 'Saved ${formatSleepHours(sleepHours)} for ${_labelForDateKey(selectedDay.dateKey)}. ${advice.shortLine}'
                : 'Applied ${formatSleepHours(sleepHours)} to ${targets.length} days. ${advice.shortLine}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save sleep schedule: $error')),
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
            'Unable to load sleep schedule:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final profile = _profile;
    if (profile == null || _calendarDays.isEmpty) {
      return const Center(child: Text('Sleep schedule unavailable'));
    }

    final selectedDay = _calendarDays[_selectedDayIndex];
    final wakeTimeMinutes = profile.usualWakeTimeMinutes ?? 7 * 60;
    final selectedSleepHours = _durationMinutes / 60;
    final advice = buildSleepAdvice(
      profile: profile,
      sleepHours: selectedSleepHours,
      wakeTimeMinutes: wakeTimeMinutes,
      referenceUtc: DateTime.now().toUtc(),
    );

    final hours = _durationMinutes ~/ 60;
    final minutes = _durationMinutes % 60;
    final selectedBedtimeMinutes = normalizeMinutes(
      wakeTimeMinutes - _durationMinutes,
    );
    final targetMinutes = _normalizeDurationMinutes(
      (profile.dailyTargets.sleepHours * 60).round(),
    );
    final quickDurations = _dedupQuickDurations([
      targetMinutes,
      6 * 60,
      7 * 60,
      8 * 60,
      9 * 60,
    ]);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Sleep schedule',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a day, enter hours and minutes, then save one day or apply the same sleep duration for the next week.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const _AutoTrackingStatusCard(),
          const SizedBox(height: 16),
          _CalendarStrip(
            days: _calendarDays,
            selectedIndex: _selectedDayIndex,
            onSelected: _selectDay,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sleepAccentMuted,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.sleepAccent.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelForDateKey(selectedDay.dateKey),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DurationDropDown(
                        label: 'Hours',
                        value: hours,
                        options: List.generate(15, (i) => i),
                        onChanged: (value) {
                          if (value == null) return;
                          _setDurationMinutes(value * 60 + minutes);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DurationDropDown(
                        label: 'Minutes',
                        value: minutes,
                        options: _minuteOptions,
                        onChanged: (value) {
                          if (value == null) return;
                          _setDurationMinutes(hours * 60 + value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      onPressed: _saving
                          ? null
                          : () => _setDurationMinutes(_durationMinutes - 5),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Expanded(
                      child: Text(
                        'Selected duration: ${formatDurationMinutes(_durationMinutes)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving
                          ? null
                          : () => _setDurationMinutes(_durationMinutes + 5),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickDurations
                      .map((minutesOption) {
                        final isTarget = minutesOption == targetMinutes;
                        return ChoiceChip(
                          label: Text(
                            isTarget
                                ? 'Target ${formatDurationMinutes(minutesOption)}'
                                : formatDurationMinutes(minutesOption),
                          ),
                          selected: _durationMinutes == minutesOption,
                          onSelected: _saving
                              ? null
                              : (_) => _setDurationMinutes(minutesOption),
                          selectedColor: AppColors.sleepAccent,
                          labelStyle: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 14),
                Text(
                  'Preset bedtimes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetBedtimeMinutes
                      .map((bedtime) {
                        return ChoiceChip(
                          label: Text(formatMinutesAsClock(bedtime)),
                          selected: selectedBedtimeMinutes == bedtime,
                          onSelected: _saving
                              ? null
                              : (_) => _applyBedtimeMinutes(
                                  bedtime,
                                  wakeTimeMinutes,
                                ),
                          selectedColor: AppColors.sleepAccent,
                          labelStyle: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Custom bedtime items (${_customBedtimeMinutes.length}/$_maxCustomBedtimeItems)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _saving ? null : _addCustomBedtimeItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (_customBedtimeMinutes.isEmpty)
                  Text(
                    'No custom bedtime items yet. Add up to 3.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  Column(
                    children: List.generate(_customBedtimeMinutes.length, (
                      index,
                    ) {
                      final bedtime = _customBedtimeMinutes[index];
                      final isSelected = selectedBedtimeMinutes == bedtime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: Text(formatMinutesAsClock(bedtime)),
                                selected: isSelected,
                                onSelected: _saving
                                    ? null
                                    : (_) => _applyBedtimeMinutes(
                                        bedtime,
                                        wakeTimeMinutes,
                                      ),
                                selectedColor: AppColors.sleepAccent,
                                labelStyle: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _saving
                                  ? null
                                  : () => _editCustomBedtimeItem(index),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Edit time',
                            ),
                            IconButton(
                              onPressed: _saving
                                  ? null
                                  : () => _deleteCustomBedtimeItem(index),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Bedtime items use wake time ${formatMinutesAsClock(wakeTimeMinutes)} to calculate your sleep duration.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  advice.title,
                  style: const TextStyle(
                    color: AppColors.sleepAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice.details,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _saveSelectedDay,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.sleepAccent,
                          side: const BorderSide(color: AppColors.sleepAccent),
                        ),
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save day'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _applyToNextWeek,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.sleepAccent,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: const Text('Apply next 7 days'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _durationMinutesForDay(double daySleepHours, double targetHours) {
    final minutes = (daySleepHours * 60).round();
    if (minutes > 0) {
      return _normalizeDurationMinutes(minutes);
    }
    return _normalizeDurationMinutes((targetHours * 60).round());
  }

  int _normalizeDurationMinutes(int minutes) {
    final rounded = ((minutes / 5).round()) * 5;
    final clamped = rounded.clamp(0, _maxSleepMinutes);
    return clamped;
  }

  List<int> _dedupQuickDurations(List<int> values) {
    final normalized = values
        .map(_normalizeDurationMinutes)
        .toList(growable: false);
    final deduped = <int>[];
    for (final value in normalized) {
      if (!deduped.contains(value)) {
        deduped.add(value);
      }
    }
    return deduped;
  }

  List<int> _normalizedBedtimeList(List<int> values) {
    final deduped = <int>[];
    for (final value in values) {
      final normalized = _normalizeBedtimeMinutes(value);
      if (!deduped.contains(normalized)) {
        deduped.add(normalized);
      }
    }
    deduped.sort();
    if (deduped.length > _maxCustomBedtimeItems) {
      return deduped.sublist(0, _maxCustomBedtimeItems);
    }
    return deduped;
  }

  int _normalizeBedtimeMinutes(int minutes) {
    final roundedToFive = ((minutes / 5).round()) * 5;
    return normalizeMinutes(roundedToFive);
  }

  int? _parseTimeInput(String input) {
    final trimmed = input.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return null;
    }

    final amPmMatch = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AP]M)$',
    ).firstMatch(trimmed);
    if (amPmMatch != null) {
      final hourRaw = int.tryParse(amPmMatch.group(1)!);
      final minuteRaw = int.tryParse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!;
      if (hourRaw == null || minuteRaw == null) {
        return null;
      }
      if (hourRaw < 1 || hourRaw > 12 || minuteRaw < 0 || minuteRaw > 59) {
        return null;
      }
      var hour = hourRaw % 12;
      if (period == 'PM') {
        hour += 12;
      }
      return hour * 60 + minuteRaw;
    }

    final twentyFourMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (twentyFourMatch != null) {
      final hour = int.tryParse(twentyFourMatch.group(1)!);
      final minute = int.tryParse(twentyFourMatch.group(2)!);
      if (hour == null || minute == null) {
        return null;
      }
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }
      return hour * 60 + minute;
    }

    return null;
  }
}

class _SleepCalendarDay {
  const _SleepCalendarDay({
    required this.dateKey,
    required this.sleepHours,
    required this.isToday,
  });

  final String dateKey;
  final double sleepHours;
  final bool isToday;

  _SleepCalendarDay copyWith({
    String? dateKey,
    double? sleepHours,
    bool? isToday,
  }) {
    return _SleepCalendarDay(
      dateKey: dateKey ?? this.dateKey,
      sleepHours: sleepHours ?? this.sleepHours,
      isToday: isToday ?? this.isToday,
    );
  }
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
            'Use this planner for manual scheduling and keep health sync as a future auto option.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_SleepCalendarDay> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = index == selectedIndex;
          final parsed = _parseDateKey(day.dateKey) ?? DateTime.now();
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelected(index),
            child: Container(
              width: 86,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.sleepAccent.withValues(alpha: 0.32)
                    : AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppColors.sleepAccent
                      : AppColors.sleepAccent.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.isToday ? 'Today' : _weekdayShort(parsed),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('${parsed.month}/${parsed.day}'),
                  const Spacer(),
                  Text(
                    day.sleepHours > 0
                        ? formatSleepHours(day.sleepHours)
                        : '--',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: days.length,
      ),
    );
  }
}

class _DurationDropDown extends StatelessWidget {
  const _DurationDropDown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> options;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.cardDark,
          items: options
              .map(
                (option) => DropdownMenuItem<int>(
                  value: option,
                  child: Text(option.toString().padLeft(2, '0')),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

List<String> _calendarDateKeys(String timezone, DateTime nowUtc) {
  tz.Location? location;
  try {
    location = tz.getLocation(timezone);
  } catch (_) {
    location = null;
  }

  final keys = <String>[];
  if (location != null) {
    final today = tz.TZDateTime.from(nowUtc, location);
    for (var offset = -6; offset <= 7; offset++) {
      final localMidday = tz.TZDateTime(
        location,
        today.year,
        today.month,
        today.day + offset,
        12,
      );
      keys.add(dateKeyFor(localMidday.toUtc(), timezone));
    }
    return keys;
  }

  final localToday = DateTime(nowUtc.year, nowUtc.month, nowUtc.day);
  for (var offset = -6; offset <= 7; offset++) {
    final day = localToday
        .add(Duration(days: offset))
        .add(const Duration(hours: 12));
    keys.add(dateKeyFor(day.toUtc(), timezone));
  }
  return keys;
}

String _labelForDateKey(String dateKey) {
  final parsed = _parseDateKey(dateKey);
  if (parsed == null) {
    return dateKey;
  }
  return '${_weekdayShort(parsed)}, ${parsed.month}/${parsed.day}/${parsed.year}';
}

String _weekdayShort(DateTime date) {
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

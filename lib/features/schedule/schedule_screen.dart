import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/meal_log_refresh_scope.dart';
import 'package:nutrilens/app/meal_plan_refresh_scope.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/app/sleep_log_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/schedule/create_schedule_event_sheet.dart';
import 'package:nutrilens/features/schedule/schedule_calendar_mode.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_filter_bar.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_header.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_meal_plan_section.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_timeline.dart';
import 'package:nutrilens/features/schedule/widgets/todays_match_card.dart';
import 'package:nutrilens/features/schedule/widgets/month_date_selector.dart';
import 'package:nutrilens/features/schedule/widgets/week_date_selector.dart';
import 'package:nutrilens/features/sleep/sleep_log_actions.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/meal_plan_serializer.dart';
import 'package:nutrilens/services/openai_meal_plan_client.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    super.key,
    this.isActive = true,
    this.onMealPlanMealTap,
  });

  final bool isActive;
  final ValueChanged<String>? onMealPlanMealTap;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  Future<UserProfile?>? _profileFuture;
  String? _loadedUid;
  ScheduleViewFilter _filter = ScheduleViewFilter.all;
  ScheduleCalendarMode _calendarMode = ScheduleCalendarMode.week;
  List<Meal> _loggedMeals = const [];
  Set<String> _mealDateKeysInRange = const {};
  Set<String> _sleepDateKeysInRange = const {};
  double _sleepHours = 0;
  MealPlanWeek? _mealPlan;
  String? _mealPlanError;
  bool _mealPlanLoading = false;
  bool _mealDataReloadInProgress = false;
  MealSlot? _regeneratingMealSlot;
  bool _wasActive = false;
  bool _mealsRequested = false;
  MealLogRefreshNotifier? _mealLogRefreshNotifier;
  SleepLogRefreshNotifier? _sleepLogRefreshNotifier;
  MealPlanRefreshNotifier? _mealPlanRefreshNotifier;
  AppSettingsController? _appSettings;
  int _lastMealLogRefreshGeneration = 0;
  int _lastSleepLogRefreshGeneration = 0;
  int _lastMealPlanRefreshGeneration = 0;
  bool _lastSleepModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dayKey(DateTime.now());
    _wasActive = widget.isActive;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    final mealLogRefresh = MealLogRefreshScope.maybeOf(context);
    if (_mealLogRefreshNotifier != mealLogRefresh) {
      _mealLogRefreshNotifier?.removeListener(_handleMealLogRefreshRequest);
      _mealLogRefreshNotifier = mealLogRefresh;
      _lastMealLogRefreshGeneration = mealLogRefresh?.generation ?? 0;
      mealLogRefresh?.addListener(_handleMealLogRefreshRequest);
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
    final appSettings = AppSettingsScope.maybeOf(context);
    if (_appSettings != appSettings) {
      _appSettings?.removeListener(_handleAppSettingsChanged);
      _appSettings = appSettings;
      _lastSleepModeEnabled = appSettings?.sleepModeEnabled ?? false;
      appSettings?.addListener(_handleAppSettingsChanged);
    }
    if (_loadedUid != scope.uid) {
      _loadedUid = scope.uid;
      _profileFuture = scope.repository.getProfile(scope.uid);
      _mealsRequested = false;
    } else if (widget.isActive && !_wasActive) {
      _returnToTodayOnOpen();
    }
    _wasActive = widget.isActive;
  }

  @override
  void didUpdateWidget(covariant ScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _returnToTodayOnOpen();
    }
    _wasActive = widget.isActive;
  }

  void _returnToTodayOnOpen() {
    final today = _dayKey(DateTime.now());
    if (!_isSameDay(today, _selectedDate) ||
        _calendarMode != ScheduleCalendarMode.week) {
      setState(() {
        _selectedDate = today;
        _calendarMode = ScheduleCalendarMode.week;
        _mealsRequested = false;
      });
    } else {
      _mealsRequested = false;
    }
    _reloadMealData();
  }

  @override
  void dispose() {
    _mealLogRefreshNotifier?.removeListener(_handleMealLogRefreshRequest);
    _sleepLogRefreshNotifier?.removeListener(_handleSleepLogRefreshRequest);
    _mealPlanRefreshNotifier?.removeListener(_handleMealPlanRefreshRequest);
    _appSettings?.removeListener(_handleAppSettingsChanged);
    super.dispose();
  }

  void _handleAppSettingsChanged() {
    if (!mounted) {
      return;
    }
    final enabled = _appSettings?.sleepModeEnabled ?? false;
    if (enabled == _lastSleepModeEnabled) {
      return;
    }
    _lastSleepModeEnabled = enabled;

    final scope = UserScope.of(context);
    setState(() {
      _profileFuture = scope.repository.getProfile(scope.uid);
      _mealsRequested = false;
      if (!enabled && _filter == ScheduleViewFilter.sleep) {
        _filter = ScheduleViewFilter.all;
      }
    });
    _reloadMealData();
  }

  void _handleMealLogRefreshRequest() {
    final notifier = _mealLogRefreshNotifier;
    if (notifier == null ||
        notifier.generation == _lastMealLogRefreshGeneration) {
      return;
    }
    _lastMealLogRefreshGeneration = notifier.generation;
    _mealsRequested = false;
    _reloadMealData();
  }

  void _handleSleepLogRefreshRequest() {
    final notifier = _sleepLogRefreshNotifier;
    if (notifier == null ||
        notifier.generation == _lastSleepLogRefreshGeneration) {
      return;
    }
    _lastSleepLogRefreshGeneration = notifier.generation;
    _mealsRequested = false;
    _reloadMealData();
  }

  void _handleMealPlanRefreshRequest() {
    final notifier = _mealPlanRefreshNotifier;
    if (notifier == null ||
        notifier.generation == _lastMealPlanRefreshGeneration) {
      return;
    }
    _lastMealPlanRefreshGeneration = notifier.generation;
    _mealsRequested = false;
    _reloadMealData(forceMealPlan: true);
  }

  Future<void> _regeneratePlannedMeal(MealPlanMeal meal) async {
    if (_regeneratingMealSlot != null) {
      return;
    }

    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted || profile == null) {
      return;
    }

    setState(() => _regeneratingMealSlot = meal.slot);

    try {
      final client =
          MealPlanScope.maybeOf(context)?.client ??
          OpenAiMealPlanClient.fromEnvironment();
      final regenerated = await client.regenerateMeal(
        uid: scope.uid,
        profile: profile,
        date: _selectedDate,
        slot: meal.slot,
      );

      if (!mounted) {
        return;
      }

      final plan = _mealPlan;
      if (plan != null) {
        final updatedDays = plan.days
            .map((day) {
              if (!_isSameDay(day.date, _selectedDate)) {
                return day;
              }

              final meals = day.meals
                  .map((plannedMeal) {
                    return plannedMeal.slot == meal.slot
                        ? regenerated
                        : plannedMeal;
                  })
                  .toList(growable: false);
              return MealPlanDay(date: day.date, meals: meals);
            })
            .toList(growable: false);

        setState(() {
          _mealPlan = MealPlanWeek(
            generatedAt: plan.generatedAt,
            days: updatedDays,
          );
          _mealPlanError = null;
          _regeneratingMealSlot = null;
        });
      } else {
        setState(() => _regeneratingMealSlot = null);
        await _reloadMealData();
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.scheduleNewMealReady(meal.slot.label.toLowerCase()),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _regeneratingMealSlot = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.scheduleMealGenerationFailed('$error'),
          ),
        ),
      );
    }
  }

  Future<void> _reloadMealData({bool forceMealPlan = false}) async {
    if (_mealDataReloadInProgress) {
      return;
    }
    _mealDataReloadInProgress = true;

    if (!mounted) {
      _mealDataReloadInProgress = false;
      return;
    }

    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted || profile == null) {
      _mealDataReloadInProgress = false;
      return;
    }

    final range = _dateKeyRangeForVisibleCalendar(
      _selectedDate,
      profile.timezone,
    );

    List<Meal> meals = const [];
    Set<String> dateKeys = const {};
    Set<String> sleepDateKeys = const {};
    double sleepHours = 0;
    MealPlanWeek? mealPlan = _mealPlan;
    String? mealPlanError = _mealPlanError;
    var mealPlanLoading = _mealPlanLoading;
    try {
      meals = await scope.repository.getMealsForDay(
        scope.uid,
        _selectedDate,
        profile.timezone,
      );
    } catch (_) {
      meals = _loggedMeals;
    }
    try {
      dateKeys = await scope.repository.getMealDateKeysInRange(
        scope.uid,
        startDateKey: range.start,
        endDateKey: range.end,
      );
    } catch (_) {
      dateKeys = _mealDateKeysInRange;
    }
    if (profile.sleepModeEnabled) {
      try {
        sleepDateKeys = await scope.repository.getSleepDateKeysInRange(
          scope.uid,
          startDateKey: range.start,
          endDateKey: range.end,
        );
      } catch (_) {
        sleepDateKeys = _sleepDateKeysInRange;
      }
      try {
        final selectedKey = dateKeyFor(_selectedDate, profile.timezone);
        final summary = await scope.repository.getDailySummary(
          scope.uid,
          selectedKey,
        );
        sleepHours = summary?.sleepHours ?? 0;
      } catch (_) {
        sleepHours = _sleepHours;
      }
    }

    mealPlanLoading = true;
    if (mounted) {
      setState(() => _mealPlanLoading = true);
    }
    try {
      final client =
          MealPlanScope.maybeOf(context)?.client ??
          OpenAiMealPlanClient.fromEnvironment();
      final planStart = DateUtils.dateOnly(DateTime.now());
      mealPlan = await client.fetchWeeklyPlan(
        uid: scope.uid,
        profile: profile,
        startDate: planStart,
        forceRefresh: forceMealPlan,
      );
      mealPlanError = null;
    } catch (error) {
      mealPlanError = '$error';
    } finally {
      mealPlanLoading = false;
    }

    if (!mounted) {
      _mealDataReloadInProgress = false;
      return;
    }

    setState(() {
      _loggedMeals = meals;
      _mealDateKeysInRange = dateKeys;
      _sleepDateKeysInRange = sleepDateKeys;
      _sleepHours = sleepHours;
      _mealPlan = mealPlan;
      _mealPlanError = mealPlanError;
      _mealPlanLoading = mealPlanLoading;
      _mealsRequested = true;
    });
    _mealDataReloadInProgress = false;
  }

  void _requestMealReload() {
    if (_mealsRequested || !widget.isActive) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mealsRequested) {
        return;
      }
      _reloadMealData();
    });
  }

  Future<void> _onAddTap() async {
    final created = await CreateScheduleEventSheet.show(
      context,
      initialDate: _selectedDate,
    );
    if (created == null || !mounted) {
      return;
    }

    final scope = UserScope.of(context);
    setState(() {
      _selectedDate = _dayKey(created.startAt.toLocal());
      _profileFuture = scope.repository.getProfile(scope.uid);
      _mealsRequested = false;
    });
    await _reloadMealData();
  }

  Future<void> _openSleepLogDialog(UserProfile profile) async {
    final dateKey = dateKeyFor(_selectedDate, profile.timezone);
    final saved = await showSleepLogDialogAndSave(
      context: context,
      profile: profile,
      dateKey: dateKey,
      title: AppLocalizations.of(context)!.scheduleLogSleep,
      initialSleepHours: _sleepHours > 0 ? _sleepHours : null,
    );
    if (saved && mounted) {
      _mealsRequested = false;
      await _reloadMealData();
    }
  }

  Future<bool> _confirmDeleteEvent(UserScheduleEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.scheduleDeleteEventTitle),
          content: Text(
            AppLocalizations.of(context)!.scheduleDeleteEventBody(event.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _deleteScheduleEvent(
    UserScheduleEvent event,
    UserProfile? profile,
  ) async {
    if (profile == null) {
      return;
    }

    final confirmed = await _confirmDeleteEvent(event);
    if (!confirmed || !mounted) {
      return;
    }

    final scope = UserScope.of(context);
    final updatedEvents = profile.scheduleEvents
        .where((item) => item.eventId != event.eventId)
        .toList();

    try {
      await scope.repository.saveProfile(
        profile.copyWith(scheduleEvents: updatedEvents),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.scheduleDeleteEventFailed,
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _profileFuture = scope.repository.getProfile(scope.uid);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.scheduleEventDeleted),
      ),
    );
  }

  Future<void> _selectDate(
    DateTime date, {
    bool stayInMonthView = false,
  }) async {
    final nextDate = _dayKey(date);
    final changedDate = !_isSameDay(nextDate, _selectedDate);

    setState(() {
      _selectedDate = nextDate;
      _mealsRequested = false;
      if (_calendarMode == ScheduleCalendarMode.month && !stayInMonthView) {
        _calendarMode = ScheduleCalendarMode.week;
      }
    });

    if (changedDate || !_mealsRequested) {
      await _reloadMealData();
    }
  }

  Future<void> _shiftMonth(int direction) async {
    setState(() {
      _selectedDate = _dayKey(
        DateTime(_selectedDate.year, _selectedDate.month + direction, 1),
      );
      _mealsRequested = false;
    });
    await _reloadMealData();
  }

  Future<void> _shiftWeek(int direction) async {
    setState(() {
      _selectedDate = _dayKey(_selectedDate.add(Duration(days: 7 * direction)));
      _mealsRequested = false;
    });
    await _reloadMealData();
  }

  Future<void> _toggleCalendarMode() async {
    setState(() {
      _calendarMode = _calendarMode == ScheduleCalendarMode.week
          ? ScheduleCalendarMode.month
          : ScheduleCalendarMode.week;
      _mealsRequested = false;
    });
    await _reloadMealData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile != null) {
          _requestMealReload();
        }

        final sleepModeEnabled =
            AppSettingsScope.maybeOf(context)?.sleepModeEnabled ??
            profile?.sleepModeEnabled ??
            false;
        if (!sleepModeEnabled && _filter == ScheduleViewFilter.sleep) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _filter = ScheduleViewFilter.all);
            }
          });
        }

        final scheduleEvents = profile?.scheduleEvents ?? const [];
        final events = _eventsFor(scheduleEvents, _selectedDate);
        final matches = events.where(
          (event) => event.type == ScheduleEventType.match,
        );
        final match = matches.isEmpty ? null : matches.first;
        final timezone = profile?.timezone ?? 'UTC';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduleHeader(
                selectedDate: _selectedDate,
                calendarMode: _calendarMode,
                onCalendarModeToggle: _toggleCalendarMode,
                onAddTap: _onAddTap,
              ),
              const SizedBox(height: 16),
              ScheduleFilterBar(
                filter: _filter,
                showSleepFilter: sleepModeEnabled,
                onFilterChanged: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 20),
              if (_calendarMode == ScheduleCalendarMode.week)
                WeekDateSelector(
                  selectedDate: _selectedDate,
                  hasEventsOn: (date) =>
                      _eventsFor(scheduleEvents, date).isNotEmpty,
                  hasLoggedMealsOn: (date) =>
                      _mealDateKeysInRange.contains(dateKeyFor(date, timezone)),
                  hasSleepOn: sleepModeEnabled
                      ? (date) => _sleepDateKeysInRange.contains(
                          dateKeyFor(date, timezone),
                        )
                      : null,
                  onDateSelected: _selectDate,
                  onPreviousWeek: () => _shiftWeek(-1),
                  onNextWeek: () => _shiftWeek(1),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => _shiftMonth(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => _shiftMonth(1),
                    ),
                  ],
                ),
                MonthDateSelector(
                  selectedDate: _selectedDate,
                  showHeader: false,
                  hasEventsOn: (date) =>
                      _eventsFor(scheduleEvents, date).isNotEmpty,
                  hasLoggedMealsOn: (date) =>
                      _mealDateKeysInRange.contains(dateKeyFor(date, timezone)),
                  hasSleepOn: sleepModeEnabled
                      ? (date) => _sleepDateKeysInRange.contains(
                          dateKeyFor(date, timezone),
                        )
                      : null,
                  onDateSelected: _selectDate,
                ),
              ],
              if (snapshot.connectionState != ConnectionState.done) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ] else if (snapshot.hasError) ...[
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.scheduleLoadFailed,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ] else ...[
                if ((_filter == ScheduleViewFilter.all ||
                        _filter == ScheduleViewFilter.events) &&
                    match != null) ...[
                  const SizedBox(height: 24),
                  TodaysMatchCard(match: match),
                ],
                if (_filter == ScheduleViewFilter.all ||
                    _filter == ScheduleViewFilter.loggedMeals) ...[
                  const SizedBox(height: 24),
                  ScheduleMealPlanSection(
                    meals: _plannedMealsForSelectedDate,
                    error: _mealPlanError,
                    loading: _mealPlanLoading,
                    onMealTap: widget.onMealPlanMealTap,
                    onRegenerateMeal: _regeneratePlannedMeal,
                    regeneratingSlot: _regeneratingMealSlot,
                  ),
                ],
                if (_filter != ScheduleViewFilter.loggedMeals) ...[
                  const SizedBox(height: 24),
                  ScheduleTimeline(
                    events: events,
                    loggedMeals: _loggedMeals,
                    filter: _filter,
                    sleepHours: sleepModeEnabled ? _sleepHours : 0,
                    onEventTap: (event) => _deleteScheduleEvent(event, profile),
                    onSleepTap: profile == null || !sleepModeEnabled
                        ? null
                        : () => _openSleepLogDialog(profile),
                  ),
                ],
                if (sleepModeEnabled &&
                    profile != null &&
                    _filter == ScheduleViewFilter.sleep &&
                    _sleepHours <= 0) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openSleepLogDialog(profile),
                      icon: const Icon(Icons.nightlight_round),
                      label: Text(
                        AppLocalizations.of(context)!.scheduleLogSleepForDay,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  ({String start, String end}) _dateKeyRangeForVisibleCalendar(
    DateTime date,
    String timezone,
  ) {
    if (_calendarMode == ScheduleCalendarMode.week) {
      return _weekDateKeyRange(date, timezone);
    }
    return _monthDateKeyRange(date, timezone);
  }

  ({String start, String end}) _weekDateKeyRange(
    DateTime date,
    String timezone,
  ) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return (
      start: dateKeyFor(weekStart, timezone),
      end: dateKeyFor(weekEnd, timezone),
    );
  }

  ({String start, String end}) _monthDateKeyRange(
    DateTime date,
    String timezone,
  ) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    return (start: dateKeyFor(start, timezone), end: dateKeyFor(end, timezone));
  }

  List<UserScheduleEvent> _eventsFor(
    List<UserScheduleEvent> events,
    DateTime date,
  ) {
    final target = _dayKey(date);
    final filtered = events.where((event) {
      final eventDay = _dayKey(event.startAt.toLocal());
      return eventDay.year == target.year &&
          eventDay.month == target.month &&
          eventDay.day == target.day;
    }).toList();
    filtered.sort((a, b) => a.startAt.compareTo(b.startAt));
    return filtered;
  }

  List<MealPlanMeal> get _plannedMealsForSelectedDate {
    final plan = _mealPlan;
    if (plan == null) {
      return const [];
    }

    return plan.mealsFor(_selectedDate);
  }
}

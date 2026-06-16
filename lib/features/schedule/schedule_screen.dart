import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/schedule/create_schedule_event_sheet.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_header.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_timeline.dart';
import 'package:nutrilens/features/schedule/widgets/todays_match_card.dart';
import 'package:nutrilens/features/schedule/widgets/week_date_selector.dart';
import 'package:nutrilens/models/models.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  Future<UserProfile?>? _profileFuture;
  String? _loadedUid;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dayKey(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    if (_loadedUid != scope.uid) {
      _loadedUid = scope.uid;
      _profileFuture = scope.repository.getProfile(scope.uid);
    }
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
    });
  }

  Future<bool> _confirmDeleteEvent(UserScheduleEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete event?'),
          content: Text('Delete "${event.title}" from your schedule?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
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
        const SnackBar(content: Text('Failed to delete event.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _profileFuture = scope.repository.getProfile(scope.uid);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final scheduleEvents = snapshot.data?.scheduleEvents ?? const [];
        final weekDates = _weekDatesAround(_selectedDate);
        final events = _eventsFor(scheduleEvents, _selectedDate);
        final matches = events.where(
          (event) => event.type == ScheduleEventType.match,
        );
        final match = matches.isEmpty ? null : matches.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduleHeader(onAddTap: _onAddTap),
              const SizedBox(height: 20),
              WeekDateSelector(
                dates: weekDates,
                selectedDate: _selectedDate,
                hasEventsOn: (date) =>
                    _eventsFor(scheduleEvents, date).isNotEmpty,
                onDateSelected: (date) =>
                    setState(() => _selectedDate = _dayKey(date)),
              ),
              if (snapshot.connectionState != ConnectionState.done) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ] else if (snapshot.hasError) ...[
                const SizedBox(height: 24),
                Text(
                  'Failed to load schedule.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ] else ...[
                if (match != null) ...[
                  const SizedBox(height: 24),
                  TodaysMatchCard(match: match),
                ],
                const SizedBox(height: 24),
                ScheduleTimeline(
                  events: events,
                  onEventTap: (event) => _deleteScheduleEvent(event, snapshot.data),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

  List<DateTime> _weekDatesAround(DateTime selectedDate) {
    final start = _dayKey(selectedDate).subtract(const Duration(days: 1));
    return List.generate(6, (index) => start.add(Duration(days: index)));
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
}

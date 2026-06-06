import 'package:flutter/material.dart';
import 'package:nutrilens/data/mock_schedule_data.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_header.dart';
import 'package:nutrilens/features/schedule/widgets/schedule_timeline.dart';
import 'package:nutrilens/features/schedule/widgets/todays_match_card.dart';
import 'package:nutrilens/features/schedule/widgets/week_date_selector.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = MockScheduleData.defaultSelectedDate;
  }

  void _onAddTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event creation coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = MockScheduleData.matchFor(_selectedDate);
    final events = MockScheduleData.eventsFor(_selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScheduleHeader(onAddTap: _onAddTap),
          const SizedBox(height: 20),
          WeekDateSelector(
            dates: MockScheduleData.weekDates,
            selectedDate: _selectedDate,
            onDateSelected: (date) => setState(() => _selectedDate = date),
          ),
          if (match != null) ...[
            const SizedBox(height: 24),
            TodaysMatchCard(match: match),
          ],
          const SizedBox(height: 24),
          ScheduleTimeline(events: events),
        ],
      ),
    );
  }
}

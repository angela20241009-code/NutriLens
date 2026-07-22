import 'package:nutrilens/theme/app_colors.dart';

const maxPreviousMeals = 10;

enum ScheduleViewFilter { all, events, loggedMeals, sleep }

extension ScheduleViewFilterLabels on ScheduleViewFilter {
  String get label {
    switch (this) {
      case ScheduleViewFilter.all:
        return 'All';
      case ScheduleViewFilter.events:
        return 'Events';
      case ScheduleViewFilter.loggedMeals:
        return 'Meals';
      case ScheduleViewFilter.sleep:
        return 'Sleep';
    }
  }
}

/// Green dots/tiles for meals the user logged.
const scheduleLoggedMealColor = AppColors.lime;

/// Purple dots/tiles for user-created schedule events.
const scheduleEventColor = AppColors.orange;

/// Purple accent for logged sleep entries.
const scheduleSleepColor = AppColors.sleepAccent;

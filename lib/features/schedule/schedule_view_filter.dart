import 'package:nutrilens/theme/app_colors.dart';

const maxPreviousMeals = 10;

enum ScheduleViewFilter { all, events, loggedMeals }

extension ScheduleViewFilterLabels on ScheduleViewFilter {
  String get label {
    switch (this) {
      case ScheduleViewFilter.all:
        return 'All';
      case ScheduleViewFilter.events:
        return 'Events';
      case ScheduleViewFilter.loggedMeals:
        return 'Logged meals';
    }
  }
}

/// Green dots/tiles for meals the user logged.
const scheduleLoggedMealColor = AppColors.lime;

/// Purple dots/tiles for user-created schedule events.
const scheduleEventColor = AppColors.orange;

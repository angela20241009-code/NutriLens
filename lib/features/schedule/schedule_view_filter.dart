import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/l10n/app_localizations.dart';

const maxPreviousMeals = 10;

enum ScheduleViewFilter { all, events, loggedMeals, sleep }

extension ScheduleViewFilterLabels on ScheduleViewFilter {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ScheduleViewFilter.all:
        return l10n.scheduleFilterAll;
      case ScheduleViewFilter.events:
        return l10n.scheduleFilterEvents;
      case ScheduleViewFilter.loggedMeals:
        return l10n.scheduleFilterMeals;
      case ScheduleViewFilter.sleep:
        return l10n.scheduleFilterSleep;
    }
  }
}

/// Green dots/tiles for meals the user logged.
const scheduleLoggedMealColor = AppColors.lime;

/// Purple dots/tiles for user-created schedule events.
const scheduleEventColor = AppColors.orange;

/// Purple accent for logged sleep entries.
const scheduleSleepColor = AppColors.sleepAccent;

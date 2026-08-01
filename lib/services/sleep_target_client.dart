import 'package:nutrilens/models/daily_summary.dart';
import 'package:nutrilens/models/user_profile.dart';

abstract class SleepTargetClient {
  Future<double> fetchDailyTargetHours(
    UserProfile profile, {
    required List<DailySummary> recentSleep,
  });
}

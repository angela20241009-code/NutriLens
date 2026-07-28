import 'package:nutrilens/models/user_profile.dart';

/// Resolves a personalized daily hydration target in liters.
abstract class HydrationTargetClient {
  Future<double> fetchDailyTargetLiters(UserProfile profile);
}

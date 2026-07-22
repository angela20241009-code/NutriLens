import 'package:flutter/material.dart';
import 'package:nutrilens/app/sleep_log_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/sleep/sleep_check_in_dialog.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/models.dart';

Future<bool> showSleepLogDialogAndSave({
  required BuildContext context,
  required UserProfile profile,
  required String dateKey,
  required String title,
  String? description,
  double? initialSleepHours,
}) async {
  final result = await SleepCheckInDialog.show(
    context: context,
    profile: profile,
    title: title,
    description:
        description ??
        'How long did you sleep? Enter hours and minutes, or skip for now.',
    allowDismiss: true,
    initialSleepHours: initialSleepHours,
  );
  if (!context.mounted || result == null || result.skipped) {
    return false;
  }

  final scope = UserScope.of(context);
  try {
    await scope.repository.updateDailySummary(
      scope.uid,
      dateKey,
      sleepHours: result.sleepHours,
    );
    SleepLogRefreshScope.maybeOf(context)?.requestRefresh();
    final advice = buildSleepAdvice(
      profile: profile,
      sleepHours: result.sleepHours!,
      wakeTimeMinutes: profile.usualWakeTimeMinutes ?? 7 * 60,
      referenceUtc: DateTime.now().toUtc(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged ${formatSleepHours(result.sleepHours!)}. ${advice.shortLine}',
        ),
      ),
    );
    return true;
  } catch (error) {
    if (!context.mounted) {
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to save sleep log: $error')),
    );
    return false;
  }
}

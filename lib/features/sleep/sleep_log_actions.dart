import 'package:flutter/material.dart';
import 'package:nutrilens/app/sleep_log_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/sleep/sleep_check_in_dialog.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
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
        description ?? AppLocalizations.of(context)!.sleepCheckInDescription,
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
    if (!context.mounted) {
      return false;
    }
    SleepLogRefreshScope.maybeOf(context)?.requestRefresh();
    final advice = buildSleepAdvice(
      l10n: AppLocalizations.of(context)!,
      profile: profile,
      sleepHours: result.sleepHours!,
      wakeTimeMinutes: profile.usualWakeTimeMinutes ?? 7 * 60,
      referenceUtc: DateTime.now().toUtc(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.sleepLogged(
            formatSleepHours(result.sleepHours!),
            advice.shortLine,
          ),
        ),
      ),
    );
    return true;
  } catch (error) {
    if (!context.mounted) {
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.unableToSaveSleepLog('$error'),
        ),
      ),
    );
    return false;
  }
}

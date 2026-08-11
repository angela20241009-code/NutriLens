import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/features/home/widgets/weekly_sleep_summary_card.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/features/sleep/sleep_log_actions.dart';
import 'package:nutrilens/features/sleep/widgets/sleep_question_card.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/models/sleep_personalization_result.dart';
import 'package:nutrilens/models/sleep_questionnaire_answers.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/notification_scheduler.dart';
import 'package:nutrilens/services/openai_sleep_target_client.dart';
import 'package:nutrilens/theme/app_colors.dart';

class WeeklySleepInsightPage extends StatefulWidget {
  const WeeklySleepInsightPage({
    super.key,
    required this.weeklyDays,
    required this.targetHours,
  });

  final List<WeeklySleepDay> weeklyDays;
  final double targetHours;

  @override
  State<WeeklySleepInsightPage> createState() => _WeeklySleepInsightPageState();
}

class _WeeklySleepInsightPageState extends State<WeeklySleepInsightPage> {
  String? _wakeTiredAnswer;
  String? _bedtimeConsistencyAnswer;
  SleepPersonalizationResult? _result;
  bool _loading = false;
  bool _applying = false;
  String? _error;

  bool get _questionsComplete =>
      _wakeTiredAnswer != null && _bedtimeConsistencyAnswer != null;

  Future<void> _submit() async {
    if (!_questionsComplete || _loading) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final scope = UserScope.of(context);
      final profile = await scope.repository.getProfile(scope.uid);
      if (!mounted || profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 13));
      final summaries = await scope.repository.getDailySummariesInRange(
        scope.uid,
        startDateKey: dateKeyFor(start, profile.timezone),
        endDateKey: dateKeyFor(end, profile.timezone),
      );
      final recentSleep = summaries.values
          .where((summary) => summary.sleepHours > 0)
          .toList(growable: false)
        ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

      final answers = SleepQuestionnaireAnswers(
        wakeTired: _wakeTiredAnswer!,
        bedtimeConsistency: _bedtimeConsistencyAnswer!,
      );

      final plan = await OpenAiSleepTargetClient.fromEnvironment()
          .fetchPersonalizedSleepPlan(
            profile,
            recentSleep: recentSleep,
            weeklyDays: widget.weeklyDays,
            answers: answers,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = plan;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _openSleepLog() async {
    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted || profile == null) {
      return;
    }

    final todayKey = dateKeyFor(DateTime.now(), profile.timezone);
    final summary = await scope.repository.getDailySummary(scope.uid, todayKey);
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await showSleepLogDialogAndSave(
      context: context,
      profile: profile,
      dateKey: todayKey,
      title: l10n.logSleep,
      initialSleepHours: summary?.sleepHours,
      initialBedtimeMinutes: summary?.sleepBedtimeMinutes,
    );
  }

  Future<void> _applyPlan() async {
    final plan = _result;
    if (plan == null || _applying) {
      return;
    }

    setState(() => _applying = true);
    try {
      final scope = UserScope.of(context);
      final profile = await scope.repository.getProfile(scope.uid);
      if (!mounted || profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final updated = profile.copyWith(
        usualBedtimeMinutes: plan.bedtimeMinutes,
        usualWakeTimeMinutes: plan.wakeTimeMinutes,
        dailyTargets: profile.dailyTargets.copyWith(
          sleepHours: plan.sleepHours,
          source: DailyTargetsSource.manual,
          effectiveFrom: DateTime.now().toUtc(),
        ),
      );

      await scope.repository.saveProfile(updated);
      await NotificationScheduler.instance.syncFromProfile(updated);

      if (!mounted) {
        return;
      }

      setState(() => _applying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.weeklySleepInsightApplied),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _applying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.weeklySleepInsightFailed('$error'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.weeklySleepInsightTitle),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            WeeklySleepSummaryCard(
              days: widget.weeklyDays,
              targetHours: widget.targetHours,
              onLogSleepTap: _openSleepLog,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.weeklySleepInsightIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            SleepQuestionCard(
              step: 1,
              question: l10n.sleepQuestionWakeTired,
              hint: l10n.sleepQuestionWakeTiredHint,
              options: [
                l10n.sleepAnswerNotOften,
                l10n.sleepAnswerSometimes,
                l10n.sleepAnswerOften,
              ],
              selected: _wakeTiredAnswer,
              onSelected: (value) => setState(() => _wakeTiredAnswer = value),
            ),
            const SizedBox(height: 16),
            SleepQuestionCard(
              step: 2,
              question: l10n.sleepQuestionBedtimeChanges,
              hint: l10n.sleepQuestionBedtimeChangesHint,
              options: [
                l10n.sleepAnswerNotOften,
                l10n.sleepAnswerSometimes,
                l10n.sleepAnswerOften,
              ],
              selected: _bedtimeConsistencyAnswer,
              onSelected: (value) =>
                  setState(() => _bedtimeConsistencyAnswer = value),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                l10n.weeklySleepInsightFailed(_error!),
                style: const TextStyle(color: AppColors.orange),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              _SleepPlanResultCard(result: _result!),
            ],
            const SizedBox(height: 24),
            if (_result == null)
              FilledButton(
                onPressed: _questionsComplete && !_loading ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sleepAccent,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _loading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.weeklySleepInsightSubmit),
              )
            else
              FilledButton(
                onPressed: _applying ? null : _applyPlan,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sleepAccent,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _applying
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.weeklySleepInsightApply),
              ),
          ],
        ),
      ),
    );
  }
}

class _SleepPlanResultCard extends StatelessWidget {
  const _SleepPlanResultCard({required this.result});

  final SleepPersonalizationResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.sleepAccentMuted,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sleepAccent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklySleepInsightResultTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.weeklySleepInsightRecommendedHours(
              result.sleepHours.toStringAsFixed(1),
            ),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(l10n.weeklySleepInsightRecommendedBedtime(
            formatMinutesAsClock(result.bedtimeMinutes),
          )),
          const SizedBox(height: 4),
          Text(l10n.weeklySleepInsightRecommendedWake(
            formatMinutesAsClock(result.wakeTimeMinutes),
          )),
          const SizedBox(height: 14),
          Text(
            result.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

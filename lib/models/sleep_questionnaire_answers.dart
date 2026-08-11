class SleepQuestionnaireAnswers {
  const SleepQuestionnaireAnswers({
    required this.wakeTired,
    required this.bedtimeConsistency,
  });

  final String wakeTired;
  final String bedtimeConsistency;

  bool get isComplete =>
      wakeTired.isNotEmpty && bedtimeConsistency.isNotEmpty;
}

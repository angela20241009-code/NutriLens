enum AppTextScale {
  small('small', 0.9),
  medium('medium', 1.0),
  large('large', 1.15),
  extraLarge('extra_large', 1.3);

  const AppTextScale(this.firestoreValue, this.scaleFactor);

  final String firestoreValue;
  final double scaleFactor;

  static AppTextScale fromFirestore(String? value) {
    return AppTextScale.values.firstWhere(
      (scale) => scale.firestoreValue == value,
      orElse: () => AppTextScale.medium,
    );
  }

  String get label => switch (this) {
    AppTextScale.small => 'Small',
    AppTextScale.medium => 'Medium',
    AppTextScale.large => 'Large',
    AppTextScale.extraLarge => 'Extra large',
  };
}

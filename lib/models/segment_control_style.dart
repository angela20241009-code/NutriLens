enum SegmentControlStyle {
  minimalTabs('minimal_tabs'),
  classicPill('classic_pill');

  const SegmentControlStyle(this.firestoreValue);

  final String firestoreValue;

  static SegmentControlStyle fromFirestore(String? value) {
    return SegmentControlStyle.values.firstWhere(
      (style) => style.firestoreValue == value,
      orElse: () => SegmentControlStyle.minimalTabs,
    );
  }
}

import 'package:nutrilens/models/firestore_map.dart';

class DietaryProfile {
  const DietaryProfile({
    this.allergens = const [],
    this.restrictions = const [],
    this.preferences = const [],
    this.notes = '',
  });

  final List<String> allergens;
  final List<String> restrictions;
  final List<String> preferences;
  final String notes;

  factory DietaryProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DietaryProfile();
    return DietaryProfile(
      allergens: parseStringList(map['allergens']),
      restrictions: parseStringList(map['restrictions']),
      preferences: parseStringList(map['preferences']),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'allergens': allergens,
    'restrictions': restrictions,
    'preferences': preferences,
    'notes': notes,
  };

  DietaryProfile copyWith({
    List<String>? allergens,
    List<String>? restrictions,
    List<String>? preferences,
    String? notes,
  }) {
    return DietaryProfile(
      allergens: allergens ?? this.allergens,
      restrictions: restrictions ?? this.restrictions,
      preferences: preferences ?? this.preferences,
      notes: notes ?? this.notes,
    );
  }
}

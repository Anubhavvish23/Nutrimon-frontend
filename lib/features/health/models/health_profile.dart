class HealthProfile {
  final double? sleep_hours;
  final List<String> allergies;
  final List<String> conditions;

  const HealthProfile({
    this.sleep_hours,
    this.allergies = const [],
    this.conditions = const [],
  });

  bool get has_sleep => sleep_hours != null;
  bool get has_conditions => allergies.isNotEmpty || conditions.isNotEmpty;
}

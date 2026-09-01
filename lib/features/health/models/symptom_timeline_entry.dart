class SymptomTimelineEntry {
  final String id;
  final DateTime analyzed_at;
  final DateTime checkin_due_at;
  final List<String> symptom_slugs;
  final String custom_text;
  final String analysis_preview;
  final List<String> suggested_meals;
  final int? feeling_score;
  final String? note;
  final DateTime? checked_in_at;

  const SymptomTimelineEntry({
    required this.id,
    required this.analyzed_at,
    required this.checkin_due_at,
    this.symptom_slugs = const [],
    this.custom_text = '',
    this.analysis_preview = '',
    this.suggested_meals = const [],
    this.feeling_score,
    this.note,
    this.checked_in_at,
  });

  bool get is_pending => feeling_score == null;
  bool get is_due =>
      is_pending && !DateTime.now().isBefore(checkin_due_at);

  SymptomTimelineEntry copyWith({
    int? feeling_score,
    String? note,
    DateTime? checked_in_at,
  }) {
    return SymptomTimelineEntry(
      id: id,
      analyzed_at: analyzed_at,
      checkin_due_at: checkin_due_at,
      symptom_slugs: symptom_slugs,
      custom_text: custom_text,
      analysis_preview: analysis_preview,
      suggested_meals: suggested_meals,
      feeling_score: feeling_score ?? this.feeling_score,
      note: note ?? this.note,
      checked_in_at: checked_in_at ?? this.checked_in_at,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analyzed_at': analyzed_at.toIso8601String(),
      'checkin_due_at': checkin_due_at.toIso8601String(),
      'symptom_slugs': symptom_slugs,
      'custom_text': custom_text,
      'analysis_preview': analysis_preview,
      'suggested_meals': suggested_meals,
      if (feeling_score != null) 'feeling_score': feeling_score,
      if (note != null) 'note': note,
      if (checked_in_at != null)
        'checked_in_at': checked_in_at!.toIso8601String(),
    };
  }

  factory SymptomTimelineEntry.fromJson(Map<String, dynamic> json) {
    return SymptomTimelineEntry(
      id: json['id']?.toString() ?? '',
      analyzed_at:
          DateTime.tryParse(json['analyzed_at']?.toString() ?? '') ??
              DateTime.now(),
      checkin_due_at:
          DateTime.tryParse(json['checkin_due_at']?.toString() ?? '') ??
              DateTime.now(),
      symptom_slugs: _as_string_list(json['symptom_slugs']),
      custom_text: json['custom_text']?.toString() ?? '',
      analysis_preview: json['analysis_preview']?.toString() ?? '',
      suggested_meals: _as_string_list(json['suggested_meals']),
      feeling_score: json['feeling_score'] is int
          ? json['feeling_score'] as int
          : int.tryParse(json['feeling_score']?.toString() ?? ''),
      note: json['note']?.toString(),
      checked_in_at:
          DateTime.tryParse(json['checked_in_at']?.toString() ?? ''),
    );
  }
}

List<String> _as_string_list(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
}

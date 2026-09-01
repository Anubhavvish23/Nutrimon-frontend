class RecipeRating {
  final bool liked;
  final String? note;
  final DateTime rated_at;

  const RecipeRating({
    required this.liked,
    this.note,
    required this.rated_at,
  });

  factory RecipeRating.fromJson(Map<String, dynamic> json) {
    return RecipeRating(
      liked: json['liked'] == true,
      note: json['note']?.toString(),
      rated_at: DateTime.tryParse(json['rated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liked': liked,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      'rated_at': rated_at.toUtc().toIso8601String(),
    };
  }
}

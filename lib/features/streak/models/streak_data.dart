class StreakData {
  final int current_streak;
  final int longest_streak;
  final String? last_meal_date;
  final bool logged_today;
  final bool streak_just_broken;
  final int broken_from_streak;

  const StreakData({
    this.current_streak = 0,
    this.longest_streak = 0,
    this.last_meal_date,
    this.logged_today = false,
    this.streak_just_broken = false,
    this.broken_from_streak = 0,
  });

  StreakData copyWith({
    int? current_streak,
    int? longest_streak,
    String? last_meal_date,
    bool? logged_today,
    bool? streak_just_broken,
    int? broken_from_streak,
  }) {
    return StreakData(
      current_streak: current_streak ?? this.current_streak,
      longest_streak: longest_streak ?? this.longest_streak,
      last_meal_date: last_meal_date ?? this.last_meal_date,
      logged_today: logged_today ?? this.logged_today,
      streak_just_broken: streak_just_broken ?? this.streak_just_broken,
      broken_from_streak: broken_from_streak ?? this.broken_from_streak,
    );
  }
}

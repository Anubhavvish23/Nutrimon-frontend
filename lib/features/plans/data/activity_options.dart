import 'package:flutter/material.dart';

class ActivityOption {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  const ActivityOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });
}

const List<ActivityOption> activityOptions = [
  ActivityOption(
    id: 'gym',
    title: 'Gym',
    subtitle: 'Strength & training',
    emoji: '🏋️',
    color: Color(0xFFFF375F),
  ),
  ActivityOption(
    id: 'badminton',
    title: 'Badminton',
    subtitle: 'Quick court sessions',
    emoji: '🏸',
    color: Color(0xFF0A84FF),
  ),
  ActivityOption(
    id: 'cricket',
    title: 'Cricket',
    subtitle: 'Match-day energy',
    emoji: '🏏',
    color: Color(0xFFFF9500),
  ),
  ActivityOption(
    id: 'football',
    title: 'Football',
    subtitle: 'Running & stamina',
    emoji: '⚽',
    color: Color(0xFF1DB954),
  ),
  ActivityOption(
    id: 'running',
    title: 'Running',
    subtitle: 'Cardio outdoors',
    emoji: '🏃',
    color: Color(0xFFBF5AF2),
  ),
  ActivityOption(
    id: 'yoga',
    title: 'Yoga',
    subtitle: 'Flexibility & calm',
    emoji: '🧘',
    color: Color(0xFF64D2FF),
  ),
  ActivityOption(
    id: 'swimming',
    title: 'Swimming',
    subtitle: 'Full-body cardio',
    emoji: '🏊',
    color: Color(0xFF30D158),
  ),
  ActivityOption(
    id: 'cycling',
    title: 'Cycling',
    subtitle: 'Endurance rides',
    emoji: '🚴',
    color: Color(0xFFFFD60A),
  ),
  ActivityOption(
    id: 'none',
    title: 'Mostly inactive',
    subtitle: 'Starting gently',
    emoji: '🛋️',
    color: Color(0xFF8E8E93),
  ),
];

const List<String> genderOptions = ['Male', 'Female', 'Other'];

String activitiesSummary(Set<String> activities) {
  if (activities.isEmpty) return 'Add activities';
  final labels = activityOptions
      .where((option) => activities.contains(option.id))
      .map((option) => option.title)
      .toList();
  if (labels.length <= 2) return labels.join(' · ');
  return '${labels.take(2).join(' · ')} +${labels.length - 2}';
}

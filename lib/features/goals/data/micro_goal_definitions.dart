enum MicroGoalKind { daily, milestone }

class MicroGoalDefinition {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final int target;
  final MicroGoalKind kind;
  final ColorSeed color;

  const MicroGoalDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.target,
    required this.kind,
    required this.color,
  });
}

class ColorSeed {
  final int value;
  const ColorSeed(this.value);
}

const microGoalDefinitions = <MicroGoalDefinition>[
  MicroGoalDefinition(
    id: 'eat_today',
    title: 'Breakfast logged',
    subtitle: 'Finish any meal timer today',
    emoji: '🍳',
    target: 1,
    kind: MicroGoalKind.daily,
    color: ColorSeed(0xFF1DB954),
  ),
  MicroGoalDefinition(
    id: 'protein_by_10',
    title: 'Protein by 10am',
    subtitle: 'Complete a higher-protein breakfast before 10',
    emoji: '💪',
    target: 1,
    kind: MicroGoalKind.daily,
    color: ColorSeed(0xFFFF375F),
  ),
  MicroGoalDefinition(
    id: 'fridge_spin',
    title: 'Fridge spin',
    subtitle: 'Use Fridge Roulette once today',
    emoji: '🧊',
    target: 1,
    kind: MicroGoalKind.daily,
    color: ColorSeed(0xFFFF9500),
  ),
  MicroGoalDefinition(
    id: 'feel_check',
    title: 'Feel check-in',
    subtitle: 'Rate how you feel 2h after analysis',
    emoji: '📈',
    target: 1,
    kind: MicroGoalKind.daily,
    color: ColorSeed(0xFFBF5AF2),
  ),
  MicroGoalDefinition(
    id: 'streak_3',
    title: '3-day flame',
    subtitle: 'Hit a 3-day breakfast streak',
    emoji: '🔥',
    target: 3,
    kind: MicroGoalKind.milestone,
    color: ColorSeed(0xFFFF9500),
  ),
  MicroGoalDefinition(
    id: 'cook_week',
    title: '3 cooks this week',
    subtitle: 'Log breakfast on 3 different days',
    emoji: '🗓️',
    target: 3,
    kind: MicroGoalKind.milestone,
    color: ColorSeed(0xFF0A84FF),
  ),
];

MicroGoalDefinition? microGoalById(String id) {
  for (final def in microGoalDefinitions) {
    if (def.id == id) return def;
  }
  return null;
}

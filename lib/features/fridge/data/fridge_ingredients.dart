class FridgeIngredient {
  final String id;
  final String label;
  final String emoji;
  final List<String> keywords;

  const FridgeIngredient({
    required this.id,
    required this.label,
    required this.emoji,
    required this.keywords,
  });
}

const fridgeIngredientOptions = <FridgeIngredient>[
  FridgeIngredient(
    id: 'eggs',
    label: 'Eggs',
    emoji: '🥚',
    keywords: ['egg'],
  ),
  FridgeIngredient(
    id: 'avocado',
    label: 'Avocado',
    emoji: '🥑',
    keywords: ['avocado'],
  ),
  FridgeIngredient(
    id: 'bread',
    label: 'Bread',
    emoji: '🍞',
    keywords: ['bread', 'toast', 'sourdough'],
  ),
  FridgeIngredient(
    id: 'yogurt',
    label: 'Yogurt',
    emoji: '🥛',
    keywords: ['yogurt', 'yoghurt', 'curd'],
  ),
  FridgeIngredient(
    id: 'banana',
    label: 'Banana',
    emoji: '🍌',
    keywords: ['banana'],
  ),
  FridgeIngredient(
    id: 'berries',
    label: 'Berries',
    emoji: '🫐',
    keywords: ['berr', 'strawberry', 'blueberry', 'berries', 'berry'],
  ),
  FridgeIngredient(
    id: 'oats',
    label: 'Oats',
    emoji: '🥣',
    keywords: ['oat', 'oats', 'oatmeal'],
  ),
  FridgeIngredient(
    id: 'milk',
    label: 'Milk',
    emoji: '🥛',
    keywords: ['milk'],
  ),
  FridgeIngredient(
    id: 'spinach',
    label: 'Spinach',
    emoji: '🥬',
    keywords: ['spinach'],
  ),
  FridgeIngredient(
    id: 'tomato',
    label: 'Tomato',
    emoji: '🍅',
    keywords: ['tomato'],
  ),
  FridgeIngredient(
    id: 'cheese',
    label: 'Cheese',
    emoji: '🧀',
    keywords: ['cheese', 'feta', 'parmesan'],
  ),
  FridgeIngredient(
    id: 'peanut_butter',
    label: 'Peanut butter',
    emoji: '🥜',
    keywords: ['peanut'],
  ),
  FridgeIngredient(
    id: 'honey',
    label: 'Honey',
    emoji: '🍯',
    keywords: ['honey'],
  ),
  FridgeIngredient(
    id: 'chia',
    label: 'Chia',
    emoji: '🌱',
    keywords: ['chia'],
  ),
  FridgeIngredient(
    id: 'apple',
    label: 'Apple',
    emoji: '🍎',
    keywords: ['apple'],
  ),
  FridgeIngredient(
    id: 'almond',
    label: 'Almonds',
    emoji: '🌰',
    keywords: ['almond'],
  ),
  FridgeIngredient(
    id: 'butter',
    label: 'Butter',
    emoji: '🧈',
    keywords: ['butter'],
  ),
  FridgeIngredient(
    id: 'lemon',
    label: 'Lemon',
    emoji: '🍋',
    keywords: ['lemon'],
  ),
  FridgeIngredient(
    id: 'chicken',
    label: 'Chicken',
    emoji: '🍗',
    keywords: ['chicken'],
  ),
  FridgeIngredient(
    id: 'salmon',
    label: 'Salmon',
    emoji: '🐟',
    keywords: ['salmon', 'fish'],
  ),
  FridgeIngredient(
    id: 'paneer',
    label: 'Paneer',
    emoji: '🧀',
    keywords: ['paneer'],
  ),
  FridgeIngredient(
    id: 'poha',
    label: 'Poha',
    emoji: '🍚',
    keywords: ['poha'],
  ),
  FridgeIngredient(
    id: 'besan',
    label: 'Besan',
    emoji: '🥣',
    keywords: ['besan'],
  ),
  FridgeIngredient(
    id: 'moong',
    label: 'Moong',
    emoji: '🫘',
    keywords: ['moong', 'dal'],
  ),
  FridgeIngredient(
    id: 'onion',
    label: 'Onion',
    emoji: '🧅',
    keywords: ['onion'],
  ),
  FridgeIngredient(
    id: 'potato',
    label: 'Potato',
    emoji: '🥔',
    keywords: ['potato', 'aloo'],
  ),
  FridgeIngredient(
    id: 'capsicum',
    label: 'Capsicum',
    emoji: '🫑',
    keywords: ['capsicum', 'bell pepper', 'pepper'],
  ),
  FridgeIngredient(
    id: 'cucumber',
    label: 'Cucumber',
    emoji: '🥒',
    keywords: ['cucumber'],
  ),
  FridgeIngredient(
    id: 'corn',
    label: 'Corn',
    emoji: '🌽',
    keywords: ['corn', 'sweet corn'],
  ),
  FridgeIngredient(
    id: 'rice',
    label: 'Rice',
    emoji: '🍚',
    keywords: ['rice', 'chawal'],
  ),
  FridgeIngredient(
    id: 'coconut',
    label: 'Coconut',
    emoji: '🥥',
    keywords: ['coconut', 'nariyal'],
  ),
];

import 'dart:math';

import 'package:flutter/material.dart';
import '../../plans/models/recipe.dart';
import '../utils/recipe_health_filter.dart';

final Map<String, Recipe> recipeCatalogByName = {
  'Avocado Toast': const Recipe(
    emoji: '🥑',
    name: 'Avocado Toast',
    time: '10 min',
    calories: '320 cal',
    protein: '12g',
    accent_color: Color(0xFF1DB954),
    background_color: Color(0xFF0D2A1A),
    tags: [
      RecipeTag(label: 'PROTEIN', color: Color(0xFF1DB954)),
      RecipeTag(label: 'ENERGY', color: Color(0xFFFF9500)),
    ],
    description:
        'Creamy avocado on toasted sourdough with lemon and chili flakes for a balanced morning boost.',
    ingredients: [
      '2 slices whole grain bread',
      '1 ripe avocado',
      '1 tsp lemon juice',
      'Salt and pepper to taste',
    ],
    steps: [
      'Toast the bread until golden.',
      'Mash avocado with lemon, salt, and pepper.',
      'Spread on toast and serve immediately.',
    ],
  ),
  'Scrambled Eggs': const Recipe(
    emoji: '🍳',
    name: 'Scrambled Eggs',
    time: '5 min',
    calories: '280 cal',
    protein: '18g',
    accent_color: Color(0xFFFF9500),
    background_color: Color(0xFF2A1A00),
    tags: [
      RecipeTag(label: 'HIGH-PROTEIN', color: Color(0xFFFF375F)),
      RecipeTag(label: 'QUICK', color: Color(0xFFFF9500)),
    ],
    description:
        'Fluffy scrambled eggs cooked low and slow for a rich, protein-packed breakfast.',
    ingredients: [
      '3 large eggs',
      '1 tbsp butter',
      '2 tbsp milk',
      'Salt and pepper',
    ],
    steps: [
      'Whisk eggs with milk, salt, and pepper.',
      'Melt butter in a pan over low heat.',
      'Stir gently until softly set and serve.',
    ],
    diet_type: 'non_veg',
  ),
  'Berry Smoothie': const Recipe(
    emoji: '🫐',
    name: 'Berry Smoothie',
    time: '5 min',
    calories: '180 cal',
    protein: '4g',
    accent_color: Color(0xFFBF5AF2),
    background_color: Color(0xFF1A0D2A),
    tags: [
      RecipeTag(label: 'ANTIOXIDANTS', color: Color(0xFFBF5AF2)),
      RecipeTag(label: 'IMMUNITY', color: Color(0xFF0A84FF)),
    ],
    description:
        'A refreshing blend of berries and banana packed with antioxidants.',
    ingredients: [
      '1 cup mixed berries',
      '1 banana',
      '1/2 cup Greek yogurt',
      '1/2 cup almond milk',
    ],
    steps: [
      'Add all ingredients to a blender.',
      'Blend until smooth.',
      'Serve chilled.',
    ],
  ),
  'Oatmeal Bowl': const Recipe(
    emoji: '🥣',
    name: 'Oatmeal Bowl',
    time: '15 min',
    calories: '350 cal',
    protein: '8g',
    accent_color: Color(0xFF0A84FF),
    background_color: Color(0xFF001833),
    tags: [
      RecipeTag(label: 'FIBER', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'IRON', color: Color(0xFFFF375F)),
    ],
    description:
        'Warm steel-cut oats topped with berries and nuts for sustained morning energy.',
    ingredients: [
      '1/2 cup rolled oats',
      '1 cup milk or water',
      '1/4 cup mixed berries',
      '1 tbsp honey',
      '1 tbsp chopped almonds',
    ],
    steps: [
      'Bring liquid to a boil and add oats.',
      'Simmer for 10 minutes, stirring occasionally.',
      'Top with berries, almonds, and honey.',
    ],
  ),
  'Protein Shake': const Recipe(
    emoji: '🥤',
    name: 'Protein Shake',
    time: '3 min',
    calories: '220 cal',
    protein: '25g',
    accent_color: Color(0xFF1DB954),
    background_color: Color(0xFF0D3320),
    tags: [
      RecipeTag(label: 'PROTEIN', color: Color(0xFF1DB954)),
      RecipeTag(label: 'QUICK', color: Color(0xFFFF9500)),
    ],
    description:
        'A fast post-workout shake with whey protein, banana, and almond milk.',
    ingredients: [
      '1 scoop protein powder',
      '1 banana',
      '1 cup almond milk',
      '1 tbsp peanut butter',
      'Ice cubes',
    ],
    steps: [
      'Add all ingredients to a blender.',
      'Blend for 30 seconds until smooth.',
      'Pour and drink immediately.',
    ],
  ),
  'Whole Wheat Waffles': const Recipe(
    emoji: '🧇',
    name: 'Whole Wheat Waffles',
    time: '20 min',
    calories: '410 cal',
    protein: '10g',
    accent_color: Color(0xFFFF9500),
    background_color: Color(0xFF2A1500),
    tags: [
      RecipeTag(label: 'ENERGY', color: Color(0xFFFF9500)),
      RecipeTag(label: 'FIBER', color: Color(0xFF0A84FF)),
    ],
    description:
        'Crispy whole wheat waffles with a light honey drizzle — weekend breakfast perfection.',
    ingredients: [
      '1 cup whole wheat flour',
      '1 egg',
      '3/4 cup milk',
      '2 tbsp honey',
      '1 tsp baking powder',
    ],
    steps: [
      'Mix dry ingredients in a bowl.',
      'Whisk in egg, milk, and honey until smooth.',
      'Cook in a preheated waffle iron until golden.',
    ],
    diet_type: 'non_veg',
  ),
  'Banana Peanut Shake': const Recipe(
    emoji: '🍌',
    name: 'Banana Peanut Shake',
    time: '5 min',
    calories: '300 cal',
    protein: '10g',
    accent_color: Color(0xFFFFD60A),
    background_color: Color(0xFF2A2200),
    tags: [
      RecipeTag(label: 'ENERGY', color: Color(0xFFFFD60A)),
      RecipeTag(label: 'POTASSIUM', color: Color(0xFF1DB954)),
    ],
    description:
        'Creamy banana and peanut butter shake — great for potassium and healthy fats.',
    ingredients: [
      '2 bananas',
      '2 tbsp peanut butter',
      '1 cup milk',
      '1 tsp honey',
      'Ice cubes',
    ],
    steps: [
      'Peel bananas and add to blender.',
      'Add peanut butter, milk, honey, and ice.',
      'Blend until creamy and serve.',
    ],
  ),
  'Protein Pancakes': const Recipe(
    emoji: '🥞',
    name: 'Protein Pancakes',
    time: '15 min',
    calories: '380 cal',
    protein: '22g',
    accent_color: Color(0xFFFF375F),
    background_color: Color(0xFF2A0D1A),
    tags: [
      RecipeTag(label: 'HIGH-PROTEIN', color: Color(0xFFFF375F)),
      RecipeTag(label: 'FILLING', color: Color(0xFFBF5AF2)),
    ],
    description:
        'Fluffy high-protein pancakes made with oats and egg whites — filling and delicious.',
    ingredients: [
      '1/2 cup oats',
      '3 egg whites',
      '1 scoop protein powder',
      '1/2 tsp baking powder',
      'Berries for topping',
    ],
    steps: [
      'Blend oats into flour consistency.',
      'Mix with egg whites, protein powder, and baking powder.',
      'Cook on a non-stick pan and top with berries.',
    ],
    diet_type: 'non_veg',
  ),
  'Greek Yogurt Bowl': const Recipe(
    emoji: '🍓',
    name: 'Greek Yogurt Bowl',
    time: '5 min',
    calories: '280 cal',
    protein: '15g',
    accent_color: Color(0xFF1DB954),
    background_color: Color(0xFF0D2A1A),
    tags: [
      RecipeTag(label: 'PROBIOTIC', color: Color(0xFF1DB954)),
      RecipeTag(label: 'CALCIUM', color: Color(0xFF0A84FF)),
    ],
    description:
        'Thick Greek yogurt layered with granola, honey, and fresh berries.',
    ingredients: [
      '1 cup Greek yogurt',
      '1/4 cup granola',
      '1/2 cup mixed berries',
      '1 tbsp honey',
      'Mint leaves (optional)',
    ],
    steps: [
      'Spoon yogurt into a bowl.',
      'Top with granola and berries.',
      'Drizzle honey and garnish with mint.',
    ],
  ),
  'Chia Pudding': const Recipe(
    emoji: '🫙',
    name: 'Chia Pudding',
    time: '5 min',
    calories: '240 cal',
    protein: '8g',
    accent_color: Color(0xFF0A84FF),
    background_color: Color(0xFF001833),
    tags: [
      RecipeTag(label: 'OMEGA-3', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'FIBER', color: Color(0xFFBF5AF2)),
    ],
    description:
        'Overnight chia pudding with almond milk — prep ahead for a zero-morning-stress breakfast.',
    ingredients: [
      '3 tbsp chia seeds',
      '1 cup almond milk',
      '1 tbsp maple syrup',
      'Fresh fruit for topping',
    ],
    steps: [
      'Mix chia seeds, milk, and syrup in a jar.',
      'Refrigerate overnight or at least 4 hours.',
      'Stir and top with fresh fruit before serving.',
    ],
  ),
  'Green Detox Salad': const Recipe(
    emoji: '🥗',
    name: 'Green Detox Salad',
    time: '10 min',
    calories: '180 cal',
    protein: '6g',
    accent_color: Color(0xFF1DB954),
    background_color: Color(0xFF0D2A1A),
    tags: [
      RecipeTag(label: 'DETOX', color: Color(0xFF1DB954)),
      RecipeTag(label: 'LOW-CAL', color: Color(0xFFFF9500)),
    ],
    description:
        'A vibrant mix of kale, cucumber, and avocado with a light lemon dressing.',
    ingredients: [
      '2 cups kale',
      '1 cucumber, sliced',
      '1/2 avocado',
      '1 tbsp olive oil',
      'Juice of 1 lemon',
    ],
    steps: [
      'Massage kale with a pinch of salt.',
      'Add cucumber and diced avocado.',
      'Toss with olive oil and lemon juice.',
    ],
  ),
  'Multigrain Toast': const Recipe(
    emoji: '🍞',
    name: 'Multigrain Toast',
    time: '5 min',
    calories: '210 cal',
    protein: '7g',
    accent_color: Color(0xFFFFD60A),
    background_color: Color(0xFF1A1200),
    tags: [
      RecipeTag(label: 'FIBER', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'QUICK', color: Color(0xFFFF9500)),
    ],
    description:
        'Toasted multigrain bread with cottage cheese and a sprinkle of seeds.',
    ingredients: [
      '2 slices multigrain bread',
      '1/4 cup cottage cheese',
      '1 tbsp mixed seeds',
      'Black pepper',
    ],
    steps: [
      'Toast bread until crisp.',
      'Spread cottage cheese evenly.',
      'Top with seeds and black pepper.',
    ],
  ),
  'Peanut Butter Bowl': const Recipe(
    emoji: '🥜',
    name: 'Peanut Butter Bowl',
    time: '5 min',
    calories: '420 cal',
    protein: '16g',
    accent_color: Color(0xFFFF9500),
    background_color: Color(0xFF2A1500),
    tags: [
      RecipeTag(label: 'HEALTHY-FAT', color: Color(0xFFFF9500)),
      RecipeTag(label: 'PROTEIN', color: Color(0xFF1DB954)),
    ],
    description:
        'A hearty bowl of oats, peanut butter, banana slices, and a dark chocolate drizzle.',
    ingredients: [
      '1/2 cup cooked oats',
      '2 tbsp peanut butter',
      '1 banana, sliced',
      '1 tsp dark chocolate chips',
    ],
    steps: [
      'Warm oats in a bowl.',
      'Stir in peanut butter until melted.',
      'Top with banana and chocolate chips.',
    ],
  ),
  'Mediterranean Bowl': const Recipe(
    emoji: '🫒',
    name: 'Mediterranean Bowl',
    time: '15 min',
    calories: '360 cal',
    protein: '14g',
    accent_color: Color(0xFF0A84FF),
    background_color: Color(0xFF001833),
    tags: [
      RecipeTag(label: 'OMEGA-3', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'HEART', color: Color(0xFFFF375F)),
    ],
    description:
        'A savory bowl with hummus, olives, cucumber, feta, and soft-boiled egg.',
    ingredients: [
      '1/2 cup hummus',
      '1/4 cup olives',
      '1/2 cucumber, diced',
      '30g feta cheese',
      '1 soft-boiled egg',
    ],
    steps: [
      'Spread hummus in the base of a bowl.',
      'Arrange olives, cucumber, and feta on top.',
      'Halve the egg and place on top to serve.',
    ],
    diet_type: 'non_veg',
  ),
  'Corn Upma': const Recipe(
    emoji: '🌽',
    name: 'Corn Upma',
    time: '20 min',
    calories: '290 cal',
    protein: '9g',
    accent_color: Color(0xFFFFD60A),
    background_color: Color(0xFF2A2200),
    tags: [
      RecipeTag(label: 'ENERGY', color: Color(0xFFFFD60A)),
      RecipeTag(label: 'FIBER', color: Color(0xFF1DB954)),
    ],
    description:
        'A light South Indian-style upma with sweet corn, mustard seeds, and curry leaves.',
    ingredients: [
      '1 cup semolina',
      '1/2 cup sweet corn',
      '1 tsp mustard seeds',
      'Curry leaves',
      '1 tbsp oil',
    ],
    steps: [
      'Roast semolina until lightly golden.',
      'Temper mustard seeds and curry leaves in oil.',
      'Add water, corn, and semolina; cook until fluffy.',
    ],
  ),
  'Egg Bhurji with Toast': const Recipe(
    emoji: '🍳',
    name: 'Egg Bhurji with Toast',
    time: '12 min',
    calories: '340 cal',
    protein: '20g',
    accent_color: Color(0xFFFF9500),
    background_color: Color(0xFF2A1A00),
    tags: [
      RecipeTag(label: 'HIGH-PROTEIN', color: Color(0xFFFF375F)),
      RecipeTag(label: 'QUICK', color: Color(0xFFFF9500)),
    ],
    description:
        'Spiced Indian-style scrambled eggs with onion, tomato, and crisp multigrain toast.',
    ingredients: [
      '3 eggs',
      '1 small onion, chopped',
      '1 small tomato, chopped',
      '1/2 tsp turmeric',
      '1/2 tsp red chili powder',
      '2 slices multigrain bread',
      '1 tsp oil',
      'Salt to taste',
    ],
    steps: [
      'Heat oil and sauté onion until soft.',
      'Add tomato and spices; cook 2 minutes.',
      'Add beaten eggs and scramble until set.',
      'Toast bread and serve bhurji alongside.',
    ],
    diet_type: 'non_veg',
  ),
  'Paneer Bhurji on Grilled Bread': const Recipe(
    emoji: '🧀',
    name: 'Paneer Bhurji on Grilled Bread',
    time: '15 min',
    calories: '360 cal',
    protein: '18g',
    accent_color: Color(0xFF1DB954),
    background_color: Color(0xFF0D3320),
    tags: [
      RecipeTag(label: 'HIGH-PROTEIN', color: Color(0xFFFF375F)),
    ],
    description:
        'Soft crumbled paneer bhurji with capsicum and spices on grilled multigrain bread.',
    ingredients: [
      '150g paneer, crumbled',
      '1/2 capsicum, chopped',
      '1 small onion, chopped',
      '1/2 tsp garam masala',
      '2 slices multigrain bread',
      '1 tsp oil',
      'Fresh coriander',
    ],
    steps: [
      'Sauté onion and capsicum in oil.',
      'Add paneer, spices, and salt; cook 4 minutes.',
      'Grill bread until crisp.',
      'Top toast with hot paneer bhurji and coriander.',
    ],
  ),
  'Vegetable Poha': const Recipe(
    emoji: '🍚',
    name: 'Vegetable Poha',
    time: '15 min',
    calories: '260 cal',
    protein: '7g',
    accent_color: Color(0xFFFFD60A),
    background_color: Color(0xFF2A2200),
    tags: [
      RecipeTag(label: 'QUICK', color: Color(0xFFFF9500)),
      RecipeTag(label: 'FIBER', color: Color(0xFF1DB954)),
    ],
    description:
        'Light flattened rice tossed with peanuts, peas, and tempered mustard seeds.',
    ingredients: [
      '1 cup thick poha, rinsed',
      '1/4 cup peas',
      '2 tbsp peanuts',
      '1 tsp mustard seeds',
      '1 small onion',
      'Turmeric, curry leaves',
      '1 tbsp oil',
      'Lemon wedge',
    ],
    steps: [
      'Rinse poha and drain well.',
      'Temper mustard seeds, curry leaves, and peanuts in oil.',
      'Add onion, peas, and turmeric; cook briefly.',
      'Fold in poha, season, and finish with lemon.',
    ],
  ),
  'Besan Chilla': const Recipe(
    emoji: '🥞',
    name: 'Besan Chilla',
    time: '12 min',
    calories: '240 cal',
    protein: '14g',
    accent_color: Color(0xFFFF9500),
    background_color: Color(0xFF2A1500),
    tags: [
      RecipeTag(label: 'HIGH-PROTEIN', color: Color(0xFFFF375F)),
      RecipeTag(label: 'QUICK', color: Color(0xFFFF9500)),
    ],
    description:
        'Savory chickpea flour pancake with onion, tomato, and coriander.',
    ingredients: [
      '1 cup besan',
      '1 small onion, finely chopped',
      '1 small tomato, chopped',
      '1 green chili, chopped',
      '1/2 tsp ajwain',
      'Water to batter',
      '1 tsp oil',
    ],
    steps: [
      'Whisk besan with water, salt, and ajwain into a smooth batter.',
      'Mix in onion, tomato, and chili.',
      'Spread thin on a hot pan with oil.',
      'Cook both sides until golden and serve hot.',
    ],
  ),
  'Moong Dal Cheela': const Recipe(
    emoji: '🫘',
    name: 'Moong Dal Cheela',
    time: '20 min',
    calories: '220 cal',
    protein: '13g',
    accent_color: Color(0xFF1DB954),
    background_color: Color(0xFF0D2A1A),
    tags: [
      RecipeTag(label: 'PROTEIN', color: Color(0xFF1DB954)),
      RecipeTag(label: 'FIBER', color: Color(0xFF0A84FF)),
    ],
    description:
        'Green moong dal crepe with ginger and green chili — light and protein-packed.',
    ingredients: [
      '1 cup soaked moong dal',
      '1 inch ginger',
      '1 green chili',
      'Pinch of asafoetida',
      '2 tbsp chopped coriander',
      '1 tsp oil',
    ],
    steps: [
      'Blend soaked dal with ginger, chili, and salt.',
      'Stir in coriander.',
      'Pour batter on a non-stick pan and spread thin.',
      'Cook both sides with a little oil until crisp.',
    ],
  ),
  'Masala Oats': const Recipe(
    emoji: '🥣',
    name: 'Masala Oats',
    time: '15 min',
    calories: '280 cal',
    protein: '9g',
    accent_color: Color(0xFF0A84FF),
    background_color: Color(0xFF001833),
    tags: [
      RecipeTag(label: 'FIBER', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'ENERGY', color: Color(0xFFFF9500)),
    ],
    description:
        'Indian-style masala oats with carrot, beans, and tempered spices.',
    ingredients: [
      '1/2 cup rolled oats',
      '1/4 cup mixed vegetables',
      '1 tsp mustard seeds',
      '1 small onion',
      '1/2 tsp turmeric',
      'Curry leaves',
      '1 cup water',
      '1 tsp oil',
    ],
    steps: [
      'Temper mustard seeds and curry leaves in oil.',
      'Sauté onion and vegetables with turmeric.',
      'Add oats and water; cook until soft.',
      'Season and serve warm.',
    ],
  ),
  'Idli with Coconut Chutney': const Recipe(
    emoji: '🍥',
    name: 'Idli with Coconut Chutney',
    time: '20 min',
    calories: '250 cal',
    protein: '8g',
    accent_color: Color(0xFF0A84FF),
    background_color: Color(0xFF0D1A2A),
    tags: [
      RecipeTag(label: 'LOW-CAL', color: Color(0xFFFF9500)),
      RecipeTag(label: 'PROBIOTIC', color: Color(0xFF1DB954)),
    ],
    description:
        'Steamed soft idlis served with fresh coconut chutney.',
    ingredients: [
      '4 steamed idlis',
      '1/2 cup grated coconut',
      '2 tbsp roasted chana dal',
      '1 green chili',
      '1/2 tsp mustard seeds',
      'Curry leaves',
      'Salt to taste',
    ],
    steps: [
      'Blend coconut, chana dal, chili, and salt with little water.',
      'Temper mustard seeds and curry leaves for chutney.',
      'Steam or warm idlis until soft.',
      'Serve idlis with chutney.',
    ],
  ),
  'Sprouts Chaat Bowl': const Recipe(
    emoji: '🌱',
    name: 'Sprouts Chaat Bowl',
    time: '10 min',
    calories: '200 cal',
    protein: '11g',
    accent_color: Color(0xFF1DB954),
    background_color: Color(0xFF0D3320),
    tags: [
      RecipeTag(label: 'IMMUNITY', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'FIBER', color: Color(0xFF1DB954)),
    ],
    description:
        'Sprouted moong tossed with onion, cucumber, lemon, and chaat masala.',
    ingredients: [
      '1 cup sprouted moong',
      '1/2 cucumber, diced',
      '1 small onion, chopped',
      '1 tomato, chopped',
      '1 tsp chaat masala',
      'Lemon juice',
      'Fresh coriander',
    ],
    steps: [
      'Combine sprouts, cucumber, onion, and tomato.',
      'Add chaat masala, lemon juice, and salt.',
      'Toss well and top with coriander.',
      'Serve immediately.',
    ],
  ),
  'Methi Thepla with Dahi': const Recipe(
    emoji: '🫓',
    name: 'Methi Thepla with Dahi',
    time: '25 min',
    calories: '310 cal',
    protein: '12g',
    accent_color: Color(0xFFFFD60A),
    background_color: Color(0xFF2A2200),
    tags: [
      RecipeTag(label: 'FIBER', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'PROBIOTIC', color: Color(0xFF1DB954)),
    ],
    description:
        'Soft fenugreek flatbreads paired with fresh curd — a Gujarati favourite.',
    ingredients: [
      '1 cup whole wheat flour',
      '1/2 cup chopped methi leaves',
      '1/2 tsp ajwain',
      '1/2 tsp turmeric',
      '1 cup fresh curd',
      '1 tsp oil',
      'Salt to taste',
    ],
    steps: [
      'Knead flour with methi, spices, oil, and water.',
      'Roll and cook theplas on a hot tawa.',
      'Serve warm with fresh curd.',
      'Pair with pickle if desired.',
    ],
  ),
  'Vegetable Dalia': const Recipe(
    emoji: '🌾',
    name: 'Vegetable Dalia',
    time: '20 min',
    calories: '270 cal',
    protein: '8g',
    accent_color: Color(0xFFFF9500),
    background_color: Color(0xFF2A1500),
    tags: [
      RecipeTag(label: 'FIBER', color: Color(0xFF0A84FF)),
      RecipeTag(label: 'FILLING', color: Color(0xFFBF5AF2)),
    ],
    description:
        'Comforting broken wheat porridge cooked with mixed vegetables and mild spices.',
    ingredients: [
      '1/2 cup broken wheat dalia',
      '1/4 cup mixed vegetables',
      '1 small tomato',
      '1/2 tsp cumin',
      '1 tsp ghee or oil',
      '4 cups water',
      'Salt to taste',
    ],
    steps: [
      'Dry roast dalia for 2 minutes.',
      'Sauté cumin, vegetables, and tomato.',
      'Add dalia and water; simmer until soft.',
      'Adjust consistency and serve warm.',
    ],
  ),
};

const Map<String, List<String>> kRecipeMealGoals = {
  'Avocado Toast': ['stay_healthy', 'build_muscle'],
  'Scrambled Eggs': ['build_muscle', 'gain_weight'],
  'Berry Smoothie': ['detox', 'stay_healthy'],
  'Oatmeal Bowl': ['gain_weight', 'stay_healthy'],
  'Protein Shake': ['build_muscle'],
  'Whole Wheat Waffles': ['gain_weight'],
  'Banana Peanut Shake': ['gain_weight', 'build_muscle'],
  'Protein Pancakes': ['build_muscle', 'gain_weight'],
  'Greek Yogurt Bowl': ['stay_healthy', 'detox'],
  'Chia Pudding': ['detox', 'stay_healthy'],
  'Green Detox Salad': ['detox'],
  'Multigrain Toast': ['stay_healthy'],
  'Peanut Butter Bowl': ['gain_weight', 'build_muscle'],
  'Mediterranean Bowl': ['stay_healthy', 'build_muscle'],
  'Corn Upma': ['gain_weight', 'stay_healthy'],
  'Egg Bhurji with Toast': ['build_muscle', 'gain_weight'],
  'Paneer Bhurji on Grilled Bread': ['build_muscle', 'stay_healthy'],
  'Vegetable Poha': ['stay_healthy', 'detox'],
  'Besan Chilla': ['build_muscle', 'stay_healthy'],
  'Moong Dal Cheela': ['build_muscle', 'detox'],
  'Masala Oats': ['stay_healthy', 'gain_weight'],
  'Idli with Coconut Chutney': ['stay_healthy', 'detox'],
  'Sprouts Chaat Bowl': ['detox', 'stay_healthy'],
  'Methi Thepla with Dahi': ['stay_healthy', 'gain_weight'],
  'Vegetable Dalia': ['gain_weight', 'stay_healthy'],
};

Recipe _recipeWithGoals(Recipe recipe) {
  final goals = kRecipeMealGoals[recipe.name];
  if (goals == null) return recipe;
  return Recipe(
    id: recipe.id,
    slug: recipe.slug,
    emoji: recipe.emoji,
    name: recipe.name,
    time: recipe.time,
    calories: recipe.calories,
    protein: recipe.protein,
    accent_color: recipe.accent_color,
    background_color: recipe.background_color,
    tags: recipe.tags,
    description: recipe.description,
    ingredients: recipe.ingredients,
    steps: recipe.steps,
    diet_type: recipe.diet_type,
    meal_goals: goals,
  );
}

List<Recipe> resolveRecipeCatalog(List<Recipe>? catalog) {
  if (catalog == null || catalog.isEmpty) {
    return [];
  }
  return catalog;
}

Recipe? catalogRecipeByName(String name, {List<Recipe>? catalog}) {
  final list = resolveRecipeCatalog(catalog);
  for (final recipe in list) {
    if (recipe.name == name) {
      return recipe;
    }
  }
  final recipe = recipeCatalogByName[name];
  if (recipe == null) return null;
  return _recipeWithGoals(recipe);
}

List<Recipe> recipesForPreferences({
  required String diet_type,
  Set<String> meal_goals = const {},
  List<Recipe>? catalog,
}) {
  var pool = resolveRecipeCatalog(catalog)
      .where((recipe) => recipe.diet_type == diet_type);

  if (meal_goals.isNotEmpty) {
    final matched = pool.where((recipe) => recipe.matchesGoals(meal_goals)).toList();
    if (matched.isNotEmpty) pool = matched;
  }

  return pool.toList();
}

List<Recipe> recipesForDiet(String diet_type, {List<Recipe>? catalog}) {
  return recipesForPreferences(diet_type: diet_type, catalog: catalog);
}

List<Recipe> pickRandomMealsForPreferences({
  required String diet_type,
  Set<String> meal_goals = const {},
  int count = 4,
  Random? random,
  Set<String>? exclude_names,
  List<Recipe>? catalog,
  List<String> allergies = const [],
  List<String> conditions = const [],
}) {
  final rng = random ?? Random();
  var pool = recipesForPreferences(
    diet_type: diet_type,
    meal_goals: meal_goals,
    catalog: catalog,
  )
      .where((recipe) => !(exclude_names?.contains(recipe.name) ?? false))
      .toList();

  pool = filter_recipes_for_health(
    pool,
    allergies: allergies,
    conditions: conditions,
  );

  if (pool.length < count) {
    pool = filter_recipes_for_health(
      recipesForPreferences(
        diet_type: diet_type,
        meal_goals: meal_goals,
        catalog: catalog,
      ).toList(),
      allergies: allergies,
      conditions: conditions,
    );
    if (exclude_names != null && exclude_names.isNotEmpty) {
      pool = pool
          .where((recipe) => !exclude_names.contains(recipe.name))
          .toList();
    }
  }

  pool.shuffle(rng);
  return pool.take(count).toList();
}

List<Recipe> pickRandomMealsForDiet(
  String diet_type, {
  int count = 4,
  Random? random,
  Set<String>? exclude_names,
  List<Recipe>? catalog,
}) {
  return pickRandomMealsForPreferences(
    diet_type: diet_type,
    count: count,
    random: random,
    exclude_names: exclude_names,
    catalog: catalog,
  );
}

Recipe recipeFromCardMap(
  Map<String, dynamic> map, {
  List<Recipe>? catalog,
}) {
  final name = map['name'] as String;
  final resolved = catalogRecipeByName(name, catalog: catalog);
  if (resolved != null) {
    return resolved;
  }

  final tags = (map['tags'] as List<Map<String, dynamic>>)
      .map(
        (tag) => RecipeTag(
          label: tag['label'] as String,
          color: tag['color'] as Color,
        ),
      )
      .toList();

  return Recipe(
    emoji: map['emoji'] as String,
    name: name,
    time: map['time'] as String,
    calories: map['cal'] as String,
    protein: map['protein'] as String,
    accent_color: map['border'] as Color,
    background_color: map['bg'] as Color,
    tags: tags,
    description: 'A nutritious breakfast recipe tailored for your morning routine.',
    ingredients: const [
      'Fresh ingredients',
      'Season to taste',
    ],
    steps: const [
      'Prepare all ingredients.',
      'Follow your preferred cooking method.',
      'Serve warm and enjoy.',
    ],
  );
}

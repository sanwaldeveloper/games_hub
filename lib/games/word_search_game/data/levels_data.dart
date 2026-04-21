// games/word_search/data/levels_data.dart

import '../models/level_model.dart';

final List<WordSearchLevelModel> wsAllLevels = [
  // ── FRUITS ──────────────────────────────────────────────────
  WordSearchLevelModel(
    id: 1, theme: 'Fruits', themeIcon: '🍎',
    words: ['APPLE', 'MANGO', 'PLUM', 'PEAR', 'KIWI'],
    gridSize: 8, difficulty: WordSearchDifficulty.easy,
  ),
  WordSearchLevelModel(
    id: 2, theme: 'Fruits', themeIcon: '🍓',
    words: ['GRAPE', 'LEMON', 'BERRY', 'PEACH', 'MELON', 'LIME'],
    gridSize: 9, difficulty: WordSearchDifficulty.medium, allowBackward: true,
  ),
  WordSearchLevelModel(
    id: 3, theme: 'Fruits', themeIcon: '🍍',
    words: ['PINEAPPLE', 'BLUEBERRY', 'WATERMELON', 'COCONUT', 'PAPAYA', 'AVOCADO'],
    gridSize: 12, difficulty: WordSearchDifficulty.hard,
    allowDiagonal: true, allowBackward: true,
  ),

  // ── ANIMALS ─────────────────────────────────────────────────
  WordSearchLevelModel(
    id: 4, theme: 'Animals', themeIcon: '🐘',
    words: ['CAT', 'DOG', 'COW', 'HEN', 'PIG', 'FOX'],
    gridSize: 8, difficulty: WordSearchDifficulty.easy,
  ),
  WordSearchLevelModel(
    id: 5, theme: 'Animals', themeIcon: '🦁',
    words: ['TIGER', 'HORSE', 'SHEEP', 'EAGLE', 'SNAKE', 'WHALE'],
    gridSize: 10, difficulty: WordSearchDifficulty.medium, allowBackward: true,
  ),
  WordSearchLevelModel(
    id: 6, theme: 'Animals', themeIcon: '🦋',
    words: ['ELEPHANT', 'CROCODILE', 'BUTTERFLY', 'CHEETAH', 'DOLPHIN', 'GORILLA'],
    gridSize: 12, difficulty: WordSearchDifficulty.hard,
    allowDiagonal: true, allowBackward: true,
  ),

  // ── COUNTRIES ───────────────────────────────────────────────
  WordSearchLevelModel(
    id: 7, theme: 'Countries', themeIcon: '🌍',
    words: ['CHINA', 'INDIA', 'SPAIN', 'JAPAN', 'ITALY'],
    gridSize: 9, difficulty: WordSearchDifficulty.easy,
  ),
  WordSearchLevelModel(
    id: 8, theme: 'Countries', themeIcon: '🗺️',
    words: ['FRANCE', 'BRAZIL', 'CANADA', 'MEXICO', 'RUSSIA', 'TURKEY'],
    gridSize: 10, difficulty: WordSearchDifficulty.medium, allowBackward: true,
  ),
  WordSearchLevelModel(
    id: 9, theme: 'Countries', themeIcon: '✈️',
    words: ['ARGENTINA', 'AUSTRALIA', 'PORTUGAL', 'PAKISTAN', 'GERMANY', 'ETHIOPIA'],
    gridSize: 12, difficulty: WordSearchDifficulty.hard,
    allowDiagonal: true, allowBackward: true,
  ),

  // ── DAILY OBJECTS ────────────────────────────────────────────
  WordSearchLevelModel(
    id: 10, theme: 'Daily Objects', themeIcon: '🏠',
    words: ['CUP', 'PEN', 'BOOK', 'LAMP', 'DESK', 'FORK'],
    gridSize: 8, difficulty: WordSearchDifficulty.easy,
  ),
  WordSearchLevelModel(
    id: 11, theme: 'Daily Objects', themeIcon: '📱',
    words: ['PHONE', 'CHAIR', 'CLOCK', 'KNIFE', 'PLATE', 'BRUSH'],
    gridSize: 10, difficulty: WordSearchDifficulty.medium, allowBackward: true,
  ),
  WordSearchLevelModel(
    id: 12, theme: 'Daily Objects', themeIcon: '🔧',
    words: ['KEYBOARD', 'UMBRELLA', 'CALENDAR', 'BACKPACK', 'SCISSORS', 'NOTEBOOK'],
    gridSize: 12, difficulty: WordSearchDifficulty.hard,
    allowDiagonal: true, allowBackward: true,
  ),

  // ── SPORTS ──────────────────────────────────────────────────
  WordSearchLevelModel(
    id: 13, theme: 'Sports', themeIcon: '⚽',
    words: ['GOLF', 'POLO', 'SWIM', 'SURF', 'YOGA'],
    gridSize: 8, difficulty: WordSearchDifficulty.easy,
  ),
  WordSearchLevelModel(
    id: 14, theme: 'Sports', themeIcon: '🏀',
    words: ['TENNIS', 'BOXING', 'SOCCER', 'HOCKEY', 'ROWING', 'DIVING'],
    gridSize: 10, difficulty: WordSearchDifficulty.medium, allowBackward: true,
  ),
  WordSearchLevelModel(
    id: 15, theme: 'Sports', themeIcon: '🏆',
    words: ['BASKETBALL', 'VOLLEYBALL', 'BADMINTON', 'ATHLETICS', 'WRESTLING', 'GYMNASTICS'],
    gridSize: 12, difficulty: WordSearchDifficulty.hard,
    allowDiagonal: true, allowBackward: true,
  ),
];

WordSearchLevelModel getWSDailyChallenge() {
  final dayOfYear =
      DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return WordSearchLevelModel(
    id: 99,
    theme: 'Daily Challenge',
    themeIcon: '🌟',
    words: _dailyWordPool[dayOfYear % _dailyWordPool.length],
    gridSize: 11,
    difficulty: WordSearchDifficulty.medium,
    allowDiagonal: true,
    allowBackward: true,
  );
}

const List<List<String>> _dailyWordPool = [
  ['FLUTTER', 'MOBILE', 'WIDGET', 'SCREEN', 'BUTTON'],
  ['NATURE', 'FOREST', 'RIVER', 'MOUNTAIN', 'VALLEY'],
  ['MUSIC', 'GUITAR', 'PIANO', 'VIOLIN', 'DRUMS', 'FLUTE'],
  ['SPACE', 'PLANET', 'GALAXY', 'COMET', 'METEOR', 'ORBIT'],
  ['OCEAN', 'CORAL', 'SHARK', 'WHALE', 'TURTLE', 'CRAB'],
  ['WINTER', 'SPRING', 'SUMMER', 'AUTUMN', 'SEASON'],
  ['PIZZA', 'PASTA', 'BURGER', 'SUSHI', 'TACOS', 'CURRY'],
];

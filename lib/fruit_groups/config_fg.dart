import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a fruit item for groups counting
class FruitGroupsItem {
  final String emoji;
  final String name;

  const FruitGroupsItem({required this.emoji, required this.name});
}

/// Palette of fruits for the Fruit Groups game
const List<FruitGroupsItem> fruitGroupsPalette = [
  FruitGroupsItem(emoji: '🍎', name: 'apples'),
  FruitGroupsItem(emoji: '🍊', name: 'oranges'),
  FruitGroupsItem(emoji: '🍌', name: 'bananas'),
  FruitGroupsItem(emoji: '🍇', name: 'grapes'),
  FruitGroupsItem(emoji: '🍓', name: 'strawberries'),
  FruitGroupsItem(emoji: '🍒', name: 'cherries'),
  FruitGroupsItem(emoji: '🥭', name: 'mangoes'),
  FruitGroupsItem(emoji: '🍑', name: 'peaches'),
  FruitGroupsItem(emoji: '🍐', name: 'pears'),
  FruitGroupsItem(emoji: '🫐', name: 'blueberries'),
];

/// Game phases for Fruit Groups
enum FruitGroupsGamePhase { learning, testing, success }

/// State for the Fruit Groups game
class FruitGroupsState {
  final FruitGroupsItem currentItem;
  final List<int> basketCounts; // Items in each basket
  final List<int> testOptions;
  final int correctAnswer;
  final FruitGroupsGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;

  const FruitGroupsState({
    required this.currentItem,
    required this.basketCounts,
    required this.testOptions,
    required this.correctAnswer,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.themeColor,
  });

  factory FruitGroupsState.initial() {
    final random = Random();
    final item = fruitGroupsPalette[random.nextInt(fruitGroupsPalette.length)];

    // Generate Baskets: 2 to 4
    final multiplier = random.nextInt(3) + 2; // 2 to 4
    // Generate Items per Basket: 3 to 9 (random for each)
    final basketCounts = List.generate(multiplier, (_) => random.nextInt(7) + 3);
    final total = basketCounts.fold(0, (sum, count) => sum + count);
    final options = _generateOptions(total, random);

    final themeColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    return FruitGroupsState(
      currentItem: item,
      basketCounts: basketCounts,
      testOptions: options.options,
      correctAnswer: total,
      phase: FruitGroupsGamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  FruitGroupsState copyWith({
    FruitGroupsItem? currentItem,
    List<int>? basketCounts,
    List<int>? testOptions,
    int? correctAnswer,
    FruitGroupsGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
  }) {
    return FruitGroupsState(
      currentItem: currentItem ?? this.currentItem,
      basketCounts: basketCounts ?? this.basketCounts,
      testOptions: testOptions ?? this.testOptions,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}

/// Helper class for option generation
class _OptionsResult {
  final List<int> options;
  final int correctIndex;

  _OptionsResult({required this.options, required this.correctIndex});
}

/// Generate answer options with one correct and two-three distractors
_OptionsResult _generateOptions(int correctTotal, Random random) {
  Set<int> wrongOptions = {};

  while (wrongOptions.length < 2) {
    // Generate wrong answers close to the correct one
    int offset = random.nextInt(5) + 1; // 1 to 5
    int val = random.nextBool() ? correctTotal + offset : correctTotal - offset;

    // Keep values reasonable and avoid duplicates
    if (val >= 6 && val <= 60 && val != correctTotal) {
      wrongOptions.add(val);
    }
  }

  final options = [correctTotal, ...wrongOptions]..shuffle(random);
  final correctIndex = options.indexOf(correctTotal);

  return _OptionsResult(options: options, correctIndex: correctIndex);
}

/// Riverpod Notifier for Fruit Groups game state
class FruitGroupsNotifier extends Notifier<FruitGroupsState> {
  final Random _random = Random();

  @override
  FruitGroupsState build() {
    return FruitGroupsState.initial();
  }

  /// Transition from learning to testing phase
  void goToTest() {
    state = state.copyWith(phase: FruitGroupsGamePhase.testing);
  }

  /// Check if the selected answer is correct
  void checkAnswer(int selectedValue) {
    if (selectedValue == state.correctAnswer) {
      state = state.copyWith(phase: FruitGroupsGamePhase.success, score: state.score + 1);
    }
  }

  /// Move to the next round or restart the game
  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Restart game after all rounds complete
      state = FruitGroupsState.initial();
    } else {
      // Generate next round
      final newItem = fruitGroupsPalette[_random.nextInt(fruitGroupsPalette.length)];
      final newMultiplier = _random.nextInt(3) + 2; // 2 to 4
      final newBasketCounts = List.generate(newMultiplier, (_) => _random.nextInt(7) + 3);
      final newTotal = newBasketCounts.fold(0, (sum, count) => sum + count);
      final options = _generateOptions(newTotal, _random);

      final themeColors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.pink,
        Colors.teal,
        Colors.amber,
      ];

      state = state.copyWith(
        currentItem: newItem,
        basketCounts: newBasketCounts,
        testOptions: options.options,
        correctAnswer: newTotal,
        phase: FruitGroupsGamePhase.learning,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

/// Provider for Fruit Groups game state
final fruitGroupsProvider = NotifierProvider<FruitGroupsNotifier, FruitGroupsState>(() {
  return FruitGroupsNotifier();
}, isAutoDispose: true);

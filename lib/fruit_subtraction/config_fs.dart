import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a fruit item for subtraction
class SubtractionItem {
  final String emoji;
  final String name;

  const SubtractionItem({required this.emoji, required this.name});
}

/// Palette of fruits for the subtraction game
const List<SubtractionItem> subtractionPalette = [
  SubtractionItem(emoji: '🍎', name: 'apples'),
  SubtractionItem(emoji: '🍊', name: 'oranges'),
  SubtractionItem(emoji: '🍌', name: 'bananas'),
  SubtractionItem(emoji: '🍇', name: 'grapes'),
  SubtractionItem(emoji: '🍓', name: 'strawberries'),
  SubtractionItem(emoji: '🍒', name: 'cherries'),
  SubtractionItem(emoji: '🥭', name: 'mangoes'),
  SubtractionItem(emoji: '🍑', name: 'peaches'),
  SubtractionItem(emoji: '🍐', name: 'pears'),
  SubtractionItem(emoji: '🫐', name: 'blueberries'),
];

/// Game phases for Fruit Subtraction
enum SubtractionGamePhase { learningCount, learningSubtract, testing, success }

/// State for the Fruit Subtraction game
class SubtractionState {
  final SubtractionItem currentItem;
  final int totalCount;
  final int takenCount;
  final int remainingCount;
  final List<int> testOptions;
  final SubtractionGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;

  const SubtractionState({
    required this.currentItem,
    required this.totalCount,
    required this.takenCount,
    required this.remainingCount,
    required this.testOptions,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.themeColor,
  });

  factory SubtractionState.initial() {
    final random = Random();
    final item = subtractionPalette[random.nextInt(subtractionPalette.length)];

    // Generate total count: 5 to 10
    final total = random.nextInt(6) + 5;
    // Generate taken count: 1 to total - 2
    final taken = random.nextInt(total - 3) + 1;
    final remaining = total - taken;
    final options = _generateOptions(remaining, random);

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

    return SubtractionState(
      currentItem: item,
      totalCount: total,
      takenCount: taken,
      remainingCount: remaining,
      testOptions: options.options,
      phase: SubtractionGamePhase.learningCount,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  SubtractionState copyWith({
    SubtractionItem? currentItem,
    int? totalCount,
    int? takenCount,
    int? remainingCount,
    List<int>? testOptions,
    SubtractionGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
  }) {
    return SubtractionState(
      currentItem: currentItem ?? this.currentItem,
      totalCount: totalCount ?? this.totalCount,
      takenCount: takenCount ?? this.takenCount,
      remainingCount: remainingCount ?? this.remainingCount,
      testOptions: testOptions ?? this.testOptions,
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

/// Generate answer options with one correct and two distractors
_OptionsResult _generateOptions(int correctRemaining, Random random) {
  Set<int> wrongOptions = {};

  while (wrongOptions.length < 2) {
    // Generate wrong answers close to the correct one for challenge
    int offset = random.nextInt(3) + 1; // 1 to 3
    int val = random.nextBool() ? correctRemaining + offset : correctRemaining - offset;

    // Keep values reasonable and not negative
    if (val >= 0 && val <= 10 && val != correctRemaining) {
      wrongOptions.add(val);
    }
  }

  final options = [correctRemaining, ...wrongOptions]..shuffle(random);
  final correctIndex = options.indexOf(correctRemaining);

  return _OptionsResult(options: options, correctIndex: correctIndex);
}

/// Riverpod Notifier for Fruit Subtraction game state
class SubtractionNotifier extends Notifier<SubtractionState> {
  final Random _random = Random();

  @override
  SubtractionState build() {
    return SubtractionState.initial();
  }

  /// Transition to the next learning phase or testing phase
  void goToNextPhase() {
    if (state.phase == SubtractionGamePhase.learningCount) {
      state = state.copyWith(phase: SubtractionGamePhase.learningSubtract);
    } else if (state.phase == SubtractionGamePhase.learningSubtract) {
      state = state.copyWith(phase: SubtractionGamePhase.testing);
    }
  }

  /// Check if the selected answer is correct
  void checkAnswer(int selectedValue) {
    if (selectedValue == state.remainingCount) {
      state = state.copyWith(phase: SubtractionGamePhase.success, score: state.score + 1);
    }
  }

  /// Move to the next round or restart the game
  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Restart game after all rounds complete
      state = SubtractionState.initial();
    } else {
      // Generate next round
      final newItem = subtractionPalette[_random.nextInt(subtractionPalette.length)];
      final newTotal = _random.nextInt(6) + 5;
      final newTaken = _random.nextInt(newTotal - 3) + 1;
      final newRemaining = newTotal - newTaken;
      final options = _generateOptions(newRemaining, _random);

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
        totalCount: newTotal,
        takenCount: newTaken,
        remainingCount: newRemaining,
        testOptions: options.options,
        phase: SubtractionGamePhase.learningCount,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

/// Provider for Fruit Subtraction game state
final subtractionProvider = NotifierProvider<SubtractionNotifier, SubtractionState>(() {
  return SubtractionNotifier();
}, isAutoDispose: true);

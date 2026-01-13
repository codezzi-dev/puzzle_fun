import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a fruit item for addition
class AdditionItem {
  final String emoji;
  final String name;

  const AdditionItem({required this.emoji, required this.name});
}

/// Palette of fruits for the addition game
const List<AdditionItem> additionPalette = [
  AdditionItem(emoji: '🍎', name: 'apples'),
  AdditionItem(emoji: '🍊', name: 'oranges'),
  AdditionItem(emoji: '🍌', name: 'bananas'),
  AdditionItem(emoji: '🍇', name: 'grapes'),
  AdditionItem(emoji: '🍓', name: 'strawberries'),
  AdditionItem(emoji: '🍒', name: 'cherries'),
  AdditionItem(emoji: '🥭', name: 'mangoes'),
  AdditionItem(emoji: '🍑', name: 'peaches'),
  AdditionItem(emoji: '🍐', name: 'pears'),
  AdditionItem(emoji: '🫐', name: 'blueberries'),
];

/// Game phases for Apple Addition
enum AdditionGamePhase { learning, testing, success }

/// State for the Apple Addition game
class AdditionState {
  final AdditionItem currentItem;
  final int leftCount;
  final int rightCount;
  final List<int> testOptions;
  final int correctAnswer;
  final AdditionGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;

  const AdditionState({
    required this.currentItem,
    required this.leftCount,
    required this.rightCount,
    required this.testOptions,
    required this.correctAnswer,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.themeColor,
  });

  factory AdditionState.initial() {
    final random = Random();
    final item = additionPalette[random.nextInt(additionPalette.length)];

    // Generate counts: 3-5 for each basket (minimum 3 items)
    final left = random.nextInt(3) + 3; // 3 to 5
    final right = random.nextInt(3) + 3; // 3 to 5
    final sum = left + right;
    final options = _generateOptions(sum, random);

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

    return AdditionState(
      currentItem: item,
      leftCount: left,
      rightCount: right,
      testOptions: options.options,
      correctAnswer: sum,
      phase: AdditionGamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  AdditionState copyWith({
    AdditionItem? currentItem,
    int? leftCount,
    int? rightCount,
    List<int>? testOptions,
    int? correctAnswer,
    AdditionGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
  }) {
    return AdditionState(
      currentItem: currentItem ?? this.currentItem,
      leftCount: leftCount ?? this.leftCount,
      rightCount: rightCount ?? this.rightCount,
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

/// Generate answer options with one correct and two distractors
_OptionsResult _generateOptions(int correctSum, Random random) {
  Set<int> wrongOptions = {};

  while (wrongOptions.length < 2) {
    // Generate wrong answers close to the correct one for challenge
    int offset = random.nextInt(4) + 1; // 1 to 4
    int val = random.nextBool() ? correctSum + offset : correctSum - offset;

    // Keep values reasonable (2 to 10 range)
    if (val >= 2 && val <= 10 && val != correctSum) {
      wrongOptions.add(val);
    }
  }

  final options = [correctSum, ...wrongOptions]..shuffle(random);
  final correctIndex = options.indexOf(correctSum);

  return _OptionsResult(options: options, correctIndex: correctIndex);
}

/// Riverpod Notifier for Apple Addition game state
class AdditionNotifier extends Notifier<AdditionState> {
  final Random _random = Random();

  @override
  AdditionState build() {
    return AdditionState.initial();
  }

  /// Transition from learning to testing phase
  void goToTest() {
    state = state.copyWith(phase: AdditionGamePhase.testing);
  }

  /// Check if the selected answer is correct
  void checkAnswer(int selectedValue) {
    if (selectedValue == state.correctAnswer) {
      state = state.copyWith(phase: AdditionGamePhase.success, score: state.score + 1);
    }
  }

  /// Move to the next round or restart the game
  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Restart game after all rounds complete
      state = AdditionState.initial();
    } else {
      // Generate next round
      final newItem = additionPalette[_random.nextInt(additionPalette.length)];
      final newLeft = _random.nextInt(3) + 3; // 3 to 5
      final newRight = _random.nextInt(3) + 3; // 3 to 5
      final newSum = newLeft + newRight;
      final options = _generateOptions(newSum, _random);

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
        leftCount: newLeft,
        rightCount: newRight,
        testOptions: options.options,
        correctAnswer: newSum,
        phase: AdditionGamePhase.learning,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

/// Provider for Apple Addition game state
final additionProvider = NotifierProvider<AdditionNotifier, AdditionState>(() {
  return AdditionNotifier();
}, isAutoDispose: true);

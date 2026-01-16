import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a fruit item for multi-subtract
class FruitMultiSubtractItem {
  final String emoji;
  final String name;

  const FruitMultiSubtractItem({required this.emoji, required this.name});
}

/// Palette of fruits for the Fruit Multi-Subtract game
const List<FruitMultiSubtractItem> fmsPalette = [
  FruitMultiSubtractItem(emoji: '🍎', name: 'apples'),
  FruitMultiSubtractItem(emoji: '🍊', name: 'oranges'),
  FruitMultiSubtractItem(emoji: '🍌', name: 'bananas'),
  FruitMultiSubtractItem(emoji: '🍇', name: 'grapes'),
  FruitMultiSubtractItem(emoji: '🍓', name: 'strawberries'),
  FruitMultiSubtractItem(emoji: '🍒', name: 'cherries'),
  FruitMultiSubtractItem(emoji: '🥭', name: 'mangoes'),
  FruitMultiSubtractItem(emoji: '🍑', name: 'peaches'),
  FruitMultiSubtractItem(emoji: '🍐', name: 'pears'),
  FruitMultiSubtractItem(emoji: '🫐', name: 'blueberries'),
];

/// Game phases for Fruit Multi-Subtract
enum FmsGamePhase { learningGroups, learningSubtract, testing, success }

/// State for the Fruit Multi-Subtract game
class FmsState {
  final FruitMultiSubtractItem currentItem;
  final int multiplier; // Number of baskets
  final int itemsPerBasket; // Equal items in each
  final int totalCount; // multiplier * itemsPerBasket
  final int takenCount; // Amount to subtract
  final int remainingCount; // totalCount - takenCount
  final List<int> testOptions;
  final FmsGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;

  const FmsState({
    required this.currentItem,
    required this.multiplier,
    required this.itemsPerBasket,
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

  factory FmsState.initial() {
    final random = Random();
    final item = fmsPalette[random.nextInt(fmsPalette.length)];

    // Generate Baskets: 2 to 3 (keep it simple first)
    final multiplier = random.nextInt(2) + 2;
    // Generate Items per Basket: 3 to 5
    final itemsPerBasket = random.nextInt(3) + 3;
    final total = multiplier * itemsPerBasket;

    // Generate taken count: 1 to (total - 2)
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

    return FmsState(
      currentItem: item,
      multiplier: multiplier,
      itemsPerBasket: itemsPerBasket,
      totalCount: total,
      takenCount: taken,
      remainingCount: remaining,
      testOptions: options,
      phase: FmsGamePhase.learningGroups,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  FmsState copyWith({
    FruitMultiSubtractItem? currentItem,
    int? multiplier,
    int? itemsPerBasket,
    int? totalCount,
    int? takenCount,
    int? remainingCount,
    List<int>? testOptions,
    FmsGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
  }) {
    return FmsState(
      currentItem: currentItem ?? this.currentItem,
      multiplier: multiplier ?? this.multiplier,
      itemsPerBasket: itemsPerBasket ?? this.itemsPerBasket,
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

/// Generate answer options with one correct and two distractors
List<int> _generateOptions(int correctRemaining, Random random) {
  Set<int> wrongOptions = {};

  while (wrongOptions.length < 2) {
    int offset = random.nextInt(3) + 1; // 1 to 3
    int val = random.nextBool() ? correctRemaining + offset : correctRemaining - offset;

    if (val >= 0 && val <= 30 && val != correctRemaining) {
      wrongOptions.add(val);
    }
  }

  final options = [correctRemaining, ...wrongOptions]..shuffle(random);
  return options;
}

/// Riverpod Notifier for Fruit Multi-Subtract game state
class FmsNotifier extends Notifier<FmsState> {
  final Random _random = Random();

  @override
  FmsState build() {
    return FmsState.initial();
  }

  /// Transition to the next phase
  void nextPhase() {
    if (state.phase == FmsGamePhase.learningGroups) {
      state = state.copyWith(phase: FmsGamePhase.learningSubtract);
    } else if (state.phase == FmsGamePhase.learningSubtract) {
      state = state.copyWith(phase: FmsGamePhase.testing);
    }
  }

  /// Check if the selected answer is correct
  void checkAnswer(int selectedValue) {
    if (selectedValue == state.remainingCount) {
      state = state.copyWith(phase: FmsGamePhase.success, score: state.score + 1);
    }
  }

  /// Move to the next round or restart the game
  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = FmsState.initial();
    } else {
      final newItem = fmsPalette[_random.nextInt(fmsPalette.length)];
      final newMultiplier = _random.nextInt(2) + 2;
      final newItemsPerBasket = _random.nextInt(3) + 3;
      final newTotal = newMultiplier * newItemsPerBasket;
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
        multiplier: newMultiplier,
        itemsPerBasket: newItemsPerBasket,
        totalCount: newTotal,
        takenCount: newTaken,
        remainingCount: newRemaining,
        testOptions: options,
        phase: FmsGamePhase.learningGroups,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

/// Provider for Fruit Multi-Subtract game state
final fmsProvider = NotifierProvider<FmsNotifier, FmsState>(() {
  return FmsNotifier();
}, isAutoDispose: true);

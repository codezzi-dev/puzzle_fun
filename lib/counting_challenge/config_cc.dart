import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountingItem {
  final String emoji;
  final String name;

  const CountingItem({required this.emoji, required this.name});
}

const List<CountingItem> countingPalette = [
  CountingItem(emoji: '🍎', name: 'Apples'),
  CountingItem(emoji: '⭐', name: 'Stars'),
  CountingItem(emoji: '🏀', name: 'Balls'),
  CountingItem(emoji: '🍦', name: 'Ice Creams'),
  CountingItem(emoji: '🎈', name: 'Balloons'),
  CountingItem(emoji: '🚗', name: 'Cars'),
  CountingItem(emoji: '🐱', name: 'Cats'),
  CountingItem(emoji: '🌸', name: 'Flowers'),
  CountingItem(emoji: '🚀', name: 'Rockets'),
  CountingItem(emoji: '🎁', name: 'Gifts'),
];

enum CountingGamePhase { learning, testing, success }

class CountingState {
  final CountingItem currentItem;
  final int count;
  final List<int> testOptions;
  final int correctIndex;
  final CountingGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;

  const CountingState({
    required this.currentItem,
    required this.count,
    required this.testOptions,
    required this.correctIndex,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.themeColor,
  });

  factory CountingState.initial() {
    final random = Random();
    final item = countingPalette[random.nextInt(countingPalette.length)];
    final count = random.nextInt(9) + 1; // 1 to 9
    final options = _generateOptions(count, random);

    final themeColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    return CountingState(
      currentItem: item,
      count: count,
      testOptions: options.options,
      correctIndex: options.correctIndex,
      phase: CountingGamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  CountingState copyWith({
    CountingItem? currentItem,
    int? count,
    List<int>? testOptions,
    int? correctIndex,
    CountingGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
  }) {
    return CountingState(
      currentItem: currentItem ?? this.currentItem,
      count: count ?? this.count,
      testOptions: testOptions ?? this.testOptions,
      correctIndex: correctIndex ?? this.correctIndex,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}

class _OptionsResult {
  final List<int> options;
  final int correctIndex;

  _OptionsResult({required this.options, required this.correctIndex});
}

_OptionsResult _generateOptions(int correctCount, Random random) {
  Set<int> wrongOptions = {};
  while (wrongOptions.length < 2) {
    int val = random.nextInt(9) + 1;
    if (val != correctCount) {
      wrongOptions.add(val);
    }
  }

  final options = [correctCount, ...wrongOptions]..shuffle(random);
  final correctIndex = options.indexOf(correctCount);

  return _OptionsResult(options: options, correctIndex: correctIndex);
}

class CountingNotifier extends Notifier<CountingState> {
  final Random _random = Random();

  @override
  CountingState build() {
    return CountingState.initial();
  }

  void goToTest() {
    state = state.copyWith(phase: CountingGamePhase.testing);
  }

  void checkAnswer(int selectedValue) {
    if (selectedValue == state.count) {
      state = state.copyWith(phase: CountingGamePhase.success, score: state.score + 1);
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = CountingState.initial();
    } else {
      final newItem = countingPalette[_random.nextInt(countingPalette.length)];
      final newCount = _random.nextInt(9) + 1;
      final options = _generateOptions(newCount, _random);

      final themeColors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.pink,
        Colors.teal,
        Colors.amber,
      ];

      state = state.copyWith(
        currentItem: newItem,
        count: newCount,
        testOptions: options.options,
        correctIndex: options.correctIndex,
        phase: CountingGamePhase.learning,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

final countingProvider = NotifierProvider<CountingNotifier, CountingState>(() {
  return CountingNotifier();
}, isAutoDispose: true);

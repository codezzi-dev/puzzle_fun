import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a passenger item for the train
class PassengerItem {
  final String emoji;
  final String name;

  const PassengerItem({required this.emoji, required this.name});
}

/// Palette of passengers for the train addition game
const List<PassengerItem> passengerPalette = [
  PassengerItem(emoji: '🐶', name: 'puppies'),
  PassengerItem(emoji: '🐱', name: 'kittens'),
  PassengerItem(emoji: '🐰', name: 'bunnies'),
  PassengerItem(emoji: '🐼', name: 'pandas'),
  PassengerItem(emoji: '🦁', name: 'lions'),
  PassengerItem(emoji: '🐵', name: 'monkeys'),
  PassengerItem(emoji: '🐸', name: 'frogs'),
  PassengerItem(emoji: '🦊', name: 'foxes'),
  PassengerItem(emoji: '🐻', name: 'bears'),
  PassengerItem(emoji: '🐨', name: 'koalas'),
];

/// Game phases for Train Addition
enum TrainAdditionPhase {
  intro, // Train arrives empty
  boardingInitial, // Boarding the FIRST group of passengers
  boardingSecond, // Boarding the SECOND group of passengers
  testing, // Question phase: "How many now?"
  success, // Celebration phase
}

/// State for the Train Addition game
class TrainAdditionState {
  final List<PassengerItem> initialGroup;
  final List<PassengerItem> boardingGroup;
  final List<int> testOptions;
  final int correctAnswer;
  final TrainAdditionPhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;
  final int currentInitialTapped;
  final int currentBoardingTapped;

  const TrainAdditionState({
    required this.initialGroup,
    required this.boardingGroup,
    required this.testOptions,
    required this.correctAnswer,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.themeColor,
    required this.currentInitialTapped,
    required this.currentBoardingTapped,
  });

  factory TrainAdditionState.initial() {
    final random = Random();

    // Generate counts: 1-4 for initial, 1-4 for boarding
    final initialCount = random.nextInt(3) + 2; // 2-4
    final boardingCount = random.nextInt(3) + 2; // 2-4

    // Pick unique-ish passengers for each group
    List<PassengerItem> shuffled = List.from(passengerPalette)..shuffle(random);
    final initialGroup = shuffled.take(initialCount).toList();
    final boardingGroup = shuffled.skip(initialCount).take(boardingCount).toList();

    final sum = initialCount + boardingCount;
    final options = _generateOptions(sum, random);

    final themeColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.deepOrange,
    ];

    return TrainAdditionState(
      initialGroup: initialGroup,
      boardingGroup: boardingGroup,
      testOptions: options,
      correctAnswer: sum,
      phase: TrainAdditionPhase.intro,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
      currentInitialTapped: 0,
      currentBoardingTapped: 0,
    );
  }

  TrainAdditionState copyWith({
    List<PassengerItem>? initialGroup,
    List<PassengerItem>? boardingGroup,
    List<int>? testOptions,
    int? correctAnswer,
    TrainAdditionPhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
    int? currentInitialTapped,
    int? currentBoardingTapped,
  }) {
    return TrainAdditionState(
      initialGroup: initialGroup ?? this.initialGroup,
      boardingGroup: boardingGroup ?? this.boardingGroup,
      testOptions: testOptions ?? this.testOptions,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      themeColor: themeColor ?? this.themeColor,
      currentInitialTapped: currentInitialTapped ?? this.currentInitialTapped,
      currentBoardingTapped: currentBoardingTapped ?? this.currentBoardingTapped,
    );
  }
}

/// Generate answer options
List<int> _generateOptions(int correctSum, Random random) {
  Set<int> options = {correctSum};
  while (options.length < 3) {
    int offset = random.nextInt(3) + 1;
    int val = random.nextBool() ? correctSum + offset : correctSum - offset;
    if (val > 0 && val <= 10 && val != correctSum) {
      options.add(val);
    }
  }
  return options.toList()..shuffle(random);
}

/// Notifier for Train Addition game state
class TrainAdditionNotifier extends Notifier<TrainAdditionState> {
  final Random _random = Random();

  @override
  TrainAdditionState build() {
    return TrainAdditionState.initial();
  }

  void startInitialPhase() {
    state = state.copyWith(phase: TrainAdditionPhase.boardingInitial);
  }

  void incrementInitialTapped() {
    if (state.currentInitialTapped < state.initialGroup.length) {
      state = state.copyWith(currentInitialTapped: state.currentInitialTapped + 1);
    }
  }

  void startSecondBoardingPhase() {
    state = state.copyWith(phase: TrainAdditionPhase.boardingSecond);
  }

  void incrementBoardingTapped() {
    if (state.currentBoardingTapped < state.boardingGroup.length) {
      state = state.copyWith(currentBoardingTapped: state.currentBoardingTapped + 1);
    }
  }

  void goToTest() {
    state = state.copyWith(phase: TrainAdditionPhase.testing);
  }

  void checkAnswer(int selectedValue) {
    if (selectedValue == state.correctAnswer) {
      state = state.copyWith(phase: TrainAdditionPhase.success, score: state.score + 1);
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = TrainAdditionState.initial();
    } else {
      final initialCount = _random.nextInt(3) + 2; // 2-4
      final boardingCount = _random.nextInt(3) + 2; // 2-4

      List<PassengerItem> shuffled = List.from(passengerPalette)..shuffle(_random);
      final initialGroup = shuffled.take(initialCount).toList();
      final boardingGroup = shuffled.skip(initialCount).take(boardingCount).toList();

      final sum = initialCount + boardingCount;
      final options = _generateOptions(sum, _random);

      final themeColors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
        Colors.indigo,
        Colors.deepOrange,
      ];

      state = state.copyWith(
        initialGroup: initialGroup,
        boardingGroup: boardingGroup,
        testOptions: options,
        correctAnswer: sum,
        phase: TrainAdditionPhase.intro,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
        currentInitialTapped: 0,
        currentBoardingTapped: 0,
      );
    }
  }
}

/// Provider
final trainAdditionProvider = NotifierProvider<TrainAdditionNotifier, TrainAdditionState>(() {
  return TrainAdditionNotifier();
}, isAutoDispose: true);

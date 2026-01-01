import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MemoryPhase { learning, testing, success, failure }

class MissingMysteryState {
  final List<String> sequence; // 5 characters
  final int hiddenIndex; // Index of character to hide (0-4)
  final List<String> options; // Correct answer + 3 distractors
  final MemoryPhase phase;
  final int score;
  final int currentRound;
  final int totalRounds;

  const MissingMysteryState({
    required this.sequence,
    required this.hiddenIndex,
    required this.options,
    required this.phase,
    required this.score,
    required this.currentRound,
    this.totalRounds = 10,
  });

  factory MissingMysteryState.initial() {
    return _generateNewChallenge(0, 1);
  }

  MissingMysteryState copyWith({
    List<String>? sequence,
    int? hiddenIndex,
    List<String>? options,
    MemoryPhase? phase,
    int? score,
    int? currentRound,
  }) {
    return MissingMysteryState(
      sequence: sequence ?? this.sequence,
      hiddenIndex: hiddenIndex ?? this.hiddenIndex,
      options: options ?? this.options,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
    );
  }

  static MissingMysteryState _generateNewChallenge(int currentScore, int currentRound) {
    final random = Random();
    final letters = List.generate(26, (i) => String.fromCharCode(65 + i));
    final numbers = List.generate(10, (i) => i.toString());
    final allPool = [...letters, ...numbers];

    // Pick 5 unique random items
    final sequence = <String>[];
    while (sequence.length < 5) {
      final item = allPool[random.nextInt(allPool.length)];
      if (!sequence.contains(item)) {
        sequence.add(item);
      }
    }

    final hiddenIndex = random.nextInt(5);
    final correctAnswer = sequence[hiddenIndex];

    // Generate 4 options (correct one + 3 others not in the sequence)
    final options = <String>[correctAnswer];
    while (options.length < 4) {
      final item = allPool[random.nextInt(allPool.length)];
      if (!sequence.contains(item) && !options.contains(item)) {
        options.add(item);
      }
    }
    options.shuffle();

    return MissingMysteryState(
      sequence: sequence,
      hiddenIndex: hiddenIndex,
      options: options,
      phase: MemoryPhase.learning,
      score: currentScore,
      currentRound: currentRound,
    );
  }
}

class MissingMysteryNotifier extends Notifier<MissingMysteryState> {
  @override
  MissingMysteryState build() => MissingMysteryState.initial();

  void startTesting() {
    if (state.phase == MemoryPhase.learning) {
      state = state.copyWith(phase: MemoryPhase.testing);
    }
  }

  void goToTest() {
    startTesting();
  }

  void checkAnswer(String choice) {
    if (state.phase != MemoryPhase.testing) return;

    final correctAnswer = state.sequence[state.hiddenIndex];
    if (choice == correctAnswer) {
      state = state.copyWith(phase: MemoryPhase.success, score: state.score + 1);
    } else {
      state = state.copyWith(phase: MemoryPhase.failure);
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      resetGame();
    } else {
      state = MissingMysteryState._generateNewChallenge(state.score, state.currentRound + 1);
    }
  }

  void retry() {
    state = state.copyWith(phase: MemoryPhase.learning);
  }

  void resetGame() {
    state = MissingMysteryState.initial();
  }
}

final missingMysteryProvider = NotifierProvider<MissingMysteryNotifier, MissingMysteryState>(() {
  return MissingMysteryNotifier();
}, isAutoDispose: true);

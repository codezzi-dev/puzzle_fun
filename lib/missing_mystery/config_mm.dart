import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GamePhase { learning, testing, success, failure }

class MissingMysteryState {
  final List<String> sequence; // 4 characters
  final int hiddenIndex; // Index of character to hide (0-3)
  final List<String> options; // Correct answer + 3 distractors
  final GamePhase phase;
  final int score;
  final int currentRound;
  final int totalRounds;
  final String motivationalMessage;

  const MissingMysteryState({
    required this.sequence,
    required this.hiddenIndex,
    required this.options,
    required this.phase,
    required this.score,
    required this.currentRound,
    required this.motivationalMessage,
    this.totalRounds = 5,
  });

  factory MissingMysteryState.initial() {
    return _generateNewChallenge(0, 1);
  }

  MissingMysteryState copyWith({
    List<String>? sequence,
    int? hiddenIndex,
    List<String>? options,
    GamePhase? phase,
    int? score,
    int? currentRound,
    String? motivationalMessage,
  }) {
    return MissingMysteryState(
      sequence: sequence ?? this.sequence,
      hiddenIndex: hiddenIndex ?? this.hiddenIndex,
      options: options ?? this.options,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      currentRound: currentRound ?? this.currentRound,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
      totalRounds: totalRounds,
    );
  }

  static MissingMysteryState _generateNewChallenge(int currentScore, int currentRound) {
    final random = Random();
    final letters = List.generate(26, (i) => String.fromCharCode(65 + i));
    final numbers = List.generate(10, (i) => i.toString());

    // Randomly decide which pool to use for this round
    final isLetterRound = random.nextBool();
    final pool = isLetterRound ? letters : numbers;

    // Pick 4 unique random items from the chosen pool
    final sequence = <String>[];
    while (sequence.length < 4) {
      final item = pool[random.nextInt(pool.length)];
      if (!sequence.contains(item)) {
        sequence.add(item);
      }
    }

    final hiddenIndex = random.nextInt(4);
    final correctAnswer = sequence[hiddenIndex];

    // Generate 4 options from the same pool (correct one + 3 distractors not in the sequence)
    final options = <String>[correctAnswer];
    while (options.length < 4) {
      final item = pool[random.nextInt(pool.length)];
      if (!sequence.contains(item) && !options.contains(item)) {
        options.add(item);
      }
    }
    options.shuffle();

    return MissingMysteryState(
      sequence: sequence,
      hiddenIndex: hiddenIndex,
      options: options,
      phase: GamePhase.learning,
      score: currentScore,
      currentRound: currentRound,
      motivationalMessage: '',
    );
  }
}

const List<String> motivationalMessages = [
  "Almost there! Try again!",
  "You can do it!",
  "Keep trying, superstar!",
  "So close! One more try!",
  "You're doing great!",
  "Don't give up!",
];

class MissingMysteryNotifier extends Notifier<MissingMysteryState> {
  final Random _random = Random();

  @override
  MissingMysteryState build() => MissingMysteryState.initial();

  void goToTest() {
    if (state.phase == GamePhase.learning) {
      state = state.copyWith(phase: GamePhase.testing);
    }
  }

  void checkAnswer(String choice) {
    if (state.phase != GamePhase.testing) return;

    final correctAnswer = state.sequence[state.hiddenIndex];
    if (choice == correctAnswer) {
      state = state.copyWith(phase: GamePhase.success, score: state.score + 1);
    } else {
      final message = motivationalMessages[_random.nextInt(motivationalMessages.length)];
      state = state.copyWith(motivationalMessage: message);
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
    state = state.copyWith(phase: GamePhase.testing, motivationalMessage: '');
  }

  void resetGame() {
    state = MissingMysteryState.initial();
  }
}

final missingMysteryProvider = NotifierProvider<MissingMysteryNotifier, MissingMysteryState>(() {
  return MissingMysteryNotifier();
}, isAutoDispose: true);

import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GamePhase { playing, success, complete }

class PatternItem {
  final String id;
  final String name;
  final String emoji;

  const PatternItem({required this.id, required this.name, required this.emoji});
}

class PatternMakerState {
  final GamePhase phase;
  final List<PatternItem?> sequence;
  final List<PatternItem> options;
  final PatternItem correctItem;
  final int missingIndex;
  final int currentRound;
  final int totalRounds;
  final int score;
  final String message;

  const PatternMakerState({
    required this.phase,
    required this.sequence,
    required this.options,
    required this.correctItem,
    required this.missingIndex,
    required this.currentRound,
    this.totalRounds = 5,
    required this.score,
    this.message = '',
  });

  PatternMakerState copyWith({
    GamePhase? phase,
    List<PatternItem?>? sequence,
    List<PatternItem>? options,
    PatternItem? correctItem,
    int? missingIndex,
    int? currentRound,
    int? score,
    String? message,
  }) {
    return PatternMakerState(
      phase: phase ?? this.phase,
      sequence: sequence ?? this.sequence,
      options: options ?? this.options,
      correctItem: correctItem ?? this.correctItem,
      missingIndex: missingIndex ?? this.missingIndex,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      score: score ?? this.score,
      message: message ?? this.message,
    );
  }
}

final allPatternItems = [
  const PatternItem(id: 'apple', name: 'Apple', emoji: '🍎'),
  const PatternItem(id: 'banana', name: 'Banana', emoji: '🍌'),
  const PatternItem(id: 'orange', name: 'Orange', emoji: '🍊'),
  const PatternItem(id: 'strawberry', name: 'Strawberry', emoji: '🍓'),
  const PatternItem(id: 'grapes', name: 'Grapes', emoji: '🍇'),
  const PatternItem(id: 'watermelon', name: 'Watermelon', emoji: '🍉'),
  const PatternItem(id: 'cherries', name: 'Cherries', emoji: '🍒'),
  const PatternItem(id: 'pineapple', name: 'Pineapple', emoji: '🍍'),
  const PatternItem(id: 'star', name: 'Star', emoji: '⭐'),
  const PatternItem(id: 'heart', name: 'Heart', emoji: '❤️'),
  const PatternItem(id: 'sun', name: 'Sun', emoji: '☀️'),
  const PatternItem(id: 'moon', name: 'Moon', emoji: '🌙'),
];

class PatternMakerNotifier extends Notifier<PatternMakerState> {
  final _random = math.Random();

  @override
  PatternMakerState build() {
    return _generateRound(1, 0);
  }

  PatternMakerState _generateRound(int round, int currentScore) {
    final shuffledItems = List<PatternItem>.from(allPatternItems)..shuffle(_random);

    // Pattern types: 0: ABAB, 1: ABCABC, 2: AABAAB
    int patternType = (round - 1) % 3;
    if (round > 3) patternType = _random.nextInt(3);

    List<PatternItem> base = [];
    int seqLength = 6;

    if (patternType == 0) {
      // ABAB
      base = [shuffledItems[0], shuffledItems[1]];
    } else if (patternType == 1) {
      // ABCABC
      base = [shuffledItems[0], shuffledItems[1], shuffledItems[2]];
    } else {
      // AABAAB
      base = [shuffledItems[0], shuffledItems[0], shuffledItems[1]];
    }

    List<PatternItem> fullSequence = [];
    while (fullSequence.length < seqLength) {
      fullSequence.add(base[fullSequence.length % base.length]);
    }

    // Set one index to missing (usually the last or second to last for preschoolers)
    int missingIdx = seqLength - 1;
    final correctItem = fullSequence[missingIdx];

    List<PatternItem?> sequenceWithGap = List<PatternItem?>.from(fullSequence);
    sequenceWithGap[missingIdx] = null;

    // Generate options (correct one + 3 random ones)
    List<PatternItem> options = [correctItem];
    while (options.length < 4) {
      final randItem = allPatternItems[_random.nextInt(allPatternItems.length)];
      if (!options.any((i) => i.id == randItem.id)) {
        options.add(randItem);
      }
    }
    options.shuffle(_random);

    return PatternMakerState(
      phase: GamePhase.playing,
      sequence: sequenceWithGap,
      options: options,
      correctItem: correctItem,
      missingIndex: missingIdx,
      currentRound: round,
      score: currentScore,
      message: _getInstruction(patternType),
    );
  }

  String _getInstruction(int type) {
    if (type == 0) return "What comes next in the pattern?";
    if (type == 1) return "Can you complete this pattern?";
    return "Finish the sequence!";
  }

  void checkGuess(PatternItem item) {
    if (state.phase != GamePhase.playing) return;

    if (item.id == state.correctItem.id) {
      final newSequence = List<PatternItem?>.from(state.sequence);
      newSequence[state.missingIndex] = item;

      state = state.copyWith(
        phase: GamePhase.success,
        sequence: newSequence,
        score: state.score + 1,
        message: "Great job! That fits perfectly!",
      );
    } else {
      state = state.copyWith(message: "Not quite, try again!");
    }
  }

  void nextRound() {
    state = _generateRound(state.currentRound + 1, state.score);
  }

  void completeGame() {
    state = state.copyWith(phase: GamePhase.complete);
  }

  void reset() {
    state = _generateRound(1, 0);
  }
}

final patternMakerProvider = NotifierProvider<PatternMakerNotifier, PatternMakerState>(() {
  return PatternMakerNotifier();
});

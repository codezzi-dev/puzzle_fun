import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MimicGamePhase { learning, testing, success, failure }

/// Represents a single piano key with its visual and audio properties
class PianoKey {
  final String label;
  final Color color;
  final Color glowColor;
  final int noteIndex; // 0-7 for tone generation

  const PianoKey({
    required this.label,
    required this.color,
    required this.glowColor,
    required this.noteIndex,
  });
}

/// 8 colorful piano keys (C major scale)
const List<PianoKey> pianoKeys = [
  PianoKey(label: 'C', color: Color(0xFFE53935), glowColor: Color(0xFFFF8A80), noteIndex: 0),
  PianoKey(label: 'D', color: Color(0xFFFF9800), glowColor: Color(0xFFFFCC80), noteIndex: 1),
  PianoKey(label: 'E', color: Color(0xFFFFEB3B), glowColor: Color(0xFFFFF59D), noteIndex: 2),
  PianoKey(label: 'F', color: Color(0xFF4CAF50), glowColor: Color(0xFFA5D6A7), noteIndex: 3),
  PianoKey(label: 'G', color: Color(0xFF2196F3), glowColor: Color(0xFF90CAF9), noteIndex: 4),
  PianoKey(label: 'A', color: Color(0xFF3F51B5), glowColor: Color(0xFF9FA8DA), noteIndex: 5),
  PianoKey(label: 'B', color: Color(0xFF9C27B0), glowColor: Color(0xFFCE93D8), noteIndex: 6),
  PianoKey(label: 'C\'', color: Color(0xFFE91E63), glowColor: Color(0xFFF48FB1), noteIndex: 7),
];

/// Game state for Musical Mimic
class MimicState {
  final List<int> sequence; // Key indices in the pattern
  final List<int> userInput; // User's tapped key indices
  final MimicGamePhase phase;
  final int score;
  final int currentRound;
  final int totalRounds;
  final Color themeColor;

  const MimicState({
    required this.sequence,
    required this.userInput,
    required this.phase,
    required this.score,
    required this.currentRound,
    required this.totalRounds,
    required this.themeColor,
  });

  factory MimicState.initial() {
    final random = Random();
    final themeColors = [Colors.pink, Colors.purple, Colors.deepPurple, Colors.indigo, Colors.blue];

    // Initial sequence of length 2
    final sequence = _generateSequence(2, random);

    return MimicState(
      sequence: sequence,
      userInput: [],
      phase: MimicGamePhase.learning,
      score: 0,
      currentRound: 1,
      totalRounds: 5,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  static List<int> _generateSequence(int length, Random random) {
    // Generate a sequence of key indices (0-7)
    return List.generate(length, (_) => random.nextInt(pianoKeys.length));
  }

  MimicState copyWith({
    List<int>? sequence,
    List<int>? userInput,
    MimicGamePhase? phase,
    int? score,
    int? currentRound,
    int? totalRounds,
    Color? themeColor,
  }) {
    return MimicState(
      sequence: sequence ?? this.sequence,
      userInput: userInput ?? this.userInput,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}

/// State notifier for Musical Mimic game logic
class MimicNotifier extends Notifier<MimicState> {
  final Random _random = Random();

  @override
  MimicState build() {
    return MimicState.initial();
  }

  /// Transition from learning to testing phase
  void startTesting() {
    state = state.copyWith(phase: MimicGamePhase.testing, userInput: []);
  }

  /// Check if the tapped key matches the expected key in sequence
  void checkKey(int keyIndex) {
    if (state.phase != MimicGamePhase.testing) return;

    final newUserInput = [...state.userInput, keyIndex];
    final currentIndex = state.userInput.length;

    if (keyIndex == state.sequence[currentIndex]) {
      // Correct so far
      if (newUserInput.length == state.sequence.length) {
        // Complete sequence correct!
        state = state.copyWith(
          userInput: newUserInput,
          phase: MimicGamePhase.success,
          score: state.score + 1,
        );
      } else {
        // More keys to go
        state = state.copyWith(userInput: newUserInput);
      }
    } else {
      // Wrong key
      state = state.copyWith(phase: MimicGamePhase.failure);
    }
  }

  /// Retry the current round (after failure)
  void retryRound() {
    state = state.copyWith(phase: MimicGamePhase.learning, userInput: []);
  }

  /// Move to the next round (after success)
  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Game complete, restart
      state = MimicState.initial();
    } else {
      final nextRound = state.currentRound + 1;
      // Sequence length increases: 2 -> 3 -> 3 -> 4 -> 5
      int seqLength = 2;
      if (nextRound == 2) seqLength = 3;
      if (nextRound == 3) seqLength = 3;
      if (nextRound == 4) seqLength = 4;
      if (nextRound == 5) seqLength = 5;

      final themeColors = [
        Colors.pink,
        Colors.purple,
        Colors.deepPurple,
        Colors.indigo,
        Colors.blue,
      ];

      state = state.copyWith(
        sequence: MimicState._generateSequence(seqLength, _random),
        userInput: [],
        phase: MimicGamePhase.learning,
        currentRound: nextRound,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

/// Riverpod provider for Musical Mimic game state
final mimicProvider = NotifierProvider<MimicNotifier, MimicState>(() {
  return MimicNotifier();
}, isAutoDispose: true);

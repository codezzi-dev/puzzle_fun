import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SafariGamePhase { learning, testing, success, failure }

class SafariAnimal {
  final String name;
  final String emoji;
  final Color color;

  const SafariAnimal({required this.name, required this.emoji, required this.color});
}

const List<SafariAnimal> safariAnimals = [
  SafariAnimal(name: 'Lion', emoji: '🦁', color: Colors.orange),
  SafariAnimal(name: 'Elephant', emoji: '🐘', color: Colors.blueGrey),
  SafariAnimal(name: 'Zebra', emoji: '🦓', color: Colors.black),
  SafariAnimal(name: 'Giraffe', emoji: '🦒', color: Colors.amber),
  SafariAnimal(name: 'Monkey', emoji: '🐒', color: Colors.brown),
  SafariAnimal(name: 'Tiger', emoji: '🐅', color: Colors.deepOrange),
  SafariAnimal(name: 'Hippo', emoji: '🦛', color: Colors.purple),
  SafariAnimal(name: 'Parrot', emoji: '🦜', color: Colors.green),
];

class SafariState {
  final List<SafariAnimal> sequence;
  final List<SafariAnimal> userInput;
  final SafariGamePhase phase;
  final int score;
  final int currentRound;
  final int totalRounds;
  final Color themeColor;

  const SafariState({
    required this.sequence,
    required this.userInput,
    required this.phase,
    required this.score,
    required this.currentRound,
    required this.totalRounds,
    required this.themeColor,
  });

  factory SafariState.initial() {
    final random = Random();
    final themeColors = [Colors.green, Colors.orange, Colors.brown, Colors.teal, Colors.amber];

    // Initial sequence of length 2
    final sequence = _generateSequence(2, random);

    return SafariState(
      sequence: sequence,
      userInput: [],
      phase: SafariGamePhase.learning,
      score: 0,
      currentRound: 1,
      totalRounds: 5,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  static List<SafariAnimal> _generateSequence(int length, Random random) {
    // Ensure unique animals by shuffling and taking the first N items
    final shuffled = [...safariAnimals]..shuffle(random);
    return shuffled.take(length).toList();
  }

  SafariState copyWith({
    List<SafariAnimal>? sequence,
    List<SafariAnimal>? userInput,
    SafariGamePhase? phase,
    int? score,
    int? currentRound,
    int? totalRounds,
    Color? themeColor,
  }) {
    return SafariState(
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

class SafariNotifier extends Notifier<SafariState> {
  final Random _random = Random();

  @override
  SafariState build() {
    return SafariState.initial();
  }

  void startTesting() {
    state = state.copyWith(phase: SafariGamePhase.testing, userInput: []);
  }

  void checkAnimal(SafariAnimal animal) {
    if (state.phase != SafariGamePhase.testing) return;

    final newUserInput = [...state.userInput, animal];
    final currentIndex = state.userInput.length;

    if (animal.name == state.sequence[currentIndex].name) {
      // Correct so far
      if (newUserInput.length == state.sequence.length) {
        // Complete sequence correct
        state = state.copyWith(
          userInput: newUserInput,
          phase: SafariGamePhase.success,
          score: state.score + 1,
        );
      } else {
        // More animals to go
        state = state.copyWith(userInput: newUserInput);
      }
    } else {
      // Wrong animal
      state = state.copyWith(phase: SafariGamePhase.failure);
    }
  }

  void retryRound() {
    state = state.copyWith(phase: SafariGamePhase.learning, userInput: []);
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = SafariState.initial();
    } else {
      final nextRound = state.currentRound + 1;
      // Sequence length increases: 2 -> 3 -> 3 -> 4 -> 5
      int seqLength = 2;
      if (nextRound == 2) seqLength = 3;
      if (nextRound == 3) seqLength = 3;
      if (nextRound == 4) seqLength = 4;
      if (nextRound == 5) seqLength = 5;

      final themeColors = [Colors.green, Colors.orange, Colors.brown, Colors.teal, Colors.amber];

      state = state.copyWith(
        sequence: SafariState._generateSequence(seqLength, _random),
        userInput: [],
        phase: SafariGamePhase.learning,
        currentRound: nextRound,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

final safariProvider = NotifierProvider<SafariNotifier, SafariState>(() {
  return SafariNotifier();
}, isAutoDispose: true);

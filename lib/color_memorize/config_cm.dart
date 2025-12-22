import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// List of colorful, child-friendly colors with names
class ColorItem {
  final String name;
  final Color color;
  final String emoji;

  const ColorItem({required this.name, required this.color, required this.emoji});
}

const List<ColorItem> colorPalette = [
  ColorItem(name: 'Red', color: Colors.red, emoji: '❤️'),
  ColorItem(name: 'Blue', color: Colors.blue, emoji: '💙'),
  ColorItem(name: 'Green', color: Colors.green, emoji: '💚'),
  ColorItem(name: 'Yellow', color: Colors.yellow, emoji: '💛'),
  ColorItem(name: 'Orange', color: Colors.orange, emoji: '🧡'),
  ColorItem(name: 'Purple', color: Colors.purple, emoji: '💜'),
  ColorItem(name: 'Pink', color: Colors.pink, emoji: '💗'),
  ColorItem(name: 'Teal', color: Colors.teal, emoji: '🩵'),
];

// Characters for the test phase
class CharacterItem {
  final String name;
  final String emoji;

  const CharacterItem({required this.name, required this.emoji});
}

const List<CharacterItem> characters = [
  CharacterItem(name: 'Car', emoji: '🚗'),
  CharacterItem(name: 'Bus', emoji: '🚌'),
  CharacterItem(name: 'Star', emoji: '⭐'),
  CharacterItem(name: 'Balloon', emoji: '🎈'),
  CharacterItem(name: 'Butterfly', emoji: '🦋'),
  CharacterItem(name: 'Cat', emoji: '🐱'),
  CharacterItem(name: 'Bird', emoji: '🐦'),
  CharacterItem(name: 'Flower', emoji: '🌸'),
];

enum GamePhase { learning, testing, success, failure }

class ColorMemorizeState {
  final ColorItem currentColor;
  final CharacterItem currentCharacter;
  final List<ColorItem> testOptions; // 3 options, one correct
  final int correctIndex;
  final GamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final String motivationalMessage;

  const ColorMemorizeState({
    required this.currentColor,
    required this.currentCharacter,
    required this.testOptions,
    required this.correctIndex,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.motivationalMessage,
  });

  factory ColorMemorizeState.initial() {
    final random = Random();
    final color = colorPalette[random.nextInt(colorPalette.length)];
    final character = characters[random.nextInt(characters.length)];
    final options = _generateOptions(color, random);

    return ColorMemorizeState(
      currentColor: color,
      currentCharacter: character,
      testOptions: options.options,
      correctIndex: options.correctIndex,
      phase: GamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      motivationalMessage: '',
    );
  }

  ColorMemorizeState copyWith({
    ColorItem? currentColor,
    CharacterItem? currentCharacter,
    List<ColorItem>? testOptions,
    int? correctIndex,
    GamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    String? motivationalMessage,
  }) {
    return ColorMemorizeState(
      currentColor: currentColor ?? this.currentColor,
      currentCharacter: currentCharacter ?? this.currentCharacter,
      testOptions: testOptions ?? this.testOptions,
      correctIndex: correctIndex ?? this.correctIndex,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
    );
  }
}

class _OptionsResult {
  final List<ColorItem> options;
  final int correctIndex;

  _OptionsResult({required this.options, required this.correctIndex});
}

_OptionsResult _generateOptions(ColorItem correctColor, Random random) {
  // Get 2 random wrong colors for 3 total options
  final wrongColors = colorPalette.where((c) => c.name != correctColor.name).toList()
    ..shuffle(random);

  final options = [correctColor, wrongColors[0], wrongColors[1]]..shuffle(random);

  final correctIndex = options.indexWhere((c) => c.name == correctColor.name);

  return _OptionsResult(options: options, correctIndex: correctIndex);
}

// Motivational messages for failure
const List<String> motivationalMessages = [
  "Almost there! Try again! 💪",
  "You can do it! 🌟",
  "Keep trying, superstar! ⭐",
  "So close! One more try! 🎯",
  "You're doing great! 🎨",
  "Don't give up! 🚀",
];

class ColorMemorizeNotifier extends Notifier<ColorMemorizeState> {
  final Random _random = Random();

  @override
  ColorMemorizeState build() {
    return ColorMemorizeState.initial();
  }

  void startNewGame() {
    state = ColorMemorizeState.initial();
  }

  void goToTest() {
    state = state.copyWith(phase: GamePhase.testing);
  }

  void checkAnswer(int selectedIndex) {
    if (selectedIndex == state.correctIndex) {
      // Correct answer!
      state = state.copyWith(phase: GamePhase.success, score: state.score + 1);
    } else {
      // Wrong answer
      final message = motivationalMessages[_random.nextInt(motivationalMessages.length)];
      state = state.copyWith(phase: GamePhase.failure, motivationalMessage: message);
    }
  }

  void retryQuestion() {
    // Stay on test phase - just dismiss the failure overlay
    state = state.copyWith(phase: GamePhase.testing);
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Game complete - restart
      state = ColorMemorizeState.initial();
    } else {
      // Generate new round
      final newColor = colorPalette[_random.nextInt(colorPalette.length)];
      final newCharacter = characters[_random.nextInt(characters.length)];
      final options = _generateOptions(newColor, _random);

      state = ColorMemorizeState(
        currentColor: newColor,
        currentCharacter: newCharacter,
        testOptions: options.options,
        correctIndex: options.correctIndex,
        phase: GamePhase.learning,
        score: state.score,
        totalRounds: state.totalRounds,
        currentRound: state.currentRound + 1,
        motivationalMessage: '',
      );
    }
  }
}

final colorMemorizeProvider = NotifierProvider<ColorMemorizeNotifier, ColorMemorizeState>(() {
  return ColorMemorizeNotifier();
}, isAutoDispose: true);

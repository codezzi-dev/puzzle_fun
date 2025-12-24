import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// List of digits with names
class DigitItem {
  final int value;
  final String name;
  final String emoji;

  const DigitItem({required this.value, required this.name, required this.emoji});
}

const List<DigitItem> digitPalette = [
  DigitItem(value: 0, name: 'Zero', emoji: '0️⃣'),
  DigitItem(value: 1, name: 'One', emoji: '1️⃣'),
  DigitItem(value: 2, name: 'Two', emoji: '2️⃣'),
  DigitItem(value: 3, name: 'Three', emoji: '3️⃣'),
  DigitItem(value: 4, name: 'Four', emoji: '4️⃣'),
  DigitItem(value: 5, name: 'Five', emoji: '5️⃣'),
  DigitItem(value: 6, name: 'Six', emoji: '6️⃣'),
  DigitItem(value: 7, name: 'Seven', emoji: '7️⃣'),
  DigitItem(value: 8, name: 'Eight', emoji: '8️⃣'),
  DigitItem(value: 9, name: 'Nine', emoji: '9️⃣'),
];

// Colors for visual display
class ColorOption {
  final String name;
  final Color color;

  const ColorOption({required this.name, required this.color});
}

const List<ColorOption> colorOptions = [
  ColorOption(name: 'Red', color: Colors.red),
  ColorOption(name: 'Blue', color: Colors.blue),
  ColorOption(name: 'Green', color: Colors.green),
  ColorOption(name: 'Orange', color: Colors.orange),
  ColorOption(name: 'Purple', color: Colors.purple),
  ColorOption(name: 'Pink', color: Colors.pink),
  ColorOption(name: 'Teal', color: Colors.teal),
  ColorOption(name: 'Amber', color: Colors.amber),
];

enum DigitGamePhase { learning, testing, success, failure }

class DigitMasterState {
  final DigitItem currentDigit;
  final ColorOption displayColor;
  final List<DigitItem> testOptions;
  final int correctIndex;
  final DigitGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final String motivationalMessage;

  const DigitMasterState({
    required this.currentDigit,
    required this.displayColor,
    required this.testOptions,
    required this.correctIndex,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.motivationalMessage,
  });

  factory DigitMasterState.initial() {
    final random = Random();
    final digit = digitPalette[random.nextInt(digitPalette.length)];
    final displayColor = colorOptions[random.nextInt(colorOptions.length)];
    final options = _generateOptions(digit, random);

    return DigitMasterState(
      currentDigit: digit,
      displayColor: displayColor,
      testOptions: options.options,
      correctIndex: options.correctIndex,
      phase: DigitGamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      motivationalMessage: '',
    );
  }

  DigitMasterState copyWith({
    DigitItem? currentDigit,
    ColorOption? displayColor,
    List<DigitItem>? testOptions,
    int? correctIndex,
    DigitGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    String? motivationalMessage,
  }) {
    return DigitMasterState(
      currentDigit: currentDigit ?? this.currentDigit,
      displayColor: displayColor ?? this.displayColor,
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
  final List<DigitItem> options;
  final int correctIndex;

  _OptionsResult({required this.options, required this.correctIndex});
}

_OptionsResult _generateOptions(DigitItem correctDigit, Random random) {
  final wrongDigits = digitPalette.where((d) => d.value != correctDigit.value).toList()
    ..shuffle(random);

  final options = [correctDigit, wrongDigits[0], wrongDigits[1]]..shuffle(random);
  final correctIndex = options.indexWhere((d) => d.value == correctDigit.value);

  return _OptionsResult(options: options, correctIndex: correctIndex);
}

const List<String> motivationalMessages = [
  "Almost there! Try again!",
  "You can do it!",
  "Keep trying, superstar!",
  "So close! One more try!",
  "You're doing great!",
  "Don't give up!",
];

class DigitMasterNotifier extends Notifier<DigitMasterState> {
  final Random _random = Random();

  @override
  DigitMasterState build() {
    return DigitMasterState.initial();
  }

  void startNewGame() {
    state = DigitMasterState.initial();
  }

  void goToTest() {
    state = state.copyWith(phase: DigitGamePhase.testing);
  }

  void checkAnswer(int selectedIndex) {
    if (selectedIndex == state.correctIndex) {
      state = state.copyWith(phase: DigitGamePhase.success, score: state.score + 1);
    } else {
      final message = motivationalMessages[_random.nextInt(motivationalMessages.length)];
      state = state.copyWith(phase: DigitGamePhase.failure, motivationalMessage: message);
    }
  }

  void retryQuestion() {
    state = state.copyWith(phase: DigitGamePhase.testing);
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = DigitMasterState.initial();
    } else {
      final newDigit = digitPalette[_random.nextInt(digitPalette.length)];
      final newDisplayColor = colorOptions[_random.nextInt(colorOptions.length)];
      final options = _generateOptions(newDigit, _random);

      state = DigitMasterState(
        currentDigit: newDigit,
        displayColor: newDisplayColor,
        testOptions: options.options,
        correctIndex: options.correctIndex,
        phase: DigitGamePhase.learning,
        score: state.score,
        totalRounds: state.totalRounds,
        currentRound: state.currentRound + 1,
        motivationalMessage: '',
      );
    }
  }
}

final digitMasterProvider = NotifierProvider<DigitMasterNotifier, DigitMasterState>(() {
  return DigitMasterNotifier();
}, isAutoDispose: true);

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BodyPartItem {
  final String name;
  final String emoji;

  const BodyPartItem({required this.name, required this.emoji});
}

const List<BodyPartItem> bodyPartsPalette = [
  BodyPartItem(name: 'Eye', emoji: '👁️'),
  BodyPartItem(name: 'Ear', emoji: '👂'),
  BodyPartItem(name: 'Nose', emoji: '👃'),
  BodyPartItem(name: 'Mouth', emoji: '👄'),
  BodyPartItem(name: 'Tongue', emoji: '👅'),
  BodyPartItem(name: 'Tooth', emoji: '🦷'),
  BodyPartItem(name: 'Arm', emoji: '💪'),
  BodyPartItem(name: 'Leg', emoji: '🦵'),
  BodyPartItem(name: 'Foot', emoji: '🦶'),
  BodyPartItem(name: 'Hand', emoji: '✋'),
  BodyPartItem(name: 'Brain', emoji: '🧠'),
  BodyPartItem(name: 'Heart', emoji: '❤️'),
  BodyPartItem(name: 'Lungs', emoji: '🫁'),
  BodyPartItem(name: 'Bone', emoji: '🦴'),
];

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
];

enum BodyPartsGamePhase { learning, testing, success, failure }

class BodyPartsState {
  final BodyPartItem currentBodyPart;
  final ColorOption displayColor;
  final List<BodyPartItem> testOptions;
  final int correctIndex;
  final BodyPartsGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final String motivationalMessage;

  const BodyPartsState({
    required this.currentBodyPart,
    required this.displayColor,
    required this.testOptions,
    required this.correctIndex,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.motivationalMessage,
  });

  factory BodyPartsState.initial() {
    final random = Random();
    final bodyPart = bodyPartsPalette[random.nextInt(bodyPartsPalette.length)];
    final displayColor = colorOptions[random.nextInt(colorOptions.length)];
    final options = _generateOptions(bodyPart, random);

    return BodyPartsState(
      currentBodyPart: bodyPart,
      displayColor: displayColor,
      testOptions: options.options,
      correctIndex: options.correctIndex,
      phase: BodyPartsGamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      motivationalMessage: '',
    );
  }

  BodyPartsState copyWith({
    BodyPartItem? currentBodyPart,
    ColorOption? displayColor,
    List<BodyPartItem>? testOptions,
    int? correctIndex,
    BodyPartsGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    String? motivationalMessage,
  }) {
    return BodyPartsState(
      currentBodyPart: currentBodyPart ?? this.currentBodyPart,
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
  final List<BodyPartItem> options;
  final int correctIndex;

  _OptionsResult({required this.options, required this.correctIndex});
}

_OptionsResult _generateOptions(BodyPartItem correctPart, Random random) {
  final wrongParts = bodyPartsPalette.where((p) => p.name != correctPart.name).toList()..shuffle(random);
  final options = [correctPart, wrongParts[0], wrongParts[1]]..shuffle(random);
  final correctIndex = options.indexWhere((p) => p.name == correctPart.name);

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

class BodyPartsNotifier extends Notifier<BodyPartsState> {
  final Random _random = Random();

  @override
  BodyPartsState build() {
    return BodyPartsState.initial();
  }

  void startNewGame() {
    state = BodyPartsState.initial();
  }

  void goToTest() {
    state = state.copyWith(phase: BodyPartsGamePhase.testing);
  }

  void checkAnswer(int selectedIndex) {
    if (selectedIndex == state.correctIndex) {
      state = state.copyWith(phase: BodyPartsGamePhase.success, score: state.score + 1);
    } else {
      final message = motivationalMessages[_random.nextInt(motivationalMessages.length)];
      state = state.copyWith(phase: BodyPartsGamePhase.failure, motivationalMessage: message);
    }
  }

  void retryQuestion() {
    state = state.copyWith(phase: BodyPartsGamePhase.testing);
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = BodyPartsState.initial();
    } else {
      final newBodyPart = bodyPartsPalette[_random.nextInt(bodyPartsPalette.length)];
      final newDisplayColor = colorOptions[_random.nextInt(colorOptions.length)];
      final options = _generateOptions(newBodyPart, _random);

      state = BodyPartsState(
        currentBodyPart: newBodyPart,
        displayColor: newDisplayColor,
        testOptions: options.options,
        correctIndex: options.correctIndex,
        phase: BodyPartsGamePhase.learning,
        score: state.score,
        totalRounds: state.totalRounds,
        currentRound: state.currentRound + 1,
        motivationalMessage: '',
      );
    }
  }
}

final bodyPartsProvider = NotifierProvider<BodyPartsNotifier, BodyPartsState>(() {
  return BodyPartsNotifier();
}, isAutoDispose: true);

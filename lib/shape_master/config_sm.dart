import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// List of shapes with names and emojis
class ShapeItem {
  final String name;
  final String emoji;

  const ShapeItem({required this.name, required this.emoji});
}

const List<ShapeItem> shapePalette = [
  ShapeItem(name: 'Square', emoji: '🟧'),
  ShapeItem(name: 'Circle', emoji: '🔵'),
  ShapeItem(name: 'Oval', emoji: '🥚'),
  ShapeItem(name: 'Rectangle', emoji: '🟩'),
  ShapeItem(name: 'Triangle', emoji: '🔺'),
  ShapeItem(name: 'Pentagon', emoji: '⬠'),
  ShapeItem(name: 'Hexagon', emoji: '⬡'),
  ShapeItem(name: 'Diamond', emoji: '🔷'),
  ShapeItem(name: 'Star', emoji: '⭐'),
];

// Colors for visual distinction in test options
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

enum ShapeGamePhase { learning, testing, success, failure }

class ShapeMasterState {
  final ShapeItem currentShape;
  final ColorOption displayColor; // Color shown during learning
  final List<ShapeItem> testOptions; // 3 shape options
  final List<ColorOption> testColors; // Different colors for each option
  final int correctIndex;
  final ShapeGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final String motivationalMessage;

  const ShapeMasterState({
    required this.currentShape,
    required this.displayColor,
    required this.testOptions,
    required this.testColors,
    required this.correctIndex,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.motivationalMessage,
  });

  factory ShapeMasterState.initial() {
    final random = Random();
    final shape = shapePalette[random.nextInt(shapePalette.length)];
    final displayColor = colorOptions[random.nextInt(colorOptions.length)];
    final options = _generateOptions(shape, random);
    final colors = _generateColors(random);

    return ShapeMasterState(
      currentShape: shape,
      displayColor: displayColor,
      testOptions: options.options,
      testColors: colors,
      correctIndex: options.correctIndex,
      phase: ShapeGamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      motivationalMessage: '',
    );
  }

  ShapeMasterState copyWith({
    ShapeItem? currentShape,
    ColorOption? displayColor,
    List<ShapeItem>? testOptions,
    List<ColorOption>? testColors,
    int? correctIndex,
    ShapeGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    String? motivationalMessage,
  }) {
    return ShapeMasterState(
      currentShape: currentShape ?? this.currentShape,
      displayColor: displayColor ?? this.displayColor,
      testOptions: testOptions ?? this.testOptions,
      testColors: testColors ?? this.testColors,
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
  final List<ShapeItem> options;
  final int correctIndex;

  _OptionsResult({required this.options, required this.correctIndex});
}

_OptionsResult _generateOptions(ShapeItem correctShape, Random random) {
  // Get 2 random wrong shapes for 3 total options
  final wrongShapes = shapePalette.where((s) => s.name != correctShape.name).toList()
    ..shuffle(random);

  final options = [correctShape, wrongShapes[0], wrongShapes[1]]..shuffle(random);

  final correctIndex = options.indexWhere((s) => s.name == correctShape.name);

  return _OptionsResult(options: options, correctIndex: correctIndex);
}

List<ColorOption> _generateColors(Random random) {
  // Generate 3 different colors for test options
  final shuffled = List<ColorOption>.from(colorOptions)..shuffle(random);
  return shuffled.take(3).toList();
}

// Motivational messages for failure
const List<String> motivationalMessages = [
  "Almost there! Try again!",
  "You can do it!",
  "Keep trying, superstar!",
  "So close! One more try!",
  "You're doing great!",
  "Don't give up!",
];

class ShapeMasterNotifier extends Notifier<ShapeMasterState> {
  final Random _random = Random();

  @override
  ShapeMasterState build() {
    return ShapeMasterState.initial();
  }

  void startNewGame() {
    state = ShapeMasterState.initial();
  }

  void goToTest() {
    state = state.copyWith(phase: ShapeGamePhase.testing);
  }

  void checkAnswer(int selectedIndex) {
    if (selectedIndex == state.correctIndex) {
      // Correct answer!
      state = state.copyWith(phase: ShapeGamePhase.success, score: state.score + 1);
    } else {
      // Wrong answer
      final message = motivationalMessages[_random.nextInt(motivationalMessages.length)];
      state = state.copyWith(phase: ShapeGamePhase.failure, motivationalMessage: message);
    }
  }

  void retryQuestion() {
    // Stay on test phase - just dismiss the failure overlay
    state = state.copyWith(phase: ShapeGamePhase.testing);
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Game complete - restart
      state = ShapeMasterState.initial();
    } else {
      // Generate new round
      final newShape = shapePalette[_random.nextInt(shapePalette.length)];
      final newDisplayColor = colorOptions[_random.nextInt(colorOptions.length)];
      final options = _generateOptions(newShape, _random);
      final colors = _generateColors(_random);

      state = ShapeMasterState(
        currentShape: newShape,
        displayColor: newDisplayColor,
        testOptions: options.options,
        testColors: colors,
        correctIndex: options.correctIndex,
        phase: ShapeGamePhase.learning,
        score: state.score,
        totalRounds: state.totalRounds,
        currentRound: state.currentRound + 1,
        motivationalMessage: '',
      );
    }
  }
}

final shapeMasterProvider = NotifierProvider<ShapeMasterNotifier, ShapeMasterState>(() {
  return ShapeMasterNotifier();
}, isAutoDispose: true);

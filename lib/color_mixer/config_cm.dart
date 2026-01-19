import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ColorMixerPhase { learning, testing, success }

class MixableColor {
  final String name;
  final Color color;
  final String emoji;

  const MixableColor({required this.name, required this.color, required this.emoji});
}

const primaryColors = [
  MixableColor(name: 'Red', color: Colors.red, emoji: '🔴'),
  MixableColor(name: 'Yellow', color: Colors.yellow, emoji: '🟡'),
  MixableColor(name: 'Blue', color: Colors.blue, emoji: '🔵'),
];

const mixRecipes = {
  'Red+Yellow': MixableColor(name: 'Orange', color: Colors.orange, emoji: '🟠'),
  'Yellow+Red': MixableColor(name: 'Orange', color: Colors.orange, emoji: '🟠'),
  'Red+Blue': MixableColor(name: 'Purple', color: Colors.purple, emoji: '🟣'),
  'Blue+Red': MixableColor(name: 'Purple', color: Colors.purple, emoji: '🟣'),
  'Yellow+Blue': MixableColor(name: 'Green', color: Colors.green, emoji: '🟢'),
  'Blue+Yellow': MixableColor(name: 'Green', color: Colors.green, emoji: '🟢'),
};

class ColorMixerState {
  final ColorMixerPhase phase;
  final List<MixableColor> currentMix;
  final MixableColor? targetColor;
  final int score;
  final int totalRounds;
  final int currentRound;
  final String motivationalMessage;

  ColorMixerState({
    this.phase = ColorMixerPhase.learning,
    this.currentMix = const [],
    this.targetColor,
    this.score = 0,
    this.totalRounds = 5,
    this.currentRound = 1,
    this.motivationalMessage = '',
  });

  ColorMixerState copyWith({
    ColorMixerPhase? phase,
    List<MixableColor>? currentMix,
    MixableColor? targetColor,
    int? score,
    int? totalRounds,
    int? currentRound,
    String? motivationalMessage,
  }) {
    return ColorMixerState(
      phase: phase ?? this.phase,
      currentMix: currentMix ?? this.currentMix,
      targetColor: targetColor ?? this.targetColor,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
    );
  }
}

final colorMixerProvider = NotifierProvider<ColorMixerNotifier, ColorMixerState>(() {
  return ColorMixerNotifier();
});

class ColorMixerNotifier extends Notifier<ColorMixerState> {
  @override
  ColorMixerState build() {
    // Initial state setup should be here or as static initial state
    return _initialState();
  }

  ColorMixerState _initialState() {
    final random = Random();
    final recipes = mixRecipes.entries.toList();
    final recipe = recipes[random.nextInt(recipes.length)];
    final parts = recipe.key.split('+');

    final color1 = primaryColors.firstWhere((c) => c.name == parts[0]);
    final color2 = primaryColors.firstWhere((c) => c.name == parts[1]);

    return ColorMixerState(
      phase: ColorMixerPhase.learning,
      currentMix: [color1, color2],
      targetColor: recipe.value,
      motivationalMessage: 'Watch how we make ${recipe.value.name}!',
    );
  }

  void _generateLearningRound() {
    state = _initialState().copyWith(currentRound: state.currentRound, score: state.score);
  }

  void goToTest() {
    state = state.copyWith(
      phase: ColorMixerPhase.testing,
      currentMix: [],
      motivationalMessage: 'Can you make ${state.targetColor?.name}?',
    );
  }

  void addColor(MixableColor color) {
    if (state.phase != ColorMixerPhase.testing) return;
    if (state.currentMix.length >= 2) return;

    final updatedMix = [...state.currentMix, color];
    state = state.copyWith(currentMix: updatedMix);

    if (updatedMix.length == 2) {
      _checkResult();
    }
  }

  void clearMix() {
    if (state.phase != ColorMixerPhase.testing) return;
    state = state.copyWith(currentMix: [], motivationalMessage: '');
  }

  void _checkResult() {
    final mixKey = '${state.currentMix[0].name}+${state.currentMix[1].name}';
    final result = mixRecipes[mixKey];

    if (result != null && result.name == state.targetColor?.name) {
      state = state.copyWith(
        phase: ColorMixerPhase.success,
        score: state.score + 1,
        motivationalMessage: 'Amazing! You made ${result.name}!',
      );
    } else {
      state = state.copyWith(
        currentMix: [],
        motivationalMessage: 'Not quite! Try another combination.',
      );
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = ColorMixerState(
        totalRounds: state.totalRounds,
        score: 0,
      ).copyWith(phase: ColorMixerPhase.learning, currentRound: 1);
      _generateLearningRound();
    } else {
      state = state.copyWith(currentRound: state.currentRound + 1, currentMix: []);
      _generateLearningRound();
    }
  }
}

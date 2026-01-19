import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MixableColor {
  final String name;
  final Color color;
  final String emoji;

  const MixableColor({required this.name, required this.color, required this.emoji});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MixableColor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color.toARGB32() == other.color.toARGB32();

  @override
  int get hashCode => name.hashCode ^ color.toARGB32();
}

const baseColors = [
  MixableColor(name: 'Red', color: Colors.red, emoji: '🔴'),
  MixableColor(name: 'Yellow', color: Colors.yellow, emoji: '🟡'),
  MixableColor(name: 'Blue', color: Colors.blue, emoji: '🔵'),
  MixableColor(name: 'White', color: Colors.white, emoji: '⚪'),
  MixableColor(name: 'Black', color: Colors.black, emoji: '⚫'),
];

const alchemyRecipes = {
  'Red+Yellow': MixableColor(name: 'Orange', color: Colors.orange, emoji: '🟠'),
  'Yellow+Red': MixableColor(name: 'Orange', color: Colors.orange, emoji: '🟠'),
  'Red+Blue': MixableColor(name: 'Purple', color: Colors.purple, emoji: '🟣'),
  'Blue+Red': MixableColor(name: 'Purple', color: Colors.purple, emoji: '🟣'),
  'Yellow+Blue': MixableColor(name: 'Green', color: Colors.green, emoji: '🟢'),
  'Blue+Yellow': MixableColor(name: 'Green', color: Colors.green, emoji: '🟢'),
  'Red+White': MixableColor(name: 'Pink', color: Colors.pink, emoji: '🌸'),
  'White+Red': MixableColor(name: 'Pink', color: Colors.pink, emoji: '🌸'),
  'Blue+White': MixableColor(name: 'Light Blue', color: Colors.lightBlue, emoji: '❄️'),
  'White+Blue': MixableColor(name: 'Light Blue', color: Colors.lightBlue, emoji: '❄️'),
  'Green+White': MixableColor(name: 'Light Green', color: Colors.lightGreen, emoji: '🌱'),
  'White+Green': MixableColor(name: 'Light Green', color: Colors.lightGreen, emoji: '🌱'),
  'Orange+White': MixableColor(name: 'Peach', color: Color(0xFFFFCC99), emoji: '🍑'),
  'White+Orange': MixableColor(name: 'Peach', color: Color(0xFFFFCC99), emoji: '🍑'),
  'Red+Black': MixableColor(name: 'Maroon', color: Color(0xFF800000), emoji: '🍷'),
  'Black+Red': MixableColor(name: 'Maroon', color: Color(0xFF800000), emoji: '🍷'),
  'Yellow+Black': MixableColor(name: 'Olive', color: Color(0xFF808000), emoji: '🍸'),
  'Black+Yellow': MixableColor(name: 'Olive', color: Color(0xFF808000), emoji: '🍸'),
  'Blue+Black': MixableColor(name: 'Navy', color: Color(0xFF000080), emoji: '⚓'),
  'Black+Blue': MixableColor(name: 'Navy', color: Color(0xFF000080), emoji: '⚓'),

  'White+Black': MixableColor(name: 'Grey', color: Colors.grey, emoji: '🌑'),
  'Black+White': MixableColor(name: 'Grey', color: Colors.grey, emoji: '🌑'),
  'Orange+Blue': MixableColor(name: 'Brown', color: Colors.brown, emoji: '🤎'),
  'Blue+Orange': MixableColor(name: 'Brown', color: Colors.brown, emoji: '🤎'),
  'Green+Red': MixableColor(name: 'Brown', color: Colors.brown, emoji: '🤎'),
  'Red+Green': MixableColor(name: 'Brown', color: Colors.brown, emoji: '🤎'),
  'Purple+Yellow': MixableColor(name: 'Brown', color: Colors.brown, emoji: '🤎'),
  'Yellow+Purple': MixableColor(name: 'Brown', color: Colors.brown, emoji: '🤎'),
};

class ColorAlchemyState {
  final List<MixableColor> availableColors;
  final List<MixableColor> currentMix;
  final MixableColor? lastResult;
  final String motivationalMessage;
  final bool isNewDiscovery;

  ColorAlchemyState({
    this.availableColors = baseColors,
    this.currentMix = const [],
    this.lastResult,
    this.motivationalMessage = 'Mix colors to discover new ones!',
    this.isNewDiscovery = false,
  });

  ColorAlchemyState copyWith({
    List<MixableColor>? availableColors,
    List<MixableColor>? currentMix,
    MixableColor? lastResult,
    String? motivationalMessage,
    bool? isNewDiscovery,
  }) {
    return ColorAlchemyState(
      availableColors: availableColors ?? this.availableColors,
      currentMix: currentMix ?? this.currentMix,
      lastResult: lastResult ?? this.lastResult,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
      isNewDiscovery: isNewDiscovery ?? this.isNewDiscovery,
    );
  }
}

final colorAlchemyProvider = NotifierProvider<ColorAlchemyNotifier, ColorAlchemyState>(() {
  return ColorAlchemyNotifier();
});

class ColorAlchemyNotifier extends Notifier<ColorAlchemyState> {
  @override
  ColorAlchemyState build() {
    return ColorAlchemyState();
  }

  void addColor(MixableColor color) {
    if (state.currentMix.length >= 2) return;

    final updatedMix = [...state.currentMix, color];
    state = state.copyWith(currentMix: updatedMix, isNewDiscovery: false);

    if (updatedMix.length == 2) {
      _mix();
    }
  }

  void clearMix() {
    state = state.copyWith(
      currentMix: [],
      lastResult: null,
      motivationalMessage: 'Pot cleared! Try a new mix.',
      isNewDiscovery: false,
    );
  }

  void _mix() {
    final mixKey = '${state.currentMix[0].name}+${state.currentMix[1].name}';
    final result = alchemyRecipes[mixKey];

    if (result != null) {
      final isNew = !state.availableColors.any((c) => c.name == result.name);
      final updatedColors = isNew ? [...state.availableColors, result] : state.availableColors;

      state = state.copyWith(
        lastResult: result,
        availableColors: updatedColors,
        motivationalMessage: isNew
            ? 'Incredible! You discovered ${result.name}! This new color added to your palette.'
            : 'You made ${result.name} again!',
        isNewDiscovery: isNew,
      );
    } else {
      // Generic muddy color if no recipe exists
      final muddy = MixableColor(
        name: 'Muddy Color',
        color: Color.lerp(state.currentMix[0].color, state.currentMix[1].color, 0.5) ?? Colors.grey,
        emoji: '💩',
      );
      state = state.copyWith(
        lastResult: muddy,
        motivationalMessage: 'That mix didn\'t discover anything new. Try again!',
        isNewDiscovery: false,
      );
    }
  }

  void resetGame() {
    state = ColorAlchemyState();
  }
}

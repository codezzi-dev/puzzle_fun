import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a letter placed on the canvas
class CanvasLetter {
  final String id;
  final String letter;
  final Offset position;
  Color color;

  CanvasLetter({
    required this.id,
    required this.letter,
    required this.position,
    this.color = Colors.white,
  });

  CanvasLetter copyWith({Color? color, Offset? position}) {
    return CanvasLetter(
      id: id,
      letter: letter,
      position: position ?? this.position,
      color: color ?? this.color,
    );
  }
}

/// Child-friendly color palette
final List<LetterColorOption> letterColorPalette = [
  LetterColorOption(name: 'Red', color: Colors.red, emoji: '❤️'),
  LetterColorOption(name: 'Blue', color: Colors.blue, emoji: '💙'),
  LetterColorOption(name: 'Green', color: Colors.green, emoji: '💚'),
  LetterColorOption(name: 'Yellow', color: Colors.yellow, emoji: '💛'),
  LetterColorOption(name: 'Orange', color: Colors.orange, emoji: '🧡'),
  LetterColorOption(name: 'Purple', color: Colors.purple, emoji: '💜'),
  LetterColorOption(name: 'Pink', color: Colors.pink, emoji: '💗'),
  LetterColorOption(name: 'Cyan', color: Colors.cyan, emoji: '💎'),
];

class LetterColorOption {
  final String name;
  final Color color;
  final String emoji;

  const LetterColorOption({required this.name, required this.color, required this.emoji});
}

/// Game state for Color Letters (coloring pad style)
class ColorLettersState {
  final List<CanvasLetter> canvasLetters; // Letters placed on canvas
  final Color? selectedColor; // Currently selected color
  final String? selectedColorName; // Name for TTS
  final int nextId; // For unique IDs

  const ColorLettersState({
    required this.canvasLetters,
    this.selectedColor,
    this.selectedColorName,
    required this.nextId,
  });

  factory ColorLettersState.initial() {
    return const ColorLettersState(
      canvasLetters: [],
      selectedColor: null,
      selectedColorName: null,
      nextId: 0,
    );
  }

  ColorLettersState copyWith({
    List<CanvasLetter>? canvasLetters,
    Color? selectedColor,
    String? selectedColorName,
    int? nextId,
    bool clearSelectedColor = false,
  }) {
    return ColorLettersState(
      canvasLetters: canvasLetters ?? this.canvasLetters,
      selectedColor: clearSelectedColor ? null : (selectedColor ?? this.selectedColor),
      selectedColorName: clearSelectedColor ? null : (selectedColorName ?? this.selectedColorName),
      nextId: nextId ?? this.nextId,
    );
  }
}

/// State notifier for Color Letters game
class ColorLettersNotifier extends Notifier<ColorLettersState> {
  // Grid layout settings
  static const int maxItems = 12; // Maximum items on canvas
  static const int maxPerRow = 4;
  static const double startX = 20;
  static const double startY = 20;
  static const double stepX = 80;
  static const double stepY = 100;

  @override
  ColorLettersState build() {
    return ColorLettersState.initial();
  }

  /// Check if more items can be added
  bool get canAddMore => state.canvasLetters.length < maxItems;

  /// Add a letter to the canvas (max 8)
  /// Returns true if added, false if limit reached
  bool addLetter(String letter) {
    if (!canAddMore) return false;

    final currentCount = state.canvasLetters.length;
    final row = currentCount ~/ maxPerRow;
    final col = currentCount % maxPerRow;

    final newLetter = CanvasLetter(
      id: 'letter_${state.nextId}',
      letter: letter,
      position: Offset(startX + col * stepX, startY + row * stepY),
    );

    state = state.copyWith(
      canvasLetters: [...state.canvasLetters, newLetter],
      nextId: state.nextId + 1,
    );
    return true;
  }

  /// Select a color from palette
  void selectColor(Color color, String colorName) {
    state = state.copyWith(selectedColor: color, selectedColorName: colorName);
  }

  /// Color a letter on the canvas
  /// Toggle behavior: if already colored, reset to white; if white, apply selected color
  bool colorLetter(String letterId) {
    if (state.selectedColor == null) return false;

    final newList = state.canvasLetters.map((l) {
      if (l.id == letterId) {
        // If already has a color (not white), reset to white
        if (l.color != Colors.white) {
          return l.copyWith(color: Colors.white);
        }
        // If white, apply the selected color
        return l.copyWith(color: state.selectedColor);
      }
      return l;
    }).toList();

    state = state.copyWith(canvasLetters: newList);
    return true;
  }

  /// Remove a letter from the canvas and recalculate positions
  void removeLetter(String letterId) {
    // Remove the item and recalculate positions for remaining items
    final filteredList = state.canvasLetters.where((l) => l.id != letterId).toList();

    // Recalculate positions for all remaining items
    final newList = filteredList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final row = index ~/ maxPerRow;
      final col = index % maxPerRow;
      return item.copyWith(position: Offset(startX + col * stepX, startY + row * stepY));
    }).toList();

    state = state.copyWith(canvasLetters: newList);
  }

  /// Remove the last letter from the canvas
  void removeLastLetter() {
    if (state.canvasLetters.isEmpty) return;
    final newList = state.canvasLetters.sublist(0, state.canvasLetters.length - 1);
    state = state.copyWith(canvasLetters: newList);
  }

  /// Clear the canvas
  void clearCanvas() {
    state = ColorLettersState.initial();
  }
}

final colorLettersProvider = NotifierProvider<ColorLettersNotifier, ColorLettersState>(() {
  return ColorLettersNotifier();
}, isAutoDispose: true);

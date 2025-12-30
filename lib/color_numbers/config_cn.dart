import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a number placed on the canvas
class CanvasNumber {
  final String id;
  final int number;
  final Offset position;
  Color color;

  CanvasNumber({
    required this.id,
    required this.number,
    required this.position,
    this.color = Colors.white,
  });

  CanvasNumber copyWith({Color? color}) {
    return CanvasNumber(id: id, number: number, position: position, color: color ?? this.color);
  }
}

/// Child-friendly color palette
final List<ColorOption> colorPalette = [
  ColorOption(name: 'Red', color: Colors.red, emoji: '❤️'),
  ColorOption(name: 'Blue', color: Colors.blue, emoji: '💙'),
  ColorOption(name: 'Green', color: Colors.green, emoji: '💚'),
  ColorOption(name: 'Yellow', color: Colors.yellow, emoji: '💛'),
  ColorOption(name: 'Orange', color: Colors.orange, emoji: '🧡'),
  ColorOption(name: 'Purple', color: Colors.purple, emoji: '💜'),
  ColorOption(name: 'Pink', color: Colors.pink, emoji: '💗'),
  ColorOption(name: 'Cyan', color: Colors.cyan, emoji: '💎'),
];

class ColorOption {
  final String name;
  final Color color;
  final String emoji;

  const ColorOption({required this.name, required this.color, required this.emoji});
}

/// Game state for Color Numbers (coloring pad style)
class ColorNumbersState {
  final List<CanvasNumber> canvasNumbers; // Numbers placed on canvas
  final Color? selectedColor; // Currently selected color
  final String? selectedColorName; // Name for TTS
  final int nextId; // For unique IDs

  const ColorNumbersState({
    required this.canvasNumbers,
    this.selectedColor,
    this.selectedColorName,
    required this.nextId,
  });

  factory ColorNumbersState.initial() {
    return const ColorNumbersState(
      canvasNumbers: [],
      selectedColor: null,
      selectedColorName: null,
      nextId: 0,
    );
  }

  ColorNumbersState copyWith({
    List<CanvasNumber>? canvasNumbers,
    Color? selectedColor,
    String? selectedColorName,
    int? nextId,
    bool clearSelectedColor = false,
  }) {
    return ColorNumbersState(
      canvasNumbers: canvasNumbers ?? this.canvasNumbers,
      selectedColor: clearSelectedColor ? null : (selectedColor ?? this.selectedColor),
      selectedColorName: clearSelectedColor ? null : (selectedColorName ?? this.selectedColorName),
      nextId: nextId ?? this.nextId,
    );
  }
}

/// State notifier for Color Numbers game
class ColorNumbersNotifier extends Notifier<ColorNumbersState> {
  // Grid layout settings
  static const int maxItems = 12; // Maximum items on canvas
  static const int maxPerRow = 4;
  static const double startX = 20;
  static const double startY = 20;
  static const double stepX = 80;
  static const double stepY = 100;

  @override
  ColorNumbersState build() {
    return ColorNumbersState.initial();
  }

  /// Check if more items can be added
  bool get canAddMore => state.canvasNumbers.length < maxItems;

  /// Add a number to the canvas (max 8)
  /// Returns true if added, false if limit reached
  bool addNumber(int number) {
    if (!canAddMore) return false;

    final currentCount = state.canvasNumbers.length;
    final row = currentCount ~/ maxPerRow;
    final col = currentCount % maxPerRow;

    final newNumber = CanvasNumber(
      id: 'num_${state.nextId}',
      number: number,
      position: Offset(startX + col * stepX, startY + row * stepY),
    );

    state = state.copyWith(
      canvasNumbers: [...state.canvasNumbers, newNumber],
      nextId: state.nextId + 1,
    );
    return true;
  }

  /// Select a color from palette
  void selectColor(Color color, String colorName) {
    state = state.copyWith(selectedColor: color, selectedColorName: colorName);
  }

  /// Color a number on the canvas
  /// Toggle behavior: if already colored, reset to white; if white, apply selected color
  bool colorNumber(String numberId) {
    if (state.selectedColor == null) return false;

    final newList = state.canvasNumbers.map((n) {
      if (n.id == numberId) {
        // If already has a color (not white), reset to white
        if (n.color != Colors.white) {
          return n.copyWith(color: Colors.white);
        }
        // If white, apply the selected color
        return n.copyWith(color: state.selectedColor);
      }
      return n;
    }).toList();

    state = state.copyWith(canvasNumbers: newList);
    return true;
  }

  /// Clear the canvas
  void clearCanvas() {
    state = ColorNumbersState.initial();
  }
}

final colorNumbersProvider = NotifierProvider<ColorNumbersNotifier, ColorNumbersState>(() {
  return ColorNumbersNotifier();
}, isAutoDispose: true);

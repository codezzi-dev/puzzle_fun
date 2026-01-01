import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CreativeMode { letters, numbers }

/// Represents an item (letter or number) placed on the canvas
class CreativeItem {
  final String id;
  final String content;
  final Offset position;
  final Color color;
  final CreativeMode type;

  CreativeItem({
    required this.id,
    required this.content,
    required this.position,
    this.color = Colors.white,
    required this.type,
  });

  CreativeItem copyWith({Color? color, Offset? position}) {
    return CreativeItem(
      id: id,
      content: content,
      position: position ?? this.position,
      color: color ?? this.color,
      type: type,
    );
  }
}

/// Child-friendly color palette
class CreativeColorOption {
  final String name;
  final Color color;
  final String emoji;

  const CreativeColorOption({required this.name, required this.color, required this.emoji});
}

final List<CreativeColorOption> creativeColorPalette = [
  const CreativeColorOption(name: 'Red', color: Colors.red, emoji: '❤️'),
  const CreativeColorOption(name: 'Blue', color: Colors.blue, emoji: '💙'),
  const CreativeColorOption(name: 'Green', color: Colors.green, emoji: '💚'),
  const CreativeColorOption(name: 'Yellow', color: Colors.yellow, emoji: '💛'),
  const CreativeColorOption(name: 'Orange', color: Colors.orange, emoji: '🧡'),
  const CreativeColorOption(name: 'Purple', color: Colors.purple, emoji: '💜'),
  const CreativeColorOption(name: 'Pink', color: Colors.pink, emoji: '💗'),
  const CreativeColorOption(name: 'Cyan', color: Colors.cyan, emoji: '💎'),
];

/// Game state for Creative Pad
class CreativePadState {
  final List<CreativeItem> items; // Items placed on canvas
  final Color? selectedColor; // Currently selected color
  final String? selectedColorName; // Name for TTS
  final CreativeMode mode; // Current mode (letters/numbers)
  final int nextId; // For unique IDs

  const CreativePadState({
    required this.items,
    this.selectedColor,
    this.selectedColorName,
    required this.mode,
    required this.nextId,
  });

  factory CreativePadState.initial() {
    return const CreativePadState(
      items: [],
      selectedColor: null,
      selectedColorName: null,
      mode: CreativeMode.letters,
      nextId: 0,
    );
  }

  CreativePadState copyWith({
    List<CreativeItem>? items,
    Color? selectedColor,
    String? selectedColorName,
    CreativeMode? mode,
    int? nextId,
    bool clearSelectedColor = false,
  }) {
    return CreativePadState(
      items: items ?? this.items,
      selectedColor: clearSelectedColor ? null : (selectedColor ?? this.selectedColor),
      selectedColorName: clearSelectedColor ? null : (selectedColorName ?? this.selectedColorName),
      mode: mode ?? this.mode,
      nextId: nextId ?? this.nextId,
    );
  }
}

/// State notifier for Creative Pad game
class CreativePadNotifier extends Notifier<CreativePadState> {
  // Grid layout settings
  static const int maxItems = 12; // Maximum items on canvas
  static const int maxPerRow = 4;
  static const double startX = 20;
  static const double startY = 20;
  static const double stepX = 80;
  static const double stepY = 100;

  @override
  CreativePadState build() {
    return CreativePadState.initial();
  }

  /// Check if more items can be added
  bool get canAddMore => state.items.length < maxItems;

  /// Switch mode (letters vs numbers)
  void setMode(CreativeMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Add an item to the canvas
  bool addItem(String content) {
    if (!canAddMore) return false;

    final currentCount = state.items.length;
    final row = currentCount ~/ maxPerRow;
    final col = currentCount % maxPerRow;

    final newItem = CreativeItem(
      id: 'item_${state.nextId}',
      content: content,
      type: state.mode,
      position: Offset(startX + col * stepX, startY + row * stepY),
    );

    state = state.copyWith(items: [...state.items, newItem], nextId: state.nextId + 1);
    return true;
  }

  /// Select a color from palette
  void selectColor(Color color, String colorName) {
    state = state.copyWith(selectedColor: color, selectedColorName: colorName);
  }

  /// Color an item on the canvas
  bool colorItem(String itemId) {
    if (state.selectedColor == null) return false;

    final newList = state.items.map((item) {
      if (item.id == itemId) {
        if (item.color != Colors.white) {
          return item.copyWith(color: Colors.white);
        }
        return item.copyWith(color: state.selectedColor);
      }
      return item;
    }).toList();

    state = state.copyWith(items: newList);
    return true;
  }

  /// Remove an item and recalculate positions
  void removeItem(String itemId) {
    final filteredList = state.items.where((item) => item.id != itemId).toList();

    final newList = filteredList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final row = index ~/ maxPerRow;
      final col = index % maxPerRow;
      return item.copyWith(position: Offset(startX + col * stepX, startY + row * stepY));
    }).toList();

    state = state.copyWith(items: newList);
  }

  /// Remove the last item from the canvas
  void removeLastItem() {
    if (state.items.isEmpty) return;
    final newList = state.items.sublist(0, state.items.length - 1);
    state = state.copyWith(items: newList);
  }

  /// Clear the canvas
  void clearCanvas() {
    state = CreativePadState.initial().copyWith(mode: state.mode);
  }
}

final creativePadProvider = NotifierProvider<CreativePadNotifier, CreativePadState>(() {
  return CreativePadNotifier();
}, isAutoDispose: true);

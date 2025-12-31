import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single part of an object with its shape and color
class ObjectPart {
  final String id;
  final String
  shapeType; // Circle, Square, Rectangle, Triangle, Oval, Pentagon, Hexagon, Diamond, Star
  final String shapeName; // Display name for TTS (e.g., "triangle", "circle")
  final Offset position; // Relative position in the object layout
  final Size size;
  final Color color; // Target color to match

  const ObjectPart({
    required this.id,
    required this.shapeType,
    required this.shapeName,
    required this.position,
    required this.size,
    required this.color,
  });
}

/// An object template with all its parts
class ObjectTemplate {
  final String name;
  final String emoji;
  final List<ObjectPart> parts;

  const ObjectTemplate({required this.name, required this.emoji, required this.parts});
}

/// Object templates using Shape Master shapes
final List<ObjectTemplate> objectTemplates = [
  // Object 1: House 🏠
  ObjectTemplate(
    name: 'House',
    emoji: '🏠',
    parts: [
      ObjectPart(
        id: 'roof',
        shapeType: 'Triangle',
        shapeName: 'triangle',
        position: const Offset(30, 0),
        size: const Size(160, 80),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'body',
        shapeType: 'Square',
        shapeName: 'square',
        position: const Offset(40, 75),
        size: const Size(140, 130),
        color: Colors.amber,
      ),
      ObjectPart(
        id: 'door',
        shapeType: 'Rectangle',
        shapeName: 'rectangle',
        position: const Offset(90, 135),
        size: const Size(40, 70),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'window_left',
        shapeType: 'Square',
        shapeName: 'square',
        position: const Offset(55, 95),
        size: const Size(35, 35),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'window_right',
        shapeType: 'Square',
        shapeName: 'square',
        position: const Offset(130, 95),
        size: const Size(35, 35),
        color: Colors.blue,
      ),
    ],
  ),

  // Object 2: Car 🚗
  ObjectTemplate(
    name: 'Car',
    emoji: '🚗',
    parts: [
      ObjectPart(
        id: 'body',
        shapeType: 'Rectangle',
        shapeName: 'rectangle',
        position: const Offset(15, 60),
        size: const Size(190, 70),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'roof',
        shapeType: 'Rectangle',
        shapeName: 'rectangle',
        position: const Offset(55, 20),
        size: const Size(100, 50),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'window',
        shapeType: 'Square',
        shapeName: 'square',
        position: const Offset(75, 30),
        size: const Size(60, 35),
        color: Colors.cyan,
      ),
      ObjectPart(
        id: 'wheel_left',
        shapeType: 'Circle',
        shapeName: 'circle',
        position: const Offset(40, 110),
        size: const Size(50, 50),
        color: Colors.grey,
      ),
      ObjectPart(
        id: 'wheel_right',
        shapeType: 'Circle',
        shapeName: 'circle',
        position: const Offset(130, 110),
        size: const Size(50, 50),
        color: Colors.grey,
      ),
    ],
  ),

  // Object 3: Tree 🌳
  ObjectTemplate(
    name: 'Tree',
    emoji: '🌳',
    parts: [
      ObjectPart(
        id: 'foliage',
        shapeType: 'Circle',
        shapeName: 'circle',
        position: const Offset(50, 0),
        size: const Size(120, 120),
        color: Colors.green,
      ),
      ObjectPart(
        id: 'trunk',
        shapeType: 'Rectangle',
        shapeName: 'rectangle',
        position: const Offset(90, 105),
        size: const Size(40, 100),
        color: Colors.brown,
      ),
    ],
  ),

  // Object 4: Flower 🌸
  ObjectTemplate(
    name: 'Flower',
    emoji: '🌸',
    parts: [
      ObjectPart(
        id: 'petal_top',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(85, 0),
        size: const Size(50, 45),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'petal_left',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(45, 35),
        size: const Size(50, 45),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'petal_right',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(125, 35),
        size: const Size(50, 45),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'petal_bottom',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(85, 70),
        size: const Size(50, 45),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'center',
        shapeType: 'Circle',
        shapeName: 'circle',
        position: const Offset(80, 35),
        size: const Size(60, 60),
        color: Colors.yellow,
      ),
      ObjectPart(
        id: 'stem',
        shapeType: 'Rectangle',
        shapeName: 'rectangle',
        position: const Offset(100, 110),
        size: const Size(20, 90),
        color: Colors.green,
      ),
    ],
  ),

  // Object 5: Rocket 🚀
  ObjectTemplate(
    name: 'Rocket',
    emoji: '🚀',
    parts: [
      ObjectPart(
        id: 'nose',
        shapeType: 'Triangle',
        shapeName: 'triangle',
        position: const Offset(70, 0),
        size: const Size(80, 50),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'body',
        shapeType: 'Rectangle',
        shapeName: 'rectangle',
        position: const Offset(70, 45),
        size: const Size(80, 110),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'window',
        shapeType: 'Circle',
        shapeName: 'circle',
        position: const Offset(85, 65),
        size: const Size(50, 50),
        color: Colors.cyan,
      ),
      ObjectPart(
        id: 'fin_left',
        shapeType: 'Triangle',
        shapeName: 'triangle',
        position: const Offset(35, 120),
        size: const Size(45, 55),
        color: Colors.orange,
      ),
      ObjectPart(
        id: 'fin_right',
        shapeType: 'Triangle',
        shapeName: 'triangle',
        position: const Offset(140, 120),
        size: const Size(45, 55),
        color: Colors.orange,
      ),
    ],
  ),

  // Object 6: Fish 🐟
  ObjectTemplate(
    name: 'Fish',
    emoji: '🐟',
    parts: [
      ObjectPart(
        id: 'body',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(20, 50),
        size: const Size(140, 90),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'tail',
        shapeType: 'Triangle',
        shapeName: 'triangle',
        position: const Offset(150, 60),
        size: const Size(55, 70),
        color: Colors.orange,
      ),
      ObjectPart(
        id: 'eye',
        shapeType: 'Circle',
        shapeName: 'circle',
        position: const Offset(45, 75),
        size: const Size(30, 30),
        color: Colors.white,
      ),
    ],
  ),

  // Object 7: Butterfly 🦋
  ObjectTemplate(
    name: 'Butterfly',
    emoji: '🦋',
    parts: [
      ObjectPart(
        id: 'wing_top_left',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(20, 15),
        size: const Size(80, 70),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'wing_top_right',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(120, 15),
        size: const Size(80, 70),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'wing_bottom_left',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(25, 95),
        size: const Size(70, 60),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wing_bottom_right',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(125, 95),
        size: const Size(70, 60),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'body',
        shapeType: 'Oval',
        shapeName: 'oval',
        position: const Offset(95, 30),
        size: const Size(30, 120),
        color: Colors.brown,
      ),
    ],
  ),

  // Object 8: Boat ⛵
  ObjectTemplate(
    name: 'Boat',
    emoji: '⛵',
    parts: [
      ObjectPart(
        id: 'sail',
        shapeType: 'Triangle',
        shapeName: 'triangle',
        position: const Offset(85, 0),
        size: const Size(90, 110),
        color: Colors.white,
      ),
      ObjectPart(
        id: 'mast',
        shapeType: 'Rectangle',
        shapeName: 'rectangle',
        position: const Offset(105, 10),
        size: const Size(10, 120),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'hull',
        shapeType: 'Pentagon',
        shapeName: 'pentagon',
        position: const Offset(30, 120),
        size: const Size(160, 70),
        color: Colors.red,
      ),
    ],
  ),
];

/// Child-friendly color palette for the coloring game (solid colors only)
final List<ColorOption> colorPalette = [
  ColorOption(id: 'red', name: 'Red', color: Colors.red, emoji: '❤️'),
  ColorOption(id: 'pink', name: 'Pink', color: Colors.pink, emoji: '💗'),
  ColorOption(id: 'orange', name: 'Orange', color: Colors.orange, emoji: '🧡'),
  ColorOption(id: 'yellow', name: 'Yellow', color: Colors.yellow, emoji: '💛'),
  ColorOption(id: 'amber', name: 'Amber', color: Colors.amber, emoji: '🌟'),
  ColorOption(id: 'green', name: 'Green', color: Colors.green, emoji: '💚'),
  ColorOption(id: 'teal', name: 'Teal', color: Colors.teal, emoji: '🌊'),
  ColorOption(id: 'cyan', name: 'Cyan', color: Colors.cyan, emoji: '💎'),
  ColorOption(id: 'blue', name: 'Blue', color: Colors.blue, emoji: '💙'),
  ColorOption(id: 'purple', name: 'Purple', color: Colors.purple, emoji: '💜'),
  ColorOption(id: 'brown', name: 'Brown', color: Colors.brown, emoji: '🟤'),
  ColorOption(id: 'grey', name: 'Grey', color: Colors.grey, emoji: '🩶'),
  ColorOption(id: 'white', name: 'White', color: Colors.white, emoji: '🤍'),
];

/// A color option in the palette
class ColorOption {
  final String id;
  final String name;
  final Color color;
  final String emoji;

  const ColorOption({
    required this.id,
    required this.name,
    required this.color,
    required this.emoji,
  });
}

/// Game phases
enum ObjectPainterPhase { learning, coloring, success }

/// Game state for Object Painter
class ObjectPainterState {
  final ObjectTemplate currentObject;
  final ObjectPainterPhase phase;
  final Map<String, Color?> coloredParts; // partId -> applied color
  final List<String> colorHistory; // Track order of colored parts for undo
  final Color? selectedColor; // Currently selected color from palette
  final String? selectedColorName; // Name of selected color for TTS
  final int score;
  final int totalObjects;
  final int currentObjectIndex;

  const ObjectPainterState({
    required this.currentObject,
    required this.phase,
    required this.coloredParts,
    required this.colorHistory,
    this.selectedColor,
    this.selectedColorName,
    required this.score,
    required this.totalObjects,
    required this.currentObjectIndex,
  });

  factory ObjectPainterState.initial() {
    final random = Random();
    final index = random.nextInt(objectTemplates.length);
    final object = objectTemplates[index];
    return ObjectPainterState(
      currentObject: object,
      phase: ObjectPainterPhase.learning,
      coloredParts: {for (var part in object.parts) part.id: null},
      colorHistory: const [],
      selectedColor: null,
      selectedColorName: null,
      score: 0,
      totalObjects: objectTemplates.length,
      currentObjectIndex: index,
    );
  }

  /// Check if all parts are colored correctly
  bool get allPartsColoredCorrectly {
    for (var part in currentObject.parts) {
      final appliedColor = coloredParts[part.id];
      if (appliedColor == null) return false;
      if (!colorsMatch(appliedColor, part.color)) return false;
    }
    return true;
  }

  /// Check if a specific part is colored correctly
  bool isPartCorrect(String partId) {
    final part = currentObject.parts.firstWhere((p) => p.id == partId);
    final appliedColor = coloredParts[partId];
    if (appliedColor == null) return false;
    return colorsMatch(appliedColor, part.color);
  }

  /// Check if a part has been colored (correctly or incorrectly)
  bool isPartColored(String partId) {
    return coloredParts[partId] != null;
  }

  /// Count of correctly colored parts
  int get correctCount {
    int count = 0;
    for (var part in currentObject.parts) {
      if (isPartCorrect(part.id)) count++;
    }
    return count;
  }

  /// Helper to match colors (exact match for solid colors)
  static bool colorsMatch(Color a, Color b) {
    return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
  }

  ObjectPainterState copyWith({
    ObjectTemplate? currentObject,
    ObjectPainterPhase? phase,
    Map<String, Color?>? coloredParts,
    List<String>? colorHistory,
    Color? selectedColor,
    String? selectedColorName,
    int? score,
    int? totalObjects,
    int? currentObjectIndex,
    bool clearSelectedColor = false,
  }) {
    return ObjectPainterState(
      currentObject: currentObject ?? this.currentObject,
      phase: phase ?? this.phase,
      coloredParts: coloredParts ?? this.coloredParts,
      colorHistory: colorHistory ?? this.colorHistory,
      selectedColor: clearSelectedColor ? null : (selectedColor ?? this.selectedColor),
      selectedColorName: clearSelectedColor ? null : (selectedColorName ?? this.selectedColorName),
      score: score ?? this.score,
      totalObjects: totalObjects ?? this.totalObjects,
      currentObjectIndex: currentObjectIndex ?? this.currentObjectIndex,
    );
  }
}

/// State notifier for Object Painter game
class ObjectPainterNotifier extends Notifier<ObjectPainterState> {
  @override
  ObjectPainterState build() {
    return ObjectPainterState.initial();
  }

  /// Start a new game from the beginning
  void startNewGame() {
    state = ObjectPainterState.initial();
  }

  /// Transition from learning to coloring phase
  void goToColoring() {
    state = state.copyWith(phase: ObjectPainterPhase.coloring);
  }

  /// Select a color from the palette
  void selectColor(Color color, String colorName) {
    state = state.copyWith(selectedColor: color, selectedColorName: colorName);
  }

  /// Apply selected color to an object part
  /// Returns: 'correct', 'incorrect', or 'no_color' (if no color selected)
  /// IMPORTANT: Wrong colors are NOT applied - only correct colors get colored
  String colorPart(String partId) {
    if (state.selectedColor == null) {
      return 'no_color';
    }

    // Check if the color is correct BEFORE applying
    final part = state.currentObject.parts.firstWhere((p) => p.id == partId);
    final isCorrect = ObjectPainterState.colorsMatch(state.selectedColor!, part.color);

    if (!isCorrect) {
      // Wrong color - don't apply it, just return incorrect
      return 'incorrect';
    }

    // Correct color - apply it
    final newColoredParts = Map<String, Color?>.from(state.coloredParts);
    newColoredParts[partId] = state.selectedColor;

    // Track in history for undo
    final newHistory = List<String>.from(state.colorHistory)..add(partId);

    state = state.copyWith(coloredParts: newColoredParts, colorHistory: newHistory);

    // Check if all parts are now correctly colored
    if (state.allPartsColoredCorrectly) {
      state = state.copyWith(
        phase: ObjectPainterPhase.success,
        score: state.score + 1,
        clearSelectedColor: true,
      );
    }

    return 'correct';
  }

  /// Undo the last colored part
  void undoLastColor() {
    if (state.colorHistory.isEmpty) return;

    final lastPartId = state.colorHistory.last;
    final newHistory = List<String>.from(state.colorHistory)..removeLast();
    final newColoredParts = Map<String, Color?>.from(state.coloredParts);
    newColoredParts[lastPartId] = null;

    state = state.copyWith(coloredParts: newColoredParts, colorHistory: newHistory);
  }

  /// Clear all colored parts
  void clearAllColors() {
    final newColoredParts = <String, Color?>{};
    for (var part in state.currentObject.parts) {
      newColoredParts[part.id] = null;
    }
    state = state.copyWith(coloredParts: newColoredParts, colorHistory: []);
  }

  /// Move to next object (picks a random object different from current)
  void nextObject() {
    final random = Random();
    int nextIndex;
    // Pick a random index that is different from the current one
    do {
      nextIndex = random.nextInt(objectTemplates.length);
    } while (nextIndex == state.currentObjectIndex && objectTemplates.length > 1);

    final nextObject = objectTemplates[nextIndex];

    state = ObjectPainterState(
      currentObject: nextObject,
      phase: ObjectPainterPhase.learning,
      coloredParts: {for (var part in nextObject.parts) part.id: null},
      colorHistory: [],
      selectedColor: null,
      selectedColorName: null,
      score: state.score,
      totalObjects: state.totalObjects,
      currentObjectIndex: nextIndex,
    );
  }

  /// Find the matching color option for an object part
  ColorOption? findMatchingColor(ObjectPart part) {
    for (var option in colorPalette) {
      if (ObjectPainterState.colorsMatch(option.color, part.color)) {
        return option;
      }
    }
    return null;
  }

  /// Get unique colors needed for current object
  List<ColorOption> getColorsForObject() {
    final Set<String> colorIds = {};
    final List<ColorOption> colors = [];

    for (var part in state.currentObject.parts) {
      final option = findMatchingColor(part);
      if (option != null && !colorIds.contains(option.id)) {
        colorIds.add(option.id);
        colors.add(option);
      }
    }

    // Add a few extra distractor colors for challenge
    final random = Random();
    final distractors = colorPalette.where((c) => !colorIds.contains(c.id)).toList()
      ..shuffle(random);
    final extraCount = (colors.length < 4) ? 2 : 1; // Add more if few colors needed
    colors.addAll(distractors.take(extraCount));

    // Shuffle the final list
    colors.shuffle(random);
    return colors;
  }
}

final objectPainterProvider = NotifierProvider<ObjectPainterNotifier, ObjectPainterState>(() {
  return ObjectPainterNotifier();
}, isAutoDispose: true);

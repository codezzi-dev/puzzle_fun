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
  // Object 1: House 🏠 - More detailed with chimney and handle
  ObjectTemplate(
    name: 'House',
    emoji: '🏠',
    parts: [
      ObjectPart(
        id: 'roof',
        shapeType: 'Trapezoid',
        shapeName: 'roof',
        position: const Offset(30, -5),
        size: const Size(160, 90),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'chimney',
        shapeType: 'Rectangle',
        shapeName: 'chimney',
        position: const Offset(135, 15),
        size: const Size(25, 45),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'body',
        shapeType: 'Square',
        shapeName: 'house walls',
        position: const Offset(40, 75),
        size: const Size(140, 130),
        color: Colors.amber,
      ),
      ObjectPart(
        id: 'door',
        shapeType: 'Rectangle',
        shapeName: 'door',
        position: const Offset(90, 135),
        size: const Size(40, 70),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'handle',
        shapeType: 'Circle',
        shapeName: 'door handle',
        position: const Offset(120, 172),
        size: const Size(8, 8),
        color: Colors.yellow,
      ),
      ObjectPart(
        id: 'window_left',
        shapeType: 'Square',
        shapeName: 'window',
        position: const Offset(55, 95),
        size: const Size(35, 35),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'window_right',
        shapeType: 'Square',
        shapeName: 'window',
        position: const Offset(130, 95),
        size: const Size(35, 35),
        color: Colors.blue,
      ),
    ],
  ),

  // Object 2: Car 🚗 - Uses trapezoid roof for realism
  ObjectTemplate(
    name: 'Car',
    emoji: '🚗',
    parts: [
      ObjectPart(
        id: 'body',
        shapeType: 'Rectangle',
        shapeName: 'car body',
        position: const Offset(10, 80),
        size: const Size(200, 60),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'roof',
        shapeType: 'Trapezoid',
        shapeName: 'car roof',
        position: const Offset(45, 35),
        size: const Size(130, 55),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'window_glass',
        shapeType: 'Trapezoid',
        shapeName: 'window',
        position: const Offset(55, 42),
        size: const Size(110, 40),
        color: Colors.cyan,
      ),
      ObjectPart(
        id: 'wheel_front',
        shapeType: 'Circle',
        shapeName: 'front wheel',
        position: const Offset(35, 115),
        size: const Size(45, 45),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wheel_back',
        shapeType: 'Circle',
        shapeName: 'back wheel',
        position: const Offset(140, 115),
        size: const Size(45, 45),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'headlight',
        shapeType: 'Oval',
        shapeName: 'headlight',
        position: const Offset(10, 95),
        size: const Size(20, 15),
        color: Colors.yellow,
      ),
    ],
  ),

  // Object 3: Tree 🌳 - fuller foliage using overlapping semicircles
  ObjectTemplate(
    name: 'Tree',
    emoji: '🌳',
    parts: [
      ObjectPart(
        id: 'trunk',
        shapeType: 'Rectangle',
        shapeName: 'tree trunk',
        position: const Offset(95, 110),
        size: const Size(30, 90),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'foliage_main',
        shapeType: 'Circle',
        shapeName: 'leaves',
        position: const Offset(55, 10),
        size: const Size(110, 110),
        color: Colors.green,
      ),
      ObjectPart(
        id: 'foliage_top',
        shapeType: 'Semicircle',
        shapeName: 'leaves top',
        position: const Offset(65, -5),
        size: const Size(90, 80),
        color: Colors.green,
      ),
    ],
  ),

  // Object 4: Rocket 🚀 - Detailing with trapezoid base
  ObjectTemplate(
    name: 'Rocket',
    emoji: '🚀',
    parts: [
      ObjectPart(
        id: 'nose',
        shapeType: 'Triangle',
        shapeName: 'rocket nose',
        position: const Offset(70, -10),
        size: const Size(80, 70),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'body',
        shapeType: 'Rectangle',
        shapeName: 'rocket body',
        position: const Offset(70, 50),
        size: const Size(80, 100),
        color: Colors.cyan,
      ),
      ObjectPart(
        id: 'window',
        shapeType: 'Circle',
        shapeName: 'port hole',
        position: const Offset(87, 65),
        size: const Size(45, 45),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'base',
        shapeType: 'Trapezoid',
        shapeName: 'engine base',
        position: const Offset(65, 140),
        size: const Size(90, 40),
        color: Colors.teal,
      ),
      ObjectPart(
        id: 'fin_left',
        shapeType: 'Triangle',
        shapeName: 'left fin',
        position: const Offset(35, 110),
        size: const Size(40, 60),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'fin_right',
        shapeType: 'Triangle',
        shapeName: 'right fin',
        position: const Offset(145, 110),
        size: const Size(40, 60),
        color: Colors.red,
      ),
    ],
  ),

  // Object 5: Fish 🐟 - with gills and extra fin
  ObjectTemplate(
    name: 'Fish',
    emoji: '🐟',
    parts: [
      ObjectPart(
        id: 'body',
        shapeType: 'Oval',
        shapeName: 'fish body',
        position: const Offset(20, 50),
        size: const Size(140, 90),
        color: Colors.orange,
      ),
      ObjectPart(
        id: 'gill',
        shapeType: 'Crescent',
        shapeName: 'gill',
        position: const Offset(60, 65),
        size: const Size(30, 60),
        color: Colors.amber,
      ),
      ObjectPart(
        id: 'tail',
        shapeType: 'Triangle',
        shapeName: 'tail fin',
        position: const Offset(150, 60),
        size: const Size(55, 70),
        color: Colors.orange,
      ),
      ObjectPart(
        id: 'eye',
        shapeType: 'Circle',
        shapeName: 'fish eye',
        position: const Offset(45, 75),
        size: const Size(25, 25),
        color: Colors.yellow,
      ),
      ObjectPart(
        id: 'pupil',
        shapeType: 'Circle',
        shapeName: 'pupil',
        position: const Offset(52, 82),
        size: const Size(10, 10),
        color: Colors.brown,
      ),
    ],
  ),

  // Object 6: Boat ⛵ - with Trapezoid hull
  ObjectTemplate(
    name: 'Boat',
    emoji: '⛵',
    parts: [
      ObjectPart(
        id: 'mast',
        shapeType: 'Rectangle',
        shapeName: 'mast',
        position: const Offset(105, 10),
        size: const Size(8, 110),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'sail',
        shapeType: 'Triangle',
        shapeName: 'sail',
        position: const Offset(70, 10),
        size: const Size(100, 100),
        color: Colors.cyan,
      ),
      ObjectPart(
        id: 'hull',
        shapeType: 'Trapezoid',
        shapeName: 'boat hull',
        position: const Offset(30, 110),
        size: const Size(160, 60),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'window_hull',
        shapeType: 'Circle',
        shapeName: 'porthole',
        position: const Offset(70, 125),
        size: const Size(25, 25),
        color: Colors.yellow,
      ),
    ],
  ),

  // Object 7: Airplane ✈️ - [NEW] Parallelogram wings
  ObjectTemplate(
    name: 'Airplane',
    emoji: '✈️',
    parts: [
      ObjectPart(
        id: 'body',
        shapeType: 'Oval',
        shapeName: 'fuselage',
        position: const Offset(20, 80),
        size: const Size(180, 45),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'wing_top',
        shapeType: 'Parallelogram',
        shapeName: 'top wing',
        position: const Offset(60, 30),
        size: const Size(70, 70),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wing_bottom',
        shapeType: 'Parallelogram',
        shapeName: 'bottom wing',
        position: const Offset(60, 95),
        size: const Size(70, 70),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'tail',
        shapeType: 'Triangle',
        shapeName: 'tail',
        position: const Offset(160, 60),
        size: const Size(40, 50),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'nose',
        shapeType: 'Semicircle',
        shapeName: 'nose cone',
        position: const Offset(10, 70),
        size: const Size(30, 65),
        color: Colors.orange,
      ),
    ],
  ),

  // Object 8: Castle 🏰 - [NEW] Complex building
  ObjectTemplate(
    name: 'Castle',
    emoji: '🏰',
    parts: [
      ObjectPart(
        id: 'base',
        shapeType: 'Rectangle',
        shapeName: 'main wall',
        position: const Offset(40, 90),
        size: const Size(140, 90),
        color: Colors.amber,
      ),
      ObjectPart(
        id: 'tower_left',
        shapeType: 'Rectangle',
        shapeName: 'left tower',
        position: const Offset(30, 40),
        size: const Size(35, 140),
        color: Colors.amber,
      ),
      ObjectPart(
        id: 'tower_right',
        shapeType: 'Rectangle',
        shapeName: 'right tower',
        position: const Offset(155, 40),
        size: const Size(35, 140),
        color: Colors.amber,
      ),
      ObjectPart(
        id: 'gate',
        shapeType: 'Semicircle',
        shapeName: 'castle gate',
        position: const Offset(85, 130),
        size: const Size(50, 50),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'roof_left',
        shapeType: 'Triangle',
        shapeName: 'left roof',
        position: const Offset(22, 5),
        size: const Size(50, 45),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'roof_right',
        shapeType: 'Triangle',
        shapeName: 'right roof',
        position: const Offset(147, 5),
        size: const Size(50, 45),
        color: Colors.purple,
      ),
    ],
  ),

  // Object 9: Robot 🤖 - [NEW] Square and Rectangle based
  ObjectTemplate(
    name: 'Robot',
    emoji: '🤖',
    parts: [
      ObjectPart(
        id: 'body',
        shapeType: 'Square',
        shapeName: 'robot body',
        position: const Offset(65, 70),
        size: const Size(90, 80),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'head',
        shapeType: 'Circle',
        shapeName: 'robot head',
        position: const Offset(80, 15),
        size: const Size(60, 60),
        color: Colors.cyan,
      ),
      ObjectPart(
        id: 'neck',
        shapeType: 'Rectangle',
        shapeName: 'neck',
        position: const Offset(102, 65),
        size: const Size(16, 12),
        color: Colors.teal,
      ),
      ObjectPart(
        id: 'antenna',
        shapeType: 'Rectangle',
        shapeName: 'antenna',
        position: const Offset(107, -5),
        size: const Size(6, 25),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'button',
        shapeType: 'Circle',
        shapeName: 'power button',
        position: const Offset(95, 100),
        size: const Size(30, 30),
        color: Colors.yellow,
      ),
    ],
  ),

  // Object 10: Train 🚂 - [NEW] Engine
  ObjectTemplate(
    name: 'Train',
    emoji: '🚂',
    parts: [
      ObjectPart(
        id: 'cabin',
        shapeType: 'Square',
        shapeName: 'engine cabin',
        position: const Offset(30, 60),
        size: const Size(80, 80),
        color: Colors.red,
      ),
      ObjectPart(
        id: 'boiler',
        shapeType: 'Rectangle',
        shapeName: 'boiler',
        position: const Offset(105, 90),
        size: const Size(90, 50),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'smokestack',
        shapeType: 'Trapezoid',
        shapeName: 'smoke stack',
        position: const Offset(155, 55),
        size: const Size(30, 45),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'wheel_big',
        shapeType: 'Circle',
        shapeName: 'big wheel',
        position: const Offset(35, 130),
        size: const Size(60, 60),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wheel_small',
        shapeType: 'Circle',
        shapeName: 'small wheel',
        position: const Offset(130, 140),
        size: const Size(45, 45),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'window',
        shapeType: 'Square',
        shapeName: 'cabin window',
        position: const Offset(45, 75),
        size: const Size(40, 40),
        color: Colors.cyan,
      ),
    ],
  ),

  // Object 11: Flower 🌸 - realistic petals and leaves
  ObjectTemplate(
    name: 'Flower',
    emoji: '🌸',
    parts: [
      ObjectPart(
        id: 'stem',
        shapeType: 'Rectangle',
        shapeName: 'stem',
        position: const Offset(105, 100),
        size: const Size(12, 100),
        color: Colors.green,
      ),
      ObjectPart(
        id: 'leaf_left',
        shapeType: 'Crescent',
        shapeName: 'leaf',
        position: const Offset(75, 120),
        size: const Size(35, 35),
        color: Colors.green,
      ),
      ObjectPart(
        id: 'petal_1',
        shapeType: 'Circle',
        shapeName: 'petal',
        position: const Offset(85, 20),
        size: const Size(50, 50),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'petal_2',
        shapeType: 'Circle',
        shapeName: 'petal',
        position: const Offset(115, 45),
        size: const Size(50, 50),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'petal_3',
        shapeType: 'Circle',
        shapeName: 'petal',
        position: const Offset(100, 85),
        size: const Size(50, 50),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'petal_4',
        shapeType: 'Circle',
        shapeName: 'petal',
        position: const Offset(60, 80),
        size: const Size(50, 50),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'petal_5',
        shapeType: 'Circle',
        shapeName: 'petal',
        position: const Offset(50, 40),
        size: const Size(50, 50),
        color: Colors.pink,
      ),
      ObjectPart(
        id: 'center',
        shapeType: 'Circle',
        shapeName: 'flower center',
        position: const Offset(80, 50),
        size: const Size(60, 60),
        color: Colors.yellow,
      ),
    ],
  ),

  // Object 12: Butterfly 🦋 - better wing structure
  ObjectTemplate(
    name: 'Butterfly',
    emoji: '🦋',
    parts: [
      ObjectPart(
        id: 'wing_tl',
        shapeType: 'Semicircle',
        shapeName: 'top wing',
        position: const Offset(20, 15),
        size: const Size(90, 80),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wing_tr',
        shapeType: 'Semicircle',
        shapeName: 'top wing',
        position: const Offset(110, 15),
        size: const Size(90, 80),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wing_bl',
        shapeType: 'Circle',
        shapeName: 'bottom wing',
        position: const Offset(35, 90),
        size: const Size(70, 70),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wing_br',
        shapeType: 'Circle',
        shapeName: 'bottom wing',
        position: const Offset(115, 90),
        size: const Size(70, 70),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'body',
        shapeType: 'Oval',
        shapeName: 'butterfly body',
        position: const Offset(95, 30),
        size: const Size(30, 130),
        color: Colors.brown,
      ),
      ObjectPart(
        id: 'spot_left',
        shapeType: 'Circle',
        shapeName: 'wing spot',
        position: const Offset(50, 40),
        size: const Size(20, 20),
        color: Colors.yellow,
      ),
      ObjectPart(
        id: 'spot_right',
        shapeType: 'Circle',
        shapeName: 'wing spot',
        position: const Offset(150, 40),
        size: const Size(20, 20),
        color: Colors.yellow,
      ),
    ],
  ),

  // Object 13: Truck 🚚 - realistic delivery truck
  ObjectTemplate(
    name: 'Truck',
    emoji: '🚚',
    parts: [
      ObjectPart(
        id: 'cargo',
        shapeType: 'Rectangle',
        shapeName: 'cargo box',
        position: const Offset(10, 40),
        size: const Size(140, 90),
        color: Colors.orange,
      ),
      ObjectPart(
        id: 'cabin',
        shapeType: 'Trapezoid',
        shapeName: 'truck cabin',
        position: const Offset(145, 60),
        size: const Size(65, 70),
        color: Colors.blue,
      ),
      ObjectPart(
        id: 'window',
        shapeType: 'Square',
        shapeName: 'cabin window',
        position: const Offset(165, 75),
        size: const Size(30, 30),
        color: Colors.cyan,
      ),
      ObjectPart(
        id: 'wheel_1',
        shapeType: 'Circle',
        shapeName: 'wheel',
        position: const Offset(30, 120),
        size: const Size(40, 40),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wheel_2',
        shapeType: 'Circle',
        shapeName: 'wheel',
        position: const Offset(100, 120),
        size: const Size(40, 40),
        color: Colors.purple,
      ),
      ObjectPart(
        id: 'wheel_3',
        shapeType: 'Circle',
        shapeName: 'wheel',
        position: const Offset(160, 120),
        size: const Size(40, 40),
        color: Colors.purple,
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

    // Only add colors that are actually used in the object to avoid "extra plates"
    for (var part in state.currentObject.parts) {
      final option = findMatchingColor(part);
      if (option != null && !colorIds.contains(option.id)) {
        colorIds.add(option.id);
        colors.add(option);
      }
    }

    // Shuffle the final list so they are not always in the same order
    colors.shuffle(Random());
    return colors;
  }
}

final objectPainterProvider = NotifierProvider<ObjectPainterNotifier, ObjectPainterState>(() {
  return ObjectPainterNotifier();
}, isAutoDispose: true);

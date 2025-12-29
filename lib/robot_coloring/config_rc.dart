import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single part of the robot with its shape and solid color
class RobotPainterPart {
  final String id;
  final String shapeType; // RobotHead, Gear, Claw, Antenna, Bolt, etc.
  final Offset position; // Relative position in the robot layout
  final Size size;
  final Color color; // Solid color - no gradients

  const RobotPainterPart({
    required this.id,
    required this.shapeType,
    required this.position,
    required this.size,
    required this.color,
  });
}

/// A robot template with all its parts (custom for painting game)
class RobotPainterTemplate {
  final String name;
  final List<RobotPainterPart> parts;

  const RobotPainterTemplate({required this.name, required this.parts});
}

/// Custom robot templates using Robot Builder style shapes with solid colors
final List<RobotPainterTemplate> painterRobotTemplates = [
  // Robot 1: Buddy Bot - Friendly helper robot
  RobotPainterTemplate(
    name: 'Buddy Bot',
    parts: [
      RobotPainterPart(
        id: 'head',
        shapeType: 'RobotHead',
        position: const Offset(70, 15),
        size: const Size(80, 80),
        color: Colors.blue,
      ),
      RobotPainterPart(
        id: 'antenna',
        shapeType: 'Antenna',
        position: const Offset(95, 0),
        size: const Size(28, 28),
        color: Colors.orange,
      ),
      RobotPainterPart(
        id: 'body',
        shapeType: 'RobotPanel',
        position: const Offset(55, 100),
        size: const Size(110, 75),
        color: Colors.red,
      ),
      RobotPainterPart(
        id: 'left_arm',
        shapeType: 'Claw',
        position: const Offset(0, 105),
        size: const Size(50, 50),
        color: Colors.green,
      ),
      RobotPainterPart(
        id: 'right_arm',
        shapeType: 'Claw',
        position: const Offset(170, 105),
        size: const Size(50, 50),
        color: Colors.green,
      ),
      RobotPainterPart(
        id: 'left_leg',
        shapeType: 'Gear',
        position: const Offset(58, 178),
        size: const Size(48, 48),
        color: Colors.purple,
      ),
      RobotPainterPart(
        id: 'right_leg',
        shapeType: 'Gear',
        position: const Offset(114, 178),
        size: const Size(48, 48),
        color: Colors.purple,
      ),
    ],
  ),

  // Robot 2: Spark Bot - Electric robot
  RobotPainterTemplate(
    name: 'Spark Bot',
    parts: [
      RobotPainterPart(
        id: 'head',
        shapeType: 'SemiCircle',
        position: const Offset(70, 5),
        size: const Size(80, 50),
        color: Colors.cyan,
      ),
      RobotPainterPart(
        id: 'body',
        shapeType: 'Hexagon',
        position: const Offset(55, 58),
        size: const Size(110, 85),
        color: Colors.blue,
      ),
      RobotPainterPart(
        id: 'left_arm',
        shapeType: 'Bolt',
        position: const Offset(2, 75),
        size: const Size(45, 52),
        color: Colors.yellow,
      ),
      RobotPainterPart(
        id: 'right_arm',
        shapeType: 'Bolt',
        position: const Offset(173, 75),
        size: const Size(45, 52),
        color: Colors.yellow,
      ),
      RobotPainterPart(
        id: 'left_leg',
        shapeType: 'Rectangle',
        position: const Offset(68, 148),
        size: const Size(35, 50),
        color: Colors.indigo,
      ),
      RobotPainterPart(
        id: 'right_leg',
        shapeType: 'Rectangle',
        position: const Offset(117, 148),
        size: const Size(35, 50),
        color: Colors.indigo,
      ),
    ],
  ),

  // Robot 3: Star Bot - Space explorer
  RobotPainterTemplate(
    name: 'Star Bot',
    parts: [
      RobotPainterPart(
        id: 'head',
        shapeType: 'Star',
        position: const Offset(70, 0),
        size: const Size(80, 80),
        color: Colors.amber,
      ),
      RobotPainterPart(
        id: 'body',
        shapeType: 'Oval',
        position: const Offset(45, 82),
        size: const Size(130, 85),
        color: Colors.teal,
      ),
      RobotPainterPart(
        id: 'left_arm',
        shapeType: 'Triangle',
        position: const Offset(0, 92),
        size: const Size(48, 48),
        color: Colors.orange,
      ),
      RobotPainterPart(
        id: 'right_arm',
        shapeType: 'Triangle',
        position: const Offset(172, 92),
        size: const Size(48, 48),
        color: Colors.orange,
      ),
      RobotPainterPart(
        id: 'left_leg',
        shapeType: 'Gear',
        position: const Offset(52, 172),
        size: const Size(52, 52),
        color: Colors.grey,
      ),
      RobotPainterPart(
        id: 'right_leg',
        shapeType: 'Gear',
        position: const Offset(116, 172),
        size: const Size(52, 52),
        color: Colors.grey,
      ),
    ],
  ),

  // Robot 4: Claw Bot - Builder robot
  RobotPainterTemplate(
    name: 'Claw Bot',
    parts: [
      RobotPainterPart(
        id: 'head',
        shapeType: 'RobotHead',
        position: const Offset(75, 12),
        size: const Size(70, 70),
        color: Colors.lime,
      ),
      RobotPainterPart(
        id: 'antenna',
        shapeType: 'Antenna',
        position: const Offset(96, 0),
        size: const Size(26, 26),
        color: Colors.red,
      ),
      RobotPainterPart(
        id: 'body',
        shapeType: 'Square',
        position: const Offset(55, 85),
        size: const Size(110, 85),
        color: Colors.green,
      ),
      RobotPainterPart(
        id: 'left_arm',
        shapeType: 'Claw',
        position: const Offset(0, 95),
        size: const Size(52, 52),
        color: Colors.brown,
      ),
      RobotPainterPart(
        id: 'right_arm',
        shapeType: 'Claw',
        position: const Offset(168, 95),
        size: const Size(52, 52),
        color: Colors.brown,
      ),
      RobotPainterPart(
        id: 'left_leg',
        shapeType: 'Bolt',
        position: const Offset(62, 175),
        size: const Size(42, 52),
        color: Colors.pink,
      ),
      RobotPainterPart(
        id: 'right_leg',
        shapeType: 'Bolt',
        position: const Offset(116, 175),
        size: const Size(42, 52),
        color: Colors.pink,
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
  ColorOption(id: 'lime', name: 'Lime', color: Colors.lime, emoji: '🍀'),
  ColorOption(id: 'teal', name: 'Teal', color: Colors.teal, emoji: '🌊'),
  ColorOption(id: 'cyan', name: 'Cyan', color: Colors.cyan, emoji: '💎'),
  ColorOption(id: 'blue', name: 'Blue', color: Colors.blue, emoji: '💙'),
  ColorOption(id: 'indigo', name: 'Indigo', color: Colors.indigo, emoji: '🔮'),
  ColorOption(id: 'purple', name: 'Purple', color: Colors.purple, emoji: '💜'),
  ColorOption(id: 'brown', name: 'Brown', color: Colors.brown, emoji: '🟤'),
  ColorOption(id: 'grey', name: 'Grey', color: Colors.grey, emoji: '🩶'),
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
enum RobotColoringPhase { learning, coloring, success }

/// Game state for Robot Coloring
class RobotColoringState {
  final RobotPainterTemplate currentRobot;
  final RobotColoringPhase phase;
  final Map<String, Color?> coloredParts; // partId -> applied color
  final Color? selectedColor; // Currently selected color from palette
  final String? selectedColorName; // Name of selected color for TTS
  final int score;
  final int totalRobots;
  final int currentRobotIndex;

  const RobotColoringState({
    required this.currentRobot,
    required this.phase,
    required this.coloredParts,
    this.selectedColor,
    this.selectedColorName,
    required this.score,
    required this.totalRobots,
    required this.currentRobotIndex,
  });

  factory RobotColoringState.initial() {
    final robot = painterRobotTemplates[0];
    return RobotColoringState(
      currentRobot: robot,
      phase: RobotColoringPhase.learning,
      coloredParts: {for (var part in robot.parts) part.id: null},
      selectedColor: null,
      selectedColorName: null,
      score: 0,
      totalRobots: painterRobotTemplates.length,
      currentRobotIndex: 0,
    );
  }

  /// Check if all parts are colored correctly
  bool get allPartsColoredCorrectly {
    for (var part in currentRobot.parts) {
      final appliedColor = coloredParts[part.id];
      if (appliedColor == null) return false;
      if (!colorsMatch(appliedColor, part.color)) return false;
    }
    return true;
  }

  /// Check if a specific part is colored correctly
  bool isPartCorrect(String partId) {
    final part = currentRobot.parts.firstWhere((p) => p.id == partId);
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
    for (var part in currentRobot.parts) {
      if (isPartCorrect(part.id)) count++;
    }
    return count;
  }

  /// Helper to match colors (exact match for solid colors)
  static bool colorsMatch(Color a, Color b) {
    return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
  }

  RobotColoringState copyWith({
    RobotPainterTemplate? currentRobot,
    RobotColoringPhase? phase,
    Map<String, Color?>? coloredParts,
    Color? selectedColor,
    String? selectedColorName,
    int? score,
    int? totalRobots,
    int? currentRobotIndex,
    bool clearSelectedColor = false,
  }) {
    return RobotColoringState(
      currentRobot: currentRobot ?? this.currentRobot,
      phase: phase ?? this.phase,
      coloredParts: coloredParts ?? this.coloredParts,
      selectedColor: clearSelectedColor ? null : (selectedColor ?? this.selectedColor),
      selectedColorName: clearSelectedColor ? null : (selectedColorName ?? this.selectedColorName),
      score: score ?? this.score,
      totalRobots: totalRobots ?? this.totalRobots,
      currentRobotIndex: currentRobotIndex ?? this.currentRobotIndex,
    );
  }
}

/// State notifier for Robot Coloring game
class RobotColoringNotifier extends Notifier<RobotColoringState> {
  @override
  RobotColoringState build() {
    return RobotColoringState.initial();
  }

  /// Start a new game from the beginning
  void startNewGame() {
    state = RobotColoringState.initial();
  }

  /// Transition from learning to coloring phase
  void goToColoring() {
    state = state.copyWith(phase: RobotColoringPhase.coloring);
  }

  /// Select a color from the palette
  void selectColor(Color color, String colorName) {
    state = state.copyWith(selectedColor: color, selectedColorName: colorName);
  }

  /// Apply selected color to a robot part
  /// Returns: 'correct', 'incorrect', or 'no_color' (if no color selected)
  /// IMPORTANT: Wrong colors are NOT applied - only correct colors get colored
  String colorPart(String partId) {
    if (state.selectedColor == null) {
      return 'no_color';
    }

    // Check if the color is correct BEFORE applying
    final part = state.currentRobot.parts.firstWhere((p) => p.id == partId);
    final isCorrect = RobotColoringState.colorsMatch(state.selectedColor!, part.color);

    if (!isCorrect) {
      // Wrong color - don't apply it, just return incorrect
      return 'incorrect';
    }

    // Correct color - apply it
    final newColoredParts = Map<String, Color?>.from(state.coloredParts);
    newColoredParts[partId] = state.selectedColor;

    state = state.copyWith(coloredParts: newColoredParts);

    // Check if all parts are now correctly colored
    if (state.allPartsColoredCorrectly) {
      state = state.copyWith(
        phase: RobotColoringPhase.success,
        score: state.score + 1,
        clearSelectedColor: true,
      );
    }

    return 'correct';
  }

  /// Move to next robot
  void nextRobot() {
    final nextIndex = (state.currentRobotIndex + 1) % painterRobotTemplates.length;
    final nextRobot = painterRobotTemplates[nextIndex];

    if (nextIndex == 0) {
      // Completed all robots - restart the game
      state = RobotColoringState.initial();
    } else {
      state = RobotColoringState(
        currentRobot: nextRobot,
        phase: RobotColoringPhase.learning,
        coloredParts: {for (var part in nextRobot.parts) part.id: null},
        selectedColor: null,
        selectedColorName: null,
        score: state.score,
        totalRobots: state.totalRobots,
        currentRobotIndex: nextIndex,
      );
    }
  }

  /// Find the matching color option for a robot part
  ColorOption? findMatchingColor(RobotPainterPart part) {
    for (var option in colorPalette) {
      if (RobotColoringState.colorsMatch(option.color, part.color)) {
        return option;
      }
    }
    return null;
  }

  /// Get unique colors needed for current robot
  List<ColorOption> getColorsForRobot() {
    final Set<String> colorIds = {};
    final List<ColorOption> colors = [];

    for (var part in state.currentRobot.parts) {
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

final robotColoringProvider = NotifierProvider<RobotColoringNotifier, RobotColoringState>(() {
  return RobotColoringNotifier();
}, isAutoDispose: true);

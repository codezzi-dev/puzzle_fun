import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single part of the robot with its shape and position
class RobotPart {
  final String id;
  final String shapeType; // circle, square, rectangle, triangle, diamond, etc.
  final Offset position; // Relative position in the robot layout
  final Size size;
  final Color color;

  const RobotPart({
    required this.id,
    required this.shapeType,
    required this.position,
    required this.size,
    required this.color,
  });
}

/// A robot template with all its parts
class RobotTemplate {
  final String name;
  final List<RobotPart> parts;

  const RobotTemplate({required this.name, required this.parts});
}

/// Child-friendly robot templates with vibrant colors and personalities
final List<RobotTemplate> robotTemplates = [
  // Robot 1: Friendly helper robot - Buddy Bot (Coral/Pink theme)
  RobotTemplate(
    name: 'Buddy Bot',
    parts: [
      // Head - RobotHead with friendly face
      RobotPart(
        id: 'head',
        shapeType: 'RobotHead',
        position: const Offset(70, 15),
        size: const Size(80, 80),
        color: Colors.pink.shade300,
      ),
      // Antenna - Glowing
      RobotPart(
        id: 'antenna',
        shapeType: 'Antenna',
        position: const Offset(95, 0),
        size: const Size(28, 28),
        color: Colors.pinkAccent.shade100,
      ),
      // Body - RobotPanel with LED
      RobotPart(
        id: 'body',
        shapeType: 'RobotPanel',
        position: const Offset(55, 100),
        size: const Size(110, 75),
        color: Colors.pink.shade200,
      ),
      // Left Arm - Claw
      RobotPart(
        id: 'left_arm',
        shapeType: 'Claw',
        position: const Offset(0, 105),
        size: const Size(50, 50),
        color: Colors.orange.shade400,
      ),
      // Right Arm - Claw
      RobotPart(
        id: 'right_arm',
        shapeType: 'Claw',
        position: const Offset(170, 105),
        size: const Size(50, 50),
        color: Colors.orange.shade400,
      ),
      // Left Leg - Gear
      RobotPart(
        id: 'left_leg',
        shapeType: 'Gear',
        position: const Offset(58, 178),
        size: const Size(48, 48),
        color: Colors.grey.shade500,
      ),
      // Right Leg - Gear
      RobotPart(
        id: 'right_leg',
        shapeType: 'Gear',
        position: const Offset(114, 178),
        size: const Size(48, 48),
        color: Colors.grey.shade500,
      ),
    ],
  ),
  // Robot 2: Electric robot - Spark Bot (Blue/Cyan theme)
  RobotTemplate(
    name: 'Spark Bot',
    parts: [
      // Head - SemiCircle dome with LED eyes
      RobotPart(
        id: 'head',
        shapeType: 'SemiCircle',
        position: const Offset(70, 5),
        size: const Size(80, 50),
        color: Colors.cyan.shade400,
      ),
      // Body - Hexagon
      RobotPart(
        id: 'body',
        shapeType: 'Hexagon',
        position: const Offset(55, 58),
        size: const Size(110, 85),
        color: Colors.blue.shade400,
      ),
      // Left Arm - Bolt (electric connector)
      RobotPart(
        id: 'left_arm',
        shapeType: 'Bolt',
        position: const Offset(2, 75),
        size: const Size(45, 52),
        color: Colors.yellow.shade600,
      ),
      // Right Arm - Bolt
      RobotPart(
        id: 'right_arm',
        shapeType: 'Bolt',
        position: const Offset(173, 75),
        size: const Size(45, 52),
        color: Colors.yellow.shade600,
      ),
      // Left Leg - Rectangle
      RobotPart(
        id: 'left_leg',
        shapeType: 'Rectangle',
        position: const Offset(68, 148),
        size: const Size(35, 50),
        color: Colors.indigo.shade400,
      ),
      // Right Leg - Rectangle
      RobotPart(
        id: 'right_leg',
        shapeType: 'Rectangle',
        position: const Offset(117, 148),
        size: const Size(35, 50),
        color: Colors.indigo.shade400,
      ),
    ],
  ),
  // Robot 3: Space explorer - Star Bot (Yellow/Gold theme)
  RobotTemplate(
    name: 'Star Bot',
    parts: [
      // Head - Star (space helmet vibe)
      RobotPart(
        id: 'head',
        shapeType: 'Star',
        position: const Offset(70, 0),
        size: const Size(80, 80),
        color: Colors.amber.shade400,
      ),
      // Body - Oval (space suit)
      RobotPart(
        id: 'body',
        shapeType: 'Oval',
        position: const Offset(45, 82),
        size: const Size(130, 85),
        color: Colors.teal.shade400,
      ),
      // Left Arm - Triangle (rocket boosters)
      RobotPart(
        id: 'left_arm',
        shapeType: 'Triangle',
        position: const Offset(0, 92),
        size: const Size(48, 48),
        color: Colors.deepOrange.shade400,
      ),
      // Right Arm - Triangle
      RobotPart(
        id: 'right_arm',
        shapeType: 'Triangle',
        position: const Offset(172, 92),
        size: const Size(48, 48),
        color: Colors.deepOrange.shade400,
      ),
      // Left Leg - Gear (space wheels)
      RobotPart(
        id: 'left_leg',
        shapeType: 'Gear',
        position: const Offset(52, 172),
        size: const Size(52, 52),
        color: Colors.blueGrey.shade500,
      ),
      // Right Leg - Gear
      RobotPart(
        id: 'right_leg',
        shapeType: 'Gear',
        position: const Offset(116, 172),
        size: const Size(52, 52),
        color: Colors.blueGrey.shade500,
      ),
    ],
  ),
  // Robot 4: Builder robot - Claw Bot (Green/Lime theme)
  RobotTemplate(
    name: 'Claw Bot',
    parts: [
      // Head - Circle with friendly face
      RobotPart(
        id: 'head',
        shapeType: 'RobotHead',
        position: const Offset(75, 12),
        size: const Size(70, 70),
        color: Colors.lime.shade400,
      ),
      // Antenna - Signal beacon
      RobotPart(
        id: 'antenna',
        shapeType: 'Antenna',
        position: const Offset(96, 0),
        size: const Size(26, 26),
        color: Colors.red.shade400,
      ),
      // Body - Square (sturdy construction)
      RobotPart(
        id: 'body',
        shapeType: 'Square',
        position: const Offset(55, 85),
        size: const Size(110, 85),
        color: Colors.green.shade400,
      ),
      // Left Arm - Claw (grabber)
      RobotPart(
        id: 'left_arm',
        shapeType: 'Claw',
        position: const Offset(0, 95),
        size: const Size(52, 52),
        color: Colors.brown.shade400,
      ),
      // Right Arm - Claw
      RobotPart(
        id: 'right_arm',
        shapeType: 'Claw',
        position: const Offset(168, 95),
        size: const Size(52, 52),
        color: Colors.brown.shade400,
      ),
      // Left Leg - Bolt (sturdy support)
      RobotPart(
        id: 'left_leg',
        shapeType: 'Bolt',
        position: const Offset(62, 175),
        size: const Size(42, 52),
        color: Colors.grey.shade600,
      ),
      // Right Leg - Bolt
      RobotPart(
        id: 'right_leg',
        shapeType: 'Bolt',
        position: const Offset(116, 175),
        size: const Size(42, 52),
        color: Colors.grey.shade600,
      ),
    ],
  ),
];

enum RobotBuilderPhase { learning, building, success }

class RobotBuilderState {
  final RobotTemplate currentRobot;
  final RobotBuilderPhase phase;
  final Map<String, bool> placedParts; // Which SLOTS have been filled
  final Set<String> usedDraggables; // Which DRAGGABLES have been used
  final int score;
  final int totalRobots;
  final int currentRobotIndex;

  const RobotBuilderState({
    required this.currentRobot,
    required this.phase,
    required this.placedParts,
    required this.usedDraggables,
    required this.score,
    required this.totalRobots,
    required this.currentRobotIndex,
  });

  factory RobotBuilderState.initial() {
    final robot = robotTemplates[0];
    return RobotBuilderState(
      currentRobot: robot,
      phase: RobotBuilderPhase.learning,
      placedParts: {for (var part in robot.parts) part.id: false},
      usedDraggables: {},
      score: 0,
      totalRobots: robotTemplates.length,
      currentRobotIndex: 0,
    );
  }

  bool get allPartsPlaced => placedParts.values.every((placed) => placed);

  int get placedCount => placedParts.values.where((p) => p).length;

  RobotBuilderState copyWith({
    RobotTemplate? currentRobot,
    RobotBuilderPhase? phase,
    Map<String, bool>? placedParts,
    Set<String>? usedDraggables,
    int? score,
    int? totalRobots,
    int? currentRobotIndex,
  }) {
    return RobotBuilderState(
      currentRobot: currentRobot ?? this.currentRobot,
      phase: phase ?? this.phase,
      placedParts: placedParts ?? this.placedParts,
      usedDraggables: usedDraggables ?? this.usedDraggables,
      score: score ?? this.score,
      totalRobots: totalRobots ?? this.totalRobots,
      currentRobotIndex: currentRobotIndex ?? this.currentRobotIndex,
    );
  }
}

class RobotBuilderNotifier extends Notifier<RobotBuilderState> {
  final Random _random = Random();

  @override
  RobotBuilderState build() {
    return RobotBuilderState.initial();
  }

  void startNewGame() {
    state = RobotBuilderState.initial();
  }

  void goToBuilding() {
    state = state.copyWith(phase: RobotBuilderPhase.building);
  }

  void placePartInSlot(String slotId, String draggedId) {
    // Mark the slot as filled
    final newPlacedParts = Map<String, bool>.from(state.placedParts);
    newPlacedParts[slotId] = true;

    // Mark the dragged item as used
    final newUsedDraggables = Set<String>.from(state.usedDraggables);
    newUsedDraggables.add(draggedId);

    state = state.copyWith(placedParts: newPlacedParts, usedDraggables: newUsedDraggables);

    // Check if all parts are placed
    if (state.allPartsPlaced) {
      state = state.copyWith(phase: RobotBuilderPhase.success, score: state.score + 1);
    }
  }

  // Keep old method for compatibility
  void placePart(String partId) {
    placePartInSlot(partId, partId);
  }

  void nextRobot() {
    final nextIndex = (state.currentRobotIndex + 1) % robotTemplates.length;
    final nextRobot = robotTemplates[nextIndex];

    if (nextIndex == 0) {
      // Completed all robots - restart
      state = RobotBuilderState.initial();
    } else {
      state = RobotBuilderState(
        currentRobot: nextRobot,
        phase: RobotBuilderPhase.learning,
        placedParts: {for (var part in nextRobot.parts) part.id: false},
        usedDraggables: {},
        score: state.score,
        totalRobots: state.totalRobots,
        currentRobotIndex: nextIndex,
      );
    }
  }

  /// Get shuffled list of parts for drag options
  List<RobotPart> getShuffledParts() {
    final parts = List<RobotPart>.from(state.currentRobot.parts);
    parts.shuffle(_random);
    return parts;
  }
}

final robotBuilderProvider = NotifierProvider<RobotBuilderNotifier, RobotBuilderState>(() {
  return RobotBuilderNotifier();
}, isAutoDispose: true);

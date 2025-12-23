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

/// Predefined robot templates with robot-specific shapes
final List<RobotTemplate> robotTemplates = [
  // Robot 1: Classic robot with gears and claws
  RobotTemplate(
    name: 'Gear Bot',
    parts: [
      // Head - Circle with antenna on top conceptually
      const RobotPart(id: 'head', shapeType: 'Circle', position: Offset(75, 20), size: Size(70, 70), color: Colors.blue),
      // Antenna
      const RobotPart(id: 'antenna', shapeType: 'Antenna', position: Offset(97, 0), size: Size(25, 25), color: Colors.lightBlue),
      // Body - Rectangle
      const RobotPart(id: 'body', shapeType: 'Rectangle', position: Offset(60, 95), size: Size(100, 70), color: Colors.blueGrey),
      // Left Arm - Claw
      const RobotPart(id: 'left_arm', shapeType: 'Claw', position: Offset(5, 100), size: Size(50, 50), color: Colors.orange),
      // Right Arm - Claw
      const RobotPart(id: 'right_arm', shapeType: 'Claw', position: Offset(165, 100), size: Size(50, 50), color: Colors.orange),
      // Left Leg - Gear
      const RobotPart(id: 'left_leg', shapeType: 'Gear', position: Offset(60, 170), size: Size(45, 45), color: Colors.grey),
      // Right Leg - Gear
      const RobotPart(id: 'right_leg', shapeType: 'Gear', position: Offset(115, 170), size: Size(45, 45), color: Colors.grey),
    ],
  ),
  // Robot 2: Mechanical robot with bolts
  RobotTemplate(
    name: 'Bolt Bot',
    parts: [
      // Head - SemiCircle dome
      const RobotPart(id: 'head', shapeType: 'SemiCircle', position: Offset(70, 10), size: Size(80, 50), color: Colors.purple),
      // Body - Hexagon
      const RobotPart(id: 'body', shapeType: 'Hexagon', position: Offset(55, 65), size: Size(110, 90), color: Colors.deepPurple),
      // Left Arm - Bolt
      const RobotPart(id: 'left_arm', shapeType: 'Bolt', position: Offset(5, 80), size: Size(45, 50), color: Colors.amber),
      // Right Arm - Bolt
      const RobotPart(id: 'right_arm', shapeType: 'Bolt', position: Offset(170, 80), size: Size(45, 50), color: Colors.amber),
      // Left Leg - Rectangle
      const RobotPart(id: 'left_leg', shapeType: 'Rectangle', position: Offset(65, 160), size: Size(35, 55), color: Colors.indigo),
      // Right Leg - Rectangle
      const RobotPart(id: 'right_leg', shapeType: 'Rectangle', position: Offset(120, 160), size: Size(35, 55), color: Colors.indigo),
    ],
  ),
  // Robot 3: Space robot with star head
  RobotTemplate(
    name: 'Star Bot',
    parts: [
      // Head - Star
      const RobotPart(id: 'head', shapeType: 'Star', position: Offset(72, 0), size: Size(75, 75), color: Colors.amber),
      // Body - Oval
      const RobotPart(id: 'body', shapeType: 'Oval', position: Offset(50, 80), size: Size(120, 80), color: Colors.cyan),
      // Left Arm - Triangle
      const RobotPart(id: 'left_arm', shapeType: 'Triangle', position: Offset(0, 90), size: Size(45, 45), color: Colors.teal),
      // Right Arm - Triangle
      const RobotPart(id: 'right_arm', shapeType: 'Triangle', position: Offset(175, 90), size: Size(45, 45), color: Colors.teal),
      // Left Leg - Gear
      const RobotPart(id: 'left_leg', shapeType: 'Gear', position: Offset(55, 165), size: Size(50, 50), color: Colors.blueGrey),
      // Right Leg - Gear
      const RobotPart(id: 'right_leg', shapeType: 'Gear', position: Offset(115, 165), size: Size(50, 50), color: Colors.blueGrey),
    ],
  ),
  // Robot 4: Construction robot
  RobotTemplate(
    name: 'Claw Bot',
    parts: [
      // Head - Circle
      const RobotPart(id: 'head', shapeType: 'Circle', position: Offset(80, 15), size: Size(60, 60), color: Colors.yellow),
      // Antenna
      const RobotPart(id: 'antenna', shapeType: 'Antenna', position: Offset(98, 0), size: Size(22, 22), color: Colors.red),
      // Body - Square
      const RobotPart(id: 'body', shapeType: 'Square', position: Offset(60, 80), size: Size(100, 80), color: Colors.orange),
      // Left Arm - Claw
      const RobotPart(id: 'left_arm', shapeType: 'Claw', position: Offset(5, 90), size: Size(50, 50), color: Colors.brown),
      // Right Arm - Claw
      const RobotPart(id: 'right_arm', shapeType: 'Claw', position: Offset(165, 90), size: Size(50, 50), color: Colors.brown),
      // Left Leg - Bolt
      const RobotPart(id: 'left_leg', shapeType: 'Bolt', position: Offset(65, 165), size: Size(40, 50), color: Colors.grey),
      // Right Leg - Bolt
      const RobotPart(id: 'right_leg', shapeType: 'Bolt', position: Offset(115, 165), size: Size(40, 50), color: Colors.grey),
    ],
  ),
];

enum RobotBuilderPhase { learning, building, success }

class RobotBuilderState {
  final RobotTemplate currentRobot;
  final RobotBuilderPhase phase;
  final Map<String, bool> placedParts; // Which parts have been correctly placed
  final int score;
  final int totalRobots;
  final int currentRobotIndex;

  const RobotBuilderState({
    required this.currentRobot,
    required this.phase,
    required this.placedParts,
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
    int? score,
    int? totalRobots,
    int? currentRobotIndex,
  }) {
    return RobotBuilderState(
      currentRobot: currentRobot ?? this.currentRobot,
      phase: phase ?? this.phase,
      placedParts: placedParts ?? this.placedParts,
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

  void placePart(String partId) {
    final newPlacedParts = Map<String, bool>.from(state.placedParts);
    newPlacedParts[partId] = true;

    state = state.copyWith(placedParts: newPlacedParts);

    // Check if all parts are placed
    if (state.allPartsPlaced) {
      state = state.copyWith(phase: RobotBuilderPhase.success, score: state.score + 1);
    }
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A match item representing a color with its properties
class MatchItem {
  final String id;
  final String name;
  final Color color;
  final String emoji;

  const MatchItem({required this.id, required this.name, required this.color, required this.emoji});
}

/// List of colorful, child-friendly colors
const List<MatchItem> colorPalette = [
  MatchItem(id: 'red', name: 'Red', color: Colors.red, emoji: '❤️'),
  MatchItem(id: 'blue', name: 'Blue', color: Colors.blue, emoji: '💙'),
  MatchItem(id: 'green', name: 'Green', color: Colors.green, emoji: '💚'),
  MatchItem(id: 'yellow', name: 'Yellow', color: Colors.amber, emoji: '💛'),
  MatchItem(id: 'orange', name: 'Orange', color: Colors.orange, emoji: '🧡'),
  MatchItem(id: 'purple', name: 'Purple', color: Colors.purple, emoji: '💜'),
  MatchItem(id: 'pink', name: 'Pink', color: Colors.pink, emoji: '💗'),
  MatchItem(id: 'teal', name: 'Teal', color: Colors.teal, emoji: '🩵'),
];

/// List of shape types for the right side
const List<String> shapeTypes = [
  'Circle',
  'Square',
  'Triangle',
  'Star',
  'Diamond',
  'Hexagon',
  'Pentagon',
  'Oval',
];

/// A shape item displayed on the right side with a specific color
class ShapeItem {
  final String id;
  final String shapeType;
  final MatchItem color;

  const ShapeItem({required this.id, required this.shapeType, required this.color});
}

/// A connection between a color (left) and a shape (right)
class Connection {
  final String colorId;
  final String shapeId;
  final bool isCorrect;

  const Connection({required this.colorId, required this.shapeId, required this.isCorrect});
}

enum ColorMatchPhase { playing, success }

class ColorMatchState {
  final List<MatchItem> leftColors; // Colors on left side
  final List<ShapeItem> rightShapes; // Shapes on right side (shuffled)
  final List<Connection> connections; // Made connections
  final String? activeColorId; // Currently dragging from this color
  final Offset? dragPosition; // Current drag position
  final ColorMatchPhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final int itemsPerRound;

  const ColorMatchState({
    required this.leftColors,
    required this.rightShapes,
    required this.connections,
    this.activeColorId,
    this.dragPosition,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.itemsPerRound,
  });

  factory ColorMatchState.initial({int itemsPerRound = 4}) {
    final random = Random();
    final result = _generateRound(random, itemsPerRound);

    return ColorMatchState(
      leftColors: result.colors,
      rightShapes: result.shapes,
      connections: const [],
      activeColorId: null,
      dragPosition: null,
      phase: ColorMatchPhase.playing,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      itemsPerRound: itemsPerRound,
    );
  }

  bool get allMatched => connections.length == leftColors.length;

  bool isColorConnected(String colorId) {
    return connections.any((c) => c.colorId == colorId);
  }

  bool isShapeConnected(String shapeId) {
    return connections.any((c) => c.shapeId == shapeId);
  }

  ColorMatchState copyWith({
    List<MatchItem>? leftColors,
    List<ShapeItem>? rightShapes,
    List<Connection>? connections,
    String? activeColorId,
    Offset? dragPosition,
    ColorMatchPhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    int? itemsPerRound,
    bool clearActiveColor = false,
    bool clearDragPosition = false,
  }) {
    return ColorMatchState(
      leftColors: leftColors ?? this.leftColors,
      rightShapes: rightShapes ?? this.rightShapes,
      connections: connections ?? this.connections,
      activeColorId: clearActiveColor ? null : (activeColorId ?? this.activeColorId),
      dragPosition: clearDragPosition ? null : (dragPosition ?? this.dragPosition),
      phase: phase ?? this.phase,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      itemsPerRound: itemsPerRound ?? this.itemsPerRound,
    );
  }
}

class _RoundResult {
  final List<MatchItem> colors;
  final List<ShapeItem> shapes;

  _RoundResult({required this.colors, required this.shapes});
}

_RoundResult _generateRound(Random random, int count) {
  // Pick random colors
  final shuffledColors = List<MatchItem>.from(colorPalette)..shuffle(random);
  final selectedColors = shuffledColors.take(count).toList();

  // Pick random shapes
  final shuffledShapes = List<String>.from(shapeTypes)..shuffle(random);
  final selectedShapeTypes = shuffledShapes.take(count).toList();

  // Create shapes with matching colors
  final shapes = <ShapeItem>[];
  for (int i = 0; i < count; i++) {
    shapes.add(
      ShapeItem(id: 'shape_$i', shapeType: selectedShapeTypes[i], color: selectedColors[i]),
    );
  }

  // Shuffle shapes so they don't align with colors
  shapes.shuffle(random);

  return _RoundResult(colors: selectedColors, shapes: shapes);
}

class ColorMatchNotifier extends Notifier<ColorMatchState> {
  final Random _random = Random();

  @override
  ColorMatchState build() {
    return ColorMatchState.initial();
  }

  void startNewGame() {
    state = ColorMatchState.initial(itemsPerRound: state.itemsPerRound);
  }

  void startDrag(String colorId, Offset position) {
    if (state.isColorConnected(colorId)) return;
    state = state.copyWith(activeColorId: colorId, dragPosition: position);
  }

  void updateDrag(Offset position) {
    if (state.activeColorId == null) return;
    state = state.copyWith(dragPosition: position);
  }

  void endDrag() {
    state = state.copyWith(clearActiveColor: true, clearDragPosition: true);
  }

  void makeConnection(String colorId, String shapeId) {
    // Check if already connected
    if (state.isColorConnected(colorId) || state.isShapeConnected(shapeId)) {
      endDrag();
      return;
    }

    // Find the color and shape
    final color = state.leftColors.firstWhere((c) => c.id == colorId);
    final shape = state.rightShapes.firstWhere((s) => s.id == shapeId);

    // Check if match is correct
    final isCorrect = color.id == shape.color.id;

    if (isCorrect) {
      // Add connection
      final newConnections = [
        ...state.connections,
        Connection(colorId: colorId, shapeId: shapeId, isCorrect: true),
      ];

      state = state.copyWith(
        connections: newConnections,
        clearActiveColor: true,
        clearDragPosition: true,
      );

      // Check if all matched
      if (state.allMatched) {
        state = state.copyWith(phase: ColorMatchPhase.success, score: state.score + 1);
      }
    } else {
      // Wrong match - just end the drag (no penalty for now)
      endDrag();
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Game complete - restart
      state = ColorMatchState.initial(itemsPerRound: state.itemsPerRound);
    } else {
      // Generate new round
      final result = _generateRound(_random, state.itemsPerRound);

      state = ColorMatchState(
        leftColors: result.colors,
        rightShapes: result.shapes,
        connections: const [],
        activeColorId: null,
        dragPosition: null,
        phase: ColorMatchPhase.playing,
        score: state.score,
        totalRounds: state.totalRounds,
        currentRound: state.currentRound + 1,
        itemsPerRound: state.itemsPerRound,
      );
    }
  }
}

final colorMatchProvider = NotifierProvider<ColorMatchNotifier, ColorMatchState>(() {
  return ColorMatchNotifier();
}, isAutoDispose: true);

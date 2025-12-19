import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Vibrant rainbow color palette for children
const List<Color> tileColors = [
  Color(0xFFFF6B6B), // Coral Red
  Color(0xFFFFBE0B), // Sunny Yellow
  Color(0xFF8AC926), // Lime Green
  Color(0xFF1982C4), // Ocean Blue
  Color(0xFF6A4C93), // Purple
  Color(0xFFFF595E), // Salmon
  Color(0xFFFFCA3A), // Gold
  Color(0xFF38B000), // Grass Green
  Color(0xFF3A86FF), // Sky Blue
  Color(0xFF9B5DE5), // Violet
  Color(0xFFFF85A1), // Pink
  Color(0xFFFFD166), // Light Orange
  Color(0xFF06D6A0), // Teal
  Color(0xFF118AB2), // Deep Blue
  Color(0xFFEF476F), // Magenta
  Color(0xFFFFD700), // Golden Yellow
  Color(0xFF00C49A), // Emerald
  Color(0xFF845EC2), // Royal Purple
  Color(0xFFFF6F91), // Hot Pink
  Color(0xFFFFC75F), // Amber
  Color(0xFF4B7BE5), // Cobalt Blue
  Color(0xFF00C9B7), // Aqua
  Color(0xFFD65DB1), // Orchid
  Color(0xFFFF9671), // Peach
];

// Generate random color map for tiles
Map<int, Color> _generateColorMap(int numTiles) {
  final random = Random();
  final availableColors = List<Color>.from(tileColors)..shuffle(random);
  final colorMap = <int, Color>{};
  for (int i = 1; i <= numTiles; i++) {
    colorMap[i] = availableColors[(i - 1) % availableColors.length];
  }
  return colorMap;
}

// Game state class to hold all game data
class GameState {
  final int moves;
  final int gridSize; // 3, 4, or 5 for 3x3, 4x4, 5x5
  final String? winState;
  final bool isGameRunning;
  final List<String> tilesList;
  final Map<int, Color> colorMap; // Random color assignment for each tile number

  GameState({
    required this.moves,
    required this.gridSize,
    required this.winState,
    required this.isGameRunning,
    required this.tilesList,
    required this.colorMap,
  });

  // Total tiles count (including empty tile)
  int get totalTiles => gridSize * gridSize;

  // Number of numbered tiles (excluding empty tile)
  int get numberedTiles => totalTiles - 1;

  // Get color for a tile number
  Color getTileColor(int tileNumber) {
    return colorMap[tileNumber] ?? tileColors[0];
  }

  // Initial state factory
  factory GameState.initial({int gridSize = 3}) {
    final numTiles = gridSize * gridSize - 1;
    final tilesList = List.generate(numTiles, (index) => (index + 1).toString());
    tilesList.add('X');
    return GameState(
      moves: 0,
      gridSize: gridSize,
      winState: 'Please shuffle the board',
      isGameRunning: false,
      tilesList: tilesList,
      colorMap: _generateColorMap(numTiles),
    );
  }

  // Computed property - get tiles in correct position
  int get correctTiles {
    int cnt = 0;
    for (int i = 1; i < tilesList.length; i++) {
      if (tilesList[i - 1] == (i).toString()) {
        cnt++;
      }
    }
    return cnt;
  }

  // Copy with method for immutable updates
  GameState copyWith({
    int? moves,
    int? gridSize,
    String? winState,
    bool? isGameRunning,
    List<String>? tilesList,
    Map<int, Color>? colorMap,
  }) {
    return GameState(
      moves: moves ?? this.moves,
      gridSize: gridSize ?? this.gridSize,
      winState: winState,
      isGameRunning: isGameRunning ?? this.isGameRunning,
      tilesList: tilesList ?? this.tilesList,
      colorMap: colorMap ?? this.colorMap,
    );
  }
}

// Game notifier - manages game state and logic
class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    return GameState.initial();
  }

  void changeGridSize(int newSize) {
    state = GameState.initial(gridSize: newSize);
  }

  void suffle() {
    final newTilesList = List<String>.from(state.tilesList);
    newTilesList.shuffle();
    state = GameState(
      moves: 0,
      gridSize: state.gridSize,
      winState: null,
      isGameRunning: true,
      tilesList: newTilesList,
      colorMap: state.colorMap, // Keep same colors during shuffle
    );
  }

  void moveTile(int index) {
    if (state.tilesList[index] != 'X' && state.isGameRunning) {
      final String val = state.tilesList[index];
      final int idx = state.tilesList.indexOf('X');
      final int temp = (idx - index).abs();

      // Check if tiles are adjacent (1 for horizontal, gridSize for vertical)
      if (temp == 1 || temp == state.gridSize) {
        // Additional check for horizontal moves to prevent wrapping
        if (temp == 1) {
          int idxRow = idx ~/ state.gridSize;
          int indexRow = index ~/ state.gridSize;
          if (idxRow != indexRow) return; // Can't move horizontally across rows
        }

        final newTilesList = List<String>.from(state.tilesList);
        newTilesList[idx] = val;
        newTilesList[index] = 'X';

        final newMoves = state.moves + 1;
        final newState = GameState(
          moves: newMoves,
          gridSize: state.gridSize,
          winState: state.winState,
          isGameRunning: state.isGameRunning,
          tilesList: newTilesList,
          colorMap: state.colorMap,
        );

        // Check win condition
        if (newState.correctTiles == state.numberedTiles) {
          state = newState.copyWith(
            winState: '🎉 You Win! 🎉',
            isGameRunning: false,
          );
        } else {
          state = newState;
        }
      }
    }
  }
}

// Provider for the game notifier
final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Game state class to hold all game data
class GameState {
  final int moves;
  final int gridSize; // 3, 4, or 5 for 3x3, 4x4, 5x5
  final String? winState;
  final bool isGameRunning;
  final List<String> tilesList;

  GameState({
    required this.moves,
    required this.gridSize,
    required this.winState,
    required this.isGameRunning,
    required this.tilesList,
  });

  // Total tiles count (including empty tile)
  int get totalTiles => gridSize * gridSize;

  // Number of numbered tiles (excluding empty tile)
  int get numberedTiles => totalTiles - 1;

  // Initial state factory
  factory GameState.initial({int gridSize = 3}) {
    final tilesList = List.generate(gridSize * gridSize - 1, (index) => (index + 1).toString());
    tilesList.add('X');
    return GameState(
      moves: 0,
      gridSize: gridSize,
      winState: 'Please shuffle the board',
      isGameRunning: false,
      tilesList: tilesList,
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
  }) {
    return GameState(
      moves: moves ?? this.moves,
      gridSize: gridSize ?? this.gridSize,
      winState: winState,
      isGameRunning: isGameRunning ?? this.isGameRunning,
      tilesList: tilesList ?? this.tilesList,
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

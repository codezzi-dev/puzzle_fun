import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MazeCell {
  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  const MazeCell({this.top = false, this.right = false, this.bottom = false, this.left = false});
}

class MazeLevel {
  final String id;
  final int rows;
  final int cols;
  final List<List<MazeCell>> grid;
  final Point start;
  final Point end;
  final String animal;
  final String target;
  final String instruction;
  final Color themeColor;

  MazeLevel({
    required this.id,
    required this.rows,
    required this.cols,
    required this.grid,
    required this.start,
    required this.end,
    required this.animal,
    required this.target,
    required this.instruction,
    required this.themeColor,
  });
}

class Point {
  final int x;
  final int y;
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class MazeState {
  final int currentLevelIndex;
  final Point playerPos;
  final bool isComplete;
  final int score;

  MazeState({
    this.currentLevelIndex = 0,
    this.playerPos = const Point(0, 0),
    this.isComplete = false,
    this.score = 0,
  });

  MazeLevel get currentLevel => mazeLevels[currentLevelIndex % mazeLevels.length];

  MazeState copyWith({int? currentLevelIndex, Point? playerPos, bool? isComplete, int? score}) {
    return MazeState(
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      playerPos: playerPos ?? this.playerPos,
      isComplete: isComplete ?? this.isComplete,
      score: score ?? this.score,
    );
  }
}

final List<MazeLevel> mazeLevels = [
  MazeLevel(
    id: 'simple_maze',
    rows: 4,
    cols: 4,
    animal: '🐁',
    target: '🧀',
    instruction: 'Help the Mouse find the cheese!',
    themeColor: Colors.orange,
    start: const Point(0, 0),
    end: const Point(3, 3),
    grid: [
      // Row 0
      [
        const MazeCell(right: true, bottom: false),
        const MazeCell(left: true, right: false, bottom: true),
        const MazeCell(bottom: false, right: true),
        const MazeCell(left: true, bottom: true),
      ],
      // Row 1
      [
        const MazeCell(bottom: true, right: true),
        const MazeCell(top: true, left: true, bottom: false),
        const MazeCell(bottom: true, right: false),
        const MazeCell(top: true, bottom: false),
      ],
      // Row 2
      [
        const MazeCell(top: true, right: false),
        const MazeCell(right: true, bottom: true),
        const MazeCell(top: true, left: true, right: true),
        const MazeCell(left: true, bottom: true),
      ],
      // Row 3
      [
        const MazeCell(right: true),
        const MazeCell(top: true, left: true, right: true),
        const MazeCell(left: true, right: false),
        const MazeCell(top: true),
      ],
    ],
  ),
  MazeLevel(
    id: 'rabbit_maze',
    rows: 5,
    cols: 5,
    animal: '🐇',
    target: '🥕',
    instruction: 'Help the Rabbit find the carrot!',
    themeColor: Colors.green,
    start: const Point(0, 0),
    end: const Point(4, 4),
    grid: [
      // Row 0
      [
        const MazeCell(right: false, bottom: true),
        const MazeCell(right: true, bottom: false),
        const MazeCell(left: true, bottom: true),
        const MazeCell(right: true, bottom: false),
        const MazeCell(left: true, bottom: true),
      ],
      // Row 1
      [
        const MazeCell(top: true, bottom: true),
        const MazeCell(right: true, bottom: true),
        const MazeCell(top: true, left: true, bottom: false),
        const MazeCell(right: false, bottom: true),
        const MazeCell(top: true, bottom: false),
      ],
      // Row 2
      [
        const MazeCell(top: true, right: true),
        const MazeCell(top: true, left: true, bottom: false),
        const MazeCell(right: true, bottom: true),
        const MazeCell(top: true, left: true, bottom: false),
        const MazeCell(bottom: true),
      ],
      // Row 3
      [
        const MazeCell(bottom: false, right: true),
        const MazeCell(right: false, bottom: true),
        const MazeCell(top: true, bottom: false),
        const MazeCell(right: true, bottom: true),
        const MazeCell(top: true, left: true),
      ],
      // Row 4
      [
        const MazeCell(right: true),
        const MazeCell(top: true, left: true, right: true),
        const MazeCell(left: true, right: true),
        const MazeCell(top: true, left: true, right: false),
        const MazeCell(bottom: false),
      ],
    ],
  ),
];

class MazeNotifier extends Notifier<MazeState> {
  @override
  MazeState build() {
    final firstLevel = mazeLevels[0];
    return MazeState(playerPos: firstLevel.start);
  }

  void move(int dx, int dy) {
    if (state.isComplete) return;

    final currentPos = state.playerPos;
    final newX = currentPos.x + dx;
    final newY = currentPos.y + dy;

    if (newX < 0 ||
        newX >= state.currentLevel.cols ||
        newY < 0 ||
        newY >= state.currentLevel.rows) {
      return;
    }

    final currentCell = state.currentLevel.grid[currentPos.y][currentPos.x];

    // Check walls
    if (dx == 1 && currentCell.right) return;
    if (dx == -1 && currentCell.left) return;
    if (dy == 1 && currentCell.bottom) return;
    if (dy == -1 && currentCell.top) return;

    // Check target cell walls (incoming connection)
    final targetCell = state.currentLevel.grid[newY][newX];
    if (dx == 1 && targetCell.left) return;
    if (dx == -1 && targetCell.right) return;
    if (dy == 1 && targetCell.top) return;
    if (dy == -1 && targetCell.bottom) return;

    final newPos = Point(newX, newY);
    state = state.copyWith(playerPos: newPos);

    if (newPos == state.currentLevel.end) {
      state = state.copyWith(isComplete: true, score: state.score + 1);
    }
  }

  void resetLevel() {
    state = state.copyWith(playerPos: state.currentLevel.start, isComplete: false);
  }

  void nextLevel() {
    final nextIndex = state.currentLevelIndex + 1;
    final nextLevel = mazeLevels[nextIndex % mazeLevels.length];
    state = MazeState(currentLevelIndex: nextIndex, playerPos: nextLevel.start, score: state.score);
  }
}

final mazeProvider = NotifierProvider<MazeNotifier, MazeState>(() {
  return MazeNotifier();
});

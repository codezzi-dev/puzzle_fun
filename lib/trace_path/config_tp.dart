import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TraceLevel {
  final String id;
  final String animal;
  final String target;
  final String instruction;
  final Color themeColor;
  final List<Offset> guidePoints; // Normalize points 0 to 1

  TraceLevel({
    required this.id,
    required this.animal,
    required this.target,
    required this.instruction,
    required this.themeColor,
    required this.guidePoints,
  });
}

class TracePathState {
  final int currentLevelIndex;
  final List<Offset> userPoints;
  final bool isComplete;
  final int score;

  TracePathState({
    this.currentLevelIndex = 0,
    this.userPoints = const [],
    this.isComplete = false,
    this.score = 0,
  });

  TraceLevel get currentLevel => levels[currentLevelIndex % levels.length];

  TracePathState copyWith({
    int? currentLevelIndex,
    List<Offset>? userPoints,
    bool? isComplete,
    int? score,
  }) {
    return TracePathState(
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      userPoints: userPoints ?? this.userPoints,
      isComplete: isComplete ?? this.isComplete,
      score: score ?? this.score,
    );
  }
}

final List<TraceLevel> levels = [
  TraceLevel(
    id: 'bee_flower',
    animal: '🐝',
    target: '🌸',
    instruction: 'Help the Bee find the flower!',
    themeColor: Colors.amber,
    guidePoints: [
      const Offset(0.1, 0.5),
      const Offset(0.3, 0.3),
      const Offset(0.5, 0.7),
      const Offset(0.7, 0.4),
      const Offset(0.9, 0.5),
    ],
  ),
  TraceLevel(
    id: 'dog_bone',
    animal: '🐶',
    target: '🦴',
    instruction: 'Help the Dog get the bone!',
    themeColor: Colors.brown,
    guidePoints: [
      const Offset(0.1, 0.8),
      const Offset(0.3, 0.6),
      const Offset(0.6, 0.8),
      const Offset(0.9, 0.7),
    ],
  ),
  TraceLevel(
    id: 'monkey_banana',
    animal: '🐒',
    target: '🍌',
    instruction: 'Help the Monkey find bananas!',
    themeColor: Colors.green,
    guidePoints: [
      const Offset(0.5, 0.1),
      const Offset(0.3, 0.4),
      const Offset(0.7, 0.6),
      const Offset(0.5, 0.9),
    ],
  ),
];

class TracePathNotifier extends Notifier<TracePathState> {
  @override
  TracePathState build() => TracePathState();

  void addPoint(Offset point, Size canvasSize) {
    if (state.isComplete) return;

    final normalizedPoint = Offset(point.dx / canvasSize.width, point.dy / canvasSize.height);

    final newPoints = [...state.userPoints, normalizedPoint];
    state = state.copyWith(userPoints: newPoints);

    _checkCompletion(normalizedPoint);
  }

  void _checkCompletion(Offset lastPoint) {
    final targetPoint = state.currentLevel.guidePoints.last;
    final distance = (lastPoint - targetPoint).distance;

    // If within 10% of the target point
    if (distance < 0.10 && state.userPoints.length > 5) {
      state = state.copyWith(isComplete: true, score: state.score + 1);
    }
  }

  void resetLevel() {
    state = state.copyWith(userPoints: [], isComplete: false);
  }

  void nextLevel() {
    state = TracePathState(currentLevelIndex: state.currentLevelIndex + 1, score: state.score);
  }
}

final tracePathProvider = NotifierProvider<TracePathNotifier, TracePathState>(() {
  return TracePathNotifier();
});

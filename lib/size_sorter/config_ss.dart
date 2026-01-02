import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GamePhase { learning, testing, success }

class SorterItem {
  final String id;
  final String type; // e.g., 'bear', 'apple', 'star'
  final double sizeScale; // 0.6, 0.8, 1.0
  final Color color;
  final IconData icon;

  SorterItem({
    required this.id,
    required this.type,
    required this.sizeScale,
    required this.color,
    required this.icon,
  });
}

class SizeSorterState {
  final List<SorterItem> pool; // Items to be placed
  final Map<int, SorterItem?> placements; // Index 0: Small, 1: Medium, 2: Large
  final GamePhase phase;
  final int score;
  final int currentRound;
  final int totalRounds;
  final String currentType;

  const SizeSorterState({
    required this.pool,
    required this.placements,
    required this.phase,
    required this.score,
    required this.currentRound,
    required this.currentType,
    this.totalRounds = 5,
  });

  factory SizeSorterState.initial() {
    return _generateRound(0, 1);
  }

  SizeSorterState copyWith({
    List<SorterItem>? pool,
    Map<int, SorterItem?>? placements,
    GamePhase? phase,
    int? score,
    int? currentRound,
    String? currentType,
  }) {
    return SizeSorterState(
      pool: pool ?? this.pool,
      placements: placements ?? this.placements,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      currentRound: currentRound ?? this.currentRound,
      currentType: currentType ?? this.currentType,
      totalRounds: totalRounds,
    );
  }

  static SizeSorterState _generateRound(int score, int round) {
    final random = Random();
    final itemTypes = [
      {'type': 'Bear', 'icon': Icons.pets},
      {'type': 'Apple', 'icon': Icons.apple},
      {'type': 'Star', 'icon': Icons.star},
      {'type': 'Favorite', 'icon': Icons.favorite},
      {'type': 'Circle', 'icon': Icons.circle},
      {'type': 'Diamond', 'icon': Icons.diamond},
    ];
    final selected = itemTypes[random.nextInt(itemTypes.length)];
    final color = Colors.primaries[random.nextInt(Colors.primaries.length)];

    final items = [
      SorterItem(
        id: 's',
        type: selected['type'] as String,
        sizeScale: 0.6,
        color: color,
        icon: selected['icon'] as IconData,
      ),
      SorterItem(
        id: 'm',
        type: selected['type'] as String,
        sizeScale: 0.8,
        color: color,
        icon: selected['icon'] as IconData,
      ),
      SorterItem(
        id: 'l',
        type: selected['type'] as String,
        sizeScale: 1.0,
        color: color,
        icon: selected['icon'] as IconData,
      ),
    ];

    final pool = List<SorterItem>.from(items)..shuffle();

    return SizeSorterState(
      pool: pool,
      placements: {0: null, 1: null, 2: null},
      phase: GamePhase.learning,
      score: score,
      currentRound: round,
      currentType: selected['type'] as String,
    );
  }
}

class SizeSorterNotifier extends Notifier<SizeSorterState> {
  @override
  SizeSorterState build() => SizeSorterState.initial();

  void startTesting() {
    state = state.copyWith(phase: GamePhase.testing);
  }

  void placeItem(int boxIndex, SorterItem item) {
    if (state.phase != GamePhase.testing) return;

    // Check if the item matches the size requirement for the box
    // Box 0: Small (0.6), Box 1: Medium (0.8), Box 2: Large (1.0)
    final expectedScale = [0.6, 0.8, 1.0][boxIndex];
    if (item.sizeScale == expectedScale) {
      final newPlacements = Map<int, SorterItem?>.from(state.placements);
      newPlacements[boxIndex] = item;

      final newPool = state.pool.where((i) => i.id != item.id).toList();

      state = state.copyWith(placements: newPlacements, pool: newPool);

      if (newPool.isEmpty) {
        state = state.copyWith(phase: GamePhase.success, score: state.score + 1);
      }
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      resetGame();
    } else {
      state = SizeSorterState._generateRound(state.score, state.currentRound + 1);
    }
  }

  void resetGame() {
    state = SizeSorterState.initial();
  }
}

final sizeSorterProvider = NotifierProvider<SizeSorterNotifier, SizeSorterState>(() {
  return SizeSorterNotifier();
}, isAutoDispose: true);

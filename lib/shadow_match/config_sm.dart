import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GamePhase { learning, playing, success }

class ShadowItem {
  final String id;
  final String name;
  final String emoji;
  final String category;

  const ShadowItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
  });
}

class ShadowMatchState {
  final GamePhase phase;
  final List<ShadowItem> currentItems;
  final Set<String> matchedIds;
  final int score;
  final int currentRound;
  final int totalRounds;
  final String lastMatchedName;

  const ShadowMatchState({
    required this.phase,
    required this.currentItems,
    required this.matchedIds,
    required this.score,
    required this.currentRound,
    this.totalRounds = 5,
    this.lastMatchedName = '',
  });

  ShadowMatchState copyWith({
    GamePhase? phase,
    List<ShadowItem>? currentItems,
    Set<String>? matchedIds,
    int? score,
    int? currentRound,
    String? lastMatchedName,
  }) {
    return ShadowMatchState(
      phase: phase ?? this.phase,
      currentItems: currentItems ?? this.currentItems,
      matchedIds: matchedIds ?? this.matchedIds,
      score: score ?? this.score,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      lastMatchedName: lastMatchedName ?? this.lastMatchedName,
    );
  }
}

final allShadowItems = [
  // Animals
  const ShadowItem(id: 'lion', name: 'Lion', emoji: '🦁', category: 'Animals'),
  const ShadowItem(id: 'elephant', name: 'Elephant', emoji: '🐘', category: 'Animals'),
  const ShadowItem(id: 'giraffe', name: 'Giraffe', emoji: '🦒', category: 'Animals'),
  const ShadowItem(id: 'monkey', name: 'Monkey', emoji: '🐒', category: 'Animals'),
  const ShadowItem(id: 'penguin', name: 'Penguin', emoji: '🐧', category: 'Animals'),
  const ShadowItem(id: 'cat', name: 'Cat', emoji: '🐱', category: 'Animals'),
  const ShadowItem(id: 'dog', name: 'Dog', emoji: '🐶', category: 'Animals'),

  // Fruits
  const ShadowItem(id: 'apple', name: 'Apple', emoji: '🍎', category: 'Fruits'),
  const ShadowItem(id: 'banana', name: 'Banana', emoji: '🍌', category: 'Fruits'),
  const ShadowItem(id: 'strawberry', name: 'Strawberry', emoji: '🍓', category: 'Fruits'),
  const ShadowItem(id: 'watermelon', name: 'Watermelon', emoji: '🍉', category: 'Fruits'),
  const ShadowItem(id: 'pineapple', name: 'Pineapple', emoji: '🍍', category: 'Fruits'),
  const ShadowItem(id: 'grape', name: 'Grape', emoji: '🍇', category: 'Fruits'),

  // Toys & Objects
  const ShadowItem(id: 'car', name: 'Car', emoji: '🚗', category: 'Toys'),
  const ShadowItem(id: 'plane', name: 'Plane', emoji: '✈️', category: 'Toys'),
  const ShadowItem(id: 'ball', name: 'Ball', emoji: '⚽', category: 'Toys'),
  const ShadowItem(id: 'robot', name: 'Robot', emoji: '🤖', category: 'Toys'),
  const ShadowItem(id: 'rocket', name: 'Rocket', emoji: '🚀', category: 'Toys'),
  const ShadowItem(id: 'train', name: 'Train', emoji: '🚂', category: 'Toys'),
];

class ShadowMatchNotifier extends Notifier<ShadowMatchState> {
  final _random = math.Random();

  @override
  ShadowMatchState build() {
    return _generateNewGame();
  }

  ShadowMatchState _generateNewGame() {
    // Pick 4 random items for a round
    final shuffled = List<ShadowItem>.from(allShadowItems)..shuffle(_random);
    final selected = shuffled.take(4).toList();

    return ShadowMatchState(
      phase: GamePhase.learning,
      currentItems: selected,
      matchedIds: {},
      score: 0,
      currentRound: 1,
    );
  }

  void startPlaying() {
    state = state.copyWith(phase: GamePhase.playing);
  }

  void matchItem(String id) {
    if (state.phase != GamePhase.playing) return;

    final item = state.currentItems.firstWhere((i) => i.id == id);
    final newMatched = Set<String>.from(state.matchedIds)..add(id);

    state = state.copyWith(matchedIds: newMatched, lastMatchedName: item.name);

    if (newMatched.length == state.currentItems.length) {
      state = state.copyWith(phase: GamePhase.success, score: state.score + 1);
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = _generateNewGame();
    } else {
      final shuffled = List<ShadowItem>.from(allShadowItems)..shuffle(_random);
      final selected = shuffled.take(4).toList();

      state = state.copyWith(
        phase: GamePhase.learning,
        currentItems: selected,
        matchedIds: {},
        currentRound: state.currentRound + 1,
        lastMatchedName: '',
      );
    }
  }
}

final shadowMatchProvider = NotifierProvider<ShadowMatchNotifier, ShadowMatchState>(() {
  return ShadowMatchNotifier();
});

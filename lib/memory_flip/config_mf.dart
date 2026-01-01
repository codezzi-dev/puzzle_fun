import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemoryCard {
  final String id;
  final String value; // Can be an emoji or color name
  final Color color;
  final bool isFlipped;
  final bool isMatched;

  MemoryCard({
    required this.id,
    required this.value,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({bool? isFlipped, bool? isMatched}) {
    return MemoryCard(
      id: id,
      value: value,
      color: color,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

enum MemoryFlipPhase { playing, success }

class MemoryFlipState {
  final List<MemoryCard> cards;
  final List<int> selectedIndices;
  final int score;
  final int moves;
  final MemoryFlipPhase phase;

  MemoryFlipState({
    required this.cards,
    this.selectedIndices = const [],
    this.score = 0,
    this.moves = 0,
    this.phase = MemoryFlipPhase.playing,
  });

  factory MemoryFlipState.initial() {
    return MemoryFlipState(cards: _generateCards());
  }

  MemoryFlipState copyWith({
    List<MemoryCard>? cards,
    List<int>? selectedIndices,
    int? score,
    int? moves,
    MemoryFlipPhase? phase,
  }) {
    return MemoryFlipState(
      cards: cards ?? this.cards,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      phase: phase ?? this.phase,
    );
  }
}

List<MemoryCard> _generateCards() {
  final items = [
    {'value': '🍎', 'color': Colors.red},
    {'value': '🍌', 'color': Colors.yellow},
    {'value': '🍇', 'color': Colors.purple},
    {'value': '🍓', 'color': Colors.pink},
    {'value': '🍊', 'color': Colors.orange},
    {'value': '🍐', 'color': Colors.green},
  ];

  // Double the items for pairs
  final pairs = [...items, ...items];
  pairs.shuffle();

  return List.generate(pairs.length, (index) {
    return MemoryCard(
      id: 'card_$index',
      value: pairs[index]['value'] as String,
      color: pairs[index]['color'] as Color,
    );
  });
}

class MemoryFlipNotifier extends Notifier<MemoryFlipState> {
  bool _isProcessing = false;

  @override
  MemoryFlipState build() => MemoryFlipState.initial();

  void flipCard(int index) {
    if (_isProcessing ||
        state.cards[index].isFlipped ||
        state.cards[index].isMatched ||
        state.phase == MemoryFlipPhase.success) {
      return;
    }

    final newCards = List<MemoryCard>.from(state.cards);
    newCards[index] = newCards[index].copyWith(isFlipped: true);

    final newSelected = [...state.selectedIndices, index];

    state = state.copyWith(cards: newCards, selectedIndices: newSelected);

    if (newSelected.length == 2) {
      _checkMatch(newSelected);
    }
  }

  Future<void> _checkMatch(List<int> indices) async {
    _isProcessing = true;
    final card1 = state.cards[indices[0]];
    final card2 = state.cards[indices[1]];

    await Future.delayed(const Duration(milliseconds: 800));

    if (card1.value == card2.value) {
      // Match!
      final newCards = List<MemoryCard>.from(state.cards);
      newCards[indices[0]] = newCards[indices[0]].copyWith(isMatched: true);
      newCards[indices[1]] = newCards[indices[1]].copyWith(isMatched: true);

      final allMatched = newCards.every((c) => c.isMatched);

      state = state.copyWith(
        cards: newCards,
        selectedIndices: [],
        score: state.score + 1,
        moves: state.moves + 1,
        phase: allMatched ? MemoryFlipPhase.success : MemoryFlipPhase.playing,
      );
    } else {
      // No match
      final newCards = List<MemoryCard>.from(state.cards);
      newCards[indices[0]] = newCards[indices[0]].copyWith(isFlipped: false);
      newCards[indices[1]] = newCards[indices[1]].copyWith(isFlipped: false);

      state = state.copyWith(cards: newCards, selectedIndices: [], moves: state.moves + 1);
    }
    _isProcessing = false;
  }

  void resetGame() {
    state = MemoryFlipState.initial();
  }
}

final memoryFlipProvider = NotifierProvider.autoDispose<MemoryFlipNotifier, MemoryFlipState>(() {
  return MemoryFlipNotifier();
});

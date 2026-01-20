import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OppositeCard {
  final String id;
  final String value; // The word or emoji on the card
  final String pairId; // Common ID for the opposite pair
  final bool isFlipped;
  final bool isMatched;

  OppositeCard({
    required this.id,
    required this.value,
    required this.pairId,
    this.isFlipped = false,
    this.isMatched = false,
  });

  OppositeCard copyWith({bool? isFlipped, bool? isMatched}) {
    return OppositeCard(
      id: id,
      value: value,
      pairId: pairId,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

enum OppositePairsPhase { playing, success }

class OppositePairsState {
  final List<OppositeCard> cards;
  final List<int> selectedIndices;
  final int score;
  final int moves;
  final OppositePairsPhase phase;

  OppositePairsState({
    required this.cards,
    this.selectedIndices = const [],
    this.score = 0,
    this.moves = 0,
    this.phase = OppositePairsPhase.playing,
  });

  factory OppositePairsState.initial() {
    return OppositePairsState(cards: _generateCards());
  }

  OppositePairsState copyWith({
    List<OppositeCard>? cards,
    List<int>? selectedIndices,
    int? score,
    int? moves,
    OppositePairsPhase? phase,
  }) {
    return OppositePairsState(
      cards: cards ?? this.cards,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      phase: phase ?? this.phase,
    );
  }
}

List<OppositeCard> _generateCards() {
  final List<Map<String, String>> pairs = [
    {'a': '🐘 Big', 'b': '🐭 Small'},
    {'a': '🔥 Hot', 'b': '❄️ Cold'},
    {'a': '😊 Happy', 'b': '😢 Sad'},
    {'a': '🏃 Fast', 'b': '🐢 Slow'},
    {'a': '☀️ Day', 'b': '🌙 Night'},
    {'a': '⬆️ Up', 'b': '⬇️ Down'},
  ];

  final List<OppositeCard> cards = [];
  for (int i = 0; i < pairs.length; i++) {
    final pairId = 'pair_$i';
    cards.add(OppositeCard(id: '${pairId}_a', value: pairs[i]['a']!, pairId: pairId));
    cards.add(OppositeCard(id: '${pairId}_b', value: pairs[i]['b']!, pairId: pairId));
  }

  cards.shuffle();
  return cards;
}

class OppositePairsNotifier extends Notifier<OppositePairsState> {
  bool _isProcessing = false;

  @override
  OppositePairsState build() => OppositePairsState.initial();

  void flipCard(int index) {
    if (_isProcessing ||
        state.cards[index].isFlipped ||
        state.cards[index].isMatched ||
        state.phase == OppositePairsPhase.success) {
      return;
    }

    final newCards = List<OppositeCard>.from(state.cards);
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

    await Future.delayed(const Duration(milliseconds: 1000));

    if (card1.pairId == card2.pairId && card1.id != card2.id) {
      // Match!
      final newCards = List<OppositeCard>.from(state.cards);
      newCards[indices[0]] = newCards[indices[0]].copyWith(isMatched: true);
      newCards[indices[1]] = newCards[indices[1]].copyWith(isMatched: true);

      final allMatched = newCards.every((c) => c.isMatched);

      state = state.copyWith(
        cards: newCards,
        selectedIndices: [],
        score: state.score + 1,
        moves: state.moves + 1,
        phase: allMatched ? OppositePairsPhase.success : OppositePairsPhase.playing,
      );
    } else {
      // No match
      final newCards = List<OppositeCard>.from(state.cards);
      newCards[indices[0]] = newCards[indices[0]].copyWith(isFlipped: false);
      newCards[indices[1]] = newCards[indices[1]].copyWith(isFlipped: false);

      state = state.copyWith(cards: newCards, selectedIndices: [], moves: state.moves + 1);
    }
    _isProcessing = false;
  }

  void resetGame() {
    state = OppositePairsState.initial();
  }
}

final oppositePairsProvider =
    NotifierProvider.autoDispose<OppositePairsNotifier, OppositePairsState>(() {
      return OppositePairsNotifier();
    });

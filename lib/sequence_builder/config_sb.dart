import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GamePhase { learning, testing, success }

class SequenceItem {
  final String id;
  final String name;
  final String emoji;
  final int order; // The correct position in the sequence (1-based)

  const SequenceItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.order,
  });
}

class SequenceTheme {
  final String id;
  final String title;
  final String instruction;
  final List<SequenceItem> items;

  const SequenceTheme({
    required this.id,
    required this.title,
    required this.instruction,
    required this.items,
  });
}

// Predefined sequence themes
final sequenceThemes = [
  const SequenceTheme(
    id: 'morning_routine',
    title: 'Morning Routine',
    instruction: 'What do we do in the morning?',
    items: [
      SequenceItem(id: 'wake', name: 'Wake Up', emoji: '🛏️', order: 1),
      SequenceItem(id: 'brush', name: 'Brush Teeth', emoji: '🪥', order: 2),
      SequenceItem(id: 'eat', name: 'Eat Breakfast', emoji: '🥣', order: 3),
      SequenceItem(id: 'school', name: 'Go to School', emoji: '🏫', order: 4),
    ],
  ),
  const SequenceTheme(
    id: 'plant_growth',
    title: 'Plant Growth',
    instruction: 'How does a plant grow?',
    items: [
      SequenceItem(id: 'seed', name: 'Seed', emoji: '🌱', order: 1),
      SequenceItem(id: 'sprout', name: 'Sprout', emoji: '🌿', order: 2),
      SequenceItem(id: 'flower', name: 'Flower', emoji: '🌸', order: 3),
      SequenceItem(id: 'fruit', name: 'Fruit', emoji: '🍎', order: 4),
    ],
  ),
  const SequenceTheme(
    id: 'butterfly_life',
    title: 'Butterfly Life',
    instruction: 'How does a butterfly grow?',
    items: [
      SequenceItem(id: 'egg', name: 'Egg', emoji: '🥚', order: 1),
      SequenceItem(id: 'caterpillar', name: 'Caterpillar', emoji: '🐛', order: 2),
      SequenceItem(id: 'cocoon', name: 'Cocoon', emoji: '🪺', order: 3),
      SequenceItem(id: 'butterfly', name: 'Butterfly', emoji: '🦋', order: 4),
    ],
  ),
  const SequenceTheme(
    id: 'bedtime_routine',
    title: 'Bedtime Routine',
    instruction: 'What do we do before bed?',
    items: [
      SequenceItem(id: 'bath', name: 'Take a Bath', emoji: '🛁', order: 1),
      SequenceItem(id: 'pajamas', name: 'Wear Pajamas', emoji: '👕', order: 2),
      SequenceItem(id: 'story', name: 'Read Story', emoji: '📖', order: 3),
      SequenceItem(id: 'sleep', name: 'Sleep', emoji: '😴', order: 4),
    ],
  ),
  const SequenceTheme(
    id: 'making_sandwich',
    title: 'Making a Sandwich',
    instruction: 'How do we make a sandwich?',
    items: [
      SequenceItem(id: 'bread1', name: 'Bread', emoji: '🍞', order: 1),
      SequenceItem(id: 'cheese', name: 'Cheese', emoji: '🧀', order: 2),
      SequenceItem(id: 'lettuce', name: 'Lettuce', emoji: '🥬', order: 3),
      SequenceItem(id: 'bread2', name: 'Top Bread', emoji: '🥪', order: 4),
    ],
  ),
  const SequenceTheme(
    id: 'seasons',
    title: 'Four Seasons',
    instruction: 'Put the seasons in order!',
    items: [
      SequenceItem(id: 'spring', name: 'Spring', emoji: '🌷', order: 1),
      SequenceItem(id: 'summer', name: 'Summer', emoji: '☀️', order: 2),
      SequenceItem(id: 'autumn', name: 'Autumn', emoji: '🍂', order: 3),
      SequenceItem(id: 'winter', name: 'Winter', emoji: '❄️', order: 4),
    ],
  ),
];

class SequenceBuilderState {
  final GamePhase phase;
  final SequenceTheme currentTheme;
  final List<SequenceItem> shuffledItems; // Items to drag (shuffled)
  final List<SequenceItem?> placements; // Slots where items are placed
  final int currentRound;
  final int totalRounds;
  final int score;

  const SequenceBuilderState({
    required this.phase,
    required this.currentTheme,
    required this.shuffledItems,
    required this.placements,
    required this.currentRound,
    this.totalRounds = 6,
    required this.score,
  });

  SequenceBuilderState copyWith({
    GamePhase? phase,
    SequenceTheme? currentTheme,
    List<SequenceItem>? shuffledItems,
    List<SequenceItem?>? placements,
    int? currentRound,
    int? score,
  }) {
    return SequenceBuilderState(
      phase: phase ?? this.phase,
      currentTheme: currentTheme ?? this.currentTheme,
      shuffledItems: shuffledItems ?? this.shuffledItems,
      placements: placements ?? this.placements,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      score: score ?? this.score,
    );
  }
}

class SequenceBuilderNotifier extends Notifier<SequenceBuilderState> {
  final _random = math.Random();

  @override
  SequenceBuilderState build() {
    return _generateRound(1, 0);
  }

  SequenceBuilderState _generateRound(int round, int currentScore) {
    // Pick a theme (cycle through or random after first pass)
    final themeIndex = (round - 1) % sequenceThemes.length;
    final theme = sequenceThemes[themeIndex];

    // Shuffle items for drag pool
    final shuffled = List<SequenceItem>.from(theme.items)..shuffle(_random);

    // Empty placements
    final placements = List<SequenceItem?>.filled(theme.items.length, null);

    return SequenceBuilderState(
      phase: GamePhase.learning,
      currentTheme: theme,
      shuffledItems: shuffled,
      placements: placements,
      currentRound: round,
      score: currentScore,
    );
  }

  void startTesting() {
    // Re-shuffle items when starting test phase
    final shuffled = List<SequenceItem>.from(state.currentTheme.items)..shuffle(_random);
    final placements = List<SequenceItem?>.filled(state.currentTheme.items.length, null);

    state = state.copyWith(
      phase: GamePhase.testing,
      shuffledItems: shuffled,
      placements: placements,
    );
  }

  void placeItem(int slotIndex, SequenceItem item) {
    if (state.phase != GamePhase.testing) return;

    // Check if the item belongs in this slot
    // slotIndex is 0-based, item.order is 1-based
    if (item.order == slotIndex + 1) {
      // Correct placement
      final newPlacements = List<SequenceItem?>.from(state.placements);
      newPlacements[slotIndex] = item;

      final newShuffled = state.shuffledItems.where((i) => i.id != item.id).toList();

      state = state.copyWith(placements: newPlacements, shuffledItems: newShuffled);

      // Check if all slots are filled
      if (newShuffled.isEmpty) {
        state = state.copyWith(phase: GamePhase.success, score: state.score + 1);
      }
    }
    // If wrong, do nothing (item stays in pool)
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Restart from round 1
      state = _generateRound(1, state.score);
    } else {
      state = _generateRound(state.currentRound + 1, state.score);
    }
  }

  void reset() {
    state = _generateRound(1, 0);
  }
}

final sequenceBuilderProvider = NotifierProvider<SequenceBuilderNotifier, SequenceBuilderState>(() {
  return SequenceBuilderNotifier();
});

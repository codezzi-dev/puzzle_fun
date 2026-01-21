import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a topping item for the Food Maker game
class ToppingItem {
  final String id;
  final String emoji;
  final String name;

  const ToppingItem({required this.id, required this.emoji, required this.name});
}

/// Represents a placed topping on the food base
class PlacedTopping {
  final ToppingItem item;
  final Offset position;
  final double scale;
  final double rotation;

  const PlacedTopping({
    required this.item,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

/// Represents the food base (e.g., Pizza, Cupcake)
class FoodBase {
  final String name;
  final String emoji;
  final List<ToppingItem> availableToppings;

  const FoodBase({required this.name, required this.emoji, required this.availableToppings});
}

/// Game phases for Food Maker
enum FoodMakerPhase { learning, playing, success }

/// Palette of toppings and bases
const List<ToppingItem> pizzaToppings = [
  ToppingItem(id: 'mushroom', emoji: '🍄', name: 'mushrooms'),
  ToppingItem(id: 'olive', emoji: '🫒', name: 'olives'),
  ToppingItem(id: 'pepperoni', emoji: '🍕', name: 'pepperoni'),
  ToppingItem(id: 'pepper', emoji: '🫑', name: 'peppers'),
  ToppingItem(id: 'onion', emoji: '🧅', name: 'onions'),
];

const List<ToppingItem> cupcakeToppings = [
  ToppingItem(id: 'cherry', emoji: '🍒', name: 'cherries'),
  ToppingItem(id: 'strawberry', emoji: '🍓', name: 'strawberries'),
  ToppingItem(id: 'sprinkles', emoji: '✨', name: 'sprinkles'),
  ToppingItem(id: 'chocolate', emoji: '🍫', name: 'chocolates'),
  ToppingItem(id: 'blueberry', emoji: '🫐', name: 'blueberries'),
];

const List<FoodBase> foodBases = [
  FoodBase(name: 'pizza', emoji: '🍕', availableToppings: pizzaToppings),
  FoodBase(name: 'cupcake', emoji: '🧁', availableToppings: cupcakeToppings),
];

/// State for the Food Maker game
class FoodMakerState {
  final FoodBase currentBase;
  final Map<String, int> targetToppings; // Topping ID -> Count
  final List<PlacedTopping> currentToppings;
  final FoodMakerPhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;

  const FoodMakerState({
    required this.currentBase,
    required this.targetToppings,
    required this.currentToppings,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.themeColor,
  });

  factory FoodMakerState.initial() {
    final random = Random();
    final base = foodBases[random.nextInt(foodBases.length)];

    // Choose 2-3 types of toppings
    final toppingCount = random.nextInt(2) + 2; // 2 to 3
    final shuffledToppings = List<ToppingItem>.from(base.availableToppings)..shuffle(random);
    final selectedToppings = shuffledToppings.take(toppingCount).toList();

    final Map<String, int> targets = {};
    for (var topping in selectedToppings) {
      targets[topping.id] = random.nextInt(3) + 1; // 1 to 3 of each
    }

    final themeColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    return FoodMakerState(
      currentBase: base,
      targetToppings: targets,
      currentToppings: [],
      phase: FoodMakerPhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  FoodMakerState copyWith({
    FoodBase? currentBase,
    Map<String, int>? targetToppings,
    List<PlacedTopping>? currentToppings,
    FoodMakerPhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
  }) {
    return FoodMakerState(
      currentBase: currentBase ?? this.currentBase,
      targetToppings: targetToppings ?? this.targetToppings,
      currentToppings: currentToppings ?? this.currentToppings,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}

/// Riverpod Notifier for Food Maker game state
class FoodMakerNotifier extends Notifier<FoodMakerState> {
  final Random _random = Random();

  @override
  FoodMakerState build() {
    return FoodMakerState.initial();
  }

  void startPlaying() {
    state = state.copyWith(phase: FoodMakerPhase.playing);
  }

  void addTopping(ToppingItem topping, Offset position) {
    if (state.phase != FoodMakerPhase.playing) return;

    final placed = PlacedTopping(
      item: topping,
      position: position,
      scale: 0.8 + _random.nextDouble() * 0.4,
      rotation: _random.nextDouble() * pi / 4 - pi / 8,
    );

    state = state.copyWith(currentToppings: [...state.currentToppings, placed]);
  }

  void removeLastTopping() {
    if (state.currentToppings.isEmpty) return;
    state = state.copyWith(currentToppings: List.from(state.currentToppings)..removeLast());
  }

  void checkOrder() {
    final Map<String, int> counts = {};
    for (var placed in state.currentToppings) {
      counts[placed.item.id] = (counts[placed.item.id] ?? 0) + 1;
    }

    bool isCorrect = true;
    if (counts.length != state.targetToppings.length) {
      isCorrect = false;
    } else {
      state.targetToppings.forEach((id, targetCount) {
        if (counts[id] != targetCount) {
          isCorrect = false;
        }
      });
    }

    if (isCorrect) {
      state = state.copyWith(phase: FoodMakerPhase.success, score: state.score + 1);
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      state = FoodMakerState.initial();
    } else {
      final base = foodBases[_random.nextInt(foodBases.length)];
      final toppingCount = _random.nextInt(2) + 2;
      final shuffledToppings = List<ToppingItem>.from(base.availableToppings)..shuffle(_random);
      final selectedToppings = shuffledToppings.take(toppingCount).toList();

      final Map<String, int> targets = {};
      for (var topping in selectedToppings) {
        targets[topping.id] = _random.nextInt(3) + 1;
      }

      final themeColors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.pink,
        Colors.teal,
        Colors.amber,
      ];

      state = state.copyWith(
        currentBase: base,
        targetToppings: targets,
        currentToppings: [],
        phase: FoodMakerPhase.learning,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

/// Provider for Food Maker game state
final foodMakerProvider = NotifierProvider<FoodMakerNotifier, FoodMakerState>(() {
  return FoodMakerNotifier();
}, isAutoDispose: true);

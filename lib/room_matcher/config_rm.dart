import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GamePhase { learning, testing, success }

/// Represents a room in the house
class Room {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final IconData icon;

  const Room({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.icon,
  });
}

/// Represents an item that belongs to a room
class RoomItem {
  final String id;
  final String name;
  final String emoji;
  final String roomId;

  const RoomItem({required this.id, required this.name, required this.emoji, required this.roomId});
}

/// All available rooms
const allRooms = [
  Room(
    id: 'bedroom',
    name: 'Bedroom',
    emoji: '🛏️',
    color: Color(0xFF9C27B0),
    icon: Icons.bed_rounded,
  ),
  Room(
    id: 'kitchen',
    name: 'Kitchen',
    emoji: '🍳',
    color: Color(0xFFFF9800),
    icon: Icons.kitchen_rounded,
  ),
  Room(
    id: 'bathroom',
    name: 'Bathroom',
    emoji: '🚿',
    color: Color(0xFF03A9F4),
    icon: Icons.bathtub_rounded,
  ),
  Room(
    id: 'living_room',
    name: 'Living Room',
    emoji: '🛋️',
    color: Color(0xFF4CAF50),
    icon: Icons.weekend_rounded,
  ),
  Room(
    id: 'dining_room',
    name: 'Dining Room',
    emoji: '🍽️',
    color: Color(0xFFE91E63),
    icon: Icons.dining_rounded,
  ),
];

/// All items organized by room
const allRoomItems = [
  // Bedroom items
  RoomItem(id: 'bed', name: 'Bed', emoji: '🛏️', roomId: 'bedroom'),
  RoomItem(id: 'pillow', name: 'Pillow', emoji: '🛌', roomId: 'bedroom'),
  RoomItem(id: 'alarm_clock', name: 'Alarm Clock', emoji: '⏰', roomId: 'bedroom'),
  RoomItem(id: 'lamp', name: 'Lamp', emoji: '🛋️', roomId: 'bedroom'),
  RoomItem(id: 'teddy_bear', name: 'Teddy Bear', emoji: '🧸', roomId: 'bedroom'),

  // Kitchen items
  RoomItem(id: 'frying_pan', name: 'Frying Pan', emoji: '🍳', roomId: 'kitchen'),
  RoomItem(id: 'pot', name: 'Pot', emoji: '🥘', roomId: 'kitchen'),
  RoomItem(id: 'knife', name: 'Knife', emoji: '🔪', roomId: 'kitchen'),
  RoomItem(id: 'refrigerator', name: 'Refrigerator', emoji: '🧊', roomId: 'kitchen'),
  RoomItem(id: 'microwave', name: 'Microwave', emoji: '📻', roomId: 'kitchen'),

  // Bathroom items
  RoomItem(id: 'toothbrush', name: 'Toothbrush', emoji: '🪥', roomId: 'bathroom'),
  RoomItem(id: 'soap', name: 'Soap', emoji: '🧼', roomId: 'bathroom'),
  RoomItem(id: 'towel', name: 'Towel', emoji: '🧺', roomId: 'bathroom'),
  RoomItem(id: 'bathtub', name: 'Bathtub', emoji: '🛁', roomId: 'bathroom'),
  RoomItem(id: 'toilet', name: 'Toilet', emoji: '🚽', roomId: 'bathroom'),

  // Living room items
  RoomItem(id: 'sofa', name: 'Sofa', emoji: '🛋️', roomId: 'living_room'),
  RoomItem(id: 'tv', name: 'Television', emoji: '📺', roomId: 'living_room'),
  RoomItem(id: 'book', name: 'Book', emoji: '📚', roomId: 'living_room'),
  RoomItem(id: 'plant', name: 'Plant', emoji: '🪴', roomId: 'living_room'),
  RoomItem(id: 'remote', name: 'Remote', emoji: '📱', roomId: 'living_room'),

  // Dining room items
  RoomItem(id: 'table', name: 'Table', emoji: '🪑', roomId: 'dining_room'),
  RoomItem(id: 'plate', name: 'Plate', emoji: '🍽️', roomId: 'dining_room'),
  RoomItem(id: 'fork', name: 'Fork', emoji: '🍴', roomId: 'dining_room'),
  RoomItem(id: 'glass', name: 'Glass', emoji: '🥛', roomId: 'dining_room'),
  RoomItem(id: 'candle', name: 'Candle', emoji: '🕯️', roomId: 'dining_room'),
];

class RoomMatcherState {
  final GamePhase phase;
  final List<Room> currentRooms;
  final List<RoomItem> itemPool;
  final Map<String, List<RoomItem>> placedItems;
  final int score;
  final int currentRound;
  final int totalRounds;
  final Room? learningRoom;
  final String lastPlacedItemName;

  const RoomMatcherState({
    required this.phase,
    required this.currentRooms,
    required this.itemPool,
    required this.placedItems,
    required this.score,
    required this.currentRound,
    this.totalRounds = 5,
    this.learningRoom,
    this.lastPlacedItemName = '',
  });

  RoomMatcherState copyWith({
    GamePhase? phase,
    List<Room>? currentRooms,
    List<RoomItem>? itemPool,
    Map<String, List<RoomItem>>? placedItems,
    int? score,
    int? currentRound,
    Room? learningRoom,
    String? lastPlacedItemName,
  }) {
    return RoomMatcherState(
      phase: phase ?? this.phase,
      currentRooms: currentRooms ?? this.currentRooms,
      itemPool: itemPool ?? this.itemPool,
      placedItems: placedItems ?? this.placedItems,
      score: score ?? this.score,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      learningRoom: learningRoom ?? this.learningRoom,
      lastPlacedItemName: lastPlacedItemName ?? this.lastPlacedItemName,
    );
  }
}

class RoomMatcherNotifier extends Notifier<RoomMatcherState> {
  final _random = Random();

  @override
  RoomMatcherState build() {
    return _generateNewRound(0, 1);
  }

  RoomMatcherState _generateNewRound(int score, int round) {
    // Pick 4 random rooms for this round
    final shuffledRooms = List<Room>.from(allRooms)..shuffle(_random);
    final selectedRooms = shuffledRooms.take(4).toList();

    // Get 1 item from each selected room (4 items total)
    final itemPool = <RoomItem>[];
    for (final room in selectedRooms) {
      final roomItems = allRoomItems.where((item) => item.roomId == room.id).toList();
      roomItems.shuffle(_random);
      if (roomItems.isNotEmpty) {
        itemPool.add(roomItems.first);
      }
    }
    itemPool.shuffle(_random);

    // Initialize placed items map
    final placedItems = <String, List<RoomItem>>{};
    for (final room in selectedRooms) {
      placedItems[room.id] = [];
    }

    // Pick a random room for learning phase
    final learningRoom = selectedRooms[_random.nextInt(selectedRooms.length)];

    return RoomMatcherState(
      phase: GamePhase.learning,
      currentRooms: selectedRooms,
      itemPool: itemPool,
      placedItems: placedItems,
      score: score,
      currentRound: round,
      learningRoom: learningRoom,
    );
  }

  void startTesting() {
    state = state.copyWith(phase: GamePhase.testing);
  }

  /// Returns true if item was placed correctly
  bool placeItem(String roomId, RoomItem item) {
    if (state.phase != GamePhase.testing) return false;

    final isCorrect = item.roomId == roomId;

    if (isCorrect) {
      // Add item to the room
      final newPlacedItems = Map<String, List<RoomItem>>.from(state.placedItems);
      newPlacedItems[roomId] = [...(newPlacedItems[roomId] ?? []), item];

      // Remove item from pool
      final newPool = state.itemPool.where((i) => i.id != item.id).toList();

      state = state.copyWith(
        placedItems: newPlacedItems,
        itemPool: newPool,
        lastPlacedItemName: item.name,
      );

      // Check if all items are placed
      if (newPool.isEmpty) {
        state = state.copyWith(phase: GamePhase.success, score: state.score + 1);
      }
    }

    return isCorrect;
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Reset game
      state = _generateNewRound(0, 1);
    } else {
      state = _generateNewRound(state.score, state.currentRound + 1);
    }
  }

  void resetGame() {
    state = _generateNewRound(0, 1);
  }

  List<RoomItem> getItemsForRoom(String roomId) {
    return allRoomItems.where((item) => item.roomId == roomId).toList();
  }
}

final roomMatcherProvider = NotifierProvider<RoomMatcherNotifier, RoomMatcherState>(() {
  return RoomMatcherNotifier();
}, isAutoDispose: true);

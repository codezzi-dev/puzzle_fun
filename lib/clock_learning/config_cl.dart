import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ClockGamePhase { learning, testing, success }

class ClockState {
  final int targetHour;
  final int targetMinute;
  final int currentHour;
  final int currentMinute;
  final ClockGamePhase phase;
  final int score;
  final int totalRounds;
  final int currentRound;
  final Color themeColor;

  const ClockState({
    required this.targetHour,
    required this.targetMinute,
    required this.currentHour,
    required this.currentMinute,
    required this.phase,
    required this.score,
    required this.totalRounds,
    required this.currentRound,
    required this.themeColor,
  });

  factory ClockState.initial() {
    final random = Random();
    // For preschoolers, start with simple "o'clock" times (minute = 0)
    final targetHour = random.nextInt(12) + 1; // 1-12
    final targetMinute = 0; // Start simple with o'clock times

    final themeColors = [
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.purple,
      Colors.deepPurple,
      Colors.cyan,
      Colors.lightBlue,
      Colors.blueGrey,
    ];

    return ClockState(
      targetHour: targetHour,
      targetMinute: targetMinute,
      currentHour: 12, // Start at 12 o'clock position
      currentMinute: 0,
      phase: ClockGamePhase.learning,
      score: 0,
      totalRounds: 5,
      currentRound: 1,
      themeColor: themeColors[random.nextInt(themeColors.length)],
    );
  }

  ClockState copyWith({
    int? targetHour,
    int? targetMinute,
    int? currentHour,
    int? currentMinute,
    ClockGamePhase? phase,
    int? score,
    int? totalRounds,
    int? currentRound,
    Color? themeColor,
  }) {
    return ClockState(
      targetHour: targetHour ?? this.targetHour,
      targetMinute: targetMinute ?? this.targetMinute,
      currentHour: currentHour ?? this.currentHour,
      currentMinute: currentMinute ?? this.currentMinute,
      phase: phase ?? this.phase,
      score: score ?? this.score,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      themeColor: themeColor ?? this.themeColor,
    );
  }

  /// Get time as spoken text
  String get spokenTime {
    if (targetMinute == 0) {
      return "$targetHour o'clock";
    } else if (targetMinute == 30) {
      return "half past $targetHour";
    } else if (targetMinute == 15) {
      return "quarter past $targetHour";
    } else if (targetMinute == 45) {
      return "quarter to ${targetHour == 12 ? 1 : targetHour + 1}";
    } else {
      return "$targetHour:${targetMinute.toString().padLeft(2, '0')}";
    }
  }

  /// Check if current time matches target time
  bool get isCorrect {
    return currentHour == targetHour && currentMinute == targetMinute;
  }
}

class ClockNotifier extends Notifier<ClockState> {
  final Random _random = Random();

  @override
  ClockState build() {
    return ClockState.initial();
  }

  void goToTest() {
    state = state.copyWith(phase: ClockGamePhase.testing);
  }

  void updateHourHand(int hour) {
    // Clamp hour to 1-12 range
    int clampedHour = hour;
    if (clampedHour < 1) clampedHour = 12;
    if (clampedHour > 12) clampedHour = 12;
    state = state.copyWith(currentHour: clampedHour);
  }

  void updateMinuteHand(int minute) {
    // Clamp minute to 0-59 range
    int clampedMinute = minute % 60;
    if (clampedMinute < 0) clampedMinute += 60;
    state = state.copyWith(currentMinute: clampedMinute);
  }

  void checkAnswer() {
    if (state.isCorrect) {
      state = state.copyWith(phase: ClockGamePhase.success, score: state.score + 1);
    }
  }

  void nextRound() {
    if (state.currentRound >= state.totalRounds) {
      // Game complete, restart
      state = ClockState.initial();
    } else {
      // Generate new target time
      final newHour = _random.nextInt(12) + 1;
      // For preschoolers, keep minutes simple (0, 15, 30, 45)
      final minuteOptions = [0, 0, 0, 15, 30, 45]; // More weight on o'clock
      final newMinute = minuteOptions[_random.nextInt(minuteOptions.length)];

      final themeColors = [
        Colors.indigo,
        Colors.blue,
        Colors.teal,
        Colors.purple,
        Colors.deepPurple,
        Colors.cyan,
        Colors.lightBlue,
        Colors.blueGrey,
      ];

      state = state.copyWith(
        targetHour: newHour,
        targetMinute: newMinute,
        currentHour: 12,
        currentMinute: 0,
        phase: ClockGamePhase.learning,
        currentRound: state.currentRound + 1,
        themeColor: themeColors[_random.nextInt(themeColors.length)],
      );
    }
  }
}

final clockProvider = NotifierProvider<ClockNotifier, ClockState>(() {
  return ClockNotifier();
}, isAutoDispose: true);

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'tts_service.dart';

/// Shared audio service for playing victory sounds across all games
class VictoryAudioService {
  static final VictoryAudioService _instance = VictoryAudioService._internal();
  factory VictoryAudioService() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Completer<void>? _completionCompleter;

  VictoryAudioService._internal() {
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_completionCompleter != null && !_completionCompleter!.isCompleted) {
        _completionCompleter!.complete();
      }
      _completionCompleter = null;
    });
  }

  /// Play the clapping/victory sound
  Future<void> playVictorySound() async {
    try {
      await tts.stop(); // Stop any ongoing speech
      await stop(); // Ensure previous completion is handled
      await _audioPlayer.play(AssetSource('music/clapping.mp3'));
      _completionCompleter = Completer<void>();
    } catch (e) {
      debugPrint('Error playing victory sound: $e');
    }
  }

  /// Wait for the current audio to complete OR be stopped
  Future<void> waitForCompletion() async {
    if (_completionCompleter != null) {
      await _completionCompleter!.future;
    }
  }

  /// Stop any playing audio and resolve pending completion
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      if (_completionCompleter != null && !_completionCompleter!.isCompleted) {
        _completionCompleter!.complete();
      }
      _completionCompleter = null;
    } catch (e) {
      debugPrint('Error stopping victory audio: $e');
    }
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}

/// Global instance for easy access
final victoryAudio = VictoryAudioService();

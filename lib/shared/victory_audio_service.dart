import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Shared audio service for playing victory sounds across all games
class VictoryAudioService {
  static final VictoryAudioService _instance = VictoryAudioService._internal();
  factory VictoryAudioService() => _instance;
  VictoryAudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Play the clapping/victory sound
  Future<void> playVictorySound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('music/clapping.mp3'));
    } catch (e) {
      // Silently fail if audio can't be played
      debugPrint('Error playing victory sound: $e');
    }
  }

  /// Stop any playing audio
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}

/// Global instance for easy access
final victoryAudio = VictoryAudioService();

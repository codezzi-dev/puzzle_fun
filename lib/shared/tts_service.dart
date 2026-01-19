import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'victory_audio_service.dart';

/// Shared TTS service for consistent voice feedback across all games.
/// Automatically stops previous speech before starting new speech.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS with child-friendly settings
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.4); // Slower for children
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.2); // Slightly higher pitch for friendliness
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  /// Speak text, automatically stopping any previous speech first.
  /// This ensures new commands immediately interrupt old ones.
  Future<void> speak(String text) async {
    try {
      await victoryAudio.stop(); // Stop any ongoing victory music
      await _flutterTts.stop(); // Stop any ongoing speech first
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  /// Stop any ongoing speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  /// Dispose the TTS engine
  void dispose() {
    _flutterTts.stop();
  }
}

/// Global instance for easy access across all games
final tts = TtsService();

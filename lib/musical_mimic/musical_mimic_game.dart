import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_mm.dart';

class MusicalMimicGame extends ConsumerStatefulWidget {
  const MusicalMimicGame({super.key});

  @override
  ConsumerState<MusicalMimicGame> createState() => _MusicalMimicGameState();
}

class _MusicalMimicGameState extends ConsumerState<MusicalMimicGame> with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnim;

  int _displayingIndex = -1;
  int _activeKeyIndex = -1; // Key currently glowing
  Timer? _sequenceTimer;
  MimicGamePhase? _lastSpokenPhase;

  // Audio player for piano tones
  final AudioPlayer _tonePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    tts.init();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _overlayScaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _overlayController, curve: Curves.elasticOut));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, 0.0),
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
  }

  void _speak(String text) {
    tts.speak(text);
  }

  @override
  void dispose() {
    tts.stop();
    victoryAudio.stop();
    _tonePlayer.dispose();
    _overlayController.dispose();
    _shakeController.dispose();
    _sequenceTimer?.cancel();
    super.dispose();
  }

  /// Play a piano tone for the given key index
  Future<void> _playTone(int keyIndex) async {
    try {
      // Using simple beep sounds for different keys
      final url = 'https://www.soundjay.com/button/beep-0${(keyIndex % 3) + 7}.mp3';
      await _tonePlayer.stop();
      await _tonePlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error playing tone: $e');
    }
  }

  Future<void> _speakSuccess() async {
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    _speak("Amazing! You played it perfectly!");
  }

  void _startSequence(MimicState state) {
    setState(() {
      _displayingIndex = 0;
      _activeKeyIndex = state.sequence[0];
    });
    _playTone(state.sequence[0]);
    _speak(pianoKeys[state.sequence[0]].label);

    _sequenceTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_displayingIndex >= state.sequence.length - 1) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _displayingIndex = -1;
              _activeKeyIndex = -1;
            });
            ref.read(mimicProvider.notifier).startTesting();
          }
        });
      } else {
        setState(() {
          _displayingIndex++;
          _activeKeyIndex = state.sequence[_displayingIndex];
        });
        _playTone(state.sequence[_displayingIndex]);
        _speak(pianoKeys[state.sequence[_displayingIndex]].label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mimicProvider);
    final notifier = ref.read(mimicProvider.notifier);

    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == MimicGamePhase.learning) {
        _speak("Listen to the melody!");
        Future.delayed(const Duration(milliseconds: 1200), () => _startSequence(state));
      } else if (state.phase == MimicGamePhase.testing) {
        _speak("Now play it back!");
      } else if (state.phase == MimicGamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      } else if (state.phase == MimicGamePhase.failure) {
        _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
        _speak("Oops! Let's try that one again.");
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              state.themeColor.withValues(alpha: 0.15),
              Colors.white,
              const Color(0xFFF3E5F5),
              state.themeColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, state),
                  Expanded(child: _buildContent(state, notifier)),
                ],
              ),
              if (state.phase == MimicGamePhase.success) _buildSuccessOverlay(state, notifier),
              if (state.phase == MimicGamePhase.failure) _buildFailureOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MimicState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              tts.stop();
              victoryAudio.stop();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: state.themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: state.themeColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.music_note_rounded, color: state.themeColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${state.score}/${state.totalRounds}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: state.themeColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Round ${state.currentRound}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: state.themeColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MimicState state, MimicNotifier notifier) {
    if (state.phase == MimicGamePhase.learning) {
      return _buildLearningMode(state);
    }
    return _buildTestingMode(state, notifier);
  }

  Widget _buildLearningMode(MimicState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [state.themeColor, Colors.purple, Colors.pink],
          ).createShader(bounds),
          child: const Text(
            "🎵 Listen & Watch! 🎵",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Remember the melody",
          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 60),
        // Piano keys display
        _buildPianoKeys(state, null, isLearning: true),
        const SizedBox(height: 40),
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(state.sequence.length, (index) {
            bool isDone =
                index < _displayingIndex ||
                (_displayingIndex == -1 && state.phase == MimicGamePhase.testing);
            bool isCurrent = index == _displayingIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: isCurrent ? 20 : 15,
              height: isCurrent ? 20 : 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? pianoKeys[state.sequence[index]].color
                    : isDone
                    ? state.themeColor
                    : Colors.grey.shade300,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: pianoKeys[state.sequence[index]].color.withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTestingMode(MimicState state, MimicNotifier notifier) {
    return SlideTransition(
      position: _shakeAnim,
      child: Column(
        children: [
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.pink, Colors.purple, state.themeColor],
            ).createShader(bounds),
            child: const Text(
              "🎹 Your Turn! 🎹",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          // User input progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.sequence.length, (index) {
              bool isFilled = index < state.userInput.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isFilled
                      ? pianoKeys[state.userInput[index]].color.withValues(alpha: 0.3)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFilled
                        ? pianoKeys[state.userInput[index]].color
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: pianoKeys[state.userInput[index]].color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    isFilled ? pianoKeys[state.userInput[index]].label : "?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isFilled
                          ? pianoKeys[state.userInput[index]].color
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          // Piano keys
          _buildPianoKeys(state, notifier, isLearning: false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPianoKeys(MimicState state, MimicNotifier? notifier, {required bool isLearning}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pianoKeys.length, (index) {
          final key = pianoKeys[index];
          final isActive = _activeKeyIndex == index;

          return GestureDetector(
            onTapDown: isLearning
                ? null
                : (_) {
                    setState(() => _activeKeyIndex = index);
                    _playTone(index);
                    _speak(key.label);
                    notifier?.checkKey(index);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) setState(() => _activeKeyIndex = -1);
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 44 : 40,
              height: isActive ? 140 : 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    key.color,
                    key.color.withValues(alpha: 0.8),
                    key.color.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? key.glowColor.withValues(alpha: 0.8)
                        : key.color.withValues(alpha: 0.3),
                    blurRadius: isActive ? 25 : 10,
                    spreadRadius: isActive ? 5 : 0,
                    offset: const Offset(0, 4),
                  ),
                  if (isActive)
                    BoxShadow(
                      color: key.glowColor.withValues(alpha: 0.6),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      key.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSuccessOverlay(MimicState state, MimicNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: state.themeColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show the sequence keys
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: state.sequence.map((keyIndex) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: pianoKeys[keyIndex].color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: pianoKeys[keyIndex].color, width: 2),
                      ),
                      child: Text(
                        pianoKeys[keyIndex].label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: pianoKeys[keyIndex].color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  '🎉 BRAVO! 🎉',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'re a Music Master!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                _buildAnimatedButton(
                  onPressed: () {
                    victoryAudio.stop();
                    notifier.nextRound();
                  },
                  gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  text: state.currentRound >= state.totalRounds ? 'Play Again!' : 'Next Level!',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureOverlay(MimicState state, MimicNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎹 Oops!", style: TextStyle(fontSize: 40)),
              const SizedBox(height: 20),
              const Text(
                "That wasn't quite right.\nLet's try again!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              _buildAnimatedButton(
                onPressed: () => notifier.retryRound(),
                gradientColors: [Colors.orange, Colors.deepOrange],
                icon: Icons.replay_rounded,
                text: "Try Again",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    required IconData icon,
    required String text,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

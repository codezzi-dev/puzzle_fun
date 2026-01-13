import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_ps.dart';

class PatternSafariGame extends ConsumerStatefulWidget {
  const PatternSafariGame({super.key});

  @override
  ConsumerState<PatternSafariGame> createState() => _PatternSafariGameState();
}

class _PatternSafariGameState extends ConsumerState<PatternSafariGame>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnim;

  int _displayingIndex = -1;
  Timer? _sequenceTimer;
  SafariGamePhase? _lastSpokenPhase;

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
    _overlayController.dispose();
    _shakeController.dispose();
    _sequenceTimer?.cancel();
    super.dispose();
  }

  void _startSequence(SafariState state) {
    setState(() => _displayingIndex = 0);
    _speakAnimal(state.sequence[0].name);

    _sequenceTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_displayingIndex >= state.sequence.length - 1) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _displayingIndex = -1);
            ref.read(safariProvider.notifier).startTesting();
          }
        });
      } else {
        setState(() => _displayingIndex++);
        _speakAnimal(state.sequence[_displayingIndex].name);
      }
    });
  }

  void _speakAnimal(String name) {
    _speak(name);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safariProvider);
    final notifier = ref.read(safariProvider.notifier);

    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == SafariGamePhase.learning) {
        _speak("Watch the pattern!");
        Future.delayed(const Duration(milliseconds: 1000), () => _startSequence(state));
      } else if (state.phase == SafariGamePhase.testing) {
        _speak("Can you repeat the pattern?");
      } else if (state.phase == SafariGamePhase.success) {
        _overlayController.forward(from: 0);
        victoryAudio.playVictorySound();
        _speak("Amazing! You remembered them all!");
      } else if (state.phase == SafariGamePhase.failure) {
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
              const Color(0xFFF1F8E9),
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
              if (state.phase == SafariGamePhase.success) _buildSuccessOverlay(state, notifier),
              if (state.phase == SafariGamePhase.failure) _buildFailureOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, SafariState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
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
                Icon(Icons.star_rounded, color: state.themeColor, size: 24),
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

  Widget _buildContent(SafariState state, SafariNotifier notifier) {
    if (state.phase == SafariGamePhase.learning) {
      return _buildLearningMode(state);
    }
    return _buildTestingMode(state, notifier);
  }

  Widget _buildLearningMode(SafariState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Watch Carefully!",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 10),
        const Text(
          "Remember the animal order",
          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 60),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _displayingIndex != -1
                ? Container(
                    key: ValueKey(_displayingIndex),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: state.sequence[_displayingIndex].color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: state.sequence[_displayingIndex].color, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        state.sequence[_displayingIndex].emoji,
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                  )
                : const SizedBox(width: 200, height: 200),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(state.sequence.length, (index) {
            bool isDone =
                index < _displayingIndex ||
                (_displayingIndex == -1 && state.phase == SafariGamePhase.testing);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? state.themeColor : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTestingMode(SafariState state, SafariNotifier notifier) {
    return SlideTransition(
      position: _shakeAnim,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Repeat the Pattern!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 40),
          // User input progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.sequence.length, (index) {
              bool isFilled = index < state.userInput.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isFilled
                      ? state.userInput[index].color.withValues(alpha: 0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isFilled ? state.userInput[index].color : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    isFilled ? state.userInput[index].emoji : "?",
                    style: TextStyle(fontSize: 30, color: isFilled ? null : Colors.grey.shade300),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 60),
          // Animals grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: safariAnimals.length,
                itemBuilder: (context, index) {
                  final animal = safariAnimals[index];
                  return GestureDetector(
                    onTap: () {
                      _speak(animal.name);
                      notifier.checkAnimal(animal);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(animal.emoji, style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay(SafariState state, SafariNotifier notifier) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: state.sequence
                      .map((a) => Text(a.emoji, style: const TextStyle(fontSize: 30)))
                      .toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FANTASTIC!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Safari Memory Master!',
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

  Widget _buildFailureOverlay(SafariState state, SafariNotifier notifier) {
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
              const Text("🤔 Oops!", style: TextStyle(fontSize: 40)),
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

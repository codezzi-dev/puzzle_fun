import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../shared/victory_audio_service.dart';
import 'config_mm.dart';
import 'widgets/mystery_card.dart';

class MissingMysteryGame extends ConsumerStatefulWidget {
  const MissingMysteryGame({super.key});

  @override
  ConsumerState<MissingMysteryGame> createState() => _MissingMysteryGameState();
}

class _MissingMysteryGameState extends ConsumerState<MissingMysteryGame>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  // Animations
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnim;
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;

  MemoryPhase? _lastSpokenPhase;

  @override
  void initState() {
    super.initState();
    _initTts();

    // Bounce animation for cards
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    // Sparkle/Floating animation
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _sparkleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_sparkleController);

    // Overlay animation
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _overlayScaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _overlayController, curve: Curves.elasticOut));
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.2);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _bounceController.dispose();
    _sparkleController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missingMysteryProvider);
    final notifier = ref.read(missingMysteryProvider.notifier);

    // Phase Change logic for TTS
    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == MemoryPhase.learning) {
        _speak("Remember these five characters!");
      } else if (state.phase == MemoryPhase.testing) {
        _speak("Which one is missing?");
      } else if (state.phase == MemoryPhase.success) {
        _overlayController.forward(from: 0);
        _speak("Amazing! You found it!");
        victoryAudio.playVictorySound();
      } else if (state.phase == MemoryPhase.failure) {
        _speak("Not quite! Look carefully.");
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE0F7FA),
              const Color(0xFFF3E5F5),
              const Color(0xFFE1F5FE).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingDecorations(),
              Column(
                children: [
                  _buildAppBar(context, state),
                  Expanded(child: _buildGameContent(state, notifier)),
                ],
              ),
              if (state.phase == MemoryPhase.success) _buildSuccessOverlay(state, notifier),
              if (state.phase == MemoryPhase.failure) _buildFailureOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: 40,
          child: AnimatedBuilder(
            animation: _sparkleAnim,
            builder: (context, child) => Transform.rotate(
              angle: _sparkleAnim.value * 2 * math.pi,
              child: Opacity(
                opacity: 0.2,
                child: Icon(Icons.star, size: 40, color: Colors.amber.shade300),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: 30,
          child: AnimatedBuilder(
            animation: _sparkleAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, math.sin(_sparkleAnim.value * 2 * math.pi) * 20),
              child: Opacity(
                opacity: 0.15,
                child: Icon(Icons.favorite, size: 35, color: Colors.pink.shade200),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, MissingMysteryState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            color: Colors.blueGrey,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${state.score}/${state.totalRounds}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Text(
              '${state.currentRound}/${state.totalRounds}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildGameContent(MissingMysteryState state, MissingMysteryNotifier notifier) {
    switch (state.phase) {
      case MemoryPhase.learning:
        return _buildLearningPage(state, notifier);
      case MemoryPhase.testing:
      case MemoryPhase.failure:
      case MemoryPhase.success:
        return _buildTestPage(state, notifier);
    }
  }

  Widget _buildLearningPage(MissingMysteryState state, MissingMysteryNotifier notifier) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: Column(
                children: [
                  const Text(
                    "Look Closely!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Remember these 5 items",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -_bounceAnim.value),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(state.sequence.length, (index) {
                    return MysteryCard(
                      content: state.sequence[index],
                      isHidden: false,
                      color: Colors.primaries[(index * 2 + 1) % Colors.primaries.length],
                      size: 80,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 80),
            _buildAnimatedButton(
              onPressed: () => notifier.goToTest(),
              gradientColors: const [Color(0xFF8AC926), Color(0xFF06D6A0)],
              icon: Icons.play_arrow_rounded,
              text: "I'm Ready!",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestPage(MissingMysteryState state, MissingMysteryNotifier notifier) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: Column(
                children: [
                  const Text(
                    "Which one's gone?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pick the missing item below",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(state.sequence.length, (index) {
                final isHidden = index == state.hiddenIndex;
                return MysteryCard(
                  content: state.sequence[index],
                  isHidden: isHidden,
                  color: Colors.primaries[(index * 2 + 1) % Colors.primaries.length],
                  size: 60,
                );
              }),
            ),
            const SizedBox(height: 60),
            Column(
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: state.options.map((option) {
                    return GestureDetector(
                      onTap: () => notifier.checkAnswer(option),
                      child: MysteryCard(content: option, color: Colors.blueAccent, size: 75),
                    );
                  }).toList(),
                ),
                if (state.phase == MemoryPhase.failure)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      "Try one more time! 🕵️",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    required IconData icon,
    required String text,
    Color? textColor,
  }) {
    final effectiveTextColor = textColor ?? Colors.white;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveTextColor, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: effectiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(MissingMysteryState state, MissingMysteryNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF81C784), Color(0xFF4CAF50)]),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🌟 HOORAY! 🌟",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                MysteryCard(
                  content: state.sequence[state.hiddenIndex],
                  color: const Color(0xFF4CAF50),
                  size: 100,
                ),
                const SizedBox(height: 30),
                _buildAnimatedButton(
                  onPressed: () {
                    notifier.nextRound();
                  },
                  gradientColors: const [Colors.white, Colors.white],
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  text: state.currentRound >= state.totalRounds ? "PLAY AGAIN" : "NEXT ROUND",
                  textColor: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureOverlay(MissingMysteryState state, MissingMysteryNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE57373), Color(0xFFF44336)]),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "OOH NO! 🥺",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "The correct one was:",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                MysteryCard(
                  content: state.sequence[state.hiddenIndex],
                  color: const Color(0xFFF44336),
                  size: 100,
                ),
                const SizedBox(height: 30),
                _buildAnimatedButton(
                  onPressed: () {
                    notifier.retry();
                  },
                  gradientColors: const [Colors.white, Colors.white],
                  icon: Icons.refresh_rounded,
                  text: "TRY AGAIN",
                  textColor: const Color(0xFFF44336),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

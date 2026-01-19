import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/tts_service.dart';
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
  // Learning page animations
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnim;

  // Success/Failure animations
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;

  // Button animation
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  GamePhase? _lastSpokenPhase;

  @override
  void initState() {
    super.initState();
    tts.init();

    // Bounce animation for cards
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(
      begin: 0.0,
      end: 12.0,
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

    // Button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
  }

  void _speak(String text) {
    tts.speak(text);
  }

  Future<void> _speakSuccess() async {
    final messages = ['Great job!', 'You found it!', 'Yay! That\'s right!', 'Awesome!'];
    final message = messages[math.Random().nextInt(messages.length)];
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    tts.speak(message);
  }

  @override
  void dispose() {
    tts.stop();
    victoryAudio.stop();
    _bounceController.dispose();
    _sparkleController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missingMysteryProvider);
    final notifier = ref.read(missingMysteryProvider.notifier);

    // Phase Change logic for TTS
    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == GamePhase.learning) {
        _speak("Remember these four characters!");
      } else if (state.phase == GamePhase.testing) {
        _speak("Which one is missing?");
      } else if (state.phase == GamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      } else if (state.motivationalMessage.isNotEmpty && state.phase == GamePhase.testing) {
        _speak(state.motivationalMessage);
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
              const Color(0xFFF3E5F5).withValues(alpha: 0.5),
              const Color(0xFFFFF8E1).withValues(alpha: 0.5),
              const Color(0xFFE1F5FE).withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
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
              if (state.phase == GamePhase.success) _buildSuccessOverlay(state, notifier),
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
                opacity: 0.25,
                child: Icon(Icons.star, size: 30, color: Colors.amber.shade300),
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
              offset: Offset(0, math.sin(_sparkleAnim.value * 2 * math.pi) * 15),
              child: Opacity(
                opacity: 0.2,
                child: Icon(Icons.favorite, size: 25, color: Colors.pink.shade300),
              ),
            ),
          ),
        ),
        Positioned(
          top: 250,
          right: 60,
          child: AnimatedBuilder(
            animation: _sparkleAnim,
            builder: (context, child) => Transform.scale(
              scale: 0.8 + (math.sin(_sparkleAnim.value * 2 * math.pi) * 0.2),
              child: Opacity(
                opacity: 0.15,
                child: Icon(Icons.circle, size: 20, color: Colors.blue.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, MissingMysteryState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              victoryAudio.stop();
              tts.stop();
              Navigator.pop(context);
            },

            color: const Color(0xFF6A4C93),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade400]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 22),
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Text(
              'Round ${state.currentRound}/${state.totalRounds}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A4C93),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildGameContent(MissingMysteryState state, MissingMysteryNotifier notifier) {
    switch (state.phase) {
      case GamePhase.learning:
        return _buildLearningPage(state, notifier);
      case GamePhase.testing:
      case GamePhase.failure:
      case GamePhase.success:
        return _buildTestPage(state, notifier);
    }
  }

  Widget _buildLearningPage(MissingMysteryState state, MissingMysteryNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: const Column(
            children: [
              Text(
                "Look Closely!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A148C),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Remember these items",
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
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
                  color: Colors.primaries[(index * 3 + 1) % Colors.primaries.length],
                  size: 80,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 80),
        _buildPremiumButton(
          onTap: () => notifier.goToTest(),
          text: "I'm Ready!",
          icon: Icons.play_arrow_rounded,
          colors: [const Color(0xFF8AC926), const Color(0xFF06D6A0)],
        ),
      ],
    );
  }

  Widget _buildTestPage(MissingMysteryState state, MissingMysteryNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: const Column(
            children: [
              Text(
                "Which one's gone?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1565C0),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Pick the missing item below",
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(state.sequence.length, (index) {
            final isHidden = index == state.hiddenIndex;
            return MysteryCard(
              content: state.sequence[index],
              isHidden: isHidden,
              color: Colors.primaries[(index * 3 + 1) % Colors.primaries.length],
              size: 65,
            );
          }),
        ),
        const SizedBox(height: 60),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: state.options.map((option) {
            return GestureDetector(
              onTap: () => notifier.checkAnswer(option),
              child: MysteryCard(content: option, color: const Color(0xFF6A4C93), size: 75),
            );
          }).toList(),
        ),
        if (state.motivationalMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              state.motivationalMessage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE57373),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumButton({
    required VoidCallback onTap,
    required String text,
    required IconData icon,
    required List<Color> colors,
    Color? textColor,
  }) {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: onTap,
      child: ScaleTransition(
        scale: _buttonScaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor ?? Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(MissingMysteryState state, MissingMysteryNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🌟 HOORAY! 🌟",
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 24),
                MysteryCard(
                  content: state.sequence[state.hiddenIndex],
                  color: const Color(0xFF43A047),
                  size: 110,
                ),
                const SizedBox(height: 32),
                _buildPremiumButton(
                  onTap: () {
                    victoryAudio.stop();
                    tts.stop();
                    notifier.nextRound();
                  },
                  text: state.currentRound >= state.totalRounds ? "PLAY AGAIN" : "NEXT ROUND",
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  colors: [Colors.white, Colors.white],
                  textColor: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

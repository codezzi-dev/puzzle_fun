import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_pm.dart';

class PatternMakerGame extends ConsumerStatefulWidget {
  const PatternMakerGame({super.key});

  @override
  ConsumerState<PatternMakerGame> createState() => _PatternMakerGameState();
}

class _PatternMakerGameState extends ConsumerState<PatternMakerGame> with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnim;
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  GamePhase? _lastPhase;
  int? _lastRound;

  @override
  void initState() {
    super.initState();
    tts.init();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _sparkleAnim = CurvedAnimation(parent: _sparkleController, curve: Curves.linear);

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _overlayScaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _overlayController, curve: Curves.elasticOut));

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
  }

  void _speak(String text) {
    tts.speak(text);
  }

  void _speakSuccess() {
    final messages = [
      'Perfect pattern!',
      'You are a pattern master!',
      'Brilliant matching!',
      'I love it!',
    ];
    final message = messages[math.Random().nextInt(messages.length)];
    tts.speak(message);
    victoryAudio.playVictorySound();
  }

  @override
  void dispose() {
    tts.stop();
    _sparkleController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patternMakerProvider);
    final notifier = ref.read(patternMakerProvider.notifier);

    // Phase/Round logic
    if (state.phase != _lastPhase || state.currentRound != _lastRound) {
      bool roundChanged = state.currentRound != _lastRound;
      _lastPhase = state.phase;
      _lastRound = state.currentRound;

      if (state.phase == GamePhase.playing && (roundChanged || _lastPhase == null)) {
        _speak(state.message);
      } else if (state.phase == GamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      } else if (state.phase == GamePhase.complete) {
        _overlayController.forward(from: 0);
        _speak("Amazing! You finished all the patterns!");
        victoryAudio.playVictorySound();
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8E1), Color(0xFFF3E5F5), Color(0xFFE1F5FE)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildDecorations(),
              Column(
                children: [
                  _buildAppBar(context, state),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPatternSequence(state, notifier),
                        const SizedBox(height: 60),
                        _buildOptionShelf(state, notifier),
                      ],
                    ),
                  ),
                  _buildMessageBox(state),
                  const SizedBox(height: 20),
                ],
              ),
              if (state.phase == GamePhase.success) _buildRoundSuccessOverlay(state, notifier),
              if (state.phase == GamePhase.complete) _buildCompleteOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorations() {
    return Stack(
      children: [
        _buildDecoration(Icons.auto_awesome, Colors.purple.withValues(alpha: 0.1), 80, 100, 30),
        _buildDecoration(Icons.favorite_rounded, Colors.pink.withValues(alpha: 0.1), 60, 400, 300),
        _buildDecoration(Icons.star_rounded, Colors.orange.withValues(alpha: 0.1), 100, 600, 50),
      ],
    );
  }

  Widget _buildDecoration(IconData icon, Color color, double size, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _sparkleAnim,
        builder: (context, child) => Transform.rotate(
          angle: _sparkleAnim.value * 2 * math.pi,
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PatternMakerState state) {
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
            color: const Color(0xFF6A1B9A),
          ),
          const Spacer(),
          _buildInfoChip(
            icon: Icons.auto_graph_rounded,
            text: '${state.score}',
            gradient: const [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
          ),
          const SizedBox(width: 12),
          _buildInfoChip(
            icon: Icons.flag_rounded,
            text: '${state.currentRound}/${state.totalRounds}',
            gradient: const [Color(0xFF26A69A), Color(0xFF00796B)],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildPatternSequence(PatternMakerState state, PatternMakerNotifier notifier) {
    return Wrap(
      spacing: 12,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: List.generate(state.sequence.length, (index) {
        final item = state.sequence[index];
        final isGap = index == state.missingIndex;

        if (isGap && item == null) {
          return DragTarget<PatternItem>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) {
              notifier.checkGuess(details.data);
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: candidateData.isNotEmpty ? Colors.green : Colors.grey.shade400,
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: candidateData.isNotEmpty ? Colors.green : Colors.grey.shade400,
                  ),
                ),
              );
            },
          );
        }

        return _buildItemCard(item!, isSuccess: state.phase == GamePhase.success && isGap);
      }),
    );
  }

  Widget _buildItemCard(PatternItem item, {bool isSuccess = false, double size = 75}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isSuccess
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSuccess ? 15 : 8,
            spreadRadius: isSuccess ? 5 : 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isSuccess ? Colors.green : Colors.white, width: 3),
      ),
      child: Center(
        child: Text(item.emoji, style: TextStyle(fontSize: size * 0.55)),
      ),
    );
  }

  Widget _buildOptionShelf(PatternMakerState state, PatternMakerNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: state.options.map((item) {
          return Draggable<PatternItem>(
            data: item,
            feedback: Material(color: Colors.transparent, child: _buildItemCard(item, size: 85)),
            childWhenDragging: Opacity(opacity: 0.3, child: _buildItemCard(item)),
            child: _buildItemCard(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBox(PatternMakerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Text(
        state.phase == GamePhase.success ? "" : state.message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
      ),
    );
  }

  Widget _buildRoundSuccessOverlay(PatternMakerState state, PatternMakerNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF43A047)],
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
                  "GREAT JOB! 🌟",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                _buildPremiumButton(
                  onTap: () {
                    victoryAudio.stop();
                    tts.stop();
                    if (state.currentRound >= state.totalRounds) {
                      notifier.completeGame();
                    } else {
                      notifier.nextRound();
                    }
                  },
                  text: state.currentRound >= state.totalRounds ? "FINISH" : "NEXT ROUND",
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.celebration_rounded
                      : Icons.arrow_forward_rounded,
                  colors: [Colors.white, Colors.white],
                  textColor: const Color(0xFF43A047),
                ),
              ],
            ),
          ),
        ),
      ),
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
                color: colors[0].withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteOverlay(PatternMakerState state, PatternMakerNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "PATTERN MASTER! 🌟",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  "You completed all ${state.totalRounds} patterns!",
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTapDown: (_) => _buttonController.forward(),
                  onTapUp: (_) => _buttonController.reverse(),
                  onTap: () {
                    victoryAudio.stop();
                    tts.stop();
                    notifier.reset();
                  },
                  child: ScaleTransition(
                    scale: _buttonScaleAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        "PLAY AGAIN",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B1FA2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_sm.dart';

class ShadowMatchGame extends ConsumerStatefulWidget {
  const ShadowMatchGame({super.key});

  @override
  ConsumerState<ShadowMatchGame> createState() => _ShadowMatchGameState();
}

class _ShadowMatchGameState extends ConsumerState<ShadowMatchGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnim;
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  GamePhase? _lastSpokenPhase;
  int? _lastRound;
  List<ShadowItem>? _shuffledDraggables;

  @override
  void initState() {
    super.initState();
    tts.init();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(
      begin: 0,
      end: 15,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

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

  Future<void> _speakSuccess() async {
    final messages = [
      'Great job!',
      'You matched them all!',
      'Yay! You\'re amazing!',
      'Awesome matching!',
    ];
    final message = messages[math.Random().nextInt(messages.length)];
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    _speak(message);
  }

  @override
  void dispose() {
    tts.stop();
    _bounceController.dispose();
    _sparkleController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shadowMatchProvider);
    final notifier = ref.read(shadowMatchProvider.notifier);

    // Phase Change logic
    if (state.phase != _lastSpokenPhase || state.currentRound != _lastRound) {
      _lastSpokenPhase = state.phase;
      _lastRound = state.currentRound;

      if (state.phase == GamePhase.playing) {
        _speak("Drag each item to its shadow!");
        _shuffledDraggables = List.from(state.currentItems)..shuffle();
      } else if (state.phase == GamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      }
    }

    // Safety check for initialization
    if (_shuffledDraggables == null && state.phase == GamePhase.playing) {
      _shuffledDraggables = List.from(state.currentItems)..shuffle();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5), Color(0xFFFFF3E0)],
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
        _buildDecoration(Icons.star_rounded, Colors.orange.withValues(alpha: 0.2), 30, 100, 50),
        _buildDecoration(Icons.favorite_rounded, Colors.pink.withValues(alpha: 0.15), 40, 300, 250),
        _buildDecoration(Icons.circle, Colors.blue.withValues(alpha: 0.1), 25, 500, 80),
        _buildDecoration(Icons.auto_awesome, Colors.purple.withValues(alpha: 0.15), 35, 700, 300),
      ],
    );
  }

  Widget _buildDecoration(IconData icon, Color color, double size, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, math.sin(_sparkleAnim.value * 2 * math.pi) * 10),
          child: Transform.rotate(
            angle: _sparkleAnim.value * 2 * math.pi,
            child: Icon(icon, color: color, size: size),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ShadowMatchState state) {
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
              gradient: const LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFFD81B60)]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  '${state.score}',
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: Color(0xFF6A4C93), size: 18),
                const SizedBox(width: 6),
                Text(
                  '${state.currentRound}/${state.totalRounds}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A4C93),
                  ),
                ),
              ],
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
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildGameContent(ShadowMatchState state, ShadowMatchNotifier notifier) {
    return _buildPlayingPage(state, notifier);
  }

  Widget _buildPlayingPage(ShadowMatchState state, ShadowMatchNotifier notifier) {
    return Row(
      children: [
        // Source Items
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (_shuffledDraggables ?? []).map((item) {
              final isMatched = state.matchedIds.contains(item.id);
              if (isMatched) return const SizedBox(height: 100);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Draggable<String>(
                  data: item.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildItemCard(item, false, size: 90),
                  ),
                  childWhenDragging: Opacity(opacity: 0.3, child: _buildItemCard(item, false)),
                  child: _buildItemCard(item, false),
                ),
              );
            }).toList(),
          ),
        ),
        // Target Shadows
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.currentItems.map((item) {
              final isMatched = state.matchedIds.contains(item.id);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (details) => details.data == item.id,
                  onAcceptWithDetails: (details) {
                    notifier.matchItem(item.id);
                    _speak("Great! That's the ${item.name}");
                  },
                  builder: (context, candidateData, rejectedData) {
                    return _buildItemCard(
                      item,
                      !isMatched,
                      isTarget: true,
                      isHighlighted: candidateData.isNotEmpty,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    ShadowItem item,
    bool isShadow, {
    double size = 80,
    bool isTarget = false,
    bool isHighlighted = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.green.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? Colors.green : (isTarget ? Colors.grey.shade300 : Colors.white),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isShadow
            ? ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                child: Text(item.emoji, style: TextStyle(fontSize: size * 0.6)),
              )
            : Text(item.emoji, style: TextStyle(fontSize: size * 0.6)),
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

  Widget _buildSuccessOverlay(ShadowMatchState state, ShadowMatchNotifier notifier) {
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
                colors: [Color(0xFFFFD166), Color(0xFFF78C6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "AMAZING! 🌟",
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  children: state.currentItems
                      .map((item) => Text(item.emoji, style: const TextStyle(fontSize: 40)))
                      .toList(),
                ),
                const SizedBox(height: 30),
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
                  textColor: const Color(0xFFF78C6B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

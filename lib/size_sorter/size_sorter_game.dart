import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_ss.dart';

class SizeSorterGame extends ConsumerStatefulWidget {
  const SizeSorterGame({super.key});

  @override
  ConsumerState<SizeSorterGame> createState() => _SizeSorterGameState();
}

class _SizeSorterGameState extends ConsumerState<SizeSorterGame> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnim;
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  GamePhase? _lastSpokenPhase;

  @override
  void initState() {
    super.initState();
    tts.init();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
      end: 0.92,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
  }

  void _speak(String text) {
    tts.speak(text);
  }

  Future<void> _speakSuccess() async {
    final messages = [
      'Fantastic!',
      'You organized them perfectly!',
      'Great eye for size!',
      'Well done!',
    ];
    final message = messages[math.Random().nextInt(messages.length)];
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    _speak(message);
  }

  @override
  void dispose() {
    tts.stop();
    _floatController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sizeSorterProvider);
    final notifier = ref.read(sizeSorterProvider.notifier);

    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == GamePhase.learning) {
        _speak("Look at how they go from small to big!");
      } else if (state.phase == GamePhase.testing) {
        _speak("Can you put them in the right boxes? Small, Medium, and Large!");
      } else if (state.phase == GamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF0F4C3),
              const Color(0xFFDCEDC8).withValues(alpha: 0.8),
              const Color(0xFFC5E1A5).withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingBackground(),
              Column(
                children: [
                  _buildHeader(context, state),
                  Expanded(child: _buildBody(state, notifier)),
                ],
              ),
              if (state.phase == GamePhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBackground() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 100 + _floatAnim.value,
              left: 30,
              child: Opacity(opacity: 0.1, child: Icon(Icons.cloud, size: 80, color: Colors.white)),
            ),
            Positioned(
              bottom: 150 - _floatAnim.value,
              right: 40,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.cloud, size: 100, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SizeSorterState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildCircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            color: const Color(0xFF33691E),
          ),
          const Spacer(),
          _buildStatBadge(
            icon: Icons.star_rounded,
            text: '${state.score}/${state.totalRounds}',
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatBadge(
            text: 'Round ${state.currentRound}/${state.totalRounds}',
            color: const Color(0xFF33691E),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
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
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildStatBadge({IconData? icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, color: color, size: 20), const SizedBox(width: 8)],
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SizeSorterState state, SizeSorterNotifier notifier) {
    if (state.phase == GamePhase.learning) {
      return _buildLearningView(state, notifier);
    }
    return _buildTestingView(state, notifier);
  }

  Widget _buildLearningView(SizeSorterState state, SizeSorterNotifier notifier) {
    final sortedItems = List<SorterItem>.from(state.pool)
      ..sort((a, b) => a.sizeScale.compareTo(b.sizeScale));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Look at the ${state.currentType}s!",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF33691E),
          ),
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: sortedItems.map((item) => _buildItemCard(item, false)).toList(),
        ),
        const SizedBox(height: 80),
        _buildPremiumButton(
          onTap: () => notifier.startTesting(),
          text: "I'm Ready!",
          icon: Icons.play_arrow_rounded,
          colors: [const Color(0xFF689F38), const Color(0xFF8BC34A)],
        ),
      ],
    );
  }

  Widget _buildTestingView(SizeSorterState state, SizeSorterNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Order by Size!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF33691E)),
        ),
        const SizedBox(height: 10),
        const Text(
          "Drag to the right box",
          style: TextStyle(fontSize: 16, color: Color(0xFF558B2F), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 40),
        // Drop targets
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDropBox(0, state.placements[0], "Small", notifier),
            _buildDropBox(1, state.placements[1], "Medium", notifier),
            _buildDropBox(2, state.placements[2], "Large", notifier),
          ],
        ),
        const SizedBox(height: 60),
        // Inventory
        Wrap(
          spacing: 20,
          children: state.pool.map((item) {
            return Draggable<SorterItem>(
              data: item,
              feedback: _buildItemCard(item, true),
              childWhenDragging: Opacity(opacity: 0.3, child: _buildItemCard(item, false)),
              child: _buildItemCard(item, false),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemCard(SorterItem item, bool isFeedback) {
    final size = 110.0 * item.sizeScale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: isFeedback
                ? []
                : [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: Icon(item.icon, size: size * 0.6, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDropBox(int index, SorterItem? item, String label, SizeSorterNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          DragTarget<SorterItem>(
            onWillAcceptWithDetails: (details) => item == null,
            onAcceptWithDetails: (details) {
              notifier.placeItem(index, details.data);
              if (details.data.sizeScale != [0.6, 0.8, 1.0][index]) {
                _speak("Not quite, that's not the $label box!");
              } else {
                final sizes = ["small", "medium", "big"];
                _speak("Great! That's the ${sizes[index]} one!");
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: candidateData.isNotEmpty ? Colors.white : Colors.white38,
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                ),
                child: item != null
                    ? Center(child: _buildItemCard(item, false))
                    : const Center(child: Icon(Icons.add, color: Colors.white38, size: 40)),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF33691E)),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.4),
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
                  fontSize: 22,
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

  Widget _buildSuccessOverlay(SizeSorterState state, SizeSorterNotifier notifier) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF81C784), Color(0xFF4CAF50)]),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 25)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🌟 AMAZING! 🌟",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 30),
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 100),
                const SizedBox(height: 40),
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
                  textColor: const Color(0xFF43A047),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

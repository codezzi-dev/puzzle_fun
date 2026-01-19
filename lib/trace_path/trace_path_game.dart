import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_tp.dart';
import 'widgets/path_painter.dart';

class TracePathGame extends ConsumerStatefulWidget {
  const TracePathGame({super.key});

  @override
  ConsumerState<TracePathGame> createState() => _TracePathGameState();
}

class _TracePathGameState extends ConsumerState<TracePathGame> with SingleTickerProviderStateMixin {
  late AnimationController _successController;
  late Animation<double> _successScale;

  int? _lastLevelIndex;

  @override
  void initState() {
    super.initState();
    tts.init();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    tts.stop();
    victoryAudio.stop();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _speakSuccess() async {
    final messages = ['Great job!', 'You traced it!', 'Yay! You\'re amazing!', 'Awesome tracing!'];
    final message = messages[math.Random().nextInt(messages.length)];
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    tts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tracePathProvider);
    final notifier = ref.read(tracePathProvider.notifier);

    // Speak instruction on level change
    if (_lastLevelIndex != state.currentLevelIndex) {
      _lastLevelIndex = state.currentLevelIndex;
      tts.speak(state.currentLevel.instruction);
    }

    if (state.isComplete && !_successController.isAnimating && _successController.value == 0) {
      _successController.forward();
      _speakSuccess();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              state.currentLevel.themeColor.withValues(alpha: 0.1),
              Colors.white,
              const Color(0xFFF3E5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, state, notifier),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildCanvas(state, notifier),
                    ),
                  ),
                ],
              ),
              if (state.isComplete) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TracePathState state, TracePathNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            color: state.currentLevel.themeColor,
          ),
          const Spacer(),
          Text(
            'Level ${state.currentLevelIndex + 1}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: state.currentLevel.themeColor,
            ),
          ),
          const Spacer(),
          _buildIconButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              notifier.resetLevel();
              _successController.reset();
            },
            color: Colors.grey,
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
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildCanvas(TracePathState state, TracePathNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // Instruction
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  state.currentLevel.instruction,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),

            // Start Animal
            Positioned(
              left: state.currentLevel.guidePoints.first.dx * canvasSize.width - 30,
              top: state.currentLevel.guidePoints.first.dy * canvasSize.height - 30,
              child: Text(state.currentLevel.animal, style: const TextStyle(fontSize: 50)),
            ),

            // Target
            Positioned(
              left: state.currentLevel.guidePoints.last.dx * canvasSize.width - 30,
              top: state.currentLevel.guidePoints.last.dy * canvasSize.height - 30,
              child: Text(state.currentLevel.target, style: const TextStyle(fontSize: 50)),
            ),

            // Custom Paint Layer
            GestureDetector(
              onPanUpdate: (details) {
                notifier.addPoint(details.localPosition, canvasSize);
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: PathPainter(
                  guidePoints: state.currentLevel.guidePoints,
                  userPoints: state.userPoints,
                  themeColor: state.currentLevel.themeColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuccessOverlay(TracePathState state, TracePathNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ScaleTransition(
          scale: _successScale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: state.currentLevel.themeColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.currentLevel.animal} ❤️ ${state.currentLevel.target}',
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 24),
                const Text(
                  'AMAZING!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You traced the path perfectly!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    victoryAudio.stop();
                    notifier.nextLevel();
                    _successController.reset();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          state.currentLevel.themeColor,
                          state.currentLevel.themeColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Next Level!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

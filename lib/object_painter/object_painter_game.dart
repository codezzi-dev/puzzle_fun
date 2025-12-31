import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../shared/victory_audio_service.dart';
import 'config_op.dart';
import 'widgets/color_palette.dart';
import 'widgets/colorable_object.dart';

class ObjectPainterGame extends ConsumerStatefulWidget {
  const ObjectPainterGame({super.key});

  @override
  ConsumerState<ObjectPainterGame> createState() => _ObjectPainterGameState();
}

class _ObjectPainterGameState extends ConsumerState<ObjectPainterGame>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final FlutterTts _tts = FlutterTts();
  String? _shakingPartId;
  List<ColorOption>? _currentColors;
  bool _showReference = false; // For hint overlay

  @override
  void initState() {
    super.initState();

    // Bounce animation for buttons
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    // Pulse animation for selected elements
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _initTts();

    // Listen for phase changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakLearning();
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.1);
  }

  Future<void> _speakLearning() async {
    final state = ref.read(objectPainterProvider);
    await _tts.speak("This is a ${state.currentObject.name}! Look at the pretty colors!");
  }

  Future<void> _speakColoring() async {
    await _tts.speak("Tap a color, then tap a shape to paint it!");
  }

  Future<void> _speakColorSelected(String colorName) async {
    await _tts.speak("$colorName!");
  }

  Future<void> _speakCorrect() async {
    await _tts.speak("Great job!");
  }

  Future<void> _speakWrong() async {
    await _tts.speak("Try again!");
  }

  Future<void> _speakSuccess() async {
    await _tts.speak(
      "Wonderful! You painted the ${ref.read(objectPainterProvider).currentObject.name} perfectly!",
    );
    victoryAudio.playVictorySound();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(objectPainterProvider);
    final notifier = ref.read(objectPainterProvider.notifier);

    // Generate colors for the object once per object
    _currentColors ??= notifier.getColorsForObject();

    // Regenerate colors when object changes
    ref.listen(objectPainterProvider.select((s) => s.currentObjectIndex), (_, _) {
      _currentColors = notifier.getColorsForObject();
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFFCE4EC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, notifier, state),
              Expanded(child: _buildGameContent(state, notifier)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ObjectPainterNotifier notifier,
    ObjectPainterState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              _buildIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  notifier.startNewGame();
                  Navigator.of(context).pop();
                },
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFFBE0B)],
                      ).createShader(bounds),
                      child: const Text(
                        '🎨 Object Painter 🖌️',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${state.currentObject.emoji} ${state.currentObject.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7B68EE), Color(0xFF9B59B6)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B68EE).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '${state.score}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.phase == ObjectPainterPhase.coloring) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Undo button
                GestureDetector(
                  onTap: () {
                    notifier.undoLastColor();
                    _tts.speak("Undo");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.undo_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Undo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Clear button
                GestureDetector(
                  onTap: () {
                    notifier.clearAllColors();
                    _tts.speak("Clear all");
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildGameContent(ObjectPainterState state, ObjectPainterNotifier notifier) {
    switch (state.phase) {
      case ObjectPainterPhase.learning:
        return _buildLearningPage(state, notifier);
      case ObjectPainterPhase.coloring:
        return _buildColoringPage(state, notifier);
      case ObjectPainterPhase.success:
        return Stack(
          children: [_buildColoringPage(state, notifier), _buildSuccessOverlay(state, notifier)],
        );
    }
  }

  Widget _buildLearningPage(ObjectPainterState state, ObjectPainterNotifier notifier) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Instructions
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(state.currentObject.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Look at the ${state.currentObject.name}!\nRemember the colors!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Reference object (large)
        Transform.scale(
          scale: 1.2,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: ColorableObject(
              object: state.currentObject,
              coloredParts: const {},
              isReference: true,
            ),
          ),
        ),

        const Spacer(),

        // Start coloring button
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(offset: Offset(0, _bounceAnimation.value), child: child);
          },
          child: _buildAnimatedButton(
            onPressed: () {
              notifier.goToColoring();
              _speakColoring();
            },
            gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFFBE0B)],
            icon: Icons.color_lens,
            text: "Start Coloring!",
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildColoringPage(ObjectPainterState state, ObjectPainterNotifier notifier) {
    // Get correct parts for checkmarks
    final correctParts = <String>{};
    for (var part in state.currentObject.parts) {
      if (state.isPartCorrect(part.id)) {
        correctParts.add(part.id);
      }
    }

    return Stack(
      children: [
        Column(
          children: [
            // Instructions with hint button
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎨 Pick a color, then tap a shape!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Progress indicator
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: state.correctCount / state.currentObject.parts.length,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${state.correctCount}/${state.currentObject.parts.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hint button
                  GestureDetector(
                    onTap: () => setState(() => _showReference = true),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Hint',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Large colorable object - takes maximum space
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ColorableObject(
                        object: state.currentObject,
                        coloredParts: state.coloredParts,
                        isReference: false,
                        correctParts: correctParts,
                        shakingPartId: _shakingPartId,
                        onPartTap: (part) => _handlePartTap(part, state, notifier),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Color palette at bottom
            if (_currentColors != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ColorPalette(
                  colors: _currentColors!,
                  selectedColor: state.selectedColor,
                  onColorSelected: (color, name) {
                    notifier.selectColor(color, name);
                    _speakColorSelected(name);
                  },
                ),
              ),
          ],
        ),

        // Reference overlay (when hint button is pressed)
        if (_showReference)
          GestureDetector(
            onTap: () => setState(() => _showReference = false),
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ColorableObject(
                        object: state.currentObject,
                        coloredParts: const {},
                        isReference: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.currentObject.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Text(
                            state.currentObject.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap anywhere to close',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handlePartTap(ObjectPart part, ObjectPainterState state, ObjectPainterNotifier notifier) {
    if (state.selectedColor == null) {
      _tts.speak("Pick a color first!");
      return;
    }

    if (state.isPartCorrect(part.id)) {
      // Already correctly colored
      _tts.speak("This ${part.shapeName} is done!");
      return;
    }

    final result = notifier.colorPart(part.id);

    if (result == 'correct') {
      _speakCorrect();
      // Check if all done
      if (ref.read(objectPainterProvider).phase == ObjectPainterPhase.success) {
        _speakSuccess();
      }
    } else if (result == 'incorrect') {
      _speakWrong();
      setState(() {
        _shakingPartId = part.id;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shakingPartId = null;
          });
        }
      });
    }
  }

  Widget _buildSuccessOverlay(ObjectPainterState state, ObjectPainterNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF5F5F5)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration
              const _CelebrationWidget(),
              const SizedBox(height: 16),

              // Success message
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFFBE0B)],
                ).createShader(bounds),
                child: const Text(
                  '🎉 Perfect! 🎉',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You painted the ',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  Text(state.currentObject.emoji, style: const TextStyle(fontSize: 24)),
                  Text(
                    ' ${state.currentObject.name}!',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Next object button
              _buildAnimatedButton(
                onPressed: () {
                  victoryAudio.stop();
                  notifier.nextObject();
                  _currentColors = null; // Reset colors for next object
                  _speakLearning();
                },
                gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFFBE0B)],
                icon: Icons.arrow_forward_rounded,
                text: "Next Object!",
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(30),
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

/// Celebration animation widget
class _CelebrationWidget extends StatefulWidget {
  const _CelebrationWidget();

  @override
  State<_CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<_CelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(8, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = (index / 8) * 2 * math.pi + _controller.value * 2 * math.pi;
              const radius = 30.0;
              return Transform.translate(
                offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
                child: _SparkleIcon(delay: index * 0.1),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Animated sparkle icon
class _SparkleIcon extends StatefulWidget {
  final double delay;

  const _SparkleIcon({this.delay = 0});

  @override
  State<_SparkleIcon> createState() => _SparkleIconState();
}

class _SparkleIconState extends State<_SparkleIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: const Text('✨', style: TextStyle(fontSize: 24)),
          ),
        );
      },
    );
  }
}

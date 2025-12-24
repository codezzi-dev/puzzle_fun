import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'config_rb.dart';
import 'widgets/draggable_shape.dart';
import 'widgets/robot_display.dart';

class RobotBuilderGame extends ConsumerStatefulWidget {
  const RobotBuilderGame({super.key});

  @override
  ConsumerState<RobotBuilderGame> createState() => _RobotBuilderGameState();
}

class _RobotBuilderGameState extends ConsumerState<RobotBuilderGame> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  RobotBuilderPhase? _lastSpokenPhase;
  List<RobotPart>? _shuffledParts;
  bool _showReference = false;

  @override
  void initState() {
    super.initState();
    _initTts();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

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

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
  }

  Future<void> _speakLearning() async {
    await _flutterTts.speak('Look at the robot! Remember where each shape goes.');
  }

  Future<void> _speakBuilding() async {
    await _flutterTts.speak('Now drag the shapes to build the robot!');
  }

  Future<void> _speakPlaced(String shapeName) async {
    await _flutterTts.speak('Great! $shapeName placed!');
  }

  Future<void> _speakSuccess() async {
    final messages = ['Amazing job!', 'You built the robot!', 'Wonderful!', 'Perfect!'];
    await _flutterTts.speak(messages[math.Random().nextInt(messages.length)]);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _bounceController.dispose();
    _pulseController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(robotBuilderProvider);
    final gameNotifier = ref.read(robotBuilderProvider.notifier);

    // Handle phase changes
    if (gameState.phase != _lastSpokenPhase) {
      _lastSpokenPhase = gameState.phase;

      if (gameState.phase == RobotBuilderPhase.learning) {
        _speakLearning();
        _shuffledParts = gameNotifier.getShuffledParts();
      } else if (gameState.phase == RobotBuilderPhase.building) {
        _speakBuilding();
      } else if (gameState.phase == RobotBuilderPhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFFCE4EC), Color(0xFFFFF8E1), Color(0xFFE8F5E9)],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, gameNotifier, gameState),
                  Expanded(child: _buildGameContent(gameState, gameNotifier)),
                ],
              ),
              if (gameState.phase == RobotBuilderPhase.success)
                _buildSuccessOverlay(gameState, gameNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    RobotBuilderNotifier notifier,
    RobotBuilderState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
            color: const Color(0xFF7B68EE),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.indigo.shade400]),
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
                const Icon(Icons.smart_toy, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  '${state.placedCount}/${state.currentRobot.parts.length}',
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
                  color: Colors.purple.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, color: Colors.purple.shade400, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${state.currentRobotIndex + 1}/${state.totalRobots}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.purple.shade400,
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

  Widget _buildGameContent(RobotBuilderState state, RobotBuilderNotifier notifier) {
    switch (state.phase) {
      case RobotBuilderPhase.learning:
        return _buildLearningPage(state, notifier);
      case RobotBuilderPhase.building:
      case RobotBuilderPhase.success:
        return _buildBuildingPage(state, notifier);
    }
  }

  Widget _buildLearningPage(RobotBuilderState state, RobotBuilderNotifier notifier) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Sparkle decorations
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SparkleIcon(delay: 0),
                const SizedBox(width: 8),
                _SparkleIcon(delay: 200),
                const SizedBox(width: 8),
                _SparkleIcon(delay: 400),
              ],
            ),
            const SizedBox(height: 16),
            // Speech bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.pink.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.pink.shade100, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('👋', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      Text(
                        'Hi! I\'m ${state.currentRobot.name}!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.pink.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remember where my parts go! 🧩',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Robot display with bounce and glow
            AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) =>
                  Transform.translate(offset: Offset(0, -_bounceAnim.value), child: child),
              child: ScaleTransition(
                scale: _pulseAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect behind robot
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.pink.withValues(alpha: 0.15), Colors.transparent],
                        ),
                      ),
                    ),
                    // Robot container
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                        border: Border.all(color: Colors.pink.shade100, width: 3),
                      ),
                      child: RobotDisplay(robot: state.currentRobot, showOutlineOnly: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Robot name badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade400, Colors.deepOrange.shade400],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    state.currentRobot.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Build button
            _buildAnimatedButton(
              onPressed: () => notifier.goToBuilding(),
              gradientColors: const [Color(0xFF8AC926), Color(0xFF06D6A0)],
              icon: Icons.build_rounded,
              text: "Let's Build! 🔧",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingPage(RobotBuilderState state, RobotBuilderNotifier notifier) {
    return Stack(
      children: [
        Column(
          children: [
            // Instructions with reference button
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '🔧 Drag shapes to the right spots!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  // Reference button
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

            // Robot with drop zones - takes maximum space
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
                        color: Colors.pink.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.pink.shade100, width: 2),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          children: state.currentRobot.parts.map((part) {
                            final isPlaced = state.placedParts[part.id] ?? false;
                            return Positioned(
                              left: part.position.dx,
                              top: part.position.dy,
                              child: DroppableSlot(
                                part: part,
                                isPlaced: isPlaced,
                                onAccept: (slotPart, draggedPart) {
                                  // Mark slot as filled AND dragged item as used
                                  notifier.placePartInSlot(slotPart.id, draggedPart.id);
                                  _speakPlaced(slotPart.shapeType);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Draggable shapes at bottom - horizontal scrollable row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🎯', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        'Pick the pieces!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.pink.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 85,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (_shuffledParts ?? state.currentRobot.parts).map((part) {
                            final isUsed = state.usedDraggables.contains(part.id);
                            if (isUsed) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: DraggableShape(part: part, isPlaced: false),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Reference overlay
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
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: RobotDisplay(robot: state.currentRobot, showOutlineOnly: false),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.currentRobot.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B68EE),
                        ),
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

  Widget _buildSuccessOverlay(RobotBuilderState state, RobotBuilderNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pink.shade400, Colors.deepOrange.shade400, Colors.amber.shade400],
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _CelebrationWidget(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: RobotDisplay(robot: state.currentRobot, showOutlineOnly: false),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        const Text(
                          'Amazing!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          'You built ${state.currentRobot.name}!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text('🎉', style: TextStyle(fontSize: 36)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildAnimatedButton(
                  onPressed: () => notifier.nextRobot(),
                  gradientColors: const [Color(0xFF06D6A0), Color(0xFF8AC926)],
                  icon: Icons.arrow_forward_rounded,
                  text: 'Next Robot! 🤖',
                ),
              ],
            ),
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
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) {
        _buttonController.reverse();
        onPressed();
      },
      onTapCancel: () => _buttonController.reverse(),
      child: ScaleTransition(
        scale: _buttonScaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: const Text('⭐', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 12),
            Transform.translate(
              offset: Offset(0, math.sin(_controller.value * 4 * math.pi) * 8),
              child: const Text('🤖', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(width: 12),
            Transform.rotate(
              angle: -_controller.value * 2 * math.pi,
              child: const Text('⭐', style: TextStyle(fontSize: 28)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated sparkle/star icon for child-friendly visual appeal
class _SparkleIcon extends StatefulWidget {
  final int delay;

  const _SparkleIcon({this.delay = 0});

  @override
  State<_SparkleIcon> createState() => _SparkleIconState();
}

class _SparkleIconState extends State<_SparkleIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotateAnim = Tween<double>(
      begin: 0,
      end: 0.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
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
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: Transform.rotate(
          angle: _rotateAnim.value,
          child: Text(
            '✨',
            style: TextStyle(
              fontSize: 24,
              shadows: [Shadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 8)],
            ),
          ),
        ),
      ),
    );
  }
}

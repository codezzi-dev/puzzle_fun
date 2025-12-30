import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../shared/victory_audio_service.dart';
import 'config_clm.dart';
import 'widgets/color_swatch.dart';
import 'widgets/colored_shape.dart';
import 'widgets/line_painter.dart';

class ColorMatchGame extends ConsumerStatefulWidget {
  const ColorMatchGame({super.key});

  @override
  ConsumerState<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends ConsumerState<ColorMatchGame> with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  // Keys for getting positions
  final Map<String, GlobalKey> _colorKeys = {};
  final Map<String, GlobalKey> _shapeKeys = {};

  // Positions for line drawing
  Map<String, Offset> _colorPositions = {};
  Map<String, Offset> _shapePositions = {};

  // Animation controllers
  late AnimationController _successController;
  late Animation<double> _successScaleAnim;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimations();

    // Speak intro after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakIntro();
    });
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.2);
  }

  void _initAnimations() {
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));
  }

  void _speakIntro() {
    _tts.speak('Match the colors! Draw a line from each color to the matching shape.');
  }

  void _speakSuccess() {
    _tts.speak('Perfect! You matched all the colors!');
    victoryAudio.playVictorySound();
  }

  void _speakCorrect(String colorName) {
    _tts.speak('Yes! $colorName is correct!');
  }

  @override
  void dispose() {
    _tts.stop();
    _successController.dispose();
    super.dispose();
  }

  // Key for the Stack to get correct reference
  final GlobalKey _stackKey = GlobalKey();

  void _updatePositions() {
    final newColorPositions = <String, Offset>{};
    final newShapePositions = <String, Offset>{};

    // Get the Stack's RenderBox for coordinate conversion
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;

    for (final entry in _colorKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        // Get global position of center, then convert to Stack-local coordinates
        final globalCenter = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
        final localCenter = stackBox.globalToLocal(globalCenter);
        newColorPositions[entry.key] = localCenter;
      }
    }

    for (final entry in _shapeKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final globalCenter = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
        final localCenter = stackBox.globalToLocal(globalCenter);
        newShapePositions[entry.key] = localCenter;
      }
    }

    if (newColorPositions.isNotEmpty && newShapePositions.isNotEmpty) {
      setState(() {
        _colorPositions = newColorPositions;
        _shapePositions = newShapePositions;
      });
    }
  }

  // Track last phase to detect changes
  ColorMatchPhase? _lastPhase;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(colorMatchProvider);
    final notifier = ref.read(colorMatchProvider.notifier);

    // Initialize keys
    for (final color in state.leftColors) {
      _colorKeys.putIfAbsent(color.id, () => GlobalKey());
    }
    for (final shape in state.rightShapes) {
      _shapeKeys.putIfAbsent(shape.id, () => GlobalKey());
    }

    // Update positions after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePositions());

    // Detect phase change and trigger success animation
    if (state.phase != _lastPhase) {
      _lastPhase = state.phase;
      if (state.phase == ColorMatchPhase.success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _successController.forward(from: 0);
          _speakSuccess();
        });
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFFCE4EC), Color(0xFFFFF8E1)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            key: _stackKey,
            children: [
              Column(
                children: [
                  _buildAppBar(notifier, state),
                  Expanded(child: _buildGameArea(state, notifier)),
                ],
              ),
              // Line painter overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: LinePainter(
                      connections: state.connections,
                      colorPositions: _colorPositions,
                      shapePositions: _shapePositions,
                      colors: state.leftColors,
                      activeColorId: state.activeColorId,
                      dragPosition: state.dragPosition,
                    ),
                  ),
                ),
              ),
              // Success overlay
              if (state.phase == ColorMatchPhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorMatchNotifier notifier, ColorMatchState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.pink, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎨 Color Match!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  'Round ${state.currentRound} of ${state.totalRounds}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.pink.shade400, Colors.orange.shade400]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
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
        ],
      ),
    );
  }

  Widget _buildGameArea(ColorMatchState state, ColorMatchNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('👆', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Drag from colors to matching shapes!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Main game content
          Expanded(
            child: Row(
              children: [
                // Left column - Colors
                Expanded(child: _buildColorColumn(state, notifier)),
                // Spacer for lines
                const SizedBox(width: 60),
                // Right column - Shapes
                Expanded(child: _buildShapeColumn(state, notifier)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorColumn(ColorMatchState state, ColorMatchNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Colors',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.pink.shade600),
        ),
        ...state.leftColors.map((color) {
          return ColorSwatchItem(
            item: color,
            isConnected: state.isColorConnected(color.id),
            isActive: state.activeColorId == color.id,
            itemKey: _colorKeys[color.id]!,
            onDragStart: (id, pos) {
              notifier.startDrag(id, pos);
              _tts.speak(color.name);
            },
            onDragUpdate: (pos) => notifier.updateDrag(pos),
            onDragEnd: () {
              // Check if we're over a shape
              _tryConnect(state, notifier);
            },
          );
        }),
      ],
    );
  }

  Widget _buildShapeColumn(ColorMatchState state, ColorMatchNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Shapes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blue.shade600),
        ),
        ...state.rightShapes.map((shape) {
          final isHovering = _isHoveringShape(state, shape.id);
          return ColoredShape(
            item: shape,
            isConnected: state.isShapeConnected(shape.id),
            isHovering: isHovering,
            itemKey: _shapeKeys[shape.id]!,
            onDropped: (shapeId) {
              if (state.activeColorId != null) {
                _makeConnection(state, notifier, state.activeColorId!, shapeId);
              }
            },
          );
        }),
      ],
    );
  }

  bool _isHoveringShape(ColorMatchState state, String shapeId) {
    if (state.activeColorId == null || state.dragPosition == null) return false;

    final shapePos = _shapePositions[shapeId];
    if (shapePos == null) return false;

    final distance = (state.dragPosition! - shapePos).distance;
    return distance < 50; // Within 50 pixels
  }

  void _tryConnect(ColorMatchState state, ColorMatchNotifier notifier) {
    if (state.activeColorId == null || state.dragPosition == null) {
      notifier.endDrag();
      return;
    }

    // Find if we're over any shape
    for (final entry in _shapePositions.entries) {
      final distance = (state.dragPosition! - entry.value).distance;
      if (distance < 50) {
        _makeConnection(state, notifier, state.activeColorId!, entry.key);
        return;
      }
    }

    notifier.endDrag();
  }

  void _makeConnection(
    ColorMatchState state,
    ColorMatchNotifier notifier,
    String colorId,
    String shapeId,
  ) {
    final color = state.leftColors.firstWhere((c) => c.id == colorId);
    final shape = state.rightShapes.firstWhere((s) => s.id == shapeId);

    if (color.id == shape.color.id) {
      // Correct match
      _speakCorrect(color.name);
      notifier.makeConnection(colorId, shapeId);
    } else {
      // Wrong match
      _tts.speak('Try again!');
      notifier.endDrag();
    }
  }

  Widget _buildSuccessOverlay(ColorMatchState state, ColorMatchNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _successScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade400, Colors.orange.shade400, Colors.amber.shade400],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 Perfect! 🎉',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'You matched all ${state.leftColors.length} colors!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    victoryAudio.stop();
                    notifier.nextRound();
                    _speakIntro();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward_rounded, color: Colors.pink.shade500, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Next Round!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade500,
                          ),
                        ),
                      ],
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

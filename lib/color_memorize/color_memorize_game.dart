import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'config_cm.dart';
import 'widgets/character_painters.dart';

class ColorMemorize extends ConsumerStatefulWidget {
  const ColorMemorize({super.key});

  @override
  ConsumerState<ColorMemorize> createState() => _ColorMemorizeState();
}

class _ColorMemorizeState extends ConsumerState<ColorMemorize> with TickerProviderStateMixin {
  // Text-to-Speech
  final FlutterTts _flutterTts = FlutterTts();

  // Learning page animations
  late AnimationController _characterBounceController;
  late Animation<double> _characterBounceAnim;
  late AnimationController _colorPulseController;
  late Animation<double> _colorPulseAnim;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnim;

  // Success/Failure animations
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;

  // Button animation
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  // Track last spoken phase to avoid repeat
  GamePhase? _lastSpokenPhase;

  @override
  void initState() {
    super.initState();

    // Initialize TTS
    _initTts();

    // Character bounce animation
    _characterBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _characterBounceAnim = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _characterBounceController, curve: Curves.easeInOut));

    // Color pulse animation
    _colorPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _colorPulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _colorPulseController, curve: Curves.easeInOut));

    // Sparkle animation
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

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4); // Slow for kids
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2); // Slightly higher pitch for friendly voice
  }

  Future<void> _speakColor(String colorName) async {
    await _flutterTts.speak(colorName);
  }

  Future<void> _speakFindColor(String colorName, String characterName) async {
    await _flutterTts.speak('Find $colorName $characterName?');
  }

  Future<void> _speakSuccess() async {
    final messages = ['Great job!', 'You found it!', 'Yay! That\'s right!', 'Awesome!'];
    final message = messages[math.Random().nextInt(messages.length)];
    await _flutterTts.speak(message);
  }

  // Future<void> _speakFailure() async {
  //   final messages = ['Oops! Try again', 'Not this one', 'Let\'s try one more time'];
  //   final message = messages[math.Random().nextInt(messages.length)];
  //   await _flutterTts.speak(message);
  // }

  @override
  void dispose() {
    _flutterTts.stop();
    _characterBounceController.dispose();
    _colorPulseController.dispose();
    _sparkleController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(colorMemorizeProvider);
    final gameNotifier = ref.read(colorMemorizeProvider.notifier);

    // Trigger overlay animation and TTS on phase change
    if (gameState.phase != _lastSpokenPhase) {
      _lastSpokenPhase = gameState.phase;

      if (gameState.phase == GamePhase.learning) {
        // Speak the color name when showing
        _speakColor(gameState.currentColor.name);
      } else if (gameState.phase == GamePhase.testing) {
        // Speak "Can you find the [color] [character]?"
        _speakFindColor(gameState.currentColor.name, gameState.currentCharacter.name);
      } else if (gameState.phase == GamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      } else if (gameState.phase == GamePhase.failure) {
        _overlayController.forward(from: 0);
        // _speakFailure();
        _speakFindColor(gameState.currentColor.name, gameState.currentCharacter.name);
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gameState.currentColor.color.withValues(alpha: 0.15),
              const Color(0xFFFFF8E1),
              const Color(0xFFE3F2FD),
              gameState.currentColor.color.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating decorations
              ..._buildFloatingDecorations(),

              Column(
                children: [
                  _buildAppBar(context, gameNotifier, gameState),
                  Expanded(child: _buildGameContent(gameState, gameNotifier)),
                ],
              ),

              // Success Overlay
              if (gameState.phase == GamePhase.success)
                _buildSuccessOverlay(gameState, gameNotifier),

              // Failure Overlay (commented out)
              // if (gameState.phase == GamePhase.failure)
              //   _buildFailureOverlay(gameState, gameNotifier),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingDecorations() {
    return [
      // Animated floating shapes
      Positioned(
        top: 100,
        left: 20,
        child: AnimatedBuilder(
          animation: _sparkleAnim,
          builder: (context, child) {
            return Transform.rotate(
              angle: _sparkleAnim.value * 2 * math.pi,
              child: Opacity(
                opacity: 0.3,
                child: Icon(Icons.star, size: 30, color: Colors.amber.shade300),
              ),
            );
          },
        ),
      ),
      Positioned(
        top: 200,
        right: 30,
        child: AnimatedBuilder(
          animation: _sparkleAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, math.sin(_sparkleAnim.value * 2 * math.pi) * 10),
              child: Opacity(
                opacity: 0.25,
                child: Icon(Icons.favorite, size: 25, color: Colors.pink.shade300),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: 150,
        left: 40,
        child: AnimatedBuilder(
          animation: _sparkleAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (math.sin(_sparkleAnim.value * 2 * math.pi) * 0.2),
              child: Opacity(
                opacity: 0.2,
                child: Icon(Icons.circle, size: 20, color: Colors.blue.shade300),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildAppBar(
    BuildContext context,
    ColorMemorizeNotifier notifier,
    ColorMemorizeState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
            color: const Color(0xFF6A4C93),
          ),

          const Spacer(),

          // Score display with animation
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

          // Round indicator
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
                Icon(Icons.flag_rounded, color: state.currentColor.color, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${state.currentRound}/${state.totalRounds}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: state.currentColor.color,
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

  Widget _buildGameContent(ColorMemorizeState state, ColorMemorizeNotifier notifier) {
    switch (state.phase) {
      case GamePhase.learning:
        return _buildLearningPage(state, notifier);
      case GamePhase.testing:
        return _buildTestPage(state, notifier);
      case GamePhase.success:
      case GamePhase.failure:
        return _buildTestPage(state, notifier);
    }
  }

  Widget _buildLearningPage(ColorMemorizeState state, ColorMemorizeNotifier notifier) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title with character preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: state.currentColor.color.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🎨 Look at this ${state.currentCharacter.name}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Remember the color!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Large color display - tap to hear "Find [color] [character]!"
            GestureDetector(
              onTap: () => _speakColor(state.currentColor.name),
              child: AnimatedBuilder(
                animation: _characterBounceAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_characterBounceAnim.value),
                    child: child,
                  );
                },
                child: ScaleTransition(
                  scale: _colorPulseAnim,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: state.currentColor.color,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: state.currentColor.color.withValues(alpha: 0.5),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 2,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shine effect
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          right: 30,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Color name badge
            GestureDetector(
              onTap: () => _speakColor(state.currentColor.name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      state.currentColor.color,
                      HSLColor.fromColor(state.currentColor.color)
                          .withLightness(
                            (HSLColor.fromColor(state.currentColor.color).lightness + 0.1).clamp(
                              0.0,
                              1.0,
                            ),
                          )
                          .toColor(),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: state.currentColor.color.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      state.currentColor.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Ready button
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

  Widget _buildTestPage(ColorMemorizeState state, ColorMemorizeNotifier notifier) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Question card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Find the ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: state.currentColor.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.currentColor.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CharacterWidget(
                        characterType: state.currentCharacter.name,
                        color: Colors.grey.shade400,
                        size: 50,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        state.currentCharacter.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6A4C93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Character options - 3 items stacked vertically, centered
            ...List.generate(state.testOptions.length, (index) {
              final option = state.testOptions[index];
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CharacterOptionCard(
                    character: state.currentCharacter,
                    color: option,
                    index: index,
                    onTap: () {
                      if (state.phase == GamePhase.testing) {
                        final isCorrect = index == state.correctIndex;
                        notifier.checkAnswer(index);
                        if (!isCorrect) {
                          // Speak "Find [color] [character]?" again on wrong answer
                          _speakFindColor(state.currentColor.name, state.currentCharacter.name);
                        }
                      }
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(ColorMemorizeState state, ColorMemorizeNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated celebration
                const _CelebrationWidget(),

                const SizedBox(height: 20),

                // Correct character display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: CharacterWidget(
                    characterType: state.currentCharacter.name,
                    color: state.currentColor.color,
                    size: 100,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  '🎉 Amazing! 🎉',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'The ${state.currentCharacter.name} was ${state.currentColor.name}!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),

                const SizedBox(height: 24),

                _buildAnimatedButton(
                  onPressed: () => notifier.nextRound(),
                  gradientColors: const [Color(0xFF8AC926), Color(0xFF06D6A0)],
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  text: state.currentRound >= state.totalRounds ? 'Play Again!' : 'Next Color!',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildFailureOverlay(ColorMemorizeState state, ColorMemorizeNotifier notifier) {
  //   return Container(
  //     color: Colors.black.withValues(alpha: 0.5),
  //     child: Center(
  //       child: ScaleTransition(
  //         scale: _overlayScaleAnim,
  //         child: _ShakingWidget(
  //           child: Container(
  //             margin: const EdgeInsets.all(24),
  //             padding: const EdgeInsets.all(32),
  //             decoration: BoxDecoration(
  //               gradient: const LinearGradient(
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //                 colors: [Color(0xFF9B5DE5), Color(0xFF6A4C93), Color(0xFF5A3D82)],
  //               ),
  //               borderRadius: BorderRadius.circular(32),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.purple.withValues(alpha: 0.5),
  //                   blurRadius: 40,
  //                   offset: const Offset(0, 20),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 // Thinking character
  //                 Container(
  //                   padding: const EdgeInsets.all(20),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white.withValues(alpha: 0.2),
  //                     borderRadius: BorderRadius.circular(24),
  //                   ),
  //                   child: const Text('🤔', style: TextStyle(fontSize: 70)),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 Text(
  //                   state.motivationalMessage,
  //                   textAlign: TextAlign.center,
  //                   style: const TextStyle(
  //                     fontSize: 28,
  //                     fontWeight: FontWeight.w800,
  //                     color: Colors.white,
  //                     height: 1.3,
  //                     shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 12),

  //                 Text(
  //                   'Look for the ${state.currentColor.name} ${state.currentCharacter.name}',
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.white.withValues(alpha: 0.8),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 24),

  //                 _buildAnimatedButton(
  //                   onPressed: () => notifier.retryQuestion(),
  //                   gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF9671)],
  //                   icon: Icons.refresh_rounded,
  //                   text: 'Try Again!',
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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

// Character Option Card with improved design
class _CharacterOptionCard extends StatefulWidget {
  final CharacterItem character;
  final ColorItem color;
  final int index;
  final VoidCallback onTap;

  const _CharacterOptionCard({
    required this.character,
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CharacterOptionCard> createState() => _CharacterOptionCardState();
}

class _CharacterOptionCardState extends State<_CharacterOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.color.withValues(alpha: 0.3), width: 3),
            boxShadow: [
              BoxShadow(
                color: widget.color.color.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CharacterWidget(
            characterType: widget.character.name,
            color: widget.color.color,
            size: 100,
          ),
        ),
      ),
    );
  }
}

class _ShakingWidget extends StatefulWidget {
  final Widget child;

  const _ShakingWidget({required this.child});

  @override
  State<_ShakingWidget> createState() => _ShakingWidgetState();
}

class _ShakingWidgetState extends State<_ShakingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(offset: Offset(_animation.value, 0), child: widget.child);
      },
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
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: const Text('⭐', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Transform.translate(
                offset: Offset(0, math.sin(_controller.value * 4 * math.pi) * 8),
                child: const Text('🎊', style: TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 12),
              Transform.rotate(
                angle: -_controller.value * 2 * math.pi,
                child: const Text('⭐', style: TextStyle(fontSize: 28)),
              ),
            ],
          );
        },
      ),
    );
  }
}

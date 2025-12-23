import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'config_bp.dart';
import 'widgets/body_parts_widget.dart';

class BodyPartsGame extends ConsumerStatefulWidget {
  const BodyPartsGame({super.key});

  @override
  ConsumerState<BodyPartsGame> createState() => _BodyPartsGameState();
}

class _BodyPartsGameState extends ConsumerState<BodyPartsGame> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnim;
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  BodyPartsGamePhase? _lastSpokenPhase;

  @override
  void initState() {
    super.initState();
    _initTts();

    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.0, end: 12.0).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _sparkleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _sparkleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_sparkleController);

    _overlayController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _overlayScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _overlayController, curve: Curves.elasticOut));

    _buttonController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
  }

  Future<void> _speakBodyPart(String name) async {
    await _flutterTts.speak(name);
  }

  Future<void> _speakFindBodyPart(String name) async {
    await _flutterTts.speak('Find $name!');
  }

  Future<void> _speakSuccess() async {
    final messages = ['Great job!', 'You found it!', 'Yay! That\'s right!', 'Awesome!'];
    await _flutterTts.speak(messages[math.Random().nextInt(messages.length)]);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _bounceController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(bodyPartsProvider);
    final gameNotifier = ref.read(bodyPartsProvider.notifier);

    if (gameState.phase != _lastSpokenPhase) {
      _lastSpokenPhase = gameState.phase;

      if (gameState.phase == BodyPartsGamePhase.learning) {
        _speakBodyPart(gameState.currentBodyPart.name);
      } else if (gameState.phase == BodyPartsGamePhase.testing) {
        _speakFindBodyPart(gameState.currentBodyPart.name);
      } else if (gameState.phase == BodyPartsGamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      } else if (gameState.phase == BodyPartsGamePhase.failure) {
        _overlayController.forward(from: 0);
        _speakFindBodyPart(gameState.currentBodyPart.name);
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gameState.displayColor.color.withValues(alpha: 0.15),
              const Color(0xFFFFF8E1),
              const Color(0xFFE3F2FD),
              gameState.displayColor.color.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildFloatingDecorations(),
              Column(
                children: [
                  _buildAppBar(context, gameNotifier, gameState),
                  Expanded(child: _buildGameContent(gameState, gameNotifier)),
                ],
              ),
              if (gameState.phase == BodyPartsGamePhase.success) _buildSuccessOverlay(gameState, gameNotifier),
              if (gameState.phase == BodyPartsGamePhase.failure) _buildFailureOverlay(gameState, gameNotifier),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingDecorations() {
    return [
      Positioned(
        top: 100,
        left: 20,
        child: AnimatedBuilder(
          animation: _sparkleAnim,
          builder: (context, child) => Transform.rotate(
            angle: _sparkleAnim.value * 2 * math.pi,
            child: Opacity(opacity: 0.3, child: Icon(Icons.favorite, size: 30, color: Colors.red.shade300)),
          ),
        ),
      ),
      Positioned(
        top: 200,
        right: 30,
        child: AnimatedBuilder(
          animation: _sparkleAnim,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, math.sin(_sparkleAnim.value * 2 * math.pi) * 10),
            child: Opacity(opacity: 0.25, child: Icon(Icons.psychology, size: 25, color: Colors.pink.shade300)),
          ),
        ),
      ),
    ];
  }

  Widget _buildAppBar(BuildContext context, BodyPartsNotifier notifier, BodyPartsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).pop(), color: const Color(0xFFE63946)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.red.shade400, Colors.orange.shade400]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text('${state.score}/${state.totalRounds}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, color: state.displayColor.color, size: 18),
                const SizedBox(width: 6),
                Text('${state.currentRound}/${state.totalRounds}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: state.displayColor.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildGameContent(BodyPartsState state, BodyPartsNotifier notifier) {
    switch (state.phase) {
      case BodyPartsGamePhase.learning:
        return _buildLearningPage(state, notifier);
      case BodyPartsGamePhase.testing:
      case BodyPartsGamePhase.success:
      case BodyPartsGamePhase.failure:
        return _buildTestPage(state, notifier);
    }
  }

  Widget _buildLearningPage(BodyPartsState state, BodyPartsNotifier notifier) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: state.displayColor.color.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text('🧍 Look at this body part!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Text('Remember this part!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => _speakBodyPart(state.currentBodyPart.name),
              child: AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.translate(offset: Offset(0, -_bounceAnim.value), child: child),
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: state.displayColor.color.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 15))],
                    ),
                    child: Center(child: BodyPartWidget(emoji: state.currentBodyPart.emoji, size: 140)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _speakBodyPart(state.currentBodyPart.name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [state.displayColor.color, HSLColor.fromColor(state.displayColor.color).withLightness((HSLColor.fromColor(state.displayColor.color).lightness + 0.1).clamp(0.0, 1.0)).toColor()]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: state.displayColor.color.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Text(
                  state.currentBodyPart.name.toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3, shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)]),
                ),
              ),
            ),
            const SizedBox(height: 50),
            _buildAnimatedButton(onPressed: () => notifier.goToTest(), gradientColors: const [Color(0xFFE63946), Color(0xFFF77F00)], icon: Icons.play_arrow_rounded, text: "I'm Ready!"),
          ],
        ),
      ),
    );
  }

  Widget _buildTestPage(BodyPartsState state, BodyPartsNotifier notifier) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Find ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFE63946), borderRadius: BorderRadius.circular(12)),
                        child: Text(state.currentBodyPart.name.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(state.testOptions.length, (index) {
              final option = state.testOptions[index];
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _BodyPartOptionCard(
                    bodyPart: option,
                    color: state.displayColor.color,
                    onTap: () {
                      if (state.phase == BodyPartsGamePhase.testing) notifier.checkAnswer(index);
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

  Widget _buildSuccessOverlay(BodyPartsState state, BodyPartsNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE63946), Color(0xFFF77F00), Color(0xFFFFBF69)]),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _CelebrationWidget(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(24)),
                  child: BodyPartWidget(emoji: state.currentBodyPart.emoji, size: 80),
                ),
                const SizedBox(height: 20),
                const Text('🎉 Amazing! 🎉', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)])),
                const SizedBox(height: 8),
                Text('You found the ${state.currentBodyPart.name}!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 24),
                _buildAnimatedButton(
                  onPressed: () => notifier.nextRound(),
                  gradientColors: const [Color(0xFF8AC926), Color(0xFF06D6A0)],
                  icon: state.currentRound >= state.totalRounds ? Icons.refresh_rounded : Icons.arrow_forward_rounded,
                  text: state.currentRound >= state.totalRounds ? 'Play Again!' : 'Next Part!',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureOverlay(BodyPartsState state, BodyPartsNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: _ShakingWidget(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9B5DE5), Color(0xFF6A4C93), Color(0xFF5A3D82)]),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(24)),
                    child: const Text('🤔', style: TextStyle(fontSize: 70)),
                  ),
                  const SizedBox(height: 20),
                  Text(state.motivationalMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3, shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)])),
                  const SizedBox(height: 12),
                  Text('Look for the ${state.currentBodyPart.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 24),
                  _buildAnimatedButton(onPressed: () => notifier.retryQuestion(), gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF9671)], icon: Icons.refresh_rounded, text: 'Try Again!'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({required VoidCallback onPressed, required List<Color> gradientColors, required IconData icon, required String text}) {
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
            boxShadow: [BoxShadow(color: gradientColors[0].withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 12),
              Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyPartOptionCard extends StatefulWidget {
  final BodyPartItem bodyPart;
  final Color color;
  final VoidCallback onTap;

  const _BodyPartOptionCard({required this.bodyPart, required this.color, required this.onTap});

  @override
  State<_BodyPartOptionCard> createState() => _BodyPartOptionCardState();
}

class _BodyPartOptionCardState extends State<_BodyPartOptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
            border: Border.all(color: widget.color.withValues(alpha: 0.3), width: 3),
            boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: BodyPartWidget(emoji: widget.bodyPart.emoji, size: 80),
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
    _animation = Tween<double>(begin: -5, end: 5).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _animation, builder: (context, child) => Transform.translate(offset: Offset(_animation.value, 0), child: widget.child));
  }
}

class _CelebrationWidget extends StatefulWidget {
  const _CelebrationWidget();

  @override
  State<_CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<_CelebrationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
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
            Transform.rotate(angle: _controller.value * 2 * math.pi, child: const Text('⭐', style: TextStyle(fontSize: 28))),
            const SizedBox(width: 12),
            Transform.translate(offset: Offset(0, math.sin(_controller.value * 4 * math.pi) * 8), child: const Text('🎊', style: TextStyle(fontSize: 36))),
            const SizedBox(width: 12),
            Transform.rotate(angle: -_controller.value * 2 * math.pi, child: const Text('⭐', style: TextStyle(fontSize: 28))),
          ],
        ),
      ),
    );
  }
}

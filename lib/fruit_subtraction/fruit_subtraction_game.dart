import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_fs.dart';

class FruitSubtractionGame extends ConsumerStatefulWidget {
  const FruitSubtractionGame({super.key});

  @override
  ConsumerState<FruitSubtractionGame> createState() => _FruitSubtractionGameState();
}

class _FruitSubtractionGameState extends ConsumerState<FruitSubtractionGame>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _basketBounceController;
  late Animation<double> _basketBounceAnim;

  Set<int> _tappedIndices = {};
  Set<int> _subtractedIndices = {};
  SubtractionGamePhase? _lastSpokenPhase;

  @override
  void initState() {
    super.initState();
    tts.init();

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

    _basketBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _basketBounceAnim = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _basketBounceController, curve: Curves.easeInOut));
  }

  void _speak(String text) {
    tts.speak(text);
  }

  Future<void> _speakSuccess(SubtractionState state) async {
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    _speak(
      'Fantastic! ${state.totalCount} minus ${state.takenCount} equals ${state.remainingCount}!',
    );
  }

  @override
  void dispose() {
    tts.stop();
    victoryAudio.stop();
    _overlayController.dispose();
    _buttonController.dispose();
    _basketBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subtractionProvider);
    final notifier = ref.read(subtractionProvider.notifier);

    // Handle phase changes with TTS
    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == SubtractionGamePhase.learningCount) {
        _tappedIndices = {};
        _subtractedIndices = {};
        _speak('How many ${state.currentItem.name} are there? Tap each one to count!');
      } else if (state.phase == SubtractionGamePhase.learningSubtract) {
        _speak(
          'Now, let\'s take away ${state.takenCount} ${state.currentItem.name}. Tap them to remove them!',
        );
      } else if (state.phase == SubtractionGamePhase.testing) {
        _speak(
          'We had ${state.totalCount} ${state.currentItem.name} and took away ${state.takenCount}. How many are left? Tap the answer!',
        );
      } else if (state.phase == SubtractionGamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess(state);
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              state.themeColor.withValues(alpha: 0.15),
              Colors.white,
              const Color(0xFFF0F4C3),
              state.themeColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, state),
                  Expanded(child: _buildContent(state, notifier)),
                ],
              ),
              if (state.phase == SubtractionGamePhase.success)
                _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, SubtractionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              tts.stop();
              victoryAudio.stop();
              Navigator.pop(context);
            },

            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: state.themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: state.themeColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: state.themeColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${state.score}/${state.totalRounds}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: state.themeColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Round ${state.currentRound}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: state.themeColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SubtractionState state, SubtractionNotifier notifier) {
    if (state.phase == SubtractionGamePhase.learningCount ||
        state.phase == SubtractionGamePhase.learningSubtract) {
      return _buildLearningMode(state, notifier);
    }
    return _buildTestingMode(state, notifier);
  }

  Widget _buildLearningMode(SubtractionState state, SubtractionNotifier notifier) {
    bool isCountingPhase = state.phase == SubtractionGamePhase.learningCount;
    bool allCounted = _tappedIndices.length == state.totalCount;
    bool allSubtracted = _subtractedIndices.length == state.takenCount;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          isCountingPhase
              ? 'Count the ${state.currentItem.name}!'
              : 'Take away ${state.takenCount} ${state.currentItem.name}!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isCountingPhase ? 'Tap each one to count!' : 'Tap the fruits to remove them!',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedBuilder(
              animation: _basketBounceAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _basketBounceAnim.value),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: state.themeColor.withValues(alpha: 0.3), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('🧺', style: TextStyle(fontSize: 50)),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Center(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: List.generate(state.totalCount, (index) {
                                bool isCounted = _tappedIndices.contains(index);
                                bool isSubtracted =
                                    !isCountingPhase && _subtractedIndices.contains(index);

                                return GestureDetector(
                                  onTap: () {
                                    if (isCountingPhase) {
                                      if (!_tappedIndices.contains(index)) {
                                        setState(() => _tappedIndices.add(index));
                                        _speak('${_tappedIndices.length}');
                                      }
                                    } else {
                                      if (!_subtractedIndices.contains(index) &&
                                          _subtractedIndices.length < state.takenCount) {
                                        setState(() => _subtractedIndices.add(index));
                                        _speak('${state.totalCount - _subtractedIndices.length}');
                                      }
                                    }
                                  },
                                  child: AnimatedOpacity(
                                    opacity: isSubtracted ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 400),
                                    child: AnimatedScale(
                                      scale: isCounted ? 1.1 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: isCounted
                                              ? state.themeColor.withValues(alpha: 0.2)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isCounted
                                                ? state.themeColor
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Text(
                                              state.currentItem.emoji,
                                              style: const TextStyle(fontSize: 32),
                                            ),
                                            if (isCounted && isCountingPhase)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: state.themeColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    '${_tappedIndices.toList().indexOf(index) + 1}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
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
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 30),
        if (isCountingPhase && allCounted)
          _buildAnimatedButton(
            onPressed: () => notifier.goToNextPhase(),
            gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
            icon: Icons.remove_circle_outline_rounded,
            text: "Now Subtract!",
          ),
        if (!isCountingPhase && allSubtracted)
          _buildAnimatedButton(
            onPressed: () => notifier.goToNextPhase(),
            gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
            icon: Icons.calculate_rounded,
            text: "What's Left?",
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTestingMode(SubtractionState state, SubtractionNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'How many are left?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: state.themeColor.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEquationPart(state.totalCount, state.currentItem.emoji, state.themeColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '−',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: state.themeColor,
                    ),
                  ),
                ),
                _buildEquationPart(
                  state.takenCount,
                  state.currentItem.emoji,
                  state.themeColor,
                  isTaken: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '=',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: state.themeColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: state.themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: state.themeColor, width: 3),
                  ),
                  child: Text(
                    '?',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: state.themeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.testOptions.length, (index) {
              final option = state.testOptions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () {
                    if (state.phase == SubtractionGamePhase.testing) {
                      if (option == state.remainingCount) {
                        notifier.checkAnswer(option);
                      } else {
                        _speak('Try again! What is ${state.totalCount} minus ${state.takenCount}?');
                      }
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: state.themeColor.withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$option',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: state.themeColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEquationPart(int count, String emoji, Color themeColor, {bool isTaken = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 2,
          runSpacing: 2,
          alignment: WrapAlignment.center,
          children: List.generate(count > 4 ? 4 : count, (index) {
            return Text(
              emoji,
              style: TextStyle(
                fontSize: 18,
                decoration: isTaken ? TextDecoration.lineThrough : null,
              ),
            );
          }),
        ),
        if (count > 4) const Text('...', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isTaken ? Colors.grey.withValues(alpha: 0.2) : themeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isTaken ? Colors.grey : themeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessOverlay(SubtractionState state, SubtractionNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: state.themeColor.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌟 🏆 🌟', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.totalCount}',
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '−',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      '${state.takenCount}',
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '=',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: state.themeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.remainingCount}',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'EXCELLENT!',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You solved the subtraction!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                _buildAnimatedButton(
                  onPressed: () {
                    victoryAudio.stop();
                    notifier.nextRound();
                  },
                  gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  text: state.currentRound >= state.totalRounds ? 'Play Again!' : 'Next Level!',
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
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
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
              const SizedBox(width: 14),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

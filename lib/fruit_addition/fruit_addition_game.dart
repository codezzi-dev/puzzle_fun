import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_fa.dart';

class FruitAdditionGame extends ConsumerStatefulWidget {
  const FruitAdditionGame({super.key});

  @override
  ConsumerState<FruitAdditionGame> createState() => _FruitAdditionGameState();
}

class _FruitAdditionGameState extends ConsumerState<FruitAdditionGame>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _basketBounceController;
  late Animation<double> _basketBounceAnim;

  int _leftTappedCount = 0;
  int _rightTappedCount = 0;
  AdditionGamePhase? _lastSpokenPhase;

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

  @override
  void dispose() {
    tts.stop();
    _overlayController.dispose();
    _buttonController.dispose();
    _basketBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(additionProvider);
    final notifier = ref.read(additionProvider.notifier);

    // Handle phase changes with TTS
    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == AdditionGamePhase.learning) {
        _leftTappedCount = 0;
        _rightTappedCount = 0;
        _speak('Count the ${state.currentItem.name}! Tap each basket to count!');
      } else if (state.phase == AdditionGamePhase.testing) {
        _speak(
          '${state.leftCount} ${state.currentItem.name} plus ${state.rightCount} ${state.currentItem.name} equals... Tap the answer!',
        );
      } else if (state.phase == AdditionGamePhase.success) {
        _overlayController.forward(from: 0);
        victoryAudio.playVictorySound();
        _speak(
          'Amazing! ${state.leftCount} plus ${state.rightCount} equals ${state.correctAnswer}!',
        );
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
              if (state.phase == AdditionGamePhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AdditionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
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

  Widget _buildContent(AdditionState state, AdditionNotifier notifier) {
    if (state.phase == AdditionGamePhase.learning) {
      return _buildLearningMode(state, notifier);
    }
    return _buildTestingMode(state, notifier);
  }

  Widget _buildLearningMode(AdditionState state, AdditionNotifier notifier) {
    bool allTapped = _leftTappedCount == state.leftCount && _rightTappedCount == state.rightCount;

    // Calculate total tapped count for continuous counting display
    int totalTapped = _leftTappedCount + _rightTappedCount;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Count the ${state.currentItem.name}!',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tap each basket to count!',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Left Basket
                Expanded(
                  child: _buildBasket(
                    state: state,
                    count: state.leftCount,
                    tappedCount: _leftTappedCount,
                    startNumber: 1, // Left basket starts from 1
                    isLeft: true,
                    onTap: () {
                      if (_leftTappedCount < state.leftCount) {
                        setState(() {
                          _leftTappedCount++;
                        });
                        // Speak the current total count
                        _speak('$_leftTappedCount');
                      }
                    },
                  ),
                ),
                // Plus Sign
                AnimatedBuilder(
                  animation: _basketBounceAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _basketBounceAnim.value),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: state.themeColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: state.themeColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Right Basket
                Expanded(
                  child: _buildBasket(
                    state: state,
                    count: state.rightCount,
                    tappedCount: _rightTappedCount,
                    startNumber: state.leftCount + 1, // Right basket continues from left
                    isLeft: false,
                    onTap: () {
                      if (_rightTappedCount < state.rightCount) {
                        setState(() {
                          _rightTappedCount++;
                        });
                        // Speak the continuous count (left count + right tapped)
                        int continuousCount = state.leftCount + _rightTappedCount;
                        _speak('$continuousCount');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Show total count badge when counting
        if (totalTapped > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: state.themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: state.themeColor, width: 2),
            ),
            child: Text(
              'Total: $totalTapped',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: state.themeColor),
            ),
          ),
        const SizedBox(height: 20),
        if (allTapped)
          _buildAnimatedButton(
            onPressed: () => notifier.goToTest(),
            gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
            icon: Icons.calculate_rounded,
            text: "What's the Total?",
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBasket({
    required AdditionState state,
    required int count,
    required int tappedCount,
    required int startNumber, // Starting number for continuous counting
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _basketBounceAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, isLeft ? _basketBounceAnim.value : -_basketBounceAnim.value + 8),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: tappedCount == count
                      ? state.themeColor
                      : Colors.grey.withValues(alpha: 0.2),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (tappedCount == count ? state.themeColor : Colors.black).withValues(
                      alpha: 0.15,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Basket icon
                  Text('🧺', style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  // Fruit items
                  Expanded(
                    child: Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(count, (index) {
                          bool isTapped = index < tappedCount;
                          // Calculate the continuous number for this item
                          int displayNumber = startNumber + index;
                          return AnimatedScale(
                            scale: isTapped ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isTapped
                                    ? state.themeColor.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isTapped ? state.themeColor : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    state.currentItem.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  // Show number badge on tapped items
                                  if (isTapped)
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
                                          '$displayNumber',
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
                          );
                        }),
                      ),
                    ),
                  ),
                  // Count badge showing continuous range
                  if (tappedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: state.themeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        // Show range for this basket (e.g., "1-4" or "5-7")
                        tappedCount == 1
                            ? '$startNumber'
                            : '$startNumber-${startNumber + tappedCount - 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestingMode(AdditionState state, AdditionNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'How many in total?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 20),
          // Equation display - scrollable for smaller screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: state.themeColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEquationPart(state.leftCount, state.currentItem.emoji, state.themeColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                  ),
                  _buildEquationPart(state.rightCount, state.currentItem.emoji, state.themeColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '=',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ),
          const SizedBox(height: 24),
          Text(
            'Tap the correct answer!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          // Answer options in a responsive row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.testOptions.length, (index) {
              final option = state.testOptions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () {
                    if (state.phase == AdditionGamePhase.testing) {
                      if (option == state.correctAnswer) {
                        notifier.checkAnswer(option);
                      } else {
                        _speak('Try again! What is ${state.leftCount} plus ${state.rightCount}?');
                      }
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
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

  Widget _buildEquationPart(int count, String emoji, Color themeColor) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stack fruits in a compact grid instead of row
          Wrap(
            spacing: 2,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            children: List.generate(count, (index) {
              return Text(emoji, style: const TextStyle(fontSize: 20));
            }),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: themeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay(AdditionState state, AdditionNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: state.themeColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration emoji row
                const Text('🎉 ⭐ 🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 20),
                // Equation result
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.leftCount}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: state.themeColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Text(
                      '${state.rightCount}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '=',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: state.themeColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: state.themeColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${state.correctAnswer}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'GREAT JOB!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You added ${state.currentItem.name} correctly!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
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
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(24),
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
      ),
    );
  }
}

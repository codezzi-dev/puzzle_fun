import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_fg.dart';

class FruitGroupsGame extends ConsumerStatefulWidget {
  const FruitGroupsGame({super.key});

  @override
  ConsumerState<FruitGroupsGame> createState() => _FruitGroupsGameState();
}

class _FruitGroupsGameState extends ConsumerState<FruitGroupsGame> with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _basketBounceController;
  late Animation<double> _basketBounceAnim;

  // Track tapped indices for each basket
  late List<Set<int>> _basketTappedIndices;
  FruitGroupsGamePhase? _lastSpokenPhase;

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

  Future<void> _speakSuccess(FruitGroupsState state) async {
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    String equationText = state.basketCounts.join(' + ');
    _speak('Super! $equationText is ${state.correctAnswer}!');
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
    final state = ref.watch(fruitGroupsProvider);
    final notifier = ref.read(fruitGroupsProvider.notifier);

    // Initialize or reset basket tapped indices on phase change to learning
    if (state.phase == FruitGroupsGamePhase.learning &&
        (_lastSpokenPhase == null || _lastSpokenPhase != FruitGroupsGamePhase.learning)) {
      _basketTappedIndices = List.generate(state.basketCounts.length, (_) => <int>{});
    }

    // Handle phase changes with TTS
    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == FruitGroupsGamePhase.learning) {
        _speak(
          'Let\'s count the fruits! There are ${state.basketCounts.length} baskets. Tap each fruit to count them all!',
        );
      } else if (state.phase == FruitGroupsGamePhase.testing) {
        String equationText = state.basketCounts.join(' plus ');
        _speak('$equationText equals... Tap the answer!');
      } else if (state.phase == FruitGroupsGamePhase.success) {
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
              if (state.phase == FruitGroupsGamePhase.success)
                _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FruitGroupsState state) {
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

  Widget _buildContent(FruitGroupsState state, FruitGroupsNotifier notifier) {
    if (state.phase == FruitGroupsGamePhase.learning) {
      return _buildLearningMode(state, notifier);
    }
    return _buildTestingMode(state, notifier);
  }

  Widget _buildLearningMode(FruitGroupsState state, FruitGroupsNotifier notifier) {
    bool allTapped = _basketTappedIndices.asMap().entries.every(
      (entry) => entry.value.length == state.basketCounts[entry.key],
    );
    int totalTapped = _basketTappedIndices.fold(0, (sum, indices) => sum + indices.length);

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Count all the fruits!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Tap fruits to count!',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: List.generate(state.basketCounts.length, (index) {
                  return SizedBox(
                    width: 160,
                    height: 180,
                    child: _buildBasket(
                      state: state,
                      basketIndex: index,
                      onTapItem: (itemIndex) {
                        if (!_basketTappedIndices[index].contains(itemIndex)) {
                          setState(() {
                            _basketTappedIndices[index].add(itemIndex);
                          });
                          // Speak continuous count
                          int currentTotal = 0;
                          for (int i = 0; i < state.basketCounts.length; i++) {
                            currentTotal += _basketTappedIndices[i].length;
                          }
                          _speak('$currentTotal');
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
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
            text: "How many in all?",
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBasket({
    required FruitGroupsState state,
    required int basketIndex,
    required void Function(int) onTapItem,
  }) {
    final tappedIndices = _basketTappedIndices[basketIndex];
    int currentBasketCount = state.basketCounts[basketIndex];
    bool isCompleted = tappedIndices.length == currentBasketCount;

    return AnimatedBuilder(
      animation: _basketBounceAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            basketIndex % 2 == 0 ? _basketBounceAnim.value : -_basketBounceAnim.value,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? state.themeColor : Colors.grey.withValues(alpha: 0.2),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCompleted ? state.themeColor : Colors.black).withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🧺', style: const TextStyle(fontSize: 24)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: state.themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#${basketIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: state.themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: List.generate(currentBasketCount, (i) {
                      bool isTapped = tappedIndices.contains(i);
                      return GestureDetector(
                        onTap: () => onTapItem(i),
                        child: AnimatedScale(
                          scale: isTapped ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: isTapped
                                  ? state.themeColor.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                state.currentItem.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestingMode(FruitGroupsState state, FruitGroupsNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'What is the result?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: state.themeColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(state.basketCounts.length, (index) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEquationFactor(
                          state.basketCounts[index],
                          state.currentItem.emoji,
                          state.themeColor,
                        ),
                        if (index < state.basketCounts.length - 1)
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
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '=',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: state.themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: state.themeColor, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: state.themeColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'How many in all?',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: state.testOptions.map((option) {
              return GestureDetector(
                onTap: () {
                  if (option == state.correctAnswer) {
                    notifier.checkAnswer(option);
                  } else {
                    _speak('Not quite! How many fruits are there in total?');
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: state.themeColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$option',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEquationFactor(int val, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$val',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: color),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessOverlay(FruitGroupsState state, FruitGroupsNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🌟 BRILLIANT! 🌟',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.basketCounts.join(' + ')} = ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      '${state.correctAnswer}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: state.themeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'You found the total of ${state.currentItem.name}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                _buildAnimatedButton(
                  onPressed: () {
                    victoryAudio.stop();
                    notifier.nextRound();
                  },
                  gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  text: state.currentRound >= state.totalRounds ? 'Play Again!' : 'Next Challenge!',
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_fms.dart';

class FruitMultiSubtractGame extends ConsumerStatefulWidget {
  const FruitMultiSubtractGame({super.key});

  @override
  ConsumerState<FruitMultiSubtractGame> createState() => _FruitMultiSubtractGameState();
}

class _FruitMultiSubtractGameState extends ConsumerState<FruitMultiSubtractGame>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _basketBounceController;
  late Animation<double> _basketBounceAnim;

  // Track tapped indices for total counting
  late List<Set<int>> _basketTappedIndices;
  // Track subtracted indices
  Set<int> _subtractedIndices = {};
  FmsGamePhase? _lastSpokenPhase;

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

  Future<void> _speakSuccess(FmsState state) async {
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    _speak(
      'Super! ${state.multiplier} groups of ${state.itemsPerBasket} minus ${state.takenCount} is ${state.remainingCount}!',
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
    final state = ref.watch(fmsProvider);
    final notifier = ref.read(fmsProvider.notifier);

    // Initialize or reset tracking on phase change
    if (state.phase == FmsGamePhase.learningGroups &&
        (_lastSpokenPhase == null || _lastSpokenPhase != FmsGamePhase.learningGroups)) {
      _basketTappedIndices = List.generate(state.multiplier, (_) => <int>{});
      _subtractedIndices = {};
    }

    // Handle phase changes with TTS
    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == FmsGamePhase.learningGroups) {
        _speak(
          'Let\'s count the fruits! There are ${state.multiplier} baskets with ${state.itemsPerBasket} ${state.currentItem.name} each. Tap each fruit to count them all!',
        );
      } else if (state.phase == FmsGamePhase.learningSubtract) {
        _speak(
          'Now, let\'s take away ${state.takenCount} ${state.currentItem.name}. Tap them to remove them!',
        );
      } else if (state.phase == FmsGamePhase.testing) {
        _speak(
          'We had ${state.multiplier} times ${state.itemsPerBasket} and took away ${state.takenCount}. How many are left? Tap the answer!',
        );
      } else if (state.phase == FmsGamePhase.success) {
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
              if (state.phase == FmsGamePhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FmsState state) {
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

  Widget _buildContent(FmsState state, FmsNotifier notifier) {
    if (state.phase == FmsGamePhase.learningGroups ||
        state.phase == FmsGamePhase.learningSubtract) {
      return _buildLearningMode(state, notifier);
    }
    return _buildTestingMode(state, notifier);
  }

  Widget _buildLearningMode(FmsState state, FmsNotifier notifier) {
    bool isGroupsPhase = state.phase == FmsGamePhase.learningGroups;
    bool allCounted = _basketTappedIndices.asMap().entries.every(
      (entry) => entry.value.length == state.itemsPerBasket,
    );
    bool allSubtracted = _subtractedIndices.length == state.takenCount;

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          isGroupsPhase ? 'Count all the fruits!' : 'Take away ${state.takenCount} fruits!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          isGroupsPhase ? 'Tap fruits to count!' : 'Tap the fruits to remove them!',
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
                children: List.generate(state.multiplier, (index) {
                  return SizedBox(
                    width: 160,
                    height: 180,
                    child: _buildBasket(
                      state: state,
                      basketIndex: index,
                      onTapItem: (itemIndex) {
                        if (isGroupsPhase) {
                          if (!_basketTappedIndices[index].contains(itemIndex)) {
                            setState(() {
                              _basketTappedIndices[index].add(itemIndex);
                            });
                            int totalTapped = _basketTappedIndices.fold(
                              0,
                              (sum, indices) => sum + indices.length,
                            );
                            _speak('$totalTapped');
                          }
                        } else {
                          // Subtraction phase
                          // We use a global index for subtraction to make it easy
                          int globalIndex = index * state.itemsPerBasket + itemIndex;
                          if (!_subtractedIndices.contains(globalIndex) &&
                              _subtractedIndices.length < state.takenCount) {
                            setState(() {
                              _subtractedIndices.add(globalIndex);
                            });
                            _speak('${state.totalCount - _subtractedIndices.length}');
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (isGroupsPhase && allCounted)
          _buildAnimatedButton(
            onPressed: () => notifier.nextPhase(),
            gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
            icon: Icons.remove_circle_outline_rounded,
            text: "Take Away!",
          ),
        if (!isGroupsPhase && allSubtracted)
          _buildAnimatedButton(
            onPressed: () => notifier.nextPhase(),
            gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
            icon: Icons.calculate_rounded,
            text: "Check Answer!",
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBasket({
    required FmsState state,
    required int basketIndex,
    required void Function(int) onTapItem,
  }) {
    bool isGroupsPhase = state.phase == FmsGamePhase.learningGroups;
    final tappedIndices = isGroupsPhase ? _basketTappedIndices[basketIndex] : <int>{};
    bool isCompleted = isGroupsPhase && tappedIndices.length == state.itemsPerBasket;

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
                    children: List.generate(state.itemsPerBasket, (i) {
                      bool isTapped = isGroupsPhase && tappedIndices.contains(i);
                      int globalIndex = basketIndex * state.itemsPerBasket + i;
                      bool isSubtracted =
                          !isGroupsPhase && _subtractedIndices.contains(globalIndex);

                      return GestureDetector(
                        onTap: () => onTapItem(i),
                        child: AnimatedOpacity(
                          opacity: isSubtracted ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 400),
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

  Widget _buildTestingMode(FmsState state, FmsNotifier notifier) {
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
                  // Multiplication Group
                  _buildEquationFactor(state.multiplier, 'baskets', state.themeColor),
                  _buildEquationSign('×', state.themeColor),
                  _buildEquationFactor(state.itemsPerBasket, 'fruits', state.themeColor),

                  _buildEquationSign('−', state.themeColor, horizontalPadding: 12),

                  // Subtraction Part
                  _buildEquationFactor(state.takenCount, 'taken', Colors.red),

                  _buildEquationSign('=', state.themeColor, fontSize: 48, horizontalPadding: 16),

                  _buildEquationFactor(0, 'total', state.themeColor, isQuestion: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: state.testOptions.map((option) {
              return GestureDetector(
                onTap: () {
                  if (option == state.remainingCount) {
                    notifier.checkAnswer(option);
                  } else {
                    _speak(
                      'Not quite! We had ${state.totalCount} and took away ${state.takenCount}.',
                    );
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

  Widget _buildEquationFactor(int val, String label, Color color, {bool isQuestion = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isQuestion)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: color),
              ),
            ),
          )
        else
          Text(
            '$val',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: color),
          ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEquationSign(
    String sign,
    Color color, {
    double fontSize = 32,
    double horizontalPadding = 8,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sign,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 20), // Height of 4 (SizedBox) + 16 (estimated label height)
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay(FmsState state, FmsNotifier notifier) {
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
                  '🌟 FANTASTIC! 🌟',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                Text(
                  '(${state.multiplier} × ${state.itemsPerBasket}) − ${state.takenCount} = ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${state.remainingCount}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: state.themeColor,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'You solved the Multi-Subtract paradox!',
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

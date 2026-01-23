import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_ta.dart';

class TrainAdditionGame extends ConsumerStatefulWidget {
  const TrainAdditionGame({super.key});

  @override
  ConsumerState<TrainAdditionGame> createState() => _TrainAdditionGameState();
}

class _TrainAdditionGameState extends ConsumerState<TrainAdditionGame>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _trainController;
  late Animation<Offset> _trainEntryAnim;

  TrainAdditionPhase? _lastSpokenPhase;

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

    _trainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _trainEntryAnim = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _trainController, curve: Curves.easeOutBack));

    _trainController.forward();
  }

  void _speak(String text) {
    tts.speak(text);
  }

  @override
  void dispose() {
    tts.stop();
    _overlayController.dispose();
    _trainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainAdditionProvider);
    final notifier = ref.read(trainAdditionProvider.notifier);

    // Handle phase changes with TTS
    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      _handlePhaseChange(state, notifier);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              state.themeColor.withValues(alpha: 0.2),
              const Color(0xFFE1F5FE),
              const Color(0xFFF1F8E9),
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
                  Expanded(child: _buildMainArea(state, notifier)),
                ],
              ),
              if (state.phase == TrainAdditionPhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePhaseChange(TrainAdditionState state, TrainAdditionNotifier notifier) async {
    switch (state.phase) {
      case TrainAdditionPhase.intro:
        _speak("The train is coming! It's empty and ready for passengers.");
        await Future.delayed(const Duration(seconds: 3));
        notifier.startInitialPhase();
        break;
      case TrainAdditionPhase.boardingInitial:
        _speak(
          "Look at the ${state.initialGroup.length} friends waiting! Tap each one to help them board the train.",
        );
        break;
      case TrainAdditionPhase.boardingSecond:
        _speak(
          "Here come ${state.boardingGroup.length} more friends! Tap them to get on the train too!",
        );
        break;
      case TrainAdditionPhase.testing:
        _speak("How many friends are on the train now? Tap the correct number!");
        break;
      case TrainAdditionPhase.success:
        _overlayController.forward(from: 0);
        await victoryAudio.playVictorySound();
        await victoryAudio.waitForCompletion();
        _speak(
          "All aboard! ${state.initialGroup.length} plus ${state.boardingGroup.length} equals ${state.correctAnswer}!",
        );
        break;
    }
  }

  Widget _buildAppBar(BuildContext context, TrainAdditionState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: state.themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: state.themeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMainArea(TrainAdditionState state, TrainAdditionNotifier notifier) {
    return Column(
      children: [
        const Spacer(),
        // Train Area
        SlideTransition(position: _trainEntryAnim, child: _buildTrain(state, notifier)),
        const Spacer(),
        // Boarding Area (always visible except success)
        if (state.phase != TrainAdditionPhase.success) _buildBoardingArea(state, notifier),
        if (state.phase == TrainAdditionPhase.testing) _buildTestingArea(state, notifier),
        const Spacer(),
      ],
    );
  }

  Widget _buildTrain(TrainAdditionState state, TrainAdditionNotifier notifier) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Engine
          _buildEngine(state.themeColor),
          // Car with passengers
          _buildTrainCar(state, notifier),
        ],
      ),
    );
  }

  Widget _buildEngine(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text('🚂', style: const TextStyle(fontSize: 100)),
        Positioned(
          top: 20,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainCar(TrainAdditionState state, TrainAdditionNotifier notifier) {
    return Container(
      width: 180,
      height: 100,
      decoration: BoxDecoration(
        color: state.themeColor.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border.all(color: Colors.black45, width: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Wheels
          Positioned(
            bottom: -15,
            left: 20,
            child: Text('🔘', style: const TextStyle(fontSize: 30)),
          ),
          Positioned(
            bottom: -15,
            right: 20,
            child: Text('🔘', style: const TextStyle(fontSize: 30)),
          ),
          // Passengers
          Center(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                ...List.generate(state.currentInitialTapped, (index) {
                  return Text(
                    state.initialGroup[index].emoji,
                    style: const TextStyle(fontSize: 35),
                  );
                }),
                ...List.generate(state.currentBoardingTapped, (index) {
                  return Text(
                    state.boardingGroup[index].emoji,
                    style: const TextStyle(fontSize: 35),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardingArea(TrainAdditionState state, TrainAdditionNotifier notifier) {
    bool isInitialBoarding = state.phase == TrainAdditionPhase.boardingInitial;
    bool isSecondBoarding = state.phase == TrainAdditionPhase.boardingSecond;

    // Choose which group of passengers to show below
    List<PassengerItem> currentItems = isSecondBoarding ? state.boardingGroup : state.initialGroup;
    int tappedCount = isSecondBoarding ? state.currentBoardingTapped : state.currentInitialTapped;

    return Opacity(
      opacity: isInitialBoarding || isSecondBoarding ? 1.0 : 0.5,
      child: Column(
        children: [
          Text(
            isInitialBoarding || isSecondBoarding ? "Tap the friends to board!" : "Waiting...",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isInitialBoarding || isSecondBoarding ? state.themeColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            children: List.generate(currentItems.length, (index) {
              bool hasBoarded = index < tappedCount;
              return GestureDetector(
                onTap: () {
                  if (isInitialBoarding && index == state.currentInitialTapped) {
                    notifier.incrementInitialTapped();
                    _speak("${index + 1}");
                    if (index + 1 == currentItems.length) {
                      Future.delayed(
                        const Duration(seconds: 1),
                        () => notifier.startSecondBoardingPhase(),
                      );
                    }
                  } else if (isSecondBoarding && index == state.currentBoardingTapped) {
                    notifier.incrementBoardingTapped();
                    _speak("${state.initialGroup.length + index + 1}");
                    if (index + 1 == currentItems.length) {
                      Future.delayed(const Duration(seconds: 1), () => notifier.goToTest());
                    }
                  }
                },
                child: AnimatedOpacity(
                  opacity: hasBoarded ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: Text(currentItems[index].emoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingArea(TrainAdditionState state, TrainAdditionNotifier notifier) {
    return Column(
      children: [
        const Text(
          "How many in total?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: state.testOptions.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  if (option == state.correctAnswer) {
                    notifier.checkAnswer(option);
                  } else {
                    _speak("Try again! Count all the friends on the train.");
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: state.themeColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: state.themeColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      "$option",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: state.themeColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuccessOverlay(TrainAdditionState state, TrainAdditionNotifier notifier) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚂✨⭐', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 20),
                Text(
                  '${state.initialGroup.length} + ${state.boardingGroup.length} = ${state.correctAnswer}',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: state.themeColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'FANTASTIC!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => notifier.nextRound(),
                  icon: Icon(
                    state.currentRound >= state.totalRounds ? Icons.refresh : Icons.arrow_forward,
                  ),
                  label: Text(
                    state.currentRound >= state.totalRounds ? "Play Again" : "Next Round",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

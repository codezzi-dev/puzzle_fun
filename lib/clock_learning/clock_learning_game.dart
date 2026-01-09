import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../shared/victory_audio_service.dart';
import 'config_cl.dart';
import 'widgets/clock_painter.dart';

class ClockLearningGame extends ConsumerStatefulWidget {
  const ClockLearningGame({super.key});

  @override
  ConsumerState<ClockLearningGame> createState() => _ClockLearningGameState();
}

class _ClockLearningGameState extends ConsumerState<ClockLearningGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _clockPulseController;
  late Animation<double> _clockPulseAnim;

  ClockGamePhase? _lastSpokenPhase;

  @override
  void initState() {
    super.initState();
    _initTts();

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

    _clockPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _clockPulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _clockPulseController, curve: Curves.easeInOut));
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _overlayController.dispose();
    _buttonController.dispose();
    _clockPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clockProvider);
    final notifier = ref.read(clockProvider.notifier);

    if (state.phase != _lastSpokenPhase) {
      _lastSpokenPhase = state.phase;
      if (state.phase == ClockGamePhase.learning) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _speak("Look at the clock! It's ${state.spokenTime}!");
        });
      } else if (state.phase == ClockGamePhase.testing) {
        _speak("Move the hands to show ${state.spokenTime}!");
      } else if (state.phase == ClockGamePhase.success) {
        _overlayController.forward(from: 0);
        victoryAudio.playVictorySound();
        _speak("Wonderful! You set the clock to ${state.spokenTime}!");
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
              const Color(0xFFF0F4F8),
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
              if (state.phase == ClockGamePhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ClockState state) {
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

  Widget _buildContent(ClockState state, ClockNotifier notifier) {
    if (state.phase == ClockGamePhase.learning) {
      return _buildLearningMode(state, notifier);
    }
    return _buildTestingMode(state, notifier);
  }

  Widget _buildLearningMode(ClockState state, ClockNotifier notifier) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "🕐 What time is it? 🕐",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: state.themeColor),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: state.themeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "It's ${state.spokenTime}!",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: state.themeColor),
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Center(
            child: ScaleTransition(
              scale: _clockPulseAnim,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: InteractiveClock(
                  hour: state.targetHour,
                  minute: state.targetMinute,
                  themeColor: state.themeColor,
                  interactive: false,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedButton(
          onPressed: () {
            _speak("Now you try!");
            notifier.goToTest();
          },
          gradientColors: [state.themeColor, state.themeColor.withValues(alpha: 0.7)],
          icon: Icons.play_arrow_rounded,
          text: "I Know This Time!",
        ),
        const SizedBox(height: 20),
        // Hint button to hear time again
        TextButton.icon(
          onPressed: () => _speak("It's ${state.spokenTime}!"),
          icon: Icon(Icons.volume_up_rounded, color: state.themeColor),
          label: Text(
            "Hear again",
            style: TextStyle(color: state.themeColor, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTestingMode(ClockState state, ClockNotifier notifier) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "🎯 Set the clock! 🎯",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: state.themeColor),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Text(
            "Show ${state.spokenTime}!",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.orange),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: InteractiveClock(
                hour: state.currentHour,
                minute: state.currentMinute,
                themeColor: state.themeColor,
                interactive: true,
                onHourChanged: (hour) => notifier.updateHourHand(hour),
                onMinuteChanged: (minute) => notifier.updateMinuteHand(minute),
                showCorrectIndicator: state.isCorrect,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Current time display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: state.isCorrect
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: state.isCorrect ? Colors.green : Colors.grey.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.isCorrect ? Icons.check_circle_rounded : Icons.access_time_rounded,
                color: state.isCorrect ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "Your clock: ${state.currentHour}:${state.currentMinute.toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: state.isCorrect ? Colors.green : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedButton(
          onPressed: () {
            if (state.isCorrect) {
              notifier.checkAnswer();
            } else {
              _speak("Not quite! Try again. Show ${state.spokenTime}.");
            }
          },
          gradientColors: state.isCorrect
              ? [Colors.green, Colors.green.shade400]
              : [Colors.grey, Colors.grey.shade400],
          icon: Icons.check_rounded,
          text: state.isCorrect ? "Check My Answer!" : "Move the hands!",
        ),
        const SizedBox(height: 20),
        // Hint button
        TextButton.icon(
          onPressed: () => _speak("Move the hands to show ${state.spokenTime}!"),
          icon: Icon(Icons.lightbulb_outline_rounded, color: state.themeColor),
          label: Text(
            "Need a hint?",
            style: TextStyle(color: state.themeColor, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSuccessOverlay(ClockState state, ClockNotifier notifier) {
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
                const Text('⏰🎉⏰', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  state.spokenTime.toUpperCase(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: state.themeColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PERFECT!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can tell time like a pro!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
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
                  text: state.currentRound >= state.totalRounds ? 'Play Again!' : 'Next Time!',
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

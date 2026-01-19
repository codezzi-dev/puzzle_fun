import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/tts_service.dart';
import '../shared/victory_audio_service.dart';
import 'config_cm.dart';
import 'widgets/mixing_pot.dart';

class ColorMixerGame extends ConsumerStatefulWidget {
  const ColorMixerGame({super.key});

  @override
  ConsumerState<ColorMixerGame> createState() => _ColorMixerGameState();
}

class _ColorMixerGameState extends ConsumerState<ColorMixerGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  ColorMixerPhase? _lastPhase;
  String? _lastSpokenMessage;

  @override
  void initState() {
    super.initState();
    tts.init();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    tts.stop();
    _bounceController.dispose();
    super.dispose();
  }

  void _speak(String text) {
    tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(colorMixerProvider);
    final notifier = ref.read(colorMixerProvider.notifier);

    // Optimized audio logic - trigger on phase OR message change
    if (state.phase != _lastPhase || state.motivationalMessage != _lastSpokenMessage) {
      final isNewPhase = state.phase != _lastPhase;
      _lastPhase = state.phase;
      _lastSpokenMessage = state.motivationalMessage;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.phase == ColorMixerPhase.success && isNewPhase) {
          // Play victory sound and then speak success message
          victoryAudio.playVictorySound().then((_) {
            _speak(state.motivationalMessage);
          });
        } else {
          _speak(state.motivationalMessage);
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Color(0xFFF3E5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, state),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusCard(state),
                    const SizedBox(height: 40),
                    DragTarget<MixableColor>(
                      onWillAcceptWithDetails: (details) =>
                          state.phase == ColorMixerPhase.testing && state.currentMix.length < 2,
                      onAcceptWithDetails: (details) {
                        notifier.addColor(details.data);
                        _speak(details.data.name);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return MixingPot(
                          currentMix: state.currentMix,
                          resultColor:
                              state.phase == ColorMixerPhase.success ||
                                  state.phase == ColorMixerPhase.learning
                              ? state.targetColor
                              : null,
                          isLearning: state.phase == ColorMixerPhase.learning,
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    _buildColorSource(state, notifier),
                    const SizedBox(height: 40),
                    _buildActionButtons(state, notifier),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorMixerState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Text(
              'Round ${state.currentRound}/${state.totalRounds}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${state.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ColorMixerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(
            state.phase == ColorMixerPhase.learning ? 'Learning Time!' : 'Puzzle Time!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: state.phase == ColorMixerPhase.learning ? Colors.blue : Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.motivationalMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          if (state.phase == ColorMixerPhase.learning && state.targetColor != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSmallColorChip(state.currentMix[0]),
                  const Text(' + ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  _buildSmallColorChip(state.currentMix[1]),
                  const Text(' = ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  _buildSmallColorChip(state.targetColor!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallColorChip(MixableColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.color, width: 2),
      ),
      child: Text(
        '${color.emoji} ${color.name}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildColorSource(ColorMixerState state, ColorMixerNotifier notifier) {
    if (state.phase == ColorMixerPhase.success) {
      return const SizedBox(height: 80);
    }

    return Wrap(
      spacing: 20,
      children: primaryColors.map((color) {
        final isAlreadyInMix = state.currentMix.contains(color);

        return Draggable<MixableColor>(
          data: color,
          feedback: Material(
            color: Colors.transparent,
            child: Text(color.emoji, style: const TextStyle(fontSize: 80)),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Text(color.emoji, style: const TextStyle(fontSize: 60)),
          ),
          child: AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, isAlreadyInMix ? 0 : -_bounceAnim.value),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                if (state.phase == ColorMixerPhase.testing) {
                  notifier.addColor(color);
                  _speak(color.name);
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Center(
                  child: Text(
                    color.emoji,
                    style: TextStyle(fontSize: 40, color: isAlreadyInMix ? Colors.grey : null),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(ColorMixerState state, ColorMixerNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.phase == ColorMixerPhase.learning)
          _buildPrimaryButton(
            onPressed: () => notifier.goToTest(),
            text: "I'm Ready!",
            icon: Icons.play_arrow_rounded,
            color: Colors.green,
          ),
        if (state.phase == ColorMixerPhase.testing)
          _buildPrimaryButton(
            onPressed: () => notifier.clearMix(),
            text: "Clear Pot",
            icon: Icons.refresh_rounded,
            color: Colors.orange,
          ),
        if (state.phase == ColorMixerPhase.success)
          _buildPrimaryButton(
            onPressed: () {
              victoryAudio.stop();
              notifier.nextRound();
            },
            text: state.currentRound >= state.totalRounds ? "Play Again" : "Next Round",
            icon: Icons.navigate_next_rounded,
            color: Colors.blue,
          ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/tts_service.dart';
import 'config_ca.dart';
import 'widgets/mixing_pot.dart';

class ColorAlchemyGame extends ConsumerStatefulWidget {
  const ColorAlchemyGame({super.key});

  @override
  ConsumerState<ColorAlchemyGame> createState() => _ColorAlchemyGameState();
}

class _ColorAlchemyGameState extends ConsumerState<ColorAlchemyGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;

  String? _lastSpokenMessage;

  @override
  void initState() {
    super.initState();
    tts.init();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
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
    final state = ref.watch(colorAlchemyProvider);
    final notifier = ref.read(colorAlchemyProvider.notifier);

    // Optimized audio logic
    if (state.motivationalMessage != _lastSpokenMessage) {
      _lastSpokenMessage = state.motivationalMessage;
      final resultName = state.lastResult?.name;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.isNewDiscovery && resultName != null) {
          // Speak ONLY the new color name for discoveries
          _speak(resultName);
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
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, state, notifier),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusCard(state),
                    const SizedBox(height: 30),
                    DragTarget<MixableColor>(
                      onWillAcceptWithDetails: (details) => state.currentMix.length < 2,
                      onAcceptWithDetails: (details) {
                        notifier.addColor(details.data);
                        _speak(details.data.name);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return MixingPot(
                          currentMix: state.currentMix,
                          resultColor: state.lastResult,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildAvailableColors(state, notifier),
                  ],
                ),
              ),
              _buildActionButtons(state, notifier),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ColorAlchemyState state,
    ColorAlchemyNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'Colors Found: ${state.availableColors.length}/${baseColors.length + alchemyRecipes.length ~/ 2}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.orange),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Alchemy?'),
                  content: const Text('You will lose all discovered colors. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        notifier.resetGame();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ColorAlchemyState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),

      child: Column(
        children: [
          const Text(
            'Mixing Laboratory',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          Text(
            state.motivationalMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: state.isNewDiscovery ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableColors(ColorAlchemyState state, ColorAlchemyNotifier notifier) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.availableColors.length,
        itemBuilder: (context, index) {
          final color = state.availableColors[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Draggable<MixableColor>(
              data: color,
              feedback: Material(
                color: Colors.transparent,
                child: Text(color.emoji, style: const TextStyle(fontSize: 60)),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: _buildColorCircle(color)),
              child: GestureDetector(
                onTap: () {
                  notifier.addColor(color);
                  _speak(color.name);
                },
                child: _buildColorCircle(color),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorCircle(MixableColor color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            border: Border.all(color: color.color.withValues(alpha: 0.5), width: 3),
          ),

          child: Center(child: Text(color.emoji, style: const TextStyle(fontSize: 35))),
        ),
        const SizedBox(height: 4),
        Text(color.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtons(ColorAlchemyState state, ColorAlchemyNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPrimaryButton(
          onPressed: () => notifier.clearMix(),
          text: "Clear Pot",
          icon: Icons.delete_outline_rounded,
          color: Colors.orange,
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

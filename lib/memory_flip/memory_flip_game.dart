import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../shared/victory_audio_service.dart';
import 'config_mf.dart';
import 'widgets/memory_card_widget.dart';

class MemoryFlipGame extends ConsumerStatefulWidget {
  const MemoryFlipGame({super.key});

  @override
  ConsumerState<MemoryFlipGame> createState() => _MemoryFlipGameState();
}

class _MemoryFlipGameState extends ConsumerState<MemoryFlipGame> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;

  int _lastScore = 0;
  bool _hasSpokenSuccess = false;

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
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
    await _flutterTts.speak('Find the matching pairs!');
  }

  Future<void> _speakMatch() async {
    final messages = ['Match found!', 'Great job!', 'You found it!', 'Awesome!'];
    final message = messages[math.Random().nextInt(messages.length)];
    await _flutterTts.speak(message);
  }

  Future<void> _speakVictory() async {
    await _flutterTts.speak('Congratulations! You matched them all!');
    victoryAudio.playVictorySound();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryFlipProvider);
    final notifier = ref.read(memoryFlipProvider.notifier);

    // TTS Logic
    if (state.score > _lastScore) {
      _lastScore = state.score;
      _speakMatch();
    }

    if (state.phase == MemoryFlipPhase.success && !_hasSpokenSuccess) {
      _hasSpokenSuccess = true;
      _overlayController.forward(from: 0);
      _speakVictory();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, state),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildGrid(state, notifier),
                    ),
                  ),
                ],
              ),
              if (state.phase == MemoryFlipPhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MemoryFlipState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
            color: const Color(0xFF6A4C93),
          ),
          const Spacer(),
          _buildInfoBadge(
            label: 'Matches',
            value: '${state.score}',
            colors: [const Color(0xFF8AC926), const Color(0xFF1982C4)],
            icon: Icons.star_rounded,
          ),
          const SizedBox(width: 12),
          _buildInfoBadge(
            label: 'Moves',
            value: '${state.moves}',
            colors: [const Color(0xFFFF9F1C), const Color(0xFFFF6B6B)],
            icon: Icons.touch_app_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required String label,
    required String value,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
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
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildGrid(MemoryFlipState state, MemoryFlipNotifier notifier) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: state.cards.length,
      itemBuilder: (context, index) {
        return MemoryCardWidget(card: state.cards[index], onTap: () => notifier.flipCard(index));
      },
    );
  }

  Widget _buildSuccessOverlay(MemoryFlipState state, MemoryFlipNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'BRAVO!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6A4C93),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You matched everything!',
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                _buildStatsRow('Moves Used', '${state.moves}'),
                const SizedBox(height: 32),
                _buildActionButton(
                  onPressed: () {
                    _hasSpokenSuccess = false;
                    _lastScore = 0;
                    victoryAudio.stop();
                    notifier.resetGame();
                  },
                  label: 'Play Again',
                  icon: Icons.refresh_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF6A4C93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF8AC926), Color(0xFF06D6A0)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8AC926).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

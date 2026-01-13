import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_sb.dart';

class SequenceBuilderGame extends ConsumerStatefulWidget {
  const SequenceBuilderGame({super.key});

  @override
  ConsumerState<SequenceBuilderGame> createState() => _SequenceBuilderGameState();
}

class _SequenceBuilderGameState extends ConsumerState<SequenceBuilderGame>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late Animation<double> _successScale;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    tts.init();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  void _speak(String text) {
    tts.speak(text);
  }

  void _speakSuccess() {
    final messages = [
      "Amazing! You got it right!",
      "Wonderful! Perfect order!",
      "Great job! You're a sequencing star!",
    ];
    tts.speak(messages[math.Random().nextInt(messages.length)]);
  }

  @override
  void dispose() {
    tts.stop();
    _successController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sequenceBuilderProvider);
    final notifier = ref.read(sequenceBuilderProvider.notifier);

    // Handle success state
    if (state.phase == GamePhase.success &&
        !_successController.isAnimating &&
        _successController.value == 0) {
      _successController.forward();
      victoryAudio.playVictorySound();
      _speakSuccess();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFF3E5F5), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingDecorations(),
              Column(
                children: [
                  _buildAppBar(context, state, notifier),
                  Expanded(child: _buildGameContent(state, notifier)),
                ],
              ),
              if (state.phase == GamePhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDecorations() {
    return Stack(
      children: [
        _buildDecoration(Icons.arrow_forward, Colors.purple.shade200, 40, 50, 20),
        _buildDecoration(Icons.timeline, Colors.blue.shade200, 35, 120, 320),
        _buildDecoration(Icons.sort, Colors.green.shade200, 45, 200, 50),
        _buildDecoration(Icons.format_list_numbered, Colors.orange.shade200, 30, 350, 280),
      ],
    );
  }

  Widget _buildDecoration(IconData icon, Color color, double size, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Opacity(
        opacity: 0.15,
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    SequenceBuilderState state,
    SequenceBuilderNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            color: Colors.purple,
          ),
          const Spacer(),
          _buildInfoChip(
            icon: Icons.flag_rounded,
            text: '${state.currentRound}/${state.totalRounds}',
            gradient: [Colors.purple, Colors.deepPurple],
          ),
          const SizedBox(width: 12),
          _buildInfoChip(
            icon: Icons.star_rounded,
            text: '${state.score}',
            gradient: [Colors.amber, Colors.orange],
          ),
          const Spacer(),
          _buildIconButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              notifier.reset();
              _successController.reset();
            },
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildGameContent(SequenceBuilderState state, SequenceBuilderNotifier notifier) {
    if (state.phase == GamePhase.learning) {
      return _buildLearningPage(state, notifier);
    } else {
      return _buildTestingPage(state, notifier);
    }
  }

  Widget _buildLearningPage(SequenceBuilderState state, SequenceBuilderNotifier notifier) {
    // Speak theme instruction on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak(state.currentTheme.instruction);
    });

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Theme Title
          Text(
            state.currentTheme.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.currentTheme.instruction,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Show correct sequence
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: state.currentTheme.items.map((item) {
                  return _buildSequenceCard(item, showOrder: true);
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Start Testing Button
          ScaleTransition(
            scale: _pulseAnimation,
            child: _buildPremiumButton(
              onTap: () {
                notifier.startTesting();
                _speak("Now put them in the right order!");
              },
              text: "Let's Test!",
              icon: Icons.play_arrow_rounded,
              colors: [Colors.purple, Colors.deepPurple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingPage(SequenceBuilderState state, SequenceBuilderNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Theme Title
          Text(
            state.currentTheme.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Put them in the right order!",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Drop targets (slots)
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(state.placements.length, (index) {
                  return _buildDropSlot(index, state.placements[index], notifier);
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Divider with arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 60, height: 2, color: Colors.grey.shade300),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_upward_rounded, color: Colors.grey),
              ),
              Container(width: 60, height: 2, color: Colors.grey.shade300),
            ],
          ),

          const SizedBox(height: 16),

          // Draggable items pool
          Expanded(
            flex: 1,
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: state.shuffledItems.map((item) {
                  return Draggable<SequenceItem>(
                    data: item,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildSequenceCard(item, isDragging: true),
                    ),
                    childWhenDragging: Opacity(opacity: 0.3, child: _buildSequenceCard(item)),
                    child: _buildSequenceCard(item),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceCard(SequenceItem item, {bool showOrder = false, bool isDragging = false}) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: isDragging ? 0.4 : 0.2),
            blurRadius: isDragging ? 20 : 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showOrder)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '${item.order}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (showOrder) const SizedBox(height: 4),
          Text(item.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(
            item.name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDropSlot(int index, SequenceItem? placedItem, SequenceBuilderNotifier notifier) {
    return DragTarget<SequenceItem>(
      onWillAcceptWithDetails: (details) => placedItem == null,
      onAcceptWithDetails: (details) {
        notifier.placeItem(index, details.data);
        if (details.data.order == index + 1) {
          _speak(details.data.name);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 75,
          height: 95,
          decoration: BoxDecoration(
            color: placedItem != null
                ? Colors.green.shade50
                : (isHighlighted ? Colors.purple.shade50 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: placedItem != null
                  ? Colors.green
                  : (isHighlighted ? Colors.purple : Colors.grey.shade300),
              width: 3,
              style: placedItem != null ? BorderStyle.solid : BorderStyle.none,
            ),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: placedItem != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(placedItem.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 2),
                    Text(
                      placedItem.name,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isHighlighted ? Colors.purple.shade100 : Colors.grey.shade200,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isHighlighted ? Colors.purple : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.add_rounded,
                      color: isHighlighted ? Colors.purple : Colors.grey.shade400,
                      size: 24,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPremiumButton({
    required VoidCallback onTap,
    required String text,
    required IconData icon,
    required List<Color> colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.4),
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
    );
  }

  Widget _buildSuccessOverlay(SequenceBuilderState state, SequenceBuilderNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: ScaleTransition(
          scale: _successScale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: state.currentTheme.items
                      .map((item) => Text(item.emoji, style: const TextStyle(fontSize: 40)))
                      .toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'PERFECT ORDER!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You completed the ${state.currentTheme.title}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    victoryAudio.stop();
                    notifier.nextRound();
                    _successController.reset();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Next Sequence!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
  }
}

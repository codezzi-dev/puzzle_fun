import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_rm.dart';

class RoomMatcherGame extends ConsumerStatefulWidget {
  const RoomMatcherGame({super.key});

  @override
  ConsumerState<RoomMatcherGame> createState() => _RoomMatcherGameState();
}

class _RoomMatcherGameState extends ConsumerState<RoomMatcherGame> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnim;
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;

  GamePhase? _lastSpokenPhase;
  int? _lastRound;

  @override
  void initState() {
    super.initState();
    tts.init();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
  }

  void _speak(String text) {
    tts.speak(text);
  }

  Future<void> _speakSuccess() async {
    final messages = [
      'Amazing job!',
      'You put everything in the right room!',
      'You\'re a home organizing expert!',
      'Perfect placement!',
    ];
    final message = messages[math.Random().nextInt(messages.length)];
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    tts.speak(message);
  }

  @override
  void dispose() {
    tts.stop();
    _floatController.dispose();
    _overlayController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomMatcherProvider);
    final notifier = ref.read(roomMatcherProvider.notifier);

    // Handle phase changes and TTS
    if (state.phase != _lastSpokenPhase || state.currentRound != _lastRound) {
      _lastSpokenPhase = state.phase;
      _lastRound = state.currentRound;

      if (state.phase == GamePhase.learning) {
        final roomNames = state.currentRooms.map((r) => r.name).join(', ');
        _speak("Let's learn the rooms! We have the $roomNames. Look at what belongs in each room!");
      } else if (state.phase == GamePhase.testing) {
        _speak("Now drag each item to its room!");
      } else if (state.phase == GamePhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3), Color(0xFFFFE082)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingDecorations(),
              Column(
                children: [
                  _buildHeader(context, state),
                  Expanded(child: _buildBody(state, notifier)),
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
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 80 + _floatAnim.value,
              left: 20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(Icons.home_rounded, size: 60, color: Colors.brown),
              ),
            ),
            Positioned(
              top: 200 - _floatAnim.value,
              right: 30,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.chair_rounded, size: 50, color: Colors.orange),
              ),
            ),
            Positioned(
              bottom: 150 + _floatAnim.value,
              left: 40,
              child: Opacity(
                opacity: 0.12,
                child: Icon(Icons.bed_rounded, size: 55, color: Colors.purple),
              ),
            ),
            Positioned(
              bottom: 80 - _floatAnim.value,
              right: 50,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.kitchen_rounded, size: 45, color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, RoomMatcherState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              victoryAudio.stop();
              tts.stop();
              Navigator.pop(context);
            },
            color: const Color(0xFF8D6E63),
          ),
          const Spacer(),
          _buildStatBadge(
            icon: Icons.star_rounded,
            text: '${state.score}',
            colors: [const Color(0xFFFFB300), const Color(0xFFFF8F00)],
          ),
          const SizedBox(width: 12),
          _buildStatBadge(
            text: 'Round ${state.currentRound}/${state.totalRounds}',
            colors: [const Color(0xFF8D6E63), const Color(0xFFA1887F)],
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
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildStatBadge({IconData? icon, required String text, required List<Color> colors}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25),
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
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RoomMatcherState state, RoomMatcherNotifier notifier) {
    if (state.phase == GamePhase.learning) {
      return _buildLearningView(state, notifier);
    }
    return _buildTestingView(state, notifier);
  }

  Widget _buildLearningView(RoomMatcherState state, RoomMatcherNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Learn the Rooms!",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF5D4037)),
          ),
          const SizedBox(height: 8),
          Text(
            "See which items belong in each room",
            style: TextStyle(
              fontSize: 16,
              color: Colors.brown.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          // Show all 4 rooms with their items
          ...state.currentRooms.map((room) {
            final roomItems = notifier.getItemsForRoom(room.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: room.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Room icon with color
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [room.color, room.color.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(room.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Items for this room (fixed size cards)
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: roomItems.take(4).map((item) {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.emoji, style: const TextStyle(fontSize: 28)),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5D4037),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildPremiumButton(
            onTap: () => notifier.startTesting(),
            text: "I'm Ready!",
            icon: Icons.play_arrow_rounded,
            colors: [const Color(0xFF8D6E63), const Color(0xFFA1887F)],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTestingView(RoomMatcherState state, RoomMatcherNotifier notifier) {
    return Column(
      children: [
        const Text(
          "Put each item in its room!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF5D4037)),
        ),
        const SizedBox(height: 8),
        Text(
          "Drag items to the matching room",
          style: TextStyle(fontSize: 14, color: Colors.brown.shade400, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        // Room targets
        Expanded(
          flex: 3,
          child: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: state.currentRooms.map((room) {
                return _buildRoomTarget(room, state, notifier);
              }).toList(),
            ),
          ),
        ),
        // Item pool
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "🏠 Items to Place",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: state.itemPool.map((item) {
                        return Draggable<RoomItem>(
                          data: item,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildItemCard(item, isDragging: true),
                          ),
                          childWhenDragging: Opacity(opacity: 0.3, child: _buildItemCard(item)),
                          child: _buildItemCard(item),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTarget(Room room, RoomMatcherState state, RoomMatcherNotifier notifier) {
    final placedItems = state.placedItems[room.id] ?? [];

    return DragTarget<RoomItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final isCorrect = notifier.placeItem(room.id, details.data);
        if (isCorrect) {
          _speak("Yes! The ${details.data.name} goes in the ${room.name}!");
        } else {
          _speak("Hmm, that doesn't go in the ${room.name}. Try again!");
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHighlighted
                  ? [room.color, room.color.withValues(alpha: 0.8)]
                  : [room.color.withValues(alpha: 0.7), room.color.withValues(alpha: 0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isHighlighted ? Colors.white : Colors.transparent, width: 3),
            boxShadow: [
              BoxShadow(
                color: room.color.withValues(alpha: isHighlighted ? 0.5 : 0.3),
                blurRadius: isHighlighted ? 20 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(room.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                room.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (placedItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: placedItems
                      .map((item) => Text(item.emoji, style: const TextStyle(fontSize: 20)))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(RoomItem item, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumButton({
    required VoidCallback onTap,
    required String text,
    required IconData icon,
    required List<Color> colors,
    Color? textColor,
  }) {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: onTap,
      child: ScaleTransition(
        scale: _buttonScaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor ?? Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(RoomMatcherState state, RoomMatcherNotifier notifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🏠 PERFECT! 🏠",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Everything is in the right room!",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 8,
                  children: state.currentRooms
                      .map((room) => Text(room.emoji, style: const TextStyle(fontSize: 36)))
                      .toList(),
                ),
                const SizedBox(height: 40),
                _buildPremiumButton(
                  onTap: () {
                    victoryAudio.stop();
                    tts.stop();
                    notifier.nextRound();
                  },
                  text: state.currentRound >= state.totalRounds ? "PLAY AGAIN" : "NEXT ROUND",
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  colors: [Colors.white, Colors.white],
                  textColor: const Color(0xFFFF9800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

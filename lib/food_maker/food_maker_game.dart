import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/victory_audio_service.dart';
import '../shared/tts_service.dart';
import 'config_fm.dart';

class FoodMakerGame extends ConsumerStatefulWidget {
  const FoodMakerGame({super.key});

  @override
  ConsumerState<FoodMakerGame> createState() => _FoodMakerGameState();
}

class _FoodMakerGameState extends ConsumerState<FoodMakerGame> with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayScaleAnim;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _decorationController;
  final GlobalKey _foodAreaKey = GlobalKey();

  FoodMakerPhase? _lastPhase;
  int? _lastRound;

  @override
  void initState() {
    super.initState();
    tts.init();

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
      end: 0.95,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _decorationController = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  void _speak(String text) {
    tts.speak(text);
  }

  Future<void> _speakSuccess() async {
    final messages = [
      'Yum! That looks delicious!',
      'Great job chef!',
      'You followed the recipe perfectly!',
      'Amazing decoration!',
    ];
    final message = messages[math.Random().nextInt(messages.length)];
    await victoryAudio.playVictorySound();
    await victoryAudio.waitForCompletion();
    _speak(message);
  }

  @override
  void dispose() {
    tts.stop();
    _overlayController.dispose();
    _buttonController.dispose();
    _pulseController.dispose();
    _decorationController.dispose();
    super.dispose();
  }

  String _getInstruction(FoodMakerState state) {
    final List<String> parts = [];
    state.targetToppings.forEach((id, count) {
      final topping = state.currentBase.availableToppings.firstWhere((t) => t.id == id);
      parts.add('$count ${topping.name}');
    });

    if (parts.isEmpty) return "Decorate the ${state.currentBase.name}!";
    if (parts.length == 1) return "Put ${parts[0]} on the ${state.currentBase.name}.";

    final lastPart = parts.removeLast();
    return "Put ${parts.join(', ')} and $lastPart on the ${state.currentBase.name}.";
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodMakerProvider);
    final notifier = ref.read(foodMakerProvider.notifier);

    // Phase Change logic
    if (state.phase != _lastPhase || state.currentRound != _lastRound) {
      if (state.phase == FoodMakerPhase.learning) {
        final instruction = _getInstruction(state);
        _speak(instruction);
      } else if (state.phase == FoodMakerPhase.success) {
        _overlayController.forward(from: 0);
        _speakSuccess();
      }
      _lastPhase = state.phase;
      _lastRound = state.currentRound;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              state.themeColor.withOpacity(0.15),
              Colors.white,
              state.themeColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundDecorations(state.themeColor),
              Column(
                children: [
                  _buildAppBar(context, state),
                  if (state.phase == FoodMakerPhase.playing) _buildOrderHeader(state),
                  Expanded(
                    child: state.phase == FoodMakerPhase.learning
                        ? _buildLearningPhase(state, notifier)
                        : _buildPlayingPhase(state, notifier),
                  ),
                ],
              ),
              if (state.phase == FoodMakerPhase.success) _buildSuccessOverlay(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations(Color themeColor) {
    return Stack(
      children: List.generate(10, (index) {
        final random = math.Random(index);
        final size = 20.0 + random.nextDouble() * 30;
        final left = random.nextDouble() * 400;
        final top = random.nextDouble() * 800;
        final icons = [Icons.star_rounded, Icons.favorite_rounded, Icons.circle_rounded];
        final icon = icons[random.nextInt(icons.length)];

        return Positioned(
          left: left,
          top: top,
          child: AnimatedBuilder(
            animation: _decorationController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: _decorationController.value * 2 * math.pi * (random.nextBool() ? 1 : -1),
                  child: Icon(icon, color: themeColor, size: size),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildAppBar(BuildContext context, FoodMakerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            color: state.themeColor,
          ),
          const Spacer(),
          _buildInfoPill('${state.score}', Icons.emoji_events_rounded, state.themeColor),
          const SizedBox(width: 12),
          _buildInfoPill(
            '${state.currentRound}/${state.totalRounds}',
            Icons.flag_rounded,
            state.themeColor,
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
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildInfoPill(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPhase(FoodMakerState state, FoodMakerNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Chef's Recipe!",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: state.themeColor),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: state.targetToppings.entries.map((entry) {
                final topping = state.currentBase.availableToppings.firstWhere(
                  (t) => t.id == entry.key,
                );
                return Column(
                  children: [
                    Text(topping.emoji, style: const TextStyle(fontSize: 70)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: state.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'x ${entry.value}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: state.themeColor,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 60),
          _buildPremiumButton(
            onTap: () => notifier.startPlaying(),
            text: "LET'S COOK!",
            icon: Icons.restaurant_rounded,
            colors: [state.themeColor, state.themeColor.withOpacity(0.8)],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(FoodMakerState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: state.themeColor.withOpacity(0.2), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: state.targetToppings.entries.map((entry) {
          final topping = state.currentBase.availableToppings.firstWhere((t) => t.id == entry.key);
          final currentCount = state.currentToppings.where((t) => t.item.id == entry.key).length;
          final isDone = currentCount == entry.value;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(topping.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  '$currentCount / ${entry.value}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDone ? Colors.green : state.themeColor,
                  ),
                ),
                if (isDone)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlayingPhase(FoodMakerState state, FoodMakerNotifier notifier) {
    bool allMet = true;
    state.targetToppings.forEach((id, count) {
      if (state.currentToppings.where((t) => t.item.id == id).length != count) {
        allMet = false;
      }
    });

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: DragTarget<ToppingItem>(
              key: _foodAreaKey,
              onAcceptWithDetails: (details) {
                final RenderBox? renderBox =
                    _foodAreaKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localPos = renderBox.globalToLocal(details.offset);
                  notifier.addTopping(details.data, localPos);
                  _speak(details.data.name);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Plate/Background effect
                    Container(
                      width: 360,
                      height: 360,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Food Base
                    Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: candidateData.isNotEmpty ? Colors.green : Colors.transparent,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'food_base',
                          child: Text(
                            state.currentBase.emoji,
                            style: const TextStyle(fontSize: 240),
                          ),
                        ),
                      ),
                    ),
                    // Placed Toppings - Ensure they are explicitly on top
                    ...state.currentToppings.asMap().entries.map((entry) {
                      final item = entry.value;
                      return Positioned(
                        left: item.position.dx,
                        top: item.position.dy,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: item.rotation,
                              child: Transform.scale(scale: item.scale * value, child: child),
                            );
                          },
                          child: Text(item.item.emoji, style: const TextStyle(fontSize: 60)),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
        // Topping Toolbar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: state.currentBase.availableToppings.map((topping) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Draggable<ToppingItem>(
                        data: topping,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Text(topping.emoji, style: const TextStyle(fontSize: 90)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: state.themeColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: state.themeColor.withOpacity(0.1), width: 2),
                          ),
                          child: Text(topping.emoji, style: const TextStyle(fontSize: 55)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(
                    icon: Icons.undo_rounded,
                    onTap: () => notifier.removeLastTopping(),
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 20),
                  ScaleTransition(
                    scale: allMet ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                    child: _buildPremiumButton(
                      onTap: () => notifier.checkOrder(),
                      text: "CHECK RECIPE",
                      icon: Icons.restaurant_menu_rounded,
                      colors: allMet
                          ? [Colors.green, Colors.green.shade700]
                          : [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.3),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(FoodMakerState state, FoodMakerNotifier notifier) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: ScaleTransition(
          scale: _overlayScaleAnim,
          child: Container(
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD166), Color(0xFFF78C6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 40, spreadRadius: 5),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "AMAZING CHEF! 🌟",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(state.currentBase.emoji, style: const TextStyle(fontSize: 100)),
                ),
                const SizedBox(height: 40),
                _buildPremiumButton(
                  onTap: () {
                    _overlayController.reverse();
                    notifier.nextRound();
                  },
                  text: state.currentRound >= state.totalRounds ? "PLAY AGAIN" : "NEXT RECIPE",
                  icon: state.currentRound >= state.totalRounds
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  colors: [Colors.white, Colors.white],
                  textColor: const Color(0xFFF78C6B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

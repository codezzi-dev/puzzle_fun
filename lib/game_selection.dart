import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'body_parts/body_parts_game.dart';
import 'color_memorize/color_memorize_game.dart';
import 'digit_master/digit_master_game.dart';
import 'puzzle_fun/puzzle_fun.dart';
import 'robot_builder/robot_builder_game.dart';
import 'shape_master/shape_master_game.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleScale;
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  final List<_GameInfo> games = [
    _GameInfo(
      title: 'Puzzle Fun',
      emoji: '🧩',
      description: 'Slide the tiles!',
      gradientColors: [const Color(0xFF6A4C93), const Color(0xFF9B5DE5)],
      page: const PuzzleFun(),
    ),
    _GameInfo(
      title: 'Color Master',
      emoji: '🎨',
      description: 'Learn colors!',
      gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFFBE0B)],
      page: const ColorMemorize(),
    ),
    _GameInfo(
      title: 'Shape Master',
      emoji: '🔷',
      description: 'Learn shapes!',
      gradientColors: [const Color(0xFF00B4D8), const Color(0xFF90E0EF)],
      page: const ShapeMaster(),
    ),
    _GameInfo(
      title: 'Digit Master',
      emoji: '🔢',
      description: 'Learn numbers!',
      gradientColors: [const Color(0xFFFF9F1C), const Color(0xFFFFBF69)],
      page: const DigitMaster(),
    ),
    _GameInfo(
      title: 'Body Parts',
      emoji: '🧍',
      description: 'Learn body parts!',
      gradientColors: [const Color(0xFFE63946), const Color(0xFFF77F00)],
      page: const BodyPartsGame(),
    ),
    _GameInfo(
      title: 'Robot Builder',
      emoji: '🤖',
      description: 'Build with shapes!',
      gradientColors: [const Color(0xFF7B68EE), const Color(0xFF9B59B6)],
      page: const RobotBuilderGame(),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Title animation
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _titleScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeInOut));

    // Card entrance animations
    _cardControllers = List.generate(
      games.length,
      (index) => AnimationController(vsync: this, duration: const Duration(milliseconds: 600)),
    );
    _cardAnimations = _cardControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    // Stagger the card animations
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 150)), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFFCE4EC), Color(0xFFFFF8E1)],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Animated Title
              ScaleTransition(
                scale: _titleScale,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFFBE0B),
                      Color(0xFF8AC926),
                      Color(0xFF1982C4),
                      Color(0xFF6A4C93),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    '🎮 Kids Games 🎮',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Choose a game to play!',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              // Game Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView.separated(
                    itemCount: games.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return ScaleTransition(
                        scale: _cardAnimations[index],
                        child: _GameCard(
                          info: games[index],
                          onTap: () => _navigateToGame(games[index].page),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _GameInfo {
  final String title;
  final String emoji;
  final String description;
  final List<Color> gradientColors;
  final Widget page;

  _GameInfo({
    required this.title,
    required this.emoji,
    required this.description,
    required this.gradientColors,
    required this.page,
  });
}

class _GameCard extends StatefulWidget {
  final _GameInfo info;
  final VoidCallback onTap;

  const _GameCard({required this.info, required this.onTap});

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _emojiRotation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
    _emojiRotation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) {
        _hoverController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.info.gradientColors,
                ),
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: widget.info.gradientColors[0].withValues(alpha: 0.4),
                    blurRadius: 20.0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 1.0,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        // Emoji with rotation
                        Transform.rotate(
                          angle: _emojiRotation.value * math.pi,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            child: Center(
                              child: Text(widget.info.emoji, style: const TextStyle(fontSize: 36)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Text content
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.info.title,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.info.description,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

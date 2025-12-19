import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config_pd.dart';
import 'game_container.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Puzzle Fun!',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Nunito',
      primarySwatch: Colors.purple,
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleScale;
  late AnimationController _winController;
  late Animation<double> _winScale;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _titleScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    _winController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _winScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _winController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _winController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Trigger win animation
    if (gameState.winState?.contains('Win') == true) {
      _winController.forward(from: 0);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9), // Light mint
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFFCE4EC), // Light pink
              Color(0xFFFFF8E1), // Light yellow
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: size.width > 500 ? 500 : size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          '🧩 Puzzle Fun! 🧩',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Grid Size Selector
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.15),
                            blurRadius: 15.0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎯 Choose Grid Size',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A4C93),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GridSizeOption(
                                label: '3×3',
                                value: 3,
                                groupValue: gameState.gridSize,
                                color: const Color(0xFFFF6B6B),
                                onChanged: (v) => gameNotifier.changeGridSize(v!),
                              ),
                              const SizedBox(width: 12.0),
                              _GridSizeOption(
                                label: '4×4',
                                value: 4,
                                groupValue: gameState.gridSize,
                                color: const Color(0xFF8AC926),
                                onChanged: (v) => gameNotifier.changeGridSize(v!),
                              ),
                              const SizedBox(width: 12.0),
                              _GridSizeOption(
                                label: '5×5',
                                value: 5,
                                groupValue: gameState.gridSize,
                                color: const Color(0xFF1982C4),
                                onChanged: (v) => gameNotifier.changeGridSize(v!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Stats Display
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 10.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            icon: '👆',
                            label: 'Moves',
                            value: gameState.moves.toString(),
                            color: const Color(0xFFFF6B6B),
                          ),
                          Container(
                            height: 40,
                            width: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          _StatItem(
                            icon: '✨',
                            label: 'Correct',
                            value: '${gameState.correctTiles}/${gameState.numberedTiles}',
                            color: const Color(0xFF8AC926),
                          ),
                        ],
                      ),
                    ),

                    // Win State Message
                    if (gameState.winState != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: gameState.winState!.contains('Win')
                            ? ScaleTransition(
                                scale: _winScale,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withValues(alpha: 0.4),
                                        blurRadius: 15.0,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    gameState.winState!,
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                gameState.winState!,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),

                    // Game Grid
                    const Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 30.0),
                      child: GameContainer(),
                    ),

                    // Shuffle Button
                    _ShuffleButton(onPressed: () => gameNotifier.suffle()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridSizeOption extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final Color color;
  final ValueChanged<int?> onChanged;

  const _GridSizeOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: color,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8.0,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18.0)),
            const SizedBox(width: 4.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ShuffleButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ShuffleButton({required this.onPressed});

  @override
  State<_ShuffleButton> createState() => _ShuffleButtonState();
}

class _ShuffleButtonState extends State<_ShuffleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6A4C93),
                Color(0xFF9B5DE5),
              ],
            ),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A4C93).withValues(alpha: 0.4),
                blurRadius: 15.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Transform.rotate(
                  angle: 320 * math.pi / 180,
                  child: const Icon(Icons.replay, size: 22.0, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8.0),
              const Text(
                'Shuffle!',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

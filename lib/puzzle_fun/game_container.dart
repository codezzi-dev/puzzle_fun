import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config_pd.dart';


class GameContainer extends ConsumerStatefulWidget {
  const GameContainer({super.key});

  @override
  ConsumerState<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends ConsumerState<GameContainer> with TickerProviderStateMixin {
  static const int maxTiles = 25; // 5x5
  List<Tween<Offset>> switchTween = [];
  List<Animation<Offset>> switchAnim = [];
  List<AnimationController> switchAnimCont = [];
  
  // Scale animations for tap feedback
  List<AnimationController> tapControllers = [];
  List<Animation<double>> tapAnimations = [];
  
  // Pulse animation for correct tiles
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize slide animations for each possible tile
    for (int i = 0; i < maxTiles; i++) {
      switchAnimCont.add(
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300)),
      );
      switchTween.add(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
      switchAnim.add(switchTween[i].animate(
        CurvedAnimation(parent: switchAnimCont[i], curve: Curves.easeOutBack),
      ));
      
      // Tap feedback animations
      tapControllers.add(
        AnimationController(vsync: this, duration: const Duration(milliseconds: 100)),
      );
      tapAnimations.add(
        Tween<double>(begin: 1.0, end: 0.9).animate(
          CurvedAnimation(parent: tapControllers[i], curve: Curves.easeInOut),
        ),
      );
    }
    
    // Pulse animation for correct tiles
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void refreshAnim(int x, int y) {
    switchAnimCont[x].reset();
    switchAnimCont[x].forward();
    switchAnimCont[y].reset();
    switchAnimCont[y].forward();
  }

  @override
  void dispose() {
    for (int i = 0; i < maxTiles; i++) {
      switchAnimCont[i].dispose();
      tapControllers[i].dispose();
    }
    _pulseController.dispose();
    super.dispose();
  }

  bool _isCorrectPosition(int index, String value) {
    if (value == 'X') return false;
    return (index + 1).toString() == value;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final gridSize = gameState.gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = (constraints.maxWidth - (gridSize - 1) * 8) / gridSize;
        
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            mainAxisSpacing: 6.0,
            crossAxisSpacing: 6.0,
          ),
          itemCount: gameState.tilesList.length,
          itemBuilder: (context, index) {
            final tileValue = gameState.tilesList[index];
            final isEmptyTile = tileValue == 'X';
            final numValue = int.tryParse(tileValue) ?? 0;
            final isCorrect = _isCorrectPosition(index, tileValue);
            
            return SlideTransition(
              position: switchAnim[index],
              child: GestureDetector(
                onTapDown: (_) {
                  if (!isEmptyTile && gameState.isGameRunning) {
                    tapControllers[index].forward();
                  }
                },
                onTapUp: (_) {
                  tapControllers[index].reverse();
                },
                onTapCancel: () {
                  tapControllers[index].reverse();
                },
                onTap: () {
                  if (!isEmptyTile && gameState.isGameRunning) {
                    int idxOfX = gameState.tilesList.indexOf('X');
                    int temp = (idxOfX - index);
                    
                    // Check horizontal move validity (prevent wrapping)
                    if (temp.abs() == 1) {
                      int idxRow = idxOfX ~/ gridSize;
                      int indexRow = index ~/ gridSize;
                      if (idxRow != indexRow) return;
                    }
                    
                    if (temp == 1) {
                      // moving right
                      switchTween[index].begin = const Offset(1, 0);
                      switchTween[index].end = Offset.zero;
                      switchTween[idxOfX].begin = const Offset(-1, 0);
                      switchTween[idxOfX].end = Offset.zero;
                      refreshAnim(index, idxOfX);
                    } else if (temp == -1) {
                      // moving left
                      switchTween[index].begin = const Offset(-1, 0);
                      switchTween[index].end = Offset.zero;
                      switchTween[idxOfX].begin = const Offset(1, 0);
                      switchTween[idxOfX].end = Offset.zero;
                      refreshAnim(index, idxOfX);
                    } else if (temp == gridSize) {
                      // moving down
                      switchTween[index].begin = const Offset(0, 1);
                      switchTween[index].end = Offset.zero;
                      switchTween[idxOfX].begin = const Offset(0, -1);
                      switchTween[idxOfX].end = Offset.zero;
                      refreshAnim(index, idxOfX);
                    } else if (temp == -gridSize) {
                      // moving up
                      switchTween[index].begin = const Offset(0, -1);
                      switchTween[index].end = Offset.zero;
                      switchTween[idxOfX].begin = const Offset(0, 1);
                      switchTween[idxOfX].end = Offset.zero;
                      refreshAnim(index, idxOfX);
                    }
                    gameNotifier.moveTile(index);
                  }
                },
                child: ScaleTransition(
                  scale: tapAnimations[index],
                  child: isEmptyTile
                      ? _buildEmptyTile()
                      : _buildColorfulTile(
                          color: gameState.getTileColor(numValue),
                          displayText: tileValue,
                          isCorrect: isCorrect,
                          tileSize: tileSize,
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 2.0,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
    );
  }

  Widget _buildColorfulTile({
    required Color color,
    required String displayText,
    required bool isCorrect,
    required double tileSize,
  }) {
    final baseColor = color;
    final darkerColor = HSLColor.fromColor(baseColor).withLightness(
      (HSLColor.fromColor(baseColor).lightness - 0.15).clamp(0.0, 1.0),
    ).toColor();

    Widget tile = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            darkerColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 1.0,
            offset: const Offset(-1, -1),
          ),
        ],
        border: isCorrect 
            ? Border.all(color: Colors.white, width: 3.0)
            : null,
      ),
      child: Stack(
        children: [
          // Highlight effect
          Positioned(
            top: 4,
            left: 4,
            right: 8,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Number text
          Center(
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: tileSize * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Star badge for correct tiles
          if (isCorrect)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.star,
                  size: tileSize * 0.12,
                  color: Colors.amber,
                ),
              ),
            ),
        ],
      ),
    );

    // Add pulse animation for correct tiles
    if (isCorrect) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: tile,
      );
    }

    return tile;
  }
}

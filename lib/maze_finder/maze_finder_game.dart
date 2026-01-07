import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:maze/maze.dart';

import '../shared/victory_audio_service.dart';

class MazeFinderGame extends StatefulWidget {
  const MazeFinderGame({super.key});

  @override
  State<MazeFinderGame> createState() => _MazeFinderGameState();
}

class _MazeFinderGameState extends State<MazeFinderGame> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _successController;
  late Animation<double> _successScale;

  int _currentLevelIndex = 0;
  bool _isComplete = false;

  final List<_MazeLevelData> _levels = [
    _MazeLevelData(
      rows: 5,
      cols: 5,
      playerAsset: 'assets/images/maze_mouse.png',
      targetAsset: 'assets/images/maze_cheese.png',
      animalEmoji: '🐁',
      targetEmoji: '🧀',
      instruction: 'Help the Mouse find the cheese!',
      themeColor: Colors.orange,
    ),
    _MazeLevelData(
      rows: 6,
      cols: 6,
      playerAsset: 'assets/images/maze_rabbit.png',
      targetAsset: 'assets/images/maze_carrot.png',
      animalEmoji: '🐇',
      targetEmoji: '🥕',
      instruction: 'Help the Rabbit find the carrot!',
      themeColor: Colors.green,
    ),
    _MazeLevelData(
      rows: 8,
      cols: 8,
      playerAsset: 'assets/images/maze_bee.png',
      targetAsset: 'assets/images/maze_flower.png',
      animalEmoji: '🐝',
      targetEmoji: '🌸',
      instruction: 'Help the Bee find the flower!',
      themeColor: Colors.amber,
    ),
    _MazeLevelData(
      rows: 10,
      cols: 10,
      playerAsset: 'assets/images/maze_mouse.png',
      targetAsset: 'assets/images/maze_cheese.png',
      animalEmoji: '🐁',
      targetEmoji: '🧀',
      instruction: 'Wait! The mouse is lost again!',
      themeColor: Colors.orange,
    ),
    _MazeLevelData(
      rows: 12,
      cols: 12,
      playerAsset: 'assets/images/maze_rabbit.png',
      targetAsset: 'assets/images/maze_carrot.png',
      animalEmoji: '🐇',
      targetEmoji: '🥕',
      instruction: 'The rabbit needs even more carrots!',
      themeColor: Colors.green,
    ),
    _MazeLevelData(
      rows: 14,
      cols: 14,
      playerAsset: 'assets/images/maze_bee.png',
      targetAsset: 'assets/images/maze_flower.png',
      animalEmoji: '🐝',
      targetEmoji: '🌸',
      instruction: 'One last flower for the busy bee!',
      themeColor: Colors.amber,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));

    _speakInstruction(_levels[_currentLevelIndex].instruction);
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
  }

  Future<void> _speakInstruction(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _successController.dispose();
    super.dispose();
  }

  void _onFinish() {
    if (_isComplete) return;
    setState(() {
      _isComplete = true;
    });
    _successController.forward();
    victoryAudio.playVictorySound();
  }

  void _nextLevel() {
    setState(() {
      _currentLevelIndex = (_currentLevelIndex + 1) % _levels.length;
      _isComplete = false;
    });
    _successController.reset();
    _speakInstruction(_levels[_currentLevelIndex].instruction);
  }

  void _resetLevel() {
    setState(() {
      _isComplete = false;
    });
    _successController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final level = _levels[_currentLevelIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              level.themeColor.withValues(alpha: 0.1),
              Colors.white,
              const Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, level),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _isComplete
                          ? const SizedBox.shrink() // Don't show maze when complete to avoid duplicate wins/interaction
                          : Maze(
                              player: MazeItem(level.playerAsset, ImageType.asset),
                              finish: MazeItem(level.targetAsset, ImageType.asset),
                              columns: level.cols,
                              rows: level.rows,
                              wallColor: level.themeColor,
                              wallThickness: 4.0,
                              onFinish: _onFinish,
                            ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      'Find the way!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isComplete) _buildSuccessOverlay(level),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, _MazeLevelData level) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: level.themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Spacer(),
          Text(
            'Level ${_currentLevelIndex + 1}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: level.themeColor),
          ),
          const Spacer(),
          IconButton(
            onPressed: _resetLevel,
            icon: const Icon(Icons.refresh_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay(_MazeLevelData level) {
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
                  color: level.themeColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${level.animalEmoji} ❤️ ${level.targetEmoji}',
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 24),
                const Text(
                  'YAY! YOU DID IT!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You found the way!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    victoryAudio.stop();
                    _nextLevel();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [level.themeColor, level.themeColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Next Level!',
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

class _MazeLevelData {
  final int rows;
  final int cols;
  final String playerAsset;
  final String targetAsset;
  final String animalEmoji;
  final String targetEmoji;
  final String instruction;
  final Color themeColor;

  _MazeLevelData({
    required this.rows,
    required this.cols,
    required this.playerAsset,
    required this.targetAsset,
    required this.animalEmoji,
    required this.targetEmoji,
    required this.instruction,
    required this.themeColor,
  });
}

import 'package:flutter/material.dart';
import '../config_mf.dart';

class MazeWidget extends StatelessWidget {
  final MazeLevel level;
  final Point playerPos;
  final Color themeColor;

  const MazeWidget({
    super.key,
    required this.level,
    required this.playerPos,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellSize = constraints.maxWidth / level.cols;
        final double mazeHeight = cellSize * level.rows;

        // Center the maze vertically if there's extra space
        return Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: mazeHeight,
            child: Stack(
              children: [
                // Walls Layer
                CustomPaint(
                  size: Size(constraints.maxWidth, mazeHeight),
                  painter: MazePainter(level: level, themeColor: themeColor, cellSize: cellSize),
                ),

                // Target Emoji
                Positioned(
                  left: level.end.x * cellSize,
                  top: level.end.y * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: Center(
                    child: Text(level.target, style: TextStyle(fontSize: cellSize * 0.6)),
                  ),
                ),

                // Player (Animal) Emoji
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutBack,
                  left: playerPos.x * cellSize,
                  top: playerPos.y * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: Center(
                    child: Text(level.animal, style: TextStyle(fontSize: cellSize * 0.7)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MazePainter extends CustomPainter {
  final MazeLevel level;
  final Color themeColor;
  final double cellSize;

  MazePainter({required this.level, required this.themeColor, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final wallPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.3)
      ..strokeWidth = 2.0;

    // Draw background grid lines (optional, for visual guide)
    for (int i = 0; i <= level.cols; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), wallPaint);
    }
    for (int j = 0; j <= level.rows; j++) {
      canvas.drawLine(Offset(0, j * cellSize), Offset(size.width, j * cellSize), wallPaint);
    }

    // Draw Walls
    for (int y = 0; y < level.rows; y++) {
      for (int x = 0; x < level.cols; x++) {
        final cell = level.grid[y][x];
        final left = x * cellSize;
        final top = y * cellSize;
        final right = (x + 1) * cellSize;
        final bottom = (y + 1) * cellSize;

        if (cell.top) canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        if (cell.bottom) canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        if (cell.left) canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        if (cell.right) canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
      }
    }

    // Draw outer border
    final outerPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
      outerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MazePainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.cellSize != cellSize;
  }
}

import 'package:flutter/material.dart';

import '../config_clm.dart';

/// Paints connection lines between colors and shapes
class LinePainter extends CustomPainter {
  final List<Connection> connections;
  final Map<String, Offset> colorPositions; // Center positions of color swatches
  final Map<String, Offset> shapePositions; // Center positions of shapes
  final String? activeColorId; // Currently dragging from this color
  final Offset? dragPosition; // Current drag end position
  final List<MatchItem> colors; // To get color values

  LinePainter({
    required this.connections,
    required this.colorPositions,
    required this.shapePositions,
    required this.colors,
    this.activeColorId,
    this.dragPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw existing connections
    for (final connection in connections) {
      final startPos = colorPositions[connection.colorId];
      final endPos = shapePositions[connection.shapeId];

      if (startPos != null && endPos != null) {
        final colorItem = colors.firstWhere((c) => c.id == connection.colorId);
        _drawLine(canvas, startPos, endPos, colorItem.color, isComplete: true);
      }
    }

    // Draw active drag line
    if (activeColorId != null && dragPosition != null) {
      final startPos = colorPositions[activeColorId];
      if (startPos != null) {
        final colorItem = colors.firstWhere((c) => c.id == activeColorId);
        _drawLine(canvas, startPos, dragPosition!, colorItem.color, isComplete: false);
      }
    }
  }

  void _drawLine(Canvas canvas, Offset start, Offset end, Color color, {required bool isComplete}) {
    final paint = Paint()
      ..color = color.withValues(alpha: isComplete ? 0.8 : 0.5)
      ..strokeWidth = isComplete ? 5 : 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Create a curved path for more visual appeal
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Calculate control point for a smooth curve
    final midX = (start.dx + end.dx) / 2;
    final controlY = (start.dy + end.dy) / 2;

    // Use quadratic bezier for smooth curve
    path.quadraticBezierTo(midX, controlY, end.dx, end.dy);

    // Draw dashed line for incomplete connections
    if (!isComplete) {
      _drawDashedPath(canvas, path, paint);
    } else {
      // Draw solid line with glow effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);

      // Draw end circles
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(start, 6, dotPaint);
      canvas.drawCircle(end, 6, dotPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      const dashLength = 10.0;
      const gapLength = 8.0;

      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashLength).clamp(0.0, metric.length);

        final extractPath = metric.extractPath(start, end);
        canvas.drawPath(extractPath, paint);

        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return connections != oldDelegate.connections ||
        colorPositions != oldDelegate.colorPositions ||
        shapePositions != oldDelegate.shapePositions ||
        activeColorId != oldDelegate.activeColorId ||
        dragPosition != oldDelegate.dragPosition;
  }
}

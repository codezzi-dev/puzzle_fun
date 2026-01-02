import 'dart:ui';

import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<Offset> guidePoints;
  final List<Offset> userPoints;
  final Color themeColor;

  PathPainter({required this.guidePoints, required this.userPoints, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Guide Path (Dashed)
    final guidePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final guidePath = Path();
    if (guidePoints.isNotEmpty) {
      guidePath.moveTo(guidePoints[0].dx * size.width, guidePoints[0].dy * size.height);
      for (int i = 1; i < guidePoints.length; i++) {
        guidePath.lineTo(guidePoints[i].dx * size.width, guidePoints[i].dy * size.height);
      }
    }

    // Draw dashed effect for guide
    _drawDashedPath(canvas, guidePath, guidePaint);

    // Draw User Path
    if (userPoints.isNotEmpty) {
      final userPaint = Paint()
        ..color = themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final userPath = Path();
      userPath.moveTo(userPoints[0].dx * size.width, userPoints[0].dy * size.height);
      for (int i = 1; i < userPoints.length; i++) {
        userPath.lineTo(userPoints[i].dx * size.width, userPoints[i].dy * size.height);
      }

      // Add a glow to user path
      canvas.drawPath(
        userPath,
        Paint()
          ..color = themeColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      canvas.drawPath(userPath, userPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 10.0;
    const double dashSpace = 8.0;

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(metric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) => true;
}

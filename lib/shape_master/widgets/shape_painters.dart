import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A collection of child-friendly, colorful custom painted shapes
/// for the Shape Master learning game.

// ============================================================
// SQUARE SHAPE
// ============================================================
class SquarePainter extends CustomPainter {
  final Color color;

  SquarePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Main square
    final squareRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.15, size.width * 0.7, size.height * 0.7),
      const Radius.circular(12),
    );
    canvas.drawRRect(squareRect, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.2, size.width * 0.2, size.height * 0.15),
        const Radius.circular(6),
      ),
      paint,
    );

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.45), size.width * 0.05, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.45), size.width * 0.05, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.43), size.width * 0.02, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.43), size.width * 0.02, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.03;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.75, size.width * 0.65, size.height * 0.6);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(SquarePainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// CIRCLE SHAPE
// ============================================================
class CirclePainter extends CustomPainter {
  final Color color;

  CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Main circle
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.4, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.2, size.width * 0.2, size.height * 0.15),
      paint,
    );

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.45), size.width * 0.05, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.45), size.width * 0.05, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.43), size.width * 0.02, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.43), size.width * 0.02, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.03;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.72, size.width * 0.65, size.height * 0.58);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// OVAL SHAPE
// ============================================================
class OvalPainter extends CustomPainter {
  final Color color;

  OvalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Main oval (horizontal)
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.25, size.width * 0.84, size.height * 0.5),
      paint,
    );

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.2, size.height * 0.12),
      paint,
    );

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.45), size.width * 0.04, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.45), size.width * 0.04, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.44), size.width * 0.015, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.44), size.width * 0.015, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.65, size.width * 0.6, size.height * 0.55);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(OvalPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// RECTANGLE SHAPE
// ============================================================
class RectanglePainter extends CustomPainter {
  final Color color;

  RectanglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Main rectangle (horizontal)
    final rectPath = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.3, size.width * 0.84, size.height * 0.4),
      const Radius.circular(10),
    );
    canvas.drawRRect(rectPath, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.12, size.height * 0.34, size.width * 0.18, size.height * 0.1),
        const Radius.circular(4),
      ),
      paint,
    );

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.45), size.width * 0.04, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.45), size.width * 0.04, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.44), size.width * 0.015, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.44), size.width * 0.015, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.63, size.width * 0.6, size.height * 0.55);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(RectanglePainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// TRIANGLE SHAPE
// ============================================================
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Main triangle
    final trianglePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.85)
      ..lineTo(size.width * 0.1, size.height * 0.85)
      ..close();
    canvas.drawPath(trianglePath, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.35);
    final shinePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.35)
      ..lineTo(size.width * 0.4, size.height * 0.35)
      ..close();
    canvas.drawPath(shinePath, paint);

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.55), size.width * 0.045, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.55), size.width * 0.045, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.41, size.height * 0.54), size.width * 0.018, paint);
    canvas.drawCircle(Offset(size.width * 0.61, size.height * 0.54), size.width * 0.018, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.78, size.width * 0.6, size.height * 0.68);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// PENTAGON SHAPE
// ============================================================
class PentagonPainter extends CustomPainter {
  final Color color;

  PentagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.42;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.28), size.width * 0.08, paint);

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.48), size.width * 0.045, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.48), size.width * 0.045, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.47), size.width * 0.018, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.47), size.width * 0.018, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.38, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.72, size.width * 0.62, size.height * 0.62);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(PentagonPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// HEXAGON SHAPE
// ============================================================
class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.42;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.25), size.width * 0.08, paint);

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.45), size.width * 0.045, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.45), size.width * 0.045, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.44), size.width * 0.018, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.44), size.width * 0.018, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.38, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.7, size.width * 0.62, size.height * 0.58);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// DIAMOND SHAPE
// ============================================================
class DiamondPainter extends CustomPainter {
  final Color color;

  DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Main diamond (rotated square)
    final diamondPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.08)
      ..lineTo(size.width * 0.92, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.92)
      ..lineTo(size.width * 0.08, size.height * 0.5)
      ..close();
    canvas.drawPath(diamondPath, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.4);
    final shinePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.18)
      ..lineTo(size.width * 0.65, size.height * 0.35)
      ..lineTo(size.width * 0.35, size.height * 0.35)
      ..close();
    canvas.drawPath(shinePath, paint);

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.45), size.width * 0.045, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.45), size.width * 0.045, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.44), size.width * 0.018, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.44), size.width * 0.018, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.38, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.7, size.width * 0.62, size.height * 0.58);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(DiamondPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// HEART SHAPE
// ============================================================
class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Heart shape using bezier curves
    final heartPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.25)
      ..cubicTo(
        size.width * 0.2, size.height * 0.0,
        size.width * 0.0, size.height * 0.35,
        size.width * 0.5, size.height * 0.9,
      )
      ..moveTo(size.width * 0.5, size.height * 0.25)
      ..cubicTo(
        size.width * 0.8, size.height * 0.0,
        size.width * 1.0, size.height * 0.35,
        size.width * 0.5, size.height * 0.9,
      );
    canvas.drawPath(heartPath, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.45);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), size.width * 0.1, paint);

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.42), size.width * 0.04, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.42), size.width * 0.04, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.41), size.width * 0.015, paint);
    canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.41), size.width * 0.015, paint);

    // Smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.65, size.width * 0.6, size.height * 0.55);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// STAR SHAPE
// ============================================================
class ShapeStarPainter extends CustomPainter {
  final Color color;

  ShapeStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width * 0.45;
    final innerRadius = size.width * 0.2;

    for (int i = 0; i < 5; i++) {
      // Outer point
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final outerX = centerX + outerRadius * math.cos(outerAngle);
      final outerY = centerY + outerRadius * math.sin(outerAngle);

      // Inner point
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
      final innerX = centerX + innerRadius * math.cos(innerAngle);
      final innerY = centerY + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Shine effect
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(centerX - size.width * 0.1, centerY - size.height * 0.1),
      size.width * 0.08,
      paint,
    );

    // Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(
      Offset(centerX - size.width * 0.1, centerY - size.height * 0.02),
      size.width * 0.04,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + size.width * 0.1, centerY - size.height * 0.02),
      size.width * 0.04,
      paint,
    );

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(centerX - size.width * 0.09, centerY - size.height * 0.03),
      size.width * 0.015,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + size.width * 0.11, centerY - size.height * 0.03),
      size.width * 0.015,
      paint,
    );

    // Smile
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.black87;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(centerX - size.width * 0.08, centerY + size.height * 0.06)
      ..quadraticBezierTo(
        centerX,
        centerY + size.height * 0.14,
        centerX + size.width * 0.08,
        centerY + size.height * 0.06,
      );
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(ShapeStarPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// SHAPE WIDGET - Wraps the painters
// ============================================================
class ShapeWidget extends StatelessWidget {
  final String shapeType;
  final Color color;
  final double size;

  const ShapeWidget({
    super.key,
    required this.shapeType,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _getPainter()),
    );
  }

  CustomPainter _getPainter() {
    switch (shapeType.toLowerCase()) {
      case 'square':
        return SquarePainter(color: color);
      case 'circle':
        return CirclePainter(color: color);
      case 'oval':
        return OvalPainter(color: color);
      case 'rectangle':
        return RectanglePainter(color: color);
      case 'triangle':
        return TrianglePainter(color: color);
      case 'pentagon':
        return PentagonPainter(color: color);
      case 'hexagon':
        return HexagonPainter(color: color);
      case 'diamond':
        return DiamondPainter(color: color);
      case 'heart':
        return HeartPainter(color: color);
      case 'star':
        return ShapeStarPainter(color: color);
      default:
        return CirclePainter(color: color);
    }
  }
}

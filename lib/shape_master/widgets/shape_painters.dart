import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A collection of clean, realistic geometric shapes
/// for the Shape Master learning game.

// ============================================================
// SQUARE SHAPE
// ============================================================
class SquarePainter extends CustomPainter {
  final Color color;

  SquarePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.18, size.height * 0.20, size.width * 0.7, size.height * 0.7),
        const Radius.circular(8),
      ),
      shadowPaint,
    );

    // Main square with gradient
    final rect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.7,
    );
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_lighten(color, 0.15), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.18, size.height * 0.18, size.width * 0.25, size.height * 0.15),
        const Radius.circular(4),
      ),
      paint,
    );

    // Inner shadow for depth
    final innerShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black.withValues(alpha: 0.1);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), innerShadow);
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
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.4;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(center.dx + 3, center.dy + 3), radius, shadowPaint);

    // Main circle with radial gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [_lighten(color, 0.25), color, _darken(color, 0.2)],
      stops: const [0.0, 0.5, 1.0],
    );
    paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.18, size.width * 0.25, size.height * 0.18),
      paint,
    );
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
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.25,
      size.width * 0.84,
      size.height * 0.5,
    );

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(rect.translate(2, 3), shadowPaint);

    // Main oval with gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.2), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawOval(rect, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.28, size.width * 0.25, size.height * 0.12),
      paint,
    );
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
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.3,
      size.width * 0.84,
      size.height * 0.4,
    );

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(2, 3), const Radius.circular(6)),
      shadowPaint,
    );

    // Main rectangle with gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_lighten(color, 0.15), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.12, size.height * 0.33, size.width * 0.2, size.height * 0.1),
        const Radius.circular(3),
      ),
      paint,
    );
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
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    final shadowPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.14)
      ..lineTo(size.width * 0.92, size.height * 0.88)
      ..lineTo(size.width * 0.12, size.height * 0.88)
      ..close();
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(shadowPath, shadowPaint);

    // Main triangle
    final trianglePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.85)
      ..lineTo(size.width * 0.1, size.height * 0.85)
      ..close();

    // Gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.2), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, size.height * 0.1, size.width, size.height * 0.75),
    );
    canvas.drawPath(trianglePath, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.3);
    final highlightPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.18)
      ..lineTo(size.width * 0.62, size.height * 0.38)
      ..lineTo(size.width * 0.38, size.height * 0.38)
      ..close();
    canvas.drawPath(highlightPath, paint);
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
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.42;

    // Create pentagon path
    Path createPentagon(double offsetX, double offsetY) {
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final angle = (i * 72 - 90) * math.pi / 180;
        final x = centerX + offsetX + radius * math.cos(angle);
        final y = centerY + offsetY + radius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(createPentagon(2, 3), shadowPaint);

    // Main pentagon with gradient
    final path = createPentagon(0, 0);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.2), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
    );
    canvas.drawPath(path, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.28), size.width * 0.1, paint);
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
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.42;

    // Create hexagon path
    Path createHexagon(double offsetX, double offsetY) {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (i * 60 - 90) * math.pi / 180;
        final x = centerX + offsetX + radius * math.cos(angle);
        final y = centerY + offsetY + radius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(createHexagon(2, 3), shadowPaint);

    // Main hexagon with gradient
    final path = createHexagon(0, 0);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.2), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
    );
    canvas.drawPath(path, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.25), size.width * 0.1, paint);
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
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    final shadowPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.11)
      ..lineTo(size.width * 0.94, size.height * 0.52)
      ..lineTo(size.width * 0.52, size.height * 0.94)
      ..lineTo(size.width * 0.1, size.height * 0.52)
      ..close();
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(shadowPath, shadowPaint);

    // Main diamond
    final diamondPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.08)
      ..lineTo(size.width * 0.92, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.92)
      ..lineTo(size.width * 0.08, size.height * 0.5)
      ..close();

    // Gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.25), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(diamondPath, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.35);
    final highlightPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.16)
      ..lineTo(size.width * 0.68, size.height * 0.35)
      ..lineTo(size.width * 0.32, size.height * 0.35)
      ..close();
    canvas.drawPath(highlightPath, paint);
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
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart path
    Path createHeart(double offsetX, double offsetY) {
      return Path()
        ..moveTo(size.width * 0.5 + offsetX, size.height * 0.25 + offsetY)
        ..cubicTo(
          size.width * 0.2 + offsetX,
          size.height * 0.0 + offsetY,
          size.width * 0.0 + offsetX,
          size.height * 0.35 + offsetY,
          size.width * 0.5 + offsetX,
          size.height * 0.9 + offsetY,
        )
        ..moveTo(size.width * 0.5 + offsetX, size.height * 0.25 + offsetY)
        ..cubicTo(
          size.width * 0.8 + offsetX,
          size.height * 0.0 + offsetY,
          size.width * 1.0 + offsetX,
          size.height * 0.35 + offsetY,
          size.width * 0.5 + offsetX,
          size.height * 0.9 + offsetY,
        );
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(createHeart(2, 3), shadowPaint);

    // Main heart with gradient
    final heartPath = createHeart(0, 0);
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 1.2,
      colors: [_lighten(color, 0.25), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(heartPath, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.28), size.width * 0.1, paint);
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
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width * 0.45;
    final innerRadius = size.width * 0.2;

    // Create star path
    Path createStar(double offsetX, double offsetY) {
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final outerAngle = (i * 72 - 90) * math.pi / 180;
        final outerX = centerX + offsetX + outerRadius * math.cos(outerAngle);
        final outerY = centerY + offsetY + outerRadius * math.sin(outerAngle);

        final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
        final innerX = centerX + offsetX + innerRadius * math.cos(innerAngle);
        final innerY = centerY + offsetY + innerRadius * math.sin(innerAngle);

        if (i == 0) {
          path.moveTo(outerX, outerY);
        } else {
          path.lineTo(outerX, outerY);
        }
        path.lineTo(innerX, innerY);
      }
      path.close();
      return path;
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(createStar(2, 3), shadowPaint);

    // Main star with gradient
    final path = createStar(0, 0);
    final gradient = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      radius: 1.0,
      colors: [_lighten(color, 0.3), color, _darken(color, 0.15)],
    );
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: outerRadius),
    );
    canvas.drawPath(path, paint);

    // Highlight
    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(
      Offset(centerX - size.width * 0.08, centerY - size.height * 0.12),
      size.width * 0.1,
      paint,
    );
  }

  @override
  bool shouldRepaint(ShapeStarPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================

/// Lighten a color by a percentage (0.0 - 1.0)
Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// Darken a color by a percentage (0.0 - 1.0)
Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

// ============================================================
// SHAPE WIDGET - Wraps the painters
// ============================================================
class ShapeWidget extends StatelessWidget {
  final String shapeType;
  final Color color;
  final double size;

  const ShapeWidget({super.key, required this.shapeType, required this.color, this.size = 80});

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

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A collection of child-friendly, colorful custom painted characters
/// for the Color Memorizing game.

// ============================================================
// CAR CHARACTER
// ============================================================
class CarPainter extends CustomPainter {
  final Color color;

  CarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = color;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.35, size.width * 0.8, size.height * 0.35),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, paint);

    // Top/Roof
    final roofPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.35)
      ..lineTo(size.width * 0.35, size.height * 0.15)
      ..lineTo(size.width * 0.65, size.height * 0.15)
      ..lineTo(size.width * 0.75, size.height * 0.35)
      ..close();
    canvas.drawPath(roofPath, paint);

    // Windows
    paint.color = Colors.lightBlue.shade100;
    final windowPath = Path()
      ..moveTo(size.width * 0.28, size.height * 0.35)
      ..lineTo(size.width * 0.36, size.height * 0.2)
      ..lineTo(size.width * 0.48, size.height * 0.2)
      ..lineTo(size.width * 0.48, size.height * 0.35)
      ..close();
    canvas.drawPath(windowPath, paint);

    final windowPath2 = Path()
      ..moveTo(size.width * 0.52, size.height * 0.35)
      ..lineTo(size.width * 0.52, size.height * 0.2)
      ..lineTo(size.width * 0.64, size.height * 0.2)
      ..lineTo(size.width * 0.72, size.height * 0.35)
      ..close();
    canvas.drawPath(windowPath2, paint);

    // Wheels
    paint.color = Colors.grey.shade800;
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.7), size.width * 0.12, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.7), size.width * 0.12, paint);

    // Wheel centers
    paint.color = Colors.grey.shade400;
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.7), size.width * 0.05, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.7), size.width * 0.05, paint);

    // Headlights
    paint.color = Colors.yellow.shade200;
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.45), size.width * 0.04, paint);

    // Tail light
    paint.color = Colors.red.shade400;
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.45), size.width * 0.03, paint);
  }

  @override
  bool shouldRepaint(CarPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// BUS CHARACTER
// ============================================================
class BusPainter extends CustomPainter {
  final Color color;

  BusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = color;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.2, size.width * 0.9, size.height * 0.55),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, paint);

    // Windows
    paint.color = Colors.lightBlue.shade100;
    for (int i = 0; i < 4; i++) {
      final windowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * (0.12 + i * 0.2),
          size.height * 0.28,
          size.width * 0.14,
          size.height * 0.22,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(windowRect, paint);
    }

    // Front window (larger)
    final frontWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.78, size.height * 0.25, size.width * 0.14, size.height * 0.28),
      const Radius.circular(6),
    );
    canvas.drawRRect(frontWindow, paint);

    // Stripe
    paint.color = Colors.white.withValues(alpha: 0.8);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.55, size.width * 0.9, size.height * 0.06),
      paint,
    );

    // Wheels
    paint.color = Colors.grey.shade800;
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.75), size.width * 0.1, paint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.75), size.width * 0.1, paint);

    // Wheel centers
    paint.color = Colors.grey.shade400;
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.75), size.width * 0.04, paint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.75), size.width * 0.04, paint);

    // Headlights
    paint.color = Colors.yellow.shade200;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.88, size.height * 0.58, size.width * 0.05, size.height * 0.08),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(BusPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// STAR CHARACTER
// ============================================================
class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

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

    // Add shine effect
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(centerX - size.width * 0.1, centerY - size.height * 0.1),
      size.width * 0.08,
      paint,
    );

    // Eyes (cute face)
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

    // Smile
    paint.style = PaintingStyle.stroke;
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
  bool shouldRepaint(StarPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// BALLOON CHARACTER
// ============================================================
class BalloonPainter extends CustomPainter {
  final Color color;

  BalloonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Balloon body (oval)
    final balloonRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.05,
      size.width * 0.7,
      size.height * 0.65,
    );
    canvas.drawOval(balloonRect, paint);

    // Balloon knot
    final knotPath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.68)
      ..lineTo(size.width * 0.5, size.height * 0.75)
      ..lineTo(size.width * 0.55, size.height * 0.68)
      ..close();
    canvas.drawPath(knotPath, paint);

    // String
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.02;
    paint.color = Colors.grey.shade600;
    final stringPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.85,
        size.width * 0.5,
        size.height * 0.95,
      );
    canvas.drawPath(stringPath, paint);

    // Shine effect
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.15, size.width * 0.2, size.height * 0.25),
      paint,
    );

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.35), size.width * 0.04, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.35), size.width * 0.04, paint);

    // Smile
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.025;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(size.width * 0.38, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.58,
        size.width * 0.62,
        size.height * 0.48,
      );
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(BalloonPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// BUTTERFLY CHARACTER
// ============================================================
class ButterflyPainter extends CustomPainter {
  final Color color;

  ButterflyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Wings
    paint.color = color;

    // Left top wing
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.1, size.width * 0.4, size.height * 0.35),
      paint,
    );

    // Left bottom wing
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.42, size.width * 0.35, size.height * 0.32),
      paint,
    );

    // Right top wing
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.1, size.width * 0.4, size.height * 0.35),
      paint,
    );

    // Right bottom wing
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.57, size.height * 0.42, size.width * 0.35, size.height * 0.32),
      paint,
    );

    // Wing decorations
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.28), size.width * 0.08, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.28), size.width * 0.08, paint);
    canvas.drawCircle(Offset(size.width * 0.23, size.height * 0.55), size.width * 0.05, paint);
    canvas.drawCircle(Offset(size.width * 0.77, size.height * 0.55), size.width * 0.05, paint);

    // Body
    paint.color = Colors.brown.shade700;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.45, size.height * 0.15, size.width * 0.1, size.height * 0.6),
        const Radius.circular(10),
      ),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.12), size.width * 0.08, paint);

    // Antennae
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.02;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.08),
      Offset(size.width * 0.35, size.height * 0.02),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.08),
      Offset(size.width * 0.65, size.height * 0.02),
      paint,
    );
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.02), size.width * 0.025, paint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.02), size.width * 0.025, paint);

    // Eyes
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.47, size.height * 0.11), size.width * 0.025, paint);
    canvas.drawCircle(Offset(size.width * 0.53, size.height * 0.11), size.width * 0.025, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.47, size.height * 0.11), size.width * 0.015, paint);
    canvas.drawCircle(Offset(size.width * 0.53, size.height * 0.11), size.width * 0.015, paint);
  }

  @override
  bool shouldRepaint(ButterflyPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// CAT CHARACTER
// ============================================================
class CatPainter extends CustomPainter {
  final Color color;

  CatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = color;
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.45, size.width * 0.6, size.height * 0.45),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.32), size.width * 0.28, paint);

    // Ears
    final leftEarPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.22)
      ..lineTo(size.width * 0.3, size.height * 0.02)
      ..lineTo(size.width * 0.42, size.height * 0.18)
      ..close();
    canvas.drawPath(leftEarPath, paint);

    final rightEarPath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.22)
      ..lineTo(size.width * 0.7, size.height * 0.02)
      ..lineTo(size.width * 0.58, size.height * 0.18)
      ..close();
    canvas.drawPath(rightEarPath, paint);

    // Inner ears
    paint.color = Colors.pink.shade200;
    final leftInnerEarPath = Path()
      ..moveTo(size.width * 0.28, size.height * 0.2)
      ..lineTo(size.width * 0.32, size.height * 0.08)
      ..lineTo(size.width * 0.4, size.height * 0.18)
      ..close();
    canvas.drawPath(leftInnerEarPath, paint);

    final rightInnerEarPath = Path()
      ..moveTo(size.width * 0.72, size.height * 0.2)
      ..lineTo(size.width * 0.68, size.height * 0.08)
      ..lineTo(size.width * 0.6, size.height * 0.18)
      ..close();
    canvas.drawPath(rightInnerEarPath, paint);

    // Eyes
    paint.color = Colors.white;
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.24, size.width * 0.15, size.height * 0.14),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.24, size.width * 0.15, size.height * 0.14),
      paint,
    );

    // Pupils
    paint.color = Colors.green.shade700;
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.27, size.width * 0.08, size.height * 0.1),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.57, size.height * 0.27, size.width * 0.08, size.height * 0.1),
      paint,
    );

    // Pupil centers
    paint.color = Colors.black;
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.36, size.height * 0.28, size.width * 0.04, size.height * 0.08),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.28, size.width * 0.04, size.height * 0.08),
      paint,
    );

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.29), size.width * 0.02, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.29), size.width * 0.02, paint);

    // Nose
    paint.color = Colors.pink.shade400;
    final nosePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width * 0.45, size.height * 0.44)
      ..lineTo(size.width * 0.55, size.height * 0.44)
      ..close();
    canvas.drawPath(nosePath, paint);

    // Mouth
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.02;
    paint.color = Colors.black54;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.44),
      Offset(size.width * 0.5, size.height * 0.5),
      paint,
    );
    final mouthPath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.54,
        size.width * 0.6,
        size.height * 0.48,
      );
    canvas.drawPath(mouthPath, paint);

    // Whiskers
    paint.strokeWidth = size.width * 0.012;
    paint.color = Colors.grey.shade600;
    // Left whiskers
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.42),
      Offset(size.width * 0.42, size.height * 0.44),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.48),
      Offset(size.width * 0.42, size.height * 0.48),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.54),
      Offset(size.width * 0.42, size.height * 0.5),
      paint,
    );
    // Right whiskers
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.42),
      Offset(size.width * 0.58, size.height * 0.44),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.48),
      Offset(size.width * 0.58, size.height * 0.48),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.54),
      Offset(size.width * 0.58, size.height * 0.5),
      paint,
    );

    // Tail
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.08;
    paint.color = color;
    paint.strokeCap = StrokeCap.round;
    final tailPath = Path()
      ..moveTo(size.width * 0.78, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 1.0,
        size.height * 0.5,
        size.width * 0.85,
        size.height * 0.35,
      );
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(CatPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// BIRD CHARACTER
// ============================================================
class BirdPainter extends CustomPainter {
  final Color color;

  BirdPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = color;
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.35, size.width * 0.55, size.height * 0.45),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.3), size.width * 0.2, paint);

    // Wing
    final darkerColor = HSLColor.fromColor(
      color,
    ).withLightness((HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0)).toColor();
    paint.color = darkerColor;
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.38, size.width * 0.35, size.height * 0.25),
      paint,
    );

    // Tail feathers
    paint.color = color;
    final tailPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.02, size.height * 0.35)
      ..lineTo(size.width * 0.02, size.height * 0.55)
      ..lineTo(size.width * 0.02, size.height * 0.65)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..close();
    canvas.drawPath(tailPath, paint);

    // Beak
    paint.color = Colors.orange.shade600;
    final beakPath = Path()
      ..moveTo(size.width * 0.82, size.height * 0.28)
      ..lineTo(size.width * 0.98, size.height * 0.32)
      ..lineTo(size.width * 0.82, size.height * 0.36)
      ..close();
    canvas.drawPath(beakPath, paint);

    // Eye
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.26), size.width * 0.06, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.71, size.height * 0.26), size.width * 0.035, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.24), size.width * 0.015, paint);

    // Belly
    paint.color = Colors.white.withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.55, size.width * 0.3, size.height * 0.2),
      paint,
    );

    // Legs
    paint.color = Colors.orange.shade600;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.03;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.78),
      Offset(size.width * 0.4, size.height * 0.92),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.78),
      Offset(size.width * 0.55, size.height * 0.92),
      paint,
    );
    // Feet
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.92),
      Offset(size.width * 0.45, size.height * 0.92),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.92),
      Offset(size.width * 0.6, size.height * 0.92),
      paint,
    );
  }

  @override
  bool shouldRepaint(BirdPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// FLOWER CHARACTER
// ============================================================
class FlowerPainter extends CustomPainter {
  final Color color;

  FlowerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Stem
    paint.color = Colors.green.shade600;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.06;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.95),
      paint,
    );

    // Leaf
    paint.style = PaintingStyle.fill;
    final leafPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width * 0.7,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.72,
        size.width * 0.5,
        size.height * 0.7,
      );
    canvas.drawPath(leafPath, paint);

    // Petals
    paint.color = color;
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.32;
    final petalRadius = size.width * 0.18;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final petalX = centerX + (petalRadius * 1.2) * math.cos(angle);
      final petalY = centerY + (petalRadius * 1.2) * math.sin(angle);

      canvas.drawCircle(Offset(petalX, petalY), petalRadius, paint);
    }

    // Center
    paint.color = Colors.yellow.shade600;
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.15, paint);

    // Center details
    paint.color = Colors.orange.shade400;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final dotX = centerX + size.width * 0.06 * math.cos(angle);
      final dotY = centerY + size.width * 0.06 * math.sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), size.width * 0.02, paint);
    }

    // Face - Eyes
    paint.color = Colors.black87;
    canvas.drawCircle(
      Offset(centerX - size.width * 0.05, centerY - size.height * 0.02),
      size.width * 0.025,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + size.width * 0.05, centerY - size.height * 0.02),
      size.width * 0.025,
      paint,
    );

    // Smile
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.02;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(centerX - size.width * 0.04, centerY + size.height * 0.03)
      ..quadraticBezierTo(
        centerX,
        centerY + size.height * 0.08,
        centerX + size.width * 0.04,
        centerY + size.height * 0.03,
      );
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(FlowerPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// CHARACTER WIDGET - Wraps the painters
// ============================================================
class CharacterWidget extends StatelessWidget {
  final String characterType;
  final Color color;
  final double size;

  const CharacterWidget({
    super.key,
    required this.characterType,
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
    switch (characterType.toLowerCase()) {
      case 'car':
        return CarPainter(color: color);
      case 'bus':
        return BusPainter(color: color);
      case 'star':
        return StarPainter(color: color);
      case 'balloon':
        return BalloonPainter(color: color);
      case 'butterfly':
        return ButterflyPainter(color: color);
      case 'cat':
        return CatPainter(color: color);
      case 'bird':
        return BirdPainter(color: color);
      case 'flower':
        return FlowerPainter(color: color);
      default:
        return StarPainter(color: color);
    }
  }
}

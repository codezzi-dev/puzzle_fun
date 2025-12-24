import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Enhanced child-friendly robot shape painters with
/// metallic effects, cute faces, and vibrant designs.

// ============================================================
// ROBOT HEAD (Circle with cute face)
// ============================================================
class RobotHeadPainter extends CustomPainter {
  final Color color;

  RobotHeadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Metallic gradient for 3D effect
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: [_lighten(color, 0.4), color, _darken(color, 0.3)],
      stops: const [0.0, 0.5, 1.0],
    );

    paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
    paint.shader = null;

    // Outer metallic ring
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.04;
    paint.color = _darken(color, 0.2);
    canvas.drawCircle(center, radius * 0.95, paint);
    paint.style = PaintingStyle.fill;

    // Cute eyes - white background
    paint.color = Colors.white;
    final eyeRadius = size.width * 0.12;
    final leftEyeCenter = Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.05);
    final rightEyeCenter = Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.05);
    canvas.drawCircle(leftEyeCenter, eyeRadius, paint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, paint);

    // Eye pupils - friendly look
    paint.color = Colors.black87;
    canvas.drawCircle(leftEyeCenter + const Offset(2, 1), eyeRadius * 0.6, paint);
    canvas.drawCircle(rightEyeCenter + const Offset(2, 1), eyeRadius * 0.6, paint);

    // Eye sparkle
    paint.color = Colors.white;
    canvas.drawCircle(
      leftEyeCenter + Offset(-eyeRadius * 0.2, -eyeRadius * 0.2),
      eyeRadius * 0.25,
      paint,
    );
    canvas.drawCircle(
      rightEyeCenter + Offset(-eyeRadius * 0.2, -eyeRadius * 0.2),
      eyeRadius * 0.25,
      paint,
    );

    // Happy smile
    paint.color = Colors.black87;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.03;
    paint.strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(center.dx - size.width * 0.12, center.dy + size.height * 0.12)
      ..quadraticBezierTo(
        center.dx,
        center.dy + size.height * 0.22,
        center.dx + size.width * 0.12,
        center.dy + size.height * 0.12,
      );
    canvas.drawPath(smilePath, paint);

    // Top shine highlight
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromLTWH(
        center.dx - size.width * 0.2,
        center.dy - size.height * 0.35,
        size.width * 0.25,
        size.height * 0.12,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(RobotHeadPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// SEMI-CIRCLE (Robot dome head with face)
// ============================================================
class SemiCirclePainter extends CustomPainter {
  final Color color;

  SemiCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Metallic gradient dome
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.5), color, _darken(color, 0.2)],
    );

    final path = Path()
      ..moveTo(0, size.height)
      ..arcToPoint(
        Offset(size.width, size.height),
        radius: Radius.circular(size.width / 2),
        clockwise: false,
      )
      ..close();

    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    paint.shader = null;

    // Cute robot eyes
    paint.color = Colors.white;
    final eyeWidth = size.width * 0.18;
    final eyeHeight = size.height * 0.35;
    final leftEyeRect = Rect.fromCenter(
      center: Offset(size.width * 0.35, size.height * 0.55),
      width: eyeWidth,
      height: eyeHeight,
    );
    final rightEyeRect = Rect.fromCenter(
      center: Offset(size.width * 0.65, size.height * 0.55),
      width: eyeWidth,
      height: eyeHeight,
    );

    // Eye screens (LED style)
    paint.color = Colors.cyan.shade100;
    canvas.drawRRect(RRect.fromRectAndRadius(leftEyeRect, const Radius.circular(4)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightEyeRect, const Radius.circular(4)), paint);

    // Pupils
    paint.color = Colors.cyan.shade700;
    canvas.drawCircle(leftEyeRect.center + const Offset(1, 2), eyeWidth * 0.3, paint);
    canvas.drawCircle(rightEyeRect.center + const Offset(1, 2), eyeWidth * 0.3, paint);

    // Shine on dome
    paint.color = Colors.white.withValues(alpha: 0.6);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.35, size.height * 0.4),
      math.pi,
      math.pi * 0.6,
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.04,
    );
  }

  @override
  bool shouldRepaint(SemiCirclePainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// GEAR SHAPE (Metallic gear with depth)
// ============================================================
class GearPainter extends CustomPainter {
  final Color color;

  GearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.45;
    final innerRadius = size.width * 0.32;
    const teeth = 8;

    // Gear shadow
    paint.color = Colors.black.withValues(alpha: 0.2);
    _drawGearPath(
      canvas,
      paint,
      Offset(center.dx + 2, center.dy + 2),
      outerRadius,
      innerRadius,
      teeth,
    );

    // Main gear with metallic gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [_lighten(color, 0.5), color, _darken(color, 0.4)],
    );
    paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: outerRadius));
    _drawGearPath(canvas, paint, center, outerRadius, innerRadius, teeth);
    paint.shader = null;

    // Inner ring
    paint.color = _darken(color, 0.3);
    canvas.drawCircle(center, size.width * 0.22, paint);

    // Center hub with gradient
    final hubGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [Colors.grey.shade300, Colors.grey.shade500, Colors.grey.shade700],
    );
    paint.shader = hubGradient.createShader(
      Rect.fromCircle(center: center, radius: size.width * 0.15),
    );
    canvas.drawCircle(center, size.width * 0.15, paint);
    paint.shader = null;

    // Center hole
    paint.color = Colors.grey.shade800;
    canvas.drawCircle(center, size.width * 0.06, paint);

    // Shine highlights
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.35), size.width * 0.06, paint);
  }

  void _drawGearPath(
    Canvas canvas,
    Paint paint,
    Offset center,
    double outerRadius,
    double innerRadius,
    int teeth,
  ) {
    final path = Path();
    for (int i = 0; i < teeth; i++) {
      final angle1 = (i * 2 * math.pi / teeth) - math.pi / 2;
      final angle2 = ((i + 0.35) * 2 * math.pi / teeth) - math.pi / 2;
      final angle3 = ((i + 0.65) * 2 * math.pi / teeth) - math.pi / 2;
      final angle4 = ((i + 1) * 2 * math.pi / teeth) - math.pi / 2;

      if (i == 0) {
        path.moveTo(
          center.dx + outerRadius * math.cos(angle1),
          center.dy + outerRadius * math.sin(angle1),
        );
      }
      path.lineTo(
        center.dx + outerRadius * math.cos(angle2),
        center.dy + outerRadius * math.sin(angle2),
      );
      path.lineTo(
        center.dx + innerRadius * math.cos(angle3),
        center.dy + innerRadius * math.sin(angle3),
      );
      path.lineTo(
        center.dx + innerRadius * math.cos(angle4),
        center.dy + innerRadius * math.sin(angle4),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GearPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// ANTENNA (Glowing antenna with signal)
// ============================================================
class AntennaPainter extends CustomPainter {
  final Color color;

  AntennaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Antenna stick with metallic gradient
    final stickGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.grey.shade400, Colors.grey.shade200, Colors.grey.shade400],
    );
    paint.shader = stickGradient.createShader(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.25, size.width * 0.2, size.height * 0.75),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4, size.height * 0.25, size.width * 0.2, size.height * 0.75),
        const Radius.circular(4),
      ),
      paint,
    );
    paint.shader = null;

    // Glowing ball effect - outer glow
    paint.color = color.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.18), size.width * 0.35, paint);

    // Main antenna ball with gradient
    final ballGradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      colors: [_lighten(color, 0.6), color, _darken(color, 0.2)],
    );
    paint.shader = ballGradient.createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.18),
        radius: size.width * 0.25,
      ),
    );
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.18), size.width * 0.25, paint);
    paint.shader = null;

    // Bright center highlight
    paint.color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.12), size.width * 0.08, paint);

    // Signal waves
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.03;
    paint.color = color.withValues(alpha: 0.5);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.18),
        width: size.width * 0.7,
        height: size.width * 0.7,
      ),
      -math.pi * 0.7,
      math.pi * 0.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(AntennaPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// BOLT/SCREW (Polished metallic bolt)
// ============================================================
class BoltPainter extends CustomPainter {
  final Color color;

  BoltPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height * 0.35);

    // Shadow
    paint.color = Colors.black.withValues(alpha: 0.2);
    _drawHexagon(canvas, paint, Offset(center.dx + 2, center.dy + 2), size.width * 0.4);

    // Hexagon head with metallic gradient
    final headGradient = RadialGradient(
      center: const Alignment(-0.4, -0.4),
      colors: [_lighten(color, 0.5), color, _darken(color, 0.3)],
    );
    paint.shader = headGradient.createShader(
      Rect.fromCircle(center: center, radius: size.width * 0.4),
    );
    _drawHexagon(canvas, paint, center, size.width * 0.4);
    paint.shader = null;

    // Thread part with gradient
    final threadGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [_darken(color, 0.2), _lighten(color, 0.2), _darken(color, 0.2)],
    );
    paint.shader = threadGradient.createShader(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.5, size.width * 0.3, size.height * 0.45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.5, size.width * 0.3, size.height * 0.45),
        const Radius.circular(3),
      ),
      paint,
    );
    paint.shader = null;

    // Thread lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    paint.color = _darken(color, 0.3);
    for (double y = size.height * 0.55; y < size.height * 0.9; y += size.height * 0.08) {
      canvas.drawLine(Offset(size.width * 0.35, y), Offset(size.width * 0.65, y), paint);
    }

    // Cross slot on top
    paint.style = PaintingStyle.fill;
    paint.color = _darken(color, 0.4);
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size.width * 0.08, height: size.height * 0.25),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size.width * 0.3, height: size.height * 0.08),
      paint,
    );

    // Shine highlight
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.25), size.width * 0.06, paint);
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BoltPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// CLAW/HAND (Robotic grabber with joints)
// ============================================================
class ClawPainter extends CustomPainter {
  final Color color;

  ClawPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow
    paint.color = Colors.black.withValues(alpha: 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.22, size.height * 0.52, size.width * 0.6, size.height * 0.35),
        const Radius.circular(8),
      ),
      paint,
    );

    // Base with metallic gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.4), color, _darken(color, 0.2)],
    );
    paint.shader = baseGradient.createShader(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.5, size.width * 0.6, size.height * 0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.5, size.width * 0.6, size.height * 0.35),
        const Radius.circular(8),
      ),
      paint,
    );
    paint.shader = null;

    // Finger gradient
    final fingerGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [_darken(color, 0.1), _lighten(color, 0.3), _darken(color, 0.1)],
    );

    // Left finger
    paint.shader = fingerGradient.createShader(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.1, size.width * 0.3, size.height * 0.4),
    );
    final leftFinger = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.08, size.height * 0.15)
      ..lineTo(size.width * 0.25, size.height * 0.12)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..close();
    canvas.drawPath(leftFinger, paint);

    // Right finger
    final rightFinger = Path()
      ..moveTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.92, size.height * 0.15)
      ..lineTo(size.width * 0.75, size.height * 0.12)
      ..lineTo(size.width * 0.65, size.height * 0.5)
      ..close();
    canvas.drawPath(rightFinger, paint);
    paint.shader = null;

    // Joint circles
    paint.color = _darken(color, 0.3);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.5), size.width * 0.06, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), size.width * 0.06, paint);

    // Joint highlights
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(size.width * 0.23, size.height * 0.48), size.width * 0.025, paint);
    canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.48), size.width * 0.025, paint);

    // Fingertip details
    paint.color = Colors.red.shade400;
    canvas.drawCircle(Offset(size.width * 0.165, size.height * 0.15), size.width * 0.04, paint);
    canvas.drawCircle(Offset(size.width * 0.835, size.height * 0.15), size.width * 0.04, paint);
  }

  @override
  bool shouldRepaint(ClawPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// ROBOT BODY PANEL (Metallic body with rivets and details)
// ============================================================
class RobotPanelPainter extends CustomPainter {
  final Color color;

  RobotPanelPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main body with metallic gradient
    final bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_lighten(color, 0.4), color, _darken(color, 0.2)],
    );
    paint.shader = bodyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.05, size.width * 0.9, size.height * 0.9),
        const Radius.circular(12),
      ),
      paint,
    );
    paint.shader = null;

    // Panel lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = _darken(color, 0.3);
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.85, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.7),
      paint,
    );

    // Rivets
    paint.style = PaintingStyle.fill;
    final rivetPositions = [
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.85),
    ];
    for (final pos in rivetPositions) {
      // Rivet shadow
      paint.color = _darken(color, 0.4);
      canvas.drawCircle(pos + const Offset(1, 1), size.width * 0.04, paint);
      // Rivet
      paint.color = Colors.grey.shade400;
      canvas.drawCircle(pos, size.width * 0.04, paint);
      // Rivet highlight
      paint.color = Colors.white.withValues(alpha: 0.6);
      canvas.drawCircle(
        pos + Offset(-size.width * 0.01, -size.width * 0.01),
        size.width * 0.015,
        paint,
      );
    }

    // Center display/LED
    paint.color = Colors.cyan.shade300;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.3,
          height: size.height * 0.2,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // LED glow
    paint.color = Colors.cyan.withValues(alpha: 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.4,
          height: size.height * 0.3,
        ),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(RobotPanelPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// HEART (For friendly robot designs)
// ============================================================
class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [_lighten(color, 0.4), color, _darken(color, 0.2)],
    );
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width * 0.5, height * 0.85);
    path.cubicTo(
      width * 0.15,
      height * 0.55,
      width * 0.0,
      height * 0.25,
      width * 0.25,
      height * 0.15,
    );
    path.cubicTo(width * 0.4, height * 0.08, width * 0.5, height * 0.2, width * 0.5, height * 0.3);
    path.cubicTo(
      width * 0.5,
      height * 0.2,
      width * 0.6,
      height * 0.08,
      width * 0.75,
      height * 0.15,
    );
    path.cubicTo(
      width * 1.0,
      height * 0.25,
      width * 0.85,
      height * 0.55,
      width * 0.5,
      height * 0.85,
    );
    path.close();

    canvas.drawPath(path, paint);
    paint.shader = null;

    // Shine
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(width * 0.3, height * 0.3), width * 0.08, paint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================
Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

// ============================================================
// ROBOT SHAPE WIDGET - For Robot Builder only
// ============================================================
class RobotShapeWidget extends StatelessWidget {
  final String shapeType;
  final Color color;
  final double size;

  const RobotShapeWidget({super.key, required this.shapeType, required this.color, this.size = 80});

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
      case 'robothead':
        return RobotHeadPainter(color: color);
      case 'semicircle':
        return SemiCirclePainter(color: color);
      case 'gear':
        return GearPainter(color: color);
      case 'antenna':
        return AntennaPainter(color: color);
      case 'bolt':
        return BoltPainter(color: color);
      case 'claw':
        return ClawPainter(color: color);
      case 'robotpanel':
        return RobotPanelPainter(color: color);
      case 'heart':
        return HeartPainter(color: color);
      default:
        return GearPainter(color: color);
    }
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom robot-specific shape painters (not in Shape Master)
/// These are unique to Robot Builder for more robot-like designs

// ============================================================
// SEMI-CIRCLE (For robot head tops, antennas base)
// ============================================================
class SemiCirclePainter extends CustomPainter {
  final Color color;

  SemiCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final path = Path()
      ..moveTo(0, size.height)
      ..arcToPoint(
        Offset(size.width, size.height),
        radius: Radius.circular(size.width / 2),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(path, paint);

    // Shine
    paint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), size.width * 0.1, paint);
  }

  @override
  bool shouldRepaint(SemiCirclePainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// GEAR SHAPE (For robot joints, mechanical parts)
// ============================================================
class GearPainter extends CustomPainter {
  final Color color;

  GearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.45;
    final innerRadius = size.width * 0.3;
    const teeth = 8;

    final path = Path();

    for (int i = 0; i < teeth; i++) {
      final angle1 = (i * 2 * math.pi / teeth) - math.pi / 2;
      final angle2 = ((i + 0.3) * 2 * math.pi / teeth) - math.pi / 2;
      final angle3 = ((i + 0.7) * 2 * math.pi / teeth) - math.pi / 2;
      final angle4 = ((i + 1) * 2 * math.pi / teeth) - math.pi / 2;

      if (i == 0) {
        path.moveTo(center.dx + outerRadius * math.cos(angle1), center.dy + outerRadius * math.sin(angle1));
      }

      path.lineTo(center.dx + outerRadius * math.cos(angle2), center.dy + outerRadius * math.sin(angle2));
      path.lineTo(center.dx + innerRadius * math.cos(angle3), center.dy + innerRadius * math.sin(angle3));
      path.lineTo(center.dx + innerRadius * math.cos(angle4), center.dy + innerRadius * math.sin(angle4));
    }

    path.close();
    canvas.drawPath(path, paint);

    // Center hole
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(center, size.width * 0.12, paint);

    // Shine
    paint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.35), size.width * 0.08, paint);
  }

  @override
  bool shouldRepaint(GearPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// ANTENNA (Small ball on a stick)
// ============================================================
class AntennaPainter extends CustomPainter {
  final Color color;

  AntennaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Stick
    final stickPath = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.3, size.width * 0.2, size.height * 0.7),
      const Radius.circular(4),
    );
    canvas.drawRRect(stickPath, paint);

    // Ball on top
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), size.width * 0.25, paint);

    // Shine on ball
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.15), size.width * 0.08, paint);
  }

  @override
  bool shouldRepaint(AntennaPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// BOLT/SCREW (For robot joints)
// ============================================================
class BoltPainter extends CustomPainter {
  final Color color;

  BoltPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Hexagon head
    final path = Path();
    final center = Offset(size.width / 2, size.height * 0.35);
    final radius = size.width * 0.4;

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

    // Thread part
    final threadRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.5, size.width * 0.3, size.height * 0.45),
      const Radius.circular(3),
    );
    canvas.drawRRect(threadRect, paint);

    // Cross slot on top
    paint.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.45, size.height * 0.2, size.width * 0.1, size.height * 0.3), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.3, size.width * 0.4, size.height * 0.1), paint);
  }

  @override
  bool shouldRepaint(BoltPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// CLAW/HAND (For robot arms)
// ============================================================
class ClawPainter extends CustomPainter {
  final Color color;

  ClawPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.5, size.width * 0.6, size.height * 0.35),
        const Radius.circular(8),
      ),
      paint,
    );

    // Left finger
    final leftFinger = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.05, size.height * 0.15)
      ..lineTo(size.width * 0.25, size.height * 0.15)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..close();
    canvas.drawPath(leftFinger, paint);

    // Right finger
    final rightFinger = Path()
      ..moveTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.95, size.height * 0.15)
      ..lineTo(size.width * 0.75, size.height * 0.15)
      ..lineTo(size.width * 0.65, size.height * 0.5)
      ..close();
    canvas.drawPath(rightFinger, paint);

    // Shine
    paint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), size.width * 0.08, paint);
  }

  @override
  bool shouldRepaint(ClawPainter oldDelegate) => color != oldDelegate.color;
}

// ============================================================
// ROBOT SHAPE WIDGET - For Robot Builder only
// ============================================================
class RobotShapeWidget extends StatelessWidget {
  final String shapeType;
  final Color color;
  final double size;

  const RobotShapeWidget({
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
      default:
        return GearPainter(color: color);
    }
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom clock painter for drawing an analog clock face
class ClockPainter extends CustomPainter {
  final int hour;
  final int minute;
  final Color themeColor;
  final bool showCorrectIndicator;

  ClockPainter({
    required this.hour,
    required this.minute,
    required this.themeColor,
    this.showCorrectIndicator = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clock face background
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 5, facePaint);

    // Draw outer ring
    final ringPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 5, ringPaint);

    // Draw inner decorative ring
    final innerRingPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 20, innerRingPaint);

    // Draw hour markers
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final markerRadius = radius - 35;
      final x = center.dx + markerRadius * math.cos(angle);
      final y = center.dy + markerRadius * math.sin(angle);

      // Draw hour number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(color: themeColor, fontSize: radius * 0.15, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // Draw minute tick marks
    for (int i = 0; i < 60; i++) {
      if (i % 5 != 0) {
        // Skip hour positions
        final angle = (i * 6 - 90) * math.pi / 180;
        final outerRadius = radius - 12;
        final innerRadius = radius - 18;

        final startX = center.dx + outerRadius * math.cos(angle);
        final startY = center.dy + outerRadius * math.sin(angle);
        final endX = center.dx + innerRadius * math.cos(angle);
        final endY = center.dy + innerRadius * math.sin(angle);

        final tickPaint = Paint()
          ..color = themeColor.withValues(alpha: 0.4)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
      }
    }

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerDotPaint);

    // Calculate hand angles
    // Hour hand: 30 degrees per hour + 0.5 degrees per minute
    final hourAngle = ((hour % 12) * 30 + minute * 0.5 - 90) * math.pi / 180;
    // Minute hand: 6 degrees per minute
    final minuteAngle = (minute * 6 - 90) * math.pi / 180;

    // Draw hour hand (shorter, thicker)
    final hourHandLength = radius * 0.45;
    final hourHandPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + hourHandLength * math.cos(hourAngle),
        center.dy + hourHandLength * math.sin(hourAngle),
      ),
      hourHandPaint,
    );

    // Draw minute hand (longer, thinner)
    final minuteHandLength = radius * 0.65;
    final minuteHandPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.7)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + minuteHandLength * math.cos(minuteAngle),
        center.dy + minuteHandLength * math.sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // Draw center cap
    final centerCapPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerCapPaint);

    // Draw correct indicator if needed
    if (showCorrectIndicator) {
      final checkPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final checkPath = Path();
      checkPath.moveTo(center.dx - 15, center.dy + 40);
      checkPath.lineTo(center.dx - 5, center.dy + 50);
      checkPath.lineTo(center.dx + 15, center.dy + 30);
      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.hour != hour ||
        oldDelegate.minute != minute ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.showCorrectIndicator != showCorrectIndicator;
  }
}

/// Interactive clock widget with draggable hands
class InteractiveClock extends StatefulWidget {
  final int hour;
  final int minute;
  final Color themeColor;
  final bool interactive;
  final Function(int)? onHourChanged;
  final Function(int)? onMinuteChanged;
  final bool showCorrectIndicator;

  const InteractiveClock({
    super.key,
    required this.hour,
    required this.minute,
    required this.themeColor,
    this.interactive = false,
    this.onHourChanged,
    this.onMinuteChanged,
    this.showCorrectIndicator = false,
  });

  @override
  State<InteractiveClock> createState() => _InteractiveClockState();
}

class _InteractiveClockState extends State<InteractiveClock> {
  String? _draggingHand; // 'hour', 'minute', or null

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(size / 2, size / 2);
        final radius = size / 2;

        return GestureDetector(
          onPanStart: widget.interactive
              ? (details) => _handlePanStart(details, center, radius)
              : null,
          onPanUpdate: widget.interactive ? (details) => _handlePanUpdate(details, center) : null,
          onPanEnd: widget.interactive ? (_) => _handlePanEnd() : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.themeColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: CustomPaint(
              size: Size(size, size),
              painter: ClockPainter(
                hour: widget.hour,
                minute: widget.minute,
                themeColor: widget.themeColor,
                showCorrectIndicator: widget.showCorrectIndicator,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePanStart(DragStartDetails details, Offset center, double radius) {
    final localPosition = details.localPosition;
    final distance = (localPosition - center).distance;

    // Calculate the angle the user touched
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    var touchAngle = math.atan2(dy, dx);
    var touchDegrees = (touchAngle * 180 / math.pi + 90) % 360;
    if (touchDegrees < 0) touchDegrees += 360;

    // Calculate current hour hand angle (accounting for minute position)
    var hourDegrees = ((widget.hour % 12) * 30 + widget.minute * 0.5) % 360;

    // Calculate current minute hand angle
    var minuteDegrees = (widget.minute * 6) % 360;

    // Calculate angular distance to each hand
    double hourDiff = _angleDifference(touchDegrees, hourDegrees.toDouble());
    double minuteDiff = _angleDifference(touchDegrees, minuteDegrees.toDouble());

    // Only allow dragging if touch is not too close to center
    if (distance < 20) {
      _draggingHand = null;
      return;
    }

    // Determine which hand based on angle proximity and distance from center
    // Hour hand is shorter (closer to center), minute hand is longer (further from center)
    final hourHandLength = radius * 0.45;

    // If closer to center, prefer hour hand; if further, prefer minute hand
    // But also consider angle proximity
    if (distance < hourHandLength + 15) {
      // Near the hour hand area - prefer hour hand if angle is close
      if (hourDiff < 25) {
        _draggingHand = 'hour';
      } else if (minuteDiff < 25) {
        _draggingHand = 'minute';
      } else {
        _draggingHand = 'hour'; // Default to hour in inner area
      }
    } else {
      // Outer area - prefer minute hand
      if (minuteDiff < 25) {
        _draggingHand = 'minute';
      } else if (hourDiff < 25) {
        _draggingHand = 'hour';
      } else {
        _draggingHand = 'minute'; // Default to minute in outer area
      }
    }
  }

  double _angleDifference(double angle1, double angle2) {
    double diff = (angle1 - angle2).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  void _handlePanUpdate(DragUpdateDetails details, Offset center) {
    if (_draggingHand == null) return;

    final localPosition = details.localPosition;

    // Calculate angle from center
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    var angle = math.atan2(dy, dx);

    // Convert to degrees and adjust for 12 o'clock being at top
    var degrees = (angle * 180 / math.pi + 90) % 360;
    if (degrees < 0) degrees += 360;

    if (_draggingHand == 'hour' && widget.onHourChanged != null) {
      // Convert degrees to hour (30 degrees per hour)
      int hour = (degrees / 30).round() % 12;
      if (hour == 0) hour = 12;
      widget.onHourChanged!(hour);
    } else if (_draggingHand == 'minute' && widget.onMinuteChanged != null) {
      // Convert degrees to minute (6 degrees per minute)
      // Snap to 5-minute intervals for easier use by preschoolers
      int minute = (degrees / 6).round() % 60;
      // Snap to nearest 5-minute interval (more options than 15)
      minute = ((minute / 5).round() * 5) % 60;
      widget.onMinuteChanged!(minute);
    }
  }

  void _handlePanEnd() {
    _draggingHand = null;
  }
}

import 'package:flutter/material.dart';

/// Simple styled digit widget using text instead of custom painters.
/// Uses a large, bold, colorful text style that's child-friendly.

class DigitWidget extends StatelessWidget {
  final int digit;
  final Color color;
  final double size;

  const DigitWidget({
    super.key,
    required this.digit,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          digit.toString(),
          style: TextStyle(
            fontSize: size * 0.75,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.0,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.3),
                offset: const Offset(3, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

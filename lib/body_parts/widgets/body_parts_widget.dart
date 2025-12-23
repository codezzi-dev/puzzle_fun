import 'package:flutter/material.dart';

/// Simple emoji-based widget for displaying body parts.

class BodyPartWidget extends StatelessWidget {
  final String emoji;
  final double size;

  const BodyPartWidget({super.key, required this.emoji, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.7)),
      ),
    );
  }
}

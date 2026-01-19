import 'package:flutter/material.dart';
import '../config_ca.dart';

class MixingPot extends StatelessWidget {
  final List<MixableColor> currentMix;
  final MixableColor? resultColor;

  const MixingPot({super.key, required this.currentMix, this.resultColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Pot itself
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 8),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
          ),

          // Liquid inside
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getLiquidColor(),
              gradient: _getLiquidGradient(),
            ),
          ),

          // Result Emoji if successful
          if (currentMix.length == 2)
            Positioned(
              top: 60,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Column(
                      children: [
                        Text(resultColor?.emoji ?? '✨', style: const TextStyle(fontSize: 70)),
                        if (resultColor != null)
                          Text(
                            resultColor!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Show mixing ingredients if only 1 is added
          if (currentMix.length == 1)
            Positioned(
              top: 70,
              child: Text(currentMix[0].emoji, style: const TextStyle(fontSize: 50)),
            ),
        ],
      ),
    );
  }

  Color _getLiquidColor() {
    if (currentMix.isEmpty) return Colors.white.withValues(alpha: 0.5);
    if (currentMix.length == 1) return currentMix[0].color.withValues(alpha: 0.7);
    if (resultColor != null) return resultColor!.color;

    return Color.lerp(currentMix[0].color, currentMix[1].color, 0.5) ?? Colors.grey;
  }

  Gradient? _getLiquidGradient() {
    if (currentMix.isEmpty) return null;
    return RadialGradient(
      colors: [Colors.white.withValues(alpha: 0.4), _getLiquidColor()],
      center: Alignment.topLeft,
      radius: 1.0,
    );
  }
}

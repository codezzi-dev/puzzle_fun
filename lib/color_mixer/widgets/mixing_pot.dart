import 'package:flutter/material.dart';
import '../config_cm.dart';

class MixingPot extends StatelessWidget {
  final List<MixableColor> currentMix;
  final MixableColor? resultColor;
  final bool isLearning;

  const MixingPot({super.key, required this.currentMix, this.resultColor, this.isLearning = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Pot itself
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 8),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
          ),

          // Liquid inside
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getLiquidColor(),
              gradient: _getLiquidGradient(),
            ),
          ),

          // Result Emoji if successful or learning
          if ((isLearning || resultColor != null) && currentMix.length == 2)
            Positioned(
              top: 50,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Text(resultColor?.emoji ?? '✨', style: const TextStyle(fontSize: 60)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _getLiquidColor() {
    if (currentMix.isEmpty) return Colors.white.withValues(alpha: 0.5);
    if (currentMix.length == 1) return currentMix[0].color.withValues(alpha: 0.7);
    if (resultColor != null) return resultColor!.color;

    // Fallback mixing logic if resultColor is not passed (testing phase mid-mix)
    return Color.lerp(currentMix[0].color, currentMix[1].color, 0.5) ?? Colors.grey;
  }

  Gradient? _getLiquidGradient() {
    if (currentMix.length < 2) return null;
    return RadialGradient(
      colors: [Colors.white.withValues(alpha: 0.3), _getLiquidColor()],
      center: Alignment.topLeft,
      radius: 1.0,
    );
  }
}

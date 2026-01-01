import 'package:flutter/material.dart';

class MysteryCard extends StatelessWidget {
  final String content;
  final bool isHidden;
  final Color color;
  final double size;

  const MysteryCard({
    super.key,
    required this.content,
    this.isHidden = false,
    this.color = Colors.blue,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        color: isHidden ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHidden ? Colors.grey.shade300 : color.withOpacity(0.5),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: isHidden ? Colors.black.withOpacity(0.05) : color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isHidden
            ? Icon(Icons.help_outline, size: size * 0.6, color: Colors.grey.shade400)
            : Text(
                content,
                style: TextStyle(fontSize: size * 0.6, fontWeight: FontWeight.w900, color: color),
              ),
      ),
    );
  }
}

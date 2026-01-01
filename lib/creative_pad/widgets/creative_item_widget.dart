import 'package:flutter/material.dart';
import '../config_cp.dart';

class CreativeItemWidget extends StatelessWidget {
  final CreativeItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CreativeItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 60,
        height: 75,
        decoration: BoxDecoration(
          color: item.color == Colors.white ? Colors.grey.shade100 : item.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            item.content,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: item.color == Colors.white ? Colors.black : Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

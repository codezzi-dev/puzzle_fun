import 'package:flutter/material.dart';

import '../../shape_master/widgets/shape_painters.dart';
import '../config_clm.dart';

/// A colored shape displayed on the right side that can receive connections
class ColoredShape extends StatelessWidget {
  final ShapeItem item;
  final bool isConnected;
  final bool isHovering;
  final Function(String) onDropped;
  final GlobalKey itemKey;

  const ColoredShape({
    super.key,
    required this.item,
    required this.isConnected,
    required this.isHovering,
    required this.onDropped,
    required this.itemKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isConnected ? null : () => onDropped(item.id),
      child: AnimatedContainer(
        key: itemKey,
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovering
                ? Colors.green.shade400
                : isConnected
                ? Colors.green.shade300
                : Colors.grey.shade300,
            width: isHovering ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovering
                  ? Colors.green.withValues(alpha: 0.3)
                  : isConnected
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isHovering ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shape with its color
            ShapeWidget(
              shapeType: item.shapeType,
              color: item.color.color.withValues(alpha: isConnected ? 0.5 : 1.0),
              size: 55,
            ),
            // Check mark overlay if connected
            if (isConnected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 8)],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../config_clm.dart';

/// A draggable color swatch displayed on the left side
class ColorSwatchItem extends StatelessWidget {
  final MatchItem item;
  final bool isConnected;
  final bool isActive;
  final Function(String, Offset) onDragStart;
  final Function(Offset) onDragUpdate;
  final VoidCallback onDragEnd;
  final GlobalKey itemKey;

  const ColorSwatchItem({
    super.key,
    required this.item,
    required this.isConnected,
    required this.isActive,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.itemKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: isConnected
          ? null
          : (details) {
              final box = itemKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                final center = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
                onDragStart(item.id, center);
              }
            },
      onPanUpdate: isConnected ? null : (details) => onDragUpdate(details.globalPosition),
      onPanEnd: isConnected ? null : (_) => onDragEnd(),
      child: AnimatedContainer(
        key: itemKey,
        duration: const Duration(milliseconds: 300),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              item.color.withValues(alpha: isConnected ? 0.4 : 1.0),
              Color.lerp(item.color, Colors.black, 0.2)!.withValues(alpha: isConnected ? 0.3 : 0.9),
            ],
            center: const Alignment(-0.3, -0.3),
          ),
          boxShadow: isConnected
              ? []
              : [
                  BoxShadow(
                    color: item.color.withValues(alpha: isActive ? 0.6 : 0.3),
                    blurRadius: isActive ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: isActive ? 3 : 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shine effect
            Positioned(
              top: 8,
              left: 12,
              child: Container(
                width: 18,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isConnected ? 0.1 : 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Check mark if connected
            if (isConnected)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

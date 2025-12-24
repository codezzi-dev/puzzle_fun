import 'package:flutter/material.dart';

import '../config_rb.dart';
import 'draggable_shape.dart';

/// Displays the robot - either filled (learning) or outline (building mode)
class RobotDisplay extends StatelessWidget {
  final RobotTemplate robot;
  final bool showOutlineOnly;
  final Map<String, bool> placedParts;

  const RobotDisplay({
    super.key,
    required this.robot,
    this.showOutlineOnly = false,
    this.placedParts = const {},
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: robot.parts.map((part) {
          final isPlaced = placedParts[part.id] ?? false;
          final showShape = !showOutlineOnly || isPlaced;

          return Positioned(
            left: part.position.dx,
            top: part.position.dy,
            child: showShape
                ? getShapeWidget(shapeType: part.shapeType, color: part.color, size: part.size.width)
                : _OutlineSlot(part: part),
          );
        }).toList(),
      ),
    );
  }
}

/// Outline slot for a robot part (dashed border, empty inside)
class _OutlineSlot extends StatelessWidget {
  final RobotPart part;

  const _OutlineSlot({required this.part});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: part.size.width,
      height: part.size.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 2, strokeAlign: BorderSide.strokeAlignCenter),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100.withValues(alpha: 0.5),
      ),
      child: Center(
        child: Icon(Icons.add, color: Colors.grey.shade400, size: part.size.width * 0.4),
      ),
    );
  }
}

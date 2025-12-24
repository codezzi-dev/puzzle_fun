import 'package:flutter/material.dart';

import '../../shape_master/widgets/shape_painters.dart';
import '../config_rb.dart';
import 'robot_shapes.dart';

/// List of robot-specific shape types (including new child-friendly shapes)
const robotShapeTypes = [
  'semicircle',
  'gear',
  'antenna',
  'bolt',
  'claw',
  'robothead',
  'robotpanel',
  'heart',
];

/// Returns the appropriate shape widget based on shape type
Widget getShapeWidget({required String shapeType, required Color color, required double size}) {
  if (robotShapeTypes.contains(shapeType.toLowerCase())) {
    return RobotShapeWidget(shapeType: shapeType, color: color, size: size);
  }
  return ShapeWidget(shapeType: shapeType, color: color, size: size);
}

/// A draggable shape that can be dropped onto robot slots
class DraggableShape extends StatelessWidget {
  final RobotPart part;
  final bool isPlaced;

  const DraggableShape({super.key, required this.part, this.isPlaced = false});

  @override
  Widget build(BuildContext context) {
    if (isPlaced) {
      return const SizedBox(width: 70, height: 70);
    }

    return Draggable<RobotPart>(
      data: part,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: part.color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: getShapeWidget(shapeType: part.shapeType, color: part.color, size: 60),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: getShapeWidget(shapeType: part.shapeType, color: part.color, size: 60),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: part.color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: getShapeWidget(shapeType: part.shapeType, color: part.color, size: 50),
      ),
    );
  }
}

/// A droppable slot on the robot where shapes can be placed
class DroppableSlot extends StatelessWidget {
  final RobotPart part; // This slot's part
  final bool isPlaced;
  final Function(RobotPart slotPart, RobotPart draggedPart) onAccept; // Pass both!

  const DroppableSlot({
    super.key,
    required this.part,
    required this.isPlaced,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaced) {
      return getShapeWidget(shapeType: part.shapeType, color: part.color, size: part.size.width);
    }

    return DragTarget<RobotPart>(
      // Accept any part with the same shape type (allows either gear to go in either leg slot)
      onWillAcceptWithDetails: (details) => details.data.shapeType == part.shapeType,
      onAcceptWithDetails: (details) => onAccept(part, details.data), // Pass BOTH slot and dragged
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: part.size.width,
          height: part.size.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: isHovering ? Colors.green : Colors.grey.shade400,
              width: isHovering ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isHovering
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.shade100.withValues(alpha: 0.5),
          ),
          child: Center(
            child: Icon(
              isHovering ? Icons.check : Icons.add,
              color: isHovering ? Colors.green : Colors.grey.shade400,
              size: part.size.width * 0.4,
            ),
          ),
        );
      },
    );
  }
}

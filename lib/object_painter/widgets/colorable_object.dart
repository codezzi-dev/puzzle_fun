import 'package:flutter/material.dart';

import '../../shape_master/widgets/shape_painters.dart';
import '../config_op.dart';

/// Displays the object for coloring mode - either as reference or colorable
class ColorableObject extends StatelessWidget {
  final ObjectTemplate object;
  final Map<String, Color?> coloredParts;
  final bool isReference; // true = show original colors (reference object)
  final Function(ObjectPart)? onPartTap; // callback when a part is tapped
  final Set<String>? correctParts; // parts that are correctly colored (for checkmarks)
  final String? shakingPartId; // part ID currently shaking (wrong color)

  const ColorableObject({
    super.key,
    required this.object,
    required this.coloredParts,
    this.isReference = false,
    this.onPartTap,
    this.correctParts,
    this.shakingPartId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: object.parts.map((part) {
          if (isReference) {
            // Reference object - show original colors using Shape Master shapes
            return Positioned(
              left: part.position.dx,
              top: part.position.dy,
              child: ShapeWidget(
                shapeType: part.shapeType,
                color: part.color,
                size: part.size.width,
              ),
            );
          } else {
            // Colorable object - show colored parts or outline
            final appliedColor = coloredParts[part.id];
            final isCorrect = correctParts?.contains(part.id) ?? false;
            final isShaking = shakingPartId == part.id;

            return Positioned(
              left: part.position.dx,
              top: part.position.dy,
              child: _ColorablePart(
                part: part,
                appliedColor: appliedColor,
                isCorrect: isCorrect,
                isShaking: isShaking,
                onTap: onPartTap != null ? () => onPartTap!(part) : null,
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}

/// A single colorable object part
class _ColorablePart extends StatefulWidget {
  final ObjectPart part;
  final Color? appliedColor;
  final bool isCorrect;
  final bool isShaking;
  final VoidCallback? onTap;

  const _ColorablePart({
    required this.part,
    this.appliedColor,
    this.isCorrect = false,
    this.isShaking = false,
    this.onTap,
  });

  @override
  State<_ColorablePart> createState() => _ColorablePartState();
}

class _ColorablePartState extends State<_ColorablePart> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(_ColorablePart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (widget.appliedColor != null) {
      // Part has been colored - show as Shape Master shape
      child = Stack(
        children: [
          ShapeWidget(
            shapeType: widget.part.shapeType,
            color: widget.appliedColor!,
            size: widget.part.size.width,
          ),
          if (widget.isCorrect)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 8),
              ),
            ),
        ],
      );
    } else {
      // Part not yet colored - show outline placeholder with shape hint
      child = Container(
        width: widget.part.size.width,
        height: widget.part.size.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100.withValues(alpha: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.color_lens_outlined,
                color: Colors.grey.shade400,
                size: widget.part.size.width * 0.3,
              ),
              if (widget.part.size.height > 50)
                Text(
                  widget.part.shapeName,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Wrap with shake animation if needed
    if (widget.isShaking) {
      child = AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset =
              (1 - _shakeAnimation.value) *
              10 *
              ((_shakeAnimation.value * 10).toInt() % 2 == 0 ? 1 : -1);
          return Transform.translate(offset: Offset(offset, 0), child: child);
        },
        child: child,
      );
    }

    // Make it tappable
    return GestureDetector(onTap: widget.onTap, child: child);
  }
}

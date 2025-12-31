import 'package:flutter/material.dart';

import '../config_op.dart';

/// A color palette widget for selecting colors to paint object parts
class ColorPalette extends StatelessWidget {
  final List<ColorOption> colors;
  final Color? selectedColor;
  final Function(Color color, String colorName) onColorSelected;

  const ColorPalette({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎨 Pick a Color!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: colors.map((option) {
              final isSelected =
                  selectedColor != null &&
                  ObjectPainterState.colorsMatch(selectedColor!, option.color);
              return _ColorButton(
                option: option,
                isSelected: isSelected,
                onTap: () => onColorSelected(option.color, option.name),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// A single color button in the palette
class _ColorButton extends StatefulWidget {
  final ColorOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({required this.option, required this.isSelected, required this.onTap});

  @override
  State<_ColorButton> createState() => _ColorButtonState();
}

class _ColorButtonState extends State<_ColorButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Special handling for white color - add border
    final isWhite = widget.option.id == 'white';

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.option.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isSelected
                  ? (isWhite ? Colors.grey : Colors.white)
                  : (isWhite ? Colors.grey.shade400 : Colors.transparent),
              width: widget.isSelected ? 4 : (isWhite ? 2 : 0),
            ),
            boxShadow: [
              BoxShadow(
                color: isWhite
                    ? Colors.grey.withValues(alpha: 0.3)
                    : widget.option.color.withValues(alpha: 0.5),
                blurRadius: widget.isSelected ? 12 : 4,
                spreadRadius: widget.isSelected ? 2 : 0,
              ),
              if (widget.isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Center(
            child: widget.isSelected
                ? Icon(Icons.brush, color: isWhite ? Colors.grey : Colors.white, size: 24)
                : Text(widget.option.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}

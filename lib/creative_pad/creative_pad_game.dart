import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/tts_service.dart';
import 'config_cp.dart';
import 'widgets/creative_item_widget.dart';

class CreativePadGame extends ConsumerStatefulWidget {
  const CreativePadGame({super.key});

  @override
  ConsumerState<CreativePadGame> createState() => _CreativePadGameState();
}

class _CreativePadGameState extends ConsumerState<CreativePadGame> {
  @override
  void initState() {
    super.initState();
    tts.init();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creativePadProvider);
    final notifier = ref.read(creativePadProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, state, notifier),
              _buildSelectionPlate(state, notifier),
              Expanded(child: _buildCanvas(state, notifier)),
              _buildColorPalette(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CreativePadState state, CreativePadNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  notifier.clearCanvas();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: Colors.green.shade600, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  ).createShader(bounds),
                  child: const Text(
                    '🎨 Creative Pad',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _buildModeToggle(state, notifier),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Undo button
              GestureDetector(
                onTap: () => notifier.removeLastItem(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.undo_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Undo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Clear button
              GestureDetector(
                onTap: () => notifier.clearCanvas(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(CreativePadState state, CreativePadNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(
            isActive: state.mode == CreativeMode.letters,
            text: 'ABC',
            onTap: () {
              notifier.setMode(CreativeMode.letters);
              tts.speak("Letters mode");
            },
          ),
          _buildToggleItem(
            isActive: state.mode == CreativeMode.numbers,
            text: '123',
            onTap: () {
              notifier.setMode(CreativeMode.numbers);
              tts.speak("Numbers mode");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required bool isActive,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionPlate(CreativePadState state, CreativePadNotifier notifier) {
    final items = state.mode == CreativeMode.letters
        ? List.generate(26, (i) => String.fromCharCode(65 + i))
        : List.generate(10, (i) => i.toString());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 100,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: items.map((content) {
              return GestureDetector(
                onTap: () {
                  final added = notifier.addItem(content);
                  if (added) {
                    tts.speak(content.toLowerCase());
                  } else {
                    tts.speak("Canvas is full!");
                  }
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(CreativePadState state, CreativePadNotifier notifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            if (state.items.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✏️', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'Tap items above to add them here!',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Center(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: state.items.map((item) {
                      return CreativeItemWidget(
                        item: item,
                        onTap: () {
                          if (state.selectedColor != null) {
                            notifier.colorItem(item.id);
                            tts.speak("Colored!");
                          } else {
                            tts.speak("Pick a color first!");
                          }
                        },
                        onLongPress: () {
                          notifier.removeItem(item.id);
                          tts.speak("Removed!");
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette(CreativePadState state, CreativePadNotifier notifier) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: creativeColorPalette.map((option) {
          final isSelected = state.selectedColor == option.color;
          return GestureDetector(
            onTap: () {
              notifier.selectColor(option.color, option.name);
              tts.speak(option.name);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 4),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.brush, color: Colors.white, size: 22)
                    : Text(option.emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

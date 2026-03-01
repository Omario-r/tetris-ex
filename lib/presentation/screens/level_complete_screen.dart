import 'package:flutter/material.dart';
import '../../game_engine/data/level_map.dart';
import '../../game_engine/models/object_template.dart';
import '../widgets/object_fragment_grid_painter.dart';

class LevelCompleteScreen extends StatefulWidget {
  final int completedLevelIndex; // 0..15
  final VoidCallback onNext;

  const LevelCompleteScreen({
    super.key,
    required this.completedLevelIndex,
    required this.onNext,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.forward(); // запустить анимацию при открытии экрана
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int objectId = widget.completedLevelIndex ~/ 4;
    final int completedFragmentIndex = widget.completedLevelIndex % 4;
    final ObjectTemplate objectTemplate = LevelMap.objects[objectId];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Complete'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: const Size(300, 300), // квадратный canvas
              painter: ObjectFragmentGridPainter(
                objectTemplate: objectTemplate,
                completedFragmentIndex: completedFragmentIndex,
                animProgress: _controller.value, // 0.0..1.0
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.onNext,
            child: const Text('Далее'),
          ),
        ],
      ),
    );
  }
}

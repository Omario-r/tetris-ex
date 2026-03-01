import 'package:flutter/material.dart';
import '../../game_engine/data/level_map.dart';
import '../widgets/object_full_painter.dart';

class ObjectCompleteScreen extends StatelessWidget {
  final int completedObjectId; // 0..3
  final VoidCallback onNext;

  const ObjectCompleteScreen({
    super.key,
    required this.completedObjectId,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final objectTemplate = LevelMap.objects[completedObjectId];

    return Scaffold(
      appBar: AppBar(
        title: Text(objectTemplate.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: ObjectFullPainter(
                  objectTemplate: objectTemplate,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Далее'),
            ),
          ),
        ],
      ),
    );
  }
}

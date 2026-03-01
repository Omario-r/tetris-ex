import 'package:flutter/material.dart';
import '../../game_engine/models/object_template.dart';

class ObjectFullPainter extends CustomPainter {
  final ObjectTemplate objectTemplate;

  const ObjectFullPainter({required this.objectTemplate});

  @override
  void paint(Canvas canvas, Size size) {
    // Объект 10×10, canvas квадратный
    final cellSize = size.width / 10;

    final fillPaint = Paint()..color = Colors.deepOrange;
    final strokePaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final fragmentDef in objectTemplate.fragments) {
      final mask = fragmentDef.level.targetMask;
      for (int localY = 0; localY < mask.height; localY++) {
        for (int localX = 0; localX < mask.width; localX++) {
          if (mask.contains(localX, localY)) {
            final globalX = fragmentDef.anchorX + localX;
            final globalY = fragmentDef.anchorY + localY;
            final rect = Rect.fromLTWH(
              globalX * cellSize,
              globalY * cellSize,
              cellSize,
              cellSize,
            );
            canvas.drawRect(rect, fillPaint);
            canvas.drawRect(rect, strokePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(ObjectFullPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../../game_engine/models/object_template.dart';

class ObjectFragmentGridPainter extends CustomPainter {
  final ObjectTemplate objectTemplate;
  final int completedFragmentIndex;
  final double animProgress;

  ObjectFragmentGridPainter({
    required this.objectTemplate,
    required this.completedFragmentIndex,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 10; // объект 10×10, canvas квадратный

    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int index = 0; index < 4; index++) {
      final fragmentDef = objectTemplate.fragments[index];
      final targetMask = fragmentDef.level.targetMask;

      Color cellColor;
      bool isNewFragment = false;

      if (index < completedFragmentIndex) {
        cellColor = Colors.green;
      } else if (index == completedFragmentIndex) {
        cellColor = Colors.green;
        isNewFragment = true;
      } else {
        cellColor = Colors.grey.shade300;
      }

      final fillPaint = Paint()..color = cellColor;

      // Перебираем все клетки TargetMask 5×5
      for (int localY = 0; localY < 5; localY++) {
        for (int localX = 0; localX < 5; localX++) {
          if (targetMask.contains(localX, localY)) {
            final globalX = fragmentDef.anchorX + localX;
            final globalY = fragmentDef.anchorY + localY;

            final rect = Rect.fromLTWH(
              globalX * cellSize,
              globalY * cellSize,
              cellSize,
              cellSize,
            );

            if (isNewFragment) {
              // Анимация scale 0→1 от центра фрагмента
              canvas.save();
              final centerX = (fragmentDef.anchorX + 2.5) * cellSize;
              final centerY = (fragmentDef.anchorY + 2.5) * cellSize;
              canvas.translate(centerX, centerY);
              canvas.scale(animProgress);
              canvas.translate(-centerX, -centerY);
              canvas.drawRect(rect, fillPaint);
              canvas.drawRect(rect, borderPaint);
              canvas.restore();
            } else {
              canvas.drawRect(rect, fillPaint);
              canvas.drawRect(rect, borderPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ObjectFragmentGridPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress;
  }
}

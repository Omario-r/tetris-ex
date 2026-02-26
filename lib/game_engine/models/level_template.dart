import 'target_mask.dart';
import '../rules/halo.dart';

class LevelTemplate {
  final int boardWidth;
  final int boardHeight;
  final TargetMask targetMask;
  final int targetX;
  final int targetY;
  final int? moveLimit;

  late final Set<(int, int)> S;
  late final Set<(int, int)> H;

  LevelTemplate({
    required this.boardWidth,
    required this.boardHeight,
    required this.targetMask,
    required this.targetX,
    required this.targetY,
    this.moveLimit,
  }) {
    S = {
      for (final cell in targetMask.cells)
        (cell.x + targetX, cell.y + targetY),
    };
    H = HaloCalculator.computeHalo8(S, boardWidth, boardHeight);
  }
}

/// Дефолтный уровень MVP.
final defaultLevel = LevelTemplate(
  boardWidth: 10,
  boardHeight: 20,
  targetMask: defaultTargetMask,
  targetX: 2,
  targetY: 14,
  moveLimit: null,
);

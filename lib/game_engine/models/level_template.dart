import 'target_mask.dart';
import '../rules/halo.dart';

class LevelTemplate {
  final int boardWidth;
  final int boardHeight;
  final TargetMask targetMask;
  final int targetX;
  final int targetY;
  final int? moveLimit;
  final int objectId;       // индекс объекта (0..3), дефолт 0
  final int fragmentIndex;  // индекс фрагмента (0..3), дефолт 0

  late final Set<(int, int)> S;
  late final Set<(int, int)> H;

  LevelTemplate({
    required this.boardWidth,
    required this.boardHeight,
    required this.targetMask,
    required this.targetX,
    required this.targetY,
    this.moveLimit,
    this.objectId = 0,
    this.fragmentIndex = 0,
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

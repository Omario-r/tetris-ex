import '../models/board.dart';
import '../models/falling_piece.dart';

class ExplosionHandler {
  /// Удаляет с board клетки, которые совпадают с отпечатком fp.
  /// Возвращает `Map<int, Set<int>>` — для каждой колонки x: множество удалённых строк y.
  /// Пустые клетки под фигурой не трогаются.
  static Map<int, Set<int>> explodeFootprint(FallingPiece fp, Board board) {
    final removed = <int, Set<int>>{};
    for (final cell in fp.boardCells) {
      if (board.isInside(cell.x, cell.y) && board.isOccupied(cell.x, cell.y)) {
        board.setCell(cell.x, cell.y, const Cell.empty());
        removed.putIfAbsent(cell.x, () => <int>{}).add(cell.y);
      }
    }
    return removed;
  }

  /// Применяет ограниченную колоночную гравитацию после взрыва.
  /// removedPerColumn — результат explodeFootprint (`Map<int, Set<int>>`).
  ///
  /// gravity removed
  static void applyLimitedGravity(
      Board board, Map<int, Set<int>> removedPerColumn) {
    // gravity removed
  }
}

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
  /// Алгоритм для каждой колонки x где removedPerColumn[x] непустой:
  ///   Считаем removedBelow[y] = количество удалённых строк в колонке x с y2 > y.
  ///   Для каждой occupied клетки (x,y) где removedBelow[y] > 0:
  ///     переместить в (x, y + removedBelow[y])
  ///     очистить (x, y)
  ///   Обрабатывать строки снизу вверх (от height-1 до 0).
  static void applyLimitedGravity(
      Board board, Map<int, Set<int>> removedPerColumn) {
    for (final entry in removedPerColumn.entries) {
      final x = entry.key;
      final removedRows = entry.value;
      if (removedRows.isEmpty) continue;

      // Считаем removedBelow[y] снизу вверх
      final removedBelow = List<int>.filled(board.height, 0);
      int count = 0;
      for (int y = board.height - 1; y >= 0; y--) {
        removedBelow[y] = count;
        if (removedRows.contains(y)) count++;
      }

      // Сдвигаем занятые клетки вниз (снизу вверх)
      for (int y = board.height - 1; y >= 0; y--) {
        if (!removedRows.contains(y) && board.isOccupied(x, y)) {
          final shift = removedBelow[y];
          if (shift > 0) {
            board.setCell(x, y + shift, const Cell.occupied());
            board.setCell(x, y, const Cell.empty());
          }
        }
      }
    }
  }
}

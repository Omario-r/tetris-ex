import '../models/board.dart';
import '../models/falling_piece.dart';

/// Проверка коллизий для Normal-режима.
class CollisionDetector {
  /// true если ни одна клетка FallingPiece не выходит за границы поля
  /// и не пересекается с занятой клеткой Board.
  static bool isValidPosition(FallingPiece fp, Board board) {
    for (final cell in fp.boardCells) {
      // Клетка невалидна если x < 0 или x >= board.width (стена)
      if (cell.x < 0 || cell.x >= board.width) {
        return false;
      }

      // Клетка невалидна если y >= board.height (дно)
      if (cell.y >= board.height) {
        return false;
      }

      // Клетка невалидна если y >= 0 и board.isOccupied(x, y) == true
      // Клетки с y < 0 — допустимы (зона спавна выше поля)
      if (cell.y >= 0 && board.isOccupied(cell.x, cell.y)) {
        return false;
      }
    }
    return true;
  }

  /// true если фигура может сдвинуться на (dx, dy).
  /// Normal: проверяет границы + занятые клетки board.
  static bool canMove(FallingPiece fp, Board board, int dx, int dy) {
    final movedPiece = fp.copyWith(x: fp.x + dx, y: fp.y + dy);
    return isValidPosition(movedPiece, board);
  }

  /// true если фигура может переместиться на y+1 (вниз).
  /// Используется для определения момента фиксации.
  static bool canMoveDown(FallingPiece fp, Board board) {
    return canMove(fp, board, 0, 1);
  }

  /// true если фигура после поворота CW находится в валидной позиции.
  /// Если нет — поворот не применяется (no wall kicks).
  static bool canRotateCW(FallingPiece fp, Board board) {
    final rotatedPiece = fp.copyWith(piece: fp.piece.rotateCW());
    return isValidPosition(rotatedPiece, board);
  }
}

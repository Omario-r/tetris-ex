import '../models/board.dart';

class HaloCalculator {
  /// Вычисляет H — множество клеток поля, прилегающих к S по 8-соседству,
  /// но не входящих в S.
  /// Клетки вне границ поля (x<0, x>=boardW, y<0, y>=boardH) игнорируются.
  static Set<(int, int)> computeHalo8(
    Set<(int, int)> S,
    int boardWidth,
    int boardHeight,
  ) {
    final H = <(int, int)>{};
    for (final (sx, sy) in S) {
      for (final dx in [-1, 0, 1]) {
        for (final dy in [-1, 0, 1]) {
          if (dx == 0 && dy == 0) continue;
          final nx = sx + dx;
          final ny = sy + dy;
          if (nx < 0 || nx >= boardWidth || ny < 0 || ny >= boardHeight) continue;
          if (!S.contains((nx, ny))) H.add((nx, ny));
        }
      }
    }
    return H;
  }

  /// Проверяет условие победы:
  /// - все клетки S на board заняты (isOccupied)
  /// - все клетки H на board пусты (!isOccupied)
  /// S и H берутся из level.S и level.H.
  static bool checkWin(Board board, Set<(int, int)> S, Set<(int, int)> H) {
    for (final (sx, sy) in S) {
      if (!board.isOccupied(sx, sy)) return false;
    }
    for (final (hx, hy) in H) {
      if (hx < 0 || hx >= board.width || hy < 0 || hy >= board.height) continue;
      if (board.isOccupied(hx, hy)) return false;
    }
    return true;
  }
}

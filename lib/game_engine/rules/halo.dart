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
}

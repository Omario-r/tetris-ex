import 'piece.dart';

/// Represents the mode of a falling piece.
enum PieceMode { normal, explosive }

/// Падающая фигура на поле. Позиция (x,y) — левый верхний угол 4×4 матрицы.
class FallingPiece {
  final Piece piece;    // текущая форма (с учётом поворотов)
  final int x;         // позиция по x на поле
  final int y;         // позиция по y на поле (y=0 сверху, y растёт вниз)
  final PieceMode mode;
  final bool armedUsed; // true если armExplosive уже был вызван

  const FallingPiece({
    required this.piece,
    required this.x,
    required this.y,
    this.mode = PieceMode.normal,
    this.armedUsed = false,
  });

  /// Возвращает абсолютные координаты занятых клеток на поле.
  List<({int x, int y})> get boardCells {
    final result = <({int x, int y})>[];
    for (final cell in piece.cells) {
      final boardX = x + cell.x;
      final boardY = y + cell.y;
      result.add((x: boardX, y: boardY));
    }
    return result;
  }

  /// Копия с изменёнными полями.
  FallingPiece copyWith({
    Piece? piece,
    int? x,
    int? y,
    PieceMode? mode,
    bool? armedUsed,
  }) {
    return FallingPiece(
      piece: piece ?? this.piece,
      x: x ?? this.x,
      y: y ?? this.y,
      mode: mode ?? this.mode,
      armedUsed: armedUsed ?? this.armedUsed,
    );
  }
}

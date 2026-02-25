import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/falling_piece.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';
import 'package:explosive_tetris/game_engine/rules/explosion.dart';

// I-piece горизонтально: row=1 в 4x4 матрице, cols 0-3.
// При FallingPiece(x=3, y=9): boardCells = (3,10),(4,10),(5,10),(6,10).
FallingPiece _makeIPiece({int x = 3, int y = 9}) {
  return FallingPiece(
    piece: PieceFactory.create(PieceType.I),
    x: x,
    y: y,
    mode: PieceMode.explosive,
  );
}

void main() {
  group('explodeFootprint', () {
    test('1) базовый: удаляет занятые клетки под фигурой', () {
      final board = Board(10, 20);
      for (int x = 3; x <= 6; x++) {
        board.setCell(x, 10, const Cell.occupied());
      }
      final fp = _makeIPiece();
      ExplosionHandler.explodeFootprint(fp, board);
      for (int x = 3; x <= 6; x++) {
        expect(board.isOccupied(x, 10), isFalse,
            reason: 'Cell ($x,10) should be empty after explosion');
      }
      // Остальные клетки не изменились
      expect(board.isOccupied(2, 10), isFalse);
      expect(board.isOccupied(7, 10), isFalse);
    });

    test('2) только занятые: пустые клетки под фигурой не трогаются', () {
      final board = Board(10, 20);
      // Только (3,10) и (5,10) заняты, (4,10) и (6,10) пустые
      board.setCell(3, 10, const Cell.occupied());
      board.setCell(5, 10, const Cell.occupied());
      final fp = _makeIPiece();
      final removed = ExplosionHandler.explodeFootprint(fp, board);
      expect(board.isOccupied(3, 10), isFalse);
      expect(board.isOccupied(5, 10), isFalse);
      expect(board.isOccupied(4, 10), isFalse); // и так было пусто
      expect(board.isOccupied(6, 10), isFalse); // и так было пусто
      // Map содержит только колонки где были удаления
      expect(removed.containsKey(3), isTrue);
      expect(removed.containsKey(5), isTrue);
      expect(removed.containsKey(4), isFalse);
      expect(removed.containsKey(6), isFalse);
    });

    test('3) возвращаемый Map: {3:{10}, 4:{10}, 5:{10}, 6:{10}}', () {
      final board = Board(10, 20);
      for (int x = 3; x <= 6; x++) {
        board.setCell(x, 10, const Cell.occupied());
      }
      final fp = _makeIPiece();
      final removed = ExplosionHandler.explodeFootprint(fp, board);
      expect(removed[3], equals({10}));
      expect(removed[4], equals({10}));
      expect(removed[5], equals({10}));
      expect(removed[6], equals({10}));
    });
  });

  group('applyLimitedGravity', () {
    test('4) базовый сдвиг: блок над 2 удалёнными сдвигается на 2', () {
      final board = Board(10, 20);
      board.setCell(3, 8, const Cell.occupied());
      // removedPerColumn = {3: {9, 10}} — 2 клетки удалены ниже строки 8
      final removedPerColumn = {3: {9, 10}};
      ExplosionHandler.applyLimitedGravity(board, removedPerColumn);
      expect(board.isOccupied(3, 8), isFalse);
      expect(board.isOccupied(3, 10), isTrue);
    });

    test('5) старые пустоты не заполняются', () {
      final board = Board(10, 20);
      // Блок на (3,3), старая пустота на (3,5), удалена строка 15
      board.setCell(3, 3, const Cell.occupied());
      // (3,5) остаётся пустой (старая пустота)
      final removedPerColumn = {3: {15}};
      ExplosionHandler.applyLimitedGravity(board, removedPerColumn);
      // Блок (3,3) сдвигается на 1 → (3,4)
      expect(board.isOccupied(3, 3), isFalse);
      expect(board.isOccupied(3, 4), isTrue);
      // Пустота (3,5) остаётся пустой
      expect(board.isOccupied(3, 5), isFalse);
    });

    test('6) колонки без удалений не трогаются', () {
      final board = Board(10, 20);
      board.setCell(5, 10, const Cell.occupied());
      final removedPerColumn = {3: {15}};
      ExplosionHandler.applyLimitedGravity(board, removedPerColumn);
      // Блок в колонке 5 не трогается
      expect(board.isOccupied(5, 10), isTrue);
    });
  });
}

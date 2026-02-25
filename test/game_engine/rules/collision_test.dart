import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/rules/collision.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/falling_piece.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';

void main() {
  group('CollisionDetector', () {
    late Board board;

    setUp(() {
      // Create standard 10×20 board
      board = Board(10, 20);
    });

    group('isValidPosition', () {
      test('piece fully inside empty field returns true', () {
        final piece = PieceFactory.create(PieceType.O);
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 8);

        expect(CollisionDetector.isValidPosition(fallingPiece, board), isTrue);
      });

      test('piece exits right wall returns false', () {
        final piece = PieceFactory.create(PieceType.I);
        // Place I-piece so it extends beyond right wall (x >= 10)
        final fallingPiece = FallingPiece(piece: piece, x: 7, y: 10);

        expect(CollisionDetector.isValidPosition(fallingPiece, board), isFalse);
      });

      test('piece exits left wall returns false', () {
        final piece = PieceFactory.create(PieceType.T);
        // Place T-piece so it extends beyond left wall (x < 0)
        final fallingPiece = FallingPiece(piece: piece, x: -1, y: 10);

        expect(CollisionDetector.isValidPosition(fallingPiece, board), isFalse);
      });

      test('piece exits bottom returns false', () {
        final piece = PieceFactory.create(PieceType.I);
        // Place I-piece so it extends beyond bottom (y >= 20)
        final fallingPiece = FallingPiece(piece: piece, x: 3, y: 19);

        expect(CollisionDetector.isValidPosition(fallingPiece, board), isFalse);
      });

      test('piece partially above field returns true', () {
        final piece = PieceFactory.create(PieceType.T);
        // Place T-piece partially above field (y < 0, spawn zone)
        final fallingPiece = FallingPiece(piece: piece, x: 3, y: -1);

        expect(CollisionDetector.isValidPosition(fallingPiece, board), isTrue);
      });

      test('piece overlapping occupied cell returns false', () {
        final piece = PieceFactory.create(PieceType.O);
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 8);

        // Occupy a cell where the piece would be placed
        board.setCell(5, 8, const Cell.occupied());

        expect(CollisionDetector.isValidPosition(fallingPiece, board), isFalse);
      });
    });

    group('canMoveDown', () {
      test('piece above empty field returns true', () {
        final piece = PieceFactory.create(PieceType.T);
        final fallingPiece = FallingPiece(piece: piece, x: 3, y: 5);

        expect(CollisionDetector.canMoveDown(fallingPiece, board), isTrue);
      });

      test('piece with bottom cell at y=19 returns false', () {
        final piece = PieceFactory.create(PieceType.I);
        // I-piece in initial form has cells at y=1, so placing at y=18 
        // means bottom cells will be at y=19 (board bottom)
        final fallingPiece = FallingPiece(piece: piece, x: 3, y: 18);

        expect(CollisionDetector.canMoveDown(fallingPiece, board), isFalse);
      });

      test('piece above occupied cell returns false', () {
        final piece = PieceFactory.create(PieceType.O);
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 8);

        // O-piece at (4,8) occupies (5,8), (6,8), (5,9), (6,9)
        // When moved down, it would occupy (5,9), (6,9), (5,10), (6,10)
        // Occupy one of the cells it would move into
        board.setCell(5, 10, const Cell.occupied());

        expect(CollisionDetector.canMoveDown(fallingPiece, board), isFalse);
      });
    });

    group('canMove', () {
      test('canMove left at left wall returns false', () {
        final piece = PieceFactory.create(PieceType.T);
        final fallingPiece = FallingPiece(piece: piece, x: 0, y: 5);

        expect(CollisionDetector.canMove(fallingPiece, board, -1, 0), isFalse);
      });

      test('canMove right at right wall returns false', () {
        final piece = PieceFactory.create(PieceType.I);
        // Place I-piece at rightmost valid position
        final fallingPiece = FallingPiece(piece: piece, x: 6, y: 5);

        expect(CollisionDetector.canMove(fallingPiece, board, 1, 0), isFalse);
      });

      test('canMove down above empty field returns true', () {
        final piece = PieceFactory.create(PieceType.S);
        final fallingPiece = FallingPiece(piece: piece, x: 3, y: 5);

        expect(CollisionDetector.canMove(fallingPiece, board, 0, 1), isTrue);
      });

      test('canMove into occupied cell returns false', () {
        final piece = PieceFactory.create(PieceType.O);
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 8);

        // Occupy cell to the right
        board.setCell(6, 8, const Cell.occupied());

        expect(CollisionDetector.canMove(fallingPiece, board, 1, 0), isFalse);
      });
    });

    group('canRotateCW', () {
      test('rotation in free space returns true', () {
        final piece = PieceFactory.create(PieceType.T);
        final fallingPiece = FallingPiece(piece: piece, x: 3, y: 5);

        expect(CollisionDetector.canRotateCW(fallingPiece, board), isTrue);
      });

      test('rotation that would exit right wall returns false', () {
        final piece = PieceFactory.create(PieceType.I);
        // Place I-piece near right wall where rotation would cause collision
        final fallingPiece = FallingPiece(piece: piece, x: 8, y: 5);

        expect(CollisionDetector.canRotateCW(fallingPiece, board), isFalse);
      });

      test('rotation that would hit occupied cell returns false', () {
        final piece = PieceFactory.create(PieceType.T);
        final fallingPiece = FallingPiece(piece: piece, x: 3, y: 5);

        // T-piece at (3,5) when rotated would occupy (6,5), (5,6), (6,6), (6,7)
        // Occupy one of the cells the rotated piece would occupy
        board.setCell(6, 5, const Cell.occupied());

        expect(CollisionDetector.canRotateCW(fallingPiece, board), isFalse);
      });

      test('O-piece rotation always returns true in valid position', () {
        final piece = PieceFactory.create(PieceType.O);
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 8);
        // O-piece doesn't change shape when rotated
        expect(CollisionDetector.canRotateCW(fallingPiece, board), isTrue);
      });
    });

    group('canMoveDownExplosive', () {
      test('фигура в середине пустого поля → true', () {
        final piece = PieceFactory.create(PieceType.O);
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 8, mode: PieceMode.explosive);
        expect(CollisionDetector.canMoveDownExplosive(fallingPiece, board), isTrue);
      });

      test('фигура с клеткой на y == board.height-1 → false', () {
        final piece = PieceFactory.create(PieceType.O);
        // O-piece занимает строки y и y+1, ставим так чтобы нижняя строка == 19
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 18, mode: PieceMode.explosive);
        expect(CollisionDetector.canMoveDownExplosive(fallingPiece, board), isFalse);
      });

      test('фигура над занятым блоком → true (Explosive игнорирует блоки)', () {
        final piece = PieceFactory.create(PieceType.O);
        final fallingPiece = FallingPiece(piece: piece, x: 4, y: 8, mode: PieceMode.explosive);
        // Ставим блок прямо под фигурой
        board.setCell(4, 10, const Cell.occupied());
        board.setCell(5, 10, const Cell.occupied());
        expect(CollisionDetector.canMoveDownExplosive(fallingPiece, board), isTrue);
      });
    });
  });
}

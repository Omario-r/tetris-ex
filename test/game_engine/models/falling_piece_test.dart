import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/falling_piece.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';

void main() {
  group('FallingPiece', () {
    group('boardCells', () {
      test('I-piece horizontal at x=3, y=5 has correct board coordinates', () {
        // Create I-piece in horizontal position (initial form)
        final iPiece = PieceFactory.create(PieceType.I);
        final fallingPiece = FallingPiece(piece: iPiece, x: 3, y: 5);

        final boardCells = fallingPiece.boardCells;

        // I-piece in initial form has cells at y=1 in the 4x4 matrix
        // So board y should be 5 + 1 = 6
        // I-piece spans x=0,1,2,3 in matrix, so board x should be 3,4,5,6
        expect(boardCells.length, equals(4));

        final expectedCells = [
          (x: 3, y: 6),
          (x: 4, y: 6),
          (x: 5, y: 6),
          (x: 6, y: 6),
        ];

        for (final expectedCell in expectedCells) {
          expect(boardCells.contains(expectedCell), isTrue,
              reason: 'Should contain cell $expectedCell');
        }
      });

      test('FallingPiece at x=0, y=0 has non-empty boardCells', () {
        final tPiece = PieceFactory.create(PieceType.T);
        final fallingPiece = FallingPiece(piece: tPiece, x: 0, y: 0);

        final boardCells = fallingPiece.boardCells;

        expect(boardCells, isNotEmpty);
        // T-piece should have 4 cells
        expect(boardCells.length, equals(4));
      });
    });

    group('copyWith', () {
      test('changing x through copyWith does not modify original object', () {
        final originalPiece = PieceFactory.create(PieceType.O);
        final original = FallingPiece(piece: originalPiece, x: 5, y: 10);

        final modified = original.copyWith(x: 8);

        // Original should be unchanged
        expect(original.x, equals(5));
        expect(original.y, equals(10));

        // Modified should have new x value
        expect(modified.x, equals(8));
        expect(modified.y, equals(10)); // y should remain the same
        expect(modified.piece, equals(originalPiece)); // piece should remain the same
      });

      test('copyWith can change mode to explosive', () {
        final piece = PieceFactory.create(PieceType.S);
        final original = FallingPiece(piece: piece, x: 0, y: 0);

        expect(original.mode, equals(PieceMode.normal));

        final explosive = original.copyWith(mode: PieceMode.explosive);

        expect(explosive.mode, equals(PieceMode.explosive));
        expect(original.mode, equals(PieceMode.normal)); // original unchanged
      });

      test('copyWith can change armedUsed flag', () {
        final piece = PieceFactory.create(PieceType.Z);
        final original = FallingPiece(piece: piece, x: 0, y: 0);

        expect(original.armedUsed, isFalse);

        final armed = original.copyWith(armedUsed: true);

        expect(armed.armedUsed, isTrue);
        expect(original.armedUsed, isFalse); // original unchanged
      });

      test('copyWith with no parameters returns equivalent object', () {
        final piece = PieceFactory.create(PieceType.J);
        final original = FallingPiece(
          piece: piece, 
          x: 3, 
          y: 7, 
          mode: PieceMode.explosive,
          armedUsed: true,
        );

        final copy = original.copyWith();

        expect(copy.piece, equals(original.piece));
        expect(copy.x, equals(original.x));
        expect(copy.y, equals(original.y));
        expect(copy.mode, equals(original.mode));
        expect(copy.armedUsed, equals(original.armedUsed));
      });
    });

    group('constructor', () {
      test('default values are set correctly', () {
        final piece = PieceFactory.create(PieceType.L);
        final fallingPiece = FallingPiece(piece: piece, x: 1, y: 2);

        expect(fallingPiece.piece, equals(piece));
        expect(fallingPiece.x, equals(1));
        expect(fallingPiece.y, equals(2));
        expect(fallingPiece.mode, equals(PieceMode.normal));
        expect(fallingPiece.armedUsed, isFalse);
      });
    });
  });
}

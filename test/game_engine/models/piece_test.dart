import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';

void main() {
  group('PieceFactory', () {
    test('creates pieces with exactly 4 occupied cells', () {
      for (final type in PieceType.values) {
        final piece = PieceFactory.create(type);
        expect(piece.cells.length, equals(4), 
               reason: 'Piece $type should have exactly 4 cells');
      }
    });

    test('all coordinates are within 0..3 range', () {
      for (final type in PieceType.values) {
        final piece = PieceFactory.create(type);
        for (final cell in piece.cells) {
          expect(cell.x, inInclusiveRange(0, 3), 
                 reason: 'x coordinate should be 0..3 for $type');
          expect(cell.y, inInclusiveRange(0, 3), 
                 reason: 'y coordinate should be 0..3 for $type');
        }
      }
    });

    test('different piece types have different cell patterns', () {
      final pieces = PieceType.values.map(PieceFactory.create).toList();

      for (int i = 0; i < pieces.length; i++) {
        for (int j = i + 1; j < pieces.length; j++) {
          final cellsI = pieces[i].cells.toSet();
          final cellsJ = pieces[j].cells.toSet();
          expect(cellsI, isNot(equals(cellsJ)), 
                 reason: '${pieces[i].type} and ${pieces[j].type} should have different patterns');
        }
      }
    });
  });

  group('Piece rotation CW', () {
    test('O-piece: 4 consecutive rotateCW() return equivalent form', () {
      final original = PieceFactory.create(PieceType.O);
      var rotated = original;

      for (int i = 0; i < 4; i++) {
        rotated = rotated.rotateCW();
      }

      expect(rotated.cells.toSet(), equals(original.cells.toSet()),
             reason: 'O-piece should return to original form after 4 rotations');
    });

    test('I-piece: has 2 unique states (horizontal/vertical)', () {
      final original = PieceFactory.create(PieceType.I);
      final rotated1 = original.rotateCW();
      final rotated2 = rotated1.rotateCW();

      // After one rotation, should be vertical (different from original)
      expect(rotated1.cells.toSet(), isNot(equals(original.cells.toSet())),
             reason: 'I-piece should be different after 1 rotation');

      // Check that rotated1 is vertical (all cells have same x, consecutive y)
      final rotated1Cells = rotated1.cells;
      final rotated1XValues = rotated1Cells.map((cell) => cell.x).toSet();
      final rotated1YValues = rotated1Cells.map((cell) => cell.y).toList()..sort();
      expect(rotated1XValues.length, equals(1), 
             reason: 'Rotated I-piece should be vertical (same x)');
      for (int i = 1; i < rotated1YValues.length; i++) {
        expect(rotated1YValues[i], equals(rotated1YValues[i-1] + 1),
               reason: 'Vertical I-piece y coordinates should be consecutive');
      }

      // After two rotations, should be horizontal again (same shape as original)
      final rotated2Cells = rotated2.cells;
      final rotated2YValues = rotated2Cells.map((cell) => cell.y).toSet();
      final rotated2XValues = rotated2Cells.map((cell) => cell.x).toList()..sort();
      expect(rotated2YValues.length, equals(1), 
             reason: 'Twice-rotated I-piece should be horizontal (same y)');
      for (int i = 1; i < rotated2XValues.length; i++) {
        expect(rotated2XValues[i], equals(rotated2XValues[i-1] + 1),
               reason: 'Horizontal I-piece x coordinates should be consecutive');
      }
    });

    test('T-piece: 4 rotateCW() return form equivalent to original', () {
      final original = PieceFactory.create(PieceType.T);
      var rotated = original;

      for (int i = 0; i < 4; i++) {
        rotated = rotated.rotateCW();
      }

      expect(rotated.cells.toSet(), equals(original.cells.toSet()),
             reason: 'T-piece should return to original form after 4 rotations');
    });

    test('all pieces return to original form after 4 rotations', () {
      for (final type in PieceType.values) {
        final original = PieceFactory.create(type);
        var rotated = original;

        for (int i = 0; i < 4; i++) {
          rotated = rotated.rotateCW();
        }

        expect(rotated.cells.toSet(), equals(original.cells.toSet()),
               reason: '$type should return to original form after 4 rotations');
      }
    });
  });

  group('Immutability', () {
    test('rotateCW() does not mutate original piece matrix', () {
      final original = PieceFactory.create(PieceType.T);
      final originalMatrix = original.matrix.map((row) => List.from(row)).toList();

      original.rotateCW();

      expect(original.matrix, equals(originalMatrix),
             reason: 'Original piece matrix should not be modified by rotateCW()');
    });

    test('rotateCW() returns new Piece object', () {
      final original = PieceFactory.create(PieceType.T);
      final rotated = original.rotateCW();

      expect(identical(original, rotated), isFalse,
             reason: 'rotateCW() should return a new Piece object');
    });
  });

  group('Basic geometry', () {
    test('horizontal I-piece has all cells with same y, consecutive x', () {
      final iPiece = PieceFactory.create(PieceType.I);
      final cells = iPiece.cells;

      // All cells should have the same y coordinate
      final yValues = cells.map((cell) => cell.y).toSet();
      expect(yValues.length, equals(1),
             reason: 'Horizontal I-piece should have all cells on same row');

      // X coordinates should be consecutive
      final xValues = cells.map((cell) => cell.x).toList()..sort();
      for (int i = 1; i < xValues.length; i++) {
        expect(xValues[i], equals(xValues[i-1] + 1),
               reason: 'I-piece x coordinates should be consecutive');
      }
    });

    test('vertical I-piece after rotation has all cells with same x, consecutive y', () {
      final iPiece = PieceFactory.create(PieceType.I);
      final rotatedIPiece = iPiece.rotateCW();
      final cells = rotatedIPiece.cells;

      // All cells should have the same x coordinate
      final xValues = cells.map((cell) => cell.x).toSet();
      expect(xValues.length, equals(1),
             reason: 'Vertical I-piece should have all cells in same column');

      // Y coordinates should be consecutive
      final yValues = cells.map((cell) => cell.y).toList()..sort();
      for (int i = 1; i < yValues.length; i++) {
        expect(yValues[i], equals(yValues[i-1] + 1),
               reason: 'Vertical I-piece y coordinates should be consecutive');
      }
    });

    test('O-piece forms 2x2 square', () {
      final oPiece = PieceFactory.create(PieceType.O);
      final cells = oPiece.cells;

      // Should have exactly 2 unique x values and 2 unique y values
      final xValues = cells.map((cell) => cell.x).toSet();
      final yValues = cells.map((cell) => cell.y).toSet();

      expect(xValues.length, equals(2),
             reason: 'O-piece should span 2 columns');
      expect(yValues.length, equals(2),
             reason: 'O-piece should span 2 rows');

      // Should form a complete 2x2 square
      final xList = xValues.toList()..sort();
      final yList = yValues.toList()..sort();

      expect(xList[1], equals(xList[0] + 1),
             reason: 'O-piece columns should be consecutive');
      expect(yList[1], equals(yList[0] + 1),
             reason: 'O-piece rows should be consecutive');
    });
  });

  group('Specific piece shapes', () {
    test('I-piece initial form matches specification', () {
      final iPiece = PieceFactory.create(PieceType.I);
      final expectedCells = {(x: 0, y: 1), (x: 1, y: 1), (x: 2, y: 1), (x: 3, y: 1)};
      expect(iPiece.cells.toSet(), equals(expectedCells));
    });

    test('O-piece initial form matches specification', () {
      final oPiece = PieceFactory.create(PieceType.O);
      final expectedCells = {(x: 1, y: 0), (x: 2, y: 0), (x: 1, y: 1), (x: 2, y: 1)};
      expect(oPiece.cells.toSet(), equals(expectedCells));
    });

    test('T-piece initial form matches specification', () {
      final tPiece = PieceFactory.create(PieceType.T);
      final expectedCells = {(x: 0, y: 0), (x: 1, y: 0), (x: 2, y: 0), (x: 1, y: 1)};
      expect(tPiece.cells.toSet(), equals(expectedCells));
    });

    test('S-piece initial form matches specification', () {
      final sPiece = PieceFactory.create(PieceType.S);
      final expectedCells = {(x: 1, y: 0), (x: 2, y: 0), (x: 0, y: 1), (x: 1, y: 1)};
      expect(sPiece.cells.toSet(), equals(expectedCells));
    });

    test('Z-piece initial form matches specification', () {
      final zPiece = PieceFactory.create(PieceType.Z);
      final expectedCells = {(x: 0, y: 0), (x: 1, y: 0), (x: 1, y: 1), (x: 2, y: 1)};
      expect(zPiece.cells.toSet(), equals(expectedCells));
    });

    test('J-piece initial form matches specification', () {
      final jPiece = PieceFactory.create(PieceType.J);
      final expectedCells = {(x: 0, y: 0), (x: 0, y: 1), (x: 1, y: 1), (x: 2, y: 1)};
      expect(jPiece.cells.toSet(), equals(expectedCells));
    });

    test('L-piece initial form matches specification', () {
      final lPiece = PieceFactory.create(PieceType.L);
      final expectedCells = {(x: 2, y: 0), (x: 0, y: 1), (x: 1, y: 1), (x: 2, y: 1)};
      expect(lPiece.cells.toSet(), equals(expectedCells));
    });
  });
}

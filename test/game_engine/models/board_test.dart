import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';

void main() {
  group('Cell', () {
    test('Cell.empty() creates empty cell', () {
      const cell = Cell.empty();
      expect(cell.state, CellState.empty);
      expect(cell.isEmpty, true);
      expect(cell.isOccupied, false);
    });

    test('Cell.occupied() creates occupied cell', () {
      const cell = Cell.occupied();
      expect(cell.state, CellState.occupied);
      expect(cell.isEmpty, false);
      expect(cell.isOccupied, true);
    });
  });

  group('Board creation', () {
    test('Board(10, 20) creates board with correct dimensions', () {
      final board = Board(10, 20);
      expect(board.width, 10);
      expect(board.height, 20);
    });

    test('All cells are empty by default', () {
      final board = Board(10, 20);
      for (int y = 0; y < 20; y++) {
        for (int x = 0; x < 10; x++) {
          expect(board.getCell(x, y).isEmpty, true);
        }
      }
    });
  });

  group('isInside', () {
    late Board board;

    setUp(() {
      board = Board(10, 20);
    });

    test('returns true for valid coordinates', () {
      expect(board.isInside(0, 0), true);
      expect(board.isInside(9, 19), true);
      expect(board.isInside(5, 10), true);
    });

    test('returns false for coordinates outside board', () {
      expect(board.isInside(-1, 0), false);
      expect(board.isInside(10, 0), false);
      expect(board.isInside(0, 20), false);
      expect(board.isInside(-1, -1), false);
      expect(board.isInside(10, 20), false);
    });
  });

  group('setCell and getCell', () {
    late Board board;

    setUp(() {
      board = Board(10, 20);
    });

    test('setCell and getCell work correctly for occupied cell', () {
      board.setCell(0, 0, const Cell.occupied());
      expect(board.getCell(0, 0).isOccupied, true);
      expect(board.getCell(0, 0).isEmpty, false);
    });

    test('setCell and getCell work correctly for empty cell', () {
      board.setCell(1, 1, const Cell.empty());
      expect(board.getCell(1, 1).isEmpty, true);
      expect(board.getCell(1, 1).isOccupied, false);
    });

    test('getCell throws assertion error for coordinates outside board', () {
      expect(() => board.getCell(-1, 0), throwsA(isA<AssertionError>()));
      expect(() => board.getCell(10, 0), throwsA(isA<AssertionError>()));
      expect(() => board.getCell(0, 20), throwsA(isA<AssertionError>()));
    });

    test('setCell throws assertion error for coordinates outside board', () {
      expect(() => board.setCell(-1, 0, const Cell.empty()), throwsA(isA<AssertionError>()));
      expect(() => board.setCell(10, 0, const Cell.empty()), throwsA(isA<AssertionError>()));
      expect(() => board.setCell(0, 20, const Cell.empty()), throwsA(isA<AssertionError>()));
    });
  });

  group('isOccupied', () {
    late Board board;

    setUp(() {
      board = Board(10, 20);
    });

    test('returns false for empty cells inside board', () {
      expect(board.isOccupied(0, 0), false);
      expect(board.isOccupied(5, 10), false);
      expect(board.isOccupied(9, 19), false);
    });

    test('returns true for occupied cells inside board', () {
      board.setCell(0, 0, const Cell.occupied());
      board.setCell(5, 10, const Cell.occupied());

      expect(board.isOccupied(0, 0), true);
      expect(board.isOccupied(5, 10), true);
    });

    test('returns false for coordinates outside board without throwing exceptions', () {
      expect(board.isOccupied(-1, 0), false);
      expect(board.isOccupied(10, 0), false);
      expect(board.isOccupied(0, 20), false);
      expect(board.isOccupied(10, 20), false);
      expect(board.isOccupied(-5, -5), false);
    });
  });

  group('clear', () {
    late Board board;

    setUp(() {
      board = Board(10, 20);
    });

    test('clear makes all cells empty after setting some occupied', () {
      // Set some cells as occupied
      board.setCell(0, 0, const Cell.occupied());
      board.setCell(5, 10, const Cell.occupied());
      board.setCell(9, 19, const Cell.occupied());

      // Verify they are occupied
      expect(board.isOccupied(0, 0), true);
      expect(board.isOccupied(5, 10), true);
      expect(board.isOccupied(9, 19), true);

      // Clear the board
      board.clear();

      // Verify all cells are empty
      for (int y = 0; y < 20; y++) {
        for (int x = 0; x < 10; x++) {
          expect(board.getCell(x, y).isEmpty, true);
        }
      }
    });
  });

  group('copyWith', () {
    late Board board;

    setUp(() {
      board = Board(10, 20);
    });

    test('copyWith creates independent copy', () {
      // Set some cells in original
      board.setCell(0, 0, const Cell.occupied());
      board.setCell(5, 10, const Cell.occupied());

      // Create copy
      final copy = board.copyWith();

      // Verify copy has same dimensions
      expect(copy.width, board.width);
      expect(copy.height, board.height);

      // Verify copy has same cell states
      expect(copy.isOccupied(0, 0), true);
      expect(copy.isOccupied(5, 10), true);
      expect(copy.isOccupied(1, 1), false);

      // Modify copy - should not affect original
      copy.setCell(1, 1, const Cell.occupied());
      expect(copy.isOccupied(1, 1), true);
      expect(board.isOccupied(1, 1), false);

      // Modify original - should not affect copy
      board.setCell(2, 2, const Cell.occupied());
      expect(board.isOccupied(2, 2), true);
      expect(copy.isOccupied(2, 2), false);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/level_template.dart';
import 'package:explosive_tetris/game_engine/models/target_mask.dart';
import 'package:explosive_tetris/game_engine/rules/halo.dart';

void main() {
  group('computeHalo8 — базовый', () {
    test('S={(5,5)} на 10x10: H содержит ровно 8 клеток', () {
      final S = {(5, 5)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      expect(H.length, equals(8));
    });

    test('S={(5,5)}: H не содержит (5,5)', () {
      final S = {(5, 5)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      expect(H.contains((5, 5)), isFalse);
    });
  });

  group('computeHalo8 — у стены', () {
    test('S={(0,0)}: H содержит 3 клетки', () {
      final S = {(0, 0)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      expect(H.length, equals(3));
    });

    test('S={(0,0)}: H содержит (1,0), (0,1), (1,1)', () {
      final S = {(0, 0)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      expect(H.contains((1, 0)), isTrue);
      expect(H.contains((0, 1)), isTrue);
      expect(H.contains((1, 1)), isTrue);
    });

    test('S={(0,0)}: клетки с отрицательными координатами не в H', () {
      final S = {(0, 0)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      for (final (x, y) in H) {
        expect(x >= 0, isTrue);
        expect(y >= 0, isTrue);
      }
    });
  });

  group('computeHalo8 — у дна', () {
    test('S={(5,9)} на 10x10: H не содержит клеток с y >= 10', () {
      final S = {(5, 9)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      for (final (_, y) in H) {
        expect(y < 10, isTrue);
      }
    });
  });

  group('computeHalo8 — несколько клеток S', () {
    test('S={(5,5),(6,5)}: H не содержит клетки S', () {
      final S = {(5, 5), (6, 5)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      expect(H.contains((5, 5)), isFalse);
      expect(H.contains((6, 5)), isFalse);
    });

    test('S={(5,5),(6,5)}: смежные соседи есть в H', () {
      final S = {(5, 5), (6, 5)};
      final H = HaloCalculator.computeHalo8(S, 10, 10);
      expect(H.contains((4, 5)), isTrue);
      expect(H.contains((7, 5)), isTrue);
      expect(H.contains((5, 4)), isTrue);
      expect(H.contains((6, 4)), isTrue);
    });
  });

  group('checkWin', () {
    test('победа — все S заняты, все H пусты', () {
      final board = Board(10, 20);
      for (final (x, y) in defaultLevel.S) {
        board.setCell(x, y, const Cell.occupied());
      }
      expect(
        HaloCalculator.checkWin(board, defaultLevel.S, defaultLevel.H),
        isTrue,
      );
    });

    test('S не заполнено — одна клетка пуста', () {
      final board = Board(10, 20);
      final sList = defaultLevel.S.toList();
      for (int i = 0; i < sList.length - 1; i++) {
        board.setCell(sList[i].$1, sList[i].$2, const Cell.occupied());
      }
      expect(
        HaloCalculator.checkWin(board, defaultLevel.S, defaultLevel.H),
        isFalse,
      );
    });

    test('H содержит мусор', () {
      final board = Board(10, 20);
      for (final (x, y) in defaultLevel.S) {
        board.setCell(x, y, const Cell.occupied());
      }
      final hCell = defaultLevel.H.first;
      board.setCell(hCell.$1, hCell.$2, const Cell.occupied());
      expect(
        HaloCalculator.checkWin(board, defaultLevel.S, defaultLevel.H),
        isFalse,
      );
    });

    test('S касается стены — H частично вне поля → checkWin == true', () {
      final level = LevelTemplate(
        boardWidth: 10,
        boardHeight: 20,
        targetMask: defaultTargetMask,
        targetX: 0,
        targetY: 14,
      );
      final board = Board(10, 20);
      for (final (x, y) in level.S) {
        board.setCell(x, y, const Cell.occupied());
      }
      // H частично вне поля (x < 0) — эти клетки уже отфильтрованы computeHalo8
      expect(
        HaloCalculator.checkWin(board, level.S, level.H),
        isTrue,
      );
    });
  });
}

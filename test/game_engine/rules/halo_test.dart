import 'package:flutter_test/flutter_test.dart';
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
}

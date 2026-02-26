import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/level_template.dart';

void main() {
  group('defaultLevel — S', () {
    test('S.length == 20', () {
      expect(defaultLevel.S.length, equals(20));
    });

    test('S содержит (4,14) — localX=2, localY=0', () {
      expect(defaultLevel.S.contains((4, 14)), isTrue);
    });

    test('S содержит (2,16) — localX=0, localY=2', () {
      expect(defaultLevel.S.contains((2, 16)), isTrue);
    });

    test('S не содержит (2,14) — угол localX=0, localY=0', () {
      expect(defaultLevel.S.contains((2, 14)), isFalse);
    });
  });

  group('defaultLevel — H', () {
    test('H не пересекается с S', () {
      final intersection = defaultLevel.H.intersection(defaultLevel.S);
      expect(intersection, isEmpty);
    });

    test('все клетки H внутри поля', () {
      for (final (x, y) in defaultLevel.H) {
        expect(x, inInclusiveRange(0, 9));
        expect(y, inInclusiveRange(0, 19));
      }
    });

    test('H не пустой', () {
      expect(defaultLevel.H, isNotEmpty);
    });
  });

  group('defaultLevel — касание дна', () {
    test('S содержит клетки с y == 19', () {
      final hasBottom = defaultLevel.S.any((cell) => cell.$2 == 19);
      expect(hasBottom, isTrue);
    });

    test('H не содержит клеток с y >= 20', () {
      for (final (_, y) in defaultLevel.H) {
        expect(y < 20, isTrue);
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/target_mask.dart';

void main() {
  group('TargetMask contains — крест', () {
    test('вертикальная перекладина (2,0)', () {
      expect(defaultTargetMask.contains(2, 0), isTrue);
    });

    test('горизонтальная перекладина (0,2)', () {
      expect(defaultTargetMask.contains(0, 2), isTrue);
    });

    test('угол (0,0) не в кресте', () {
      expect(defaultTargetMask.contains(0, 0), isFalse);
    });

    test('угол (5,5) не в кресте', () {
      expect(defaultTargetMask.contains(5, 5), isFalse);
    });

    test('пересечение перекладин (3,3)', () {
      expect(defaultTargetMask.contains(3, 3), isTrue);
    });
  });

  group('TargetMask cells', () {
    test('количество клеток == 20', () {
      expect(defaultTargetMask.cells.length, equals(20));
    });

    test('все координаты в диапазоне 0..5', () {
      for (final cell in defaultTargetMask.cells) {
        expect(cell.x, inInclusiveRange(0, 5));
        expect(cell.y, inInclusiveRange(0, 5));
      }
    });

    test('contains == true для каждой клетки из cells', () {
      for (final cell in defaultTargetMask.cells) {
        expect(defaultTargetMask.contains(cell.x, cell.y), isTrue);
      }
    });
  });

  group('MSB-first битмаска', () {
    test('1x1 mask=1 содержит (0,0)', () {
      const m = TargetMask(width: 1, height: 1, mask: 1);
      expect(m.contains(0, 0), isTrue);
    });

    test('2x2 mask=8 содержит (0,0)', () {
      const m = TargetMask(width: 2, height: 2, mask: 8);
      expect(m.contains(0, 0), isTrue);
    });

    test('2x2 mask=1 содержит (1,1)', () {
      const m = TargetMask(width: 2, height: 2, mask: 1);
      expect(m.contains(1, 1), isTrue);
    });
  });
}

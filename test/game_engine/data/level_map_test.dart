import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/data/level_map.dart';

void main() {
  group('LevelMap structure', () {
    test('LevelMap.objects.length == 4', () {
      expect(LevelMap.objects.length, equals(4));
    });

    test('Каждый объект содержит ровно 4 фрагмента', () {
      for (var i = 0; i < LevelMap.objects.length; i++) {
        expect(
          LevelMap.objects[i].fragments.length,
          equals(4),
          reason: 'Объект $i должен содержать 4 фрагмента',
        );
      }
    });
  });

  group('LevelMap.levelAt маршрутизация', () {
    test('levelAt(0) → objectId=0, fragmentIndex=0', () {
      final level = LevelMap.levelAt(0);
      expect(level.objectId, equals(0));
      expect(level.fragmentIndex, equals(0));
    });

    test('levelAt(3) → objectId=0, fragmentIndex=3', () {
      final level = LevelMap.levelAt(3);
      expect(level.objectId, equals(0));
      expect(level.fragmentIndex, equals(3));
    });

    test('levelAt(4) → objectId=1, fragmentIndex=0', () {
      final level = LevelMap.levelAt(4);
      expect(level.objectId, equals(1));
      expect(level.fragmentIndex, equals(0));
    });

    test('levelAt(15) → objectId=3, fragmentIndex=3', () {
      final level = LevelMap.levelAt(15);
      expect(level.objectId, equals(3));
      expect(level.fragmentIndex, equals(3));
    });
  });

  group('Spot-check масок Домика (TargetMask.contains)', () {
    // Крыша левая 0x119DFF: правило localX >= (4 - localY)
    test('фрагмент 0: contains(4, 0) == true (4 >= 4)', () {
      final mask = LevelMap.objects[0].fragments[0].level.targetMask;
      expect(mask.contains(4, 0), isTrue);
    });

    test('фрагмент 0: contains(0, 0) == false (0 < 4)', () {
      final mask = LevelMap.objects[0].fragments[0].level.targetMask;
      expect(mask.contains(0, 0), isFalse);
    });

    test('фрагмент 0: contains(2, 2) == true (2 >= 2)', () {
      final mask = LevelMap.objects[0].fragments[0].level.targetMask;
      expect(mask.contains(2, 2), isTrue);
    });

    // Крыша правая 0x10C73DF: правило localX <= localY
    test('фрагмент 1: contains(0, 0) == true (0 <= 0)', () {
      final mask = LevelMap.objects[0].fragments[1].level.targetMask;
      expect(mask.contains(0, 0), isTrue);
    });

    test('фрагмент 1: contains(4, 0) == false (4 > 0)', () {
      final mask = LevelMap.objects[0].fragments[1].level.targetMask;
      expect(mask.contains(4, 0), isFalse);
    });

    test('фрагмент 1: contains(2, 2) == true (2 <= 2)', () {
      final mask = LevelMap.objects[0].fragments[1].level.targetMask;
      expect(mask.contains(2, 2), isTrue);
    });
  });

  group('Anchorы заглушек', () {
    test('объект 1, фрагмент 2: anchorX=0, anchorY=5', () {
      final fragment = LevelMap.objects[1].fragments[2];
      expect(fragment.anchorX, equals(0));
      expect(fragment.anchorY, equals(5));
    });

    test('объект 2, фрагмент 3: anchorX=5, anchorY=5', () {
      final fragment = LevelMap.objects[2].fragments[3];
      expect(fragment.anchorX, equals(5));
      expect(fragment.anchorY, equals(5));
    });
  });
}

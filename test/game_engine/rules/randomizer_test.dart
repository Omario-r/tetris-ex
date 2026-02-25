import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';
import 'package:explosive_tetris/game_engine/rules/randomizer.dart';

void main() {
  group('SevenBagGenerator', () {
    test('1) Each bag contains all 7 types exactly once', () {
      final gen = SevenBagGenerator(seed: 42);
      final bag = List.generate(7, (_) => gen.next());
      expect(bag.toSet(), equals(PieceType.values.toSet()));
    });

    test('2) Two consecutive bags each contain all 7 types', () {
      final gen = SevenBagGenerator(seed: 42);
      final first = List.generate(7, (_) => gen.next());
      final second = List.generate(7, (_) => gen.next());
      expect(first.toSet(), equals(PieceType.values.toSet()));
      expect(second.toSet(), equals(PieceType.values.toSet()));
    });

    test('3) Determinism: same seed produces same sequence', () {
      final gen1 = SevenBagGenerator(seed: 42);
      final gen2 = SevenBagGenerator(seed: 42);
      final seq1 = List.generate(7, (_) => gen1.next());
      final seq2 = List.generate(7, (_) => gen2.next());
      expect(seq1, equals(seq2));
    });

    test('4) preview does not change state', () {
      final gen = SevenBagGenerator(seed: 42);
      final previewed = gen.preview(3);
      expect(previewed.length, equals(3));
      final actual = List.generate(3, (_) => gen.next());
      expect(actual, equals(previewed));
    });

    test('5) preview across bag boundary returns n elements without exception', () {
      final gen = SevenBagGenerator(seed: 42);
      // Consume 5 elements, leaving 2 in the bag
      for (int i = 0; i < 5; i++) { gen.next(); }
      // Preview 5 elements crosses the bag boundary
      final result = gen.preview(5);
      expect(result.length, equals(5));
    });
  });

  group('FixedSequenceGenerator', () {
    test('6) Basic sequence', () {
      final gen = FixedSequenceGenerator([PieceType.I, PieceType.T, PieceType.O]);
      expect(gen.next(), equals(PieceType.I));
      expect(gen.next(), equals(PieceType.T));
      expect(gen.next(), equals(PieceType.O));
    });

    test('7) Cyclic wrapping', () {
      final gen = FixedSequenceGenerator([PieceType.I, PieceType.T]);
      final result = List.generate(4, (_) => gen.next());
      expect(result, equals([PieceType.I, PieceType.T, PieceType.I, PieceType.T]));
    });

    test('8) preview does not change state', () {
      final gen = FixedSequenceGenerator([PieceType.I, PieceType.T, PieceType.O]);
      final previewed = gen.preview(2);
      expect(previewed, equals([PieceType.I, PieceType.T]));
      expect(gen.next(), equals(PieceType.I));
    });

    test('9) preview cyclic', () {
      final gen = FixedSequenceGenerator([PieceType.I, PieceType.T]);
      final result = gen.preview(5);
      expect(result, equals([
        PieceType.I, PieceType.T, PieceType.I, PieceType.T, PieceType.I,
      ]));
    });
  });
}

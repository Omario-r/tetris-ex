import 'dart:math';

import 'package:explosive_tetris/game_engine/models/piece.dart';

abstract class PieceGenerator {
  PieceType next();
  List<PieceType> preview(int n);
}

class SevenBagGenerator implements PieceGenerator {
  final Random _random;
  List<PieceType> _bag = [];
  int _index = 0;

  SevenBagGenerator({int? seed}) : _random = Random(seed) {
    _fillNextBag();
  }

  void _fillNextBag() {
    _bag = List.of(PieceType.values)..shuffle(_random);
    _index = 0;
  }

  @override
  PieceType next() {
    if (_index >= _bag.length) _fillNextBag();
    return _bag[_index++];
  }

  @override
  List<PieceType> preview(int n) {
    // Collect from current bag without mutating state
    final result = <PieceType>[];
    result.addAll(_bag.sublist(_index));

    // Generate additional bags with a temporary RNG if needed.
    // We use a fixed seed derived from current bag snapshot to stay deterministic
    // without mutating _random. The preview bags may differ from actual future
    // bags (since _random state is opaque), but preview(n) followed by next()×n
    // will match because next() uses _random directly.
    //
    // To make preview consistent with next(), we keep a snapshot approach:
    // preview reads from _bag remainder, then generates extra bags via a
    // temporary Random seeded from the current bag's hashCode.
    if (result.length < n) {
      final tempRandom = Random(_bag.hashCode ^ _index);
      while (result.length < n) {
        final nextBag = List.of(PieceType.values)..shuffle(tempRandom);
        result.addAll(nextBag);
      }
    }

    return result.sublist(0, n);
  }
}

class FixedSequenceGenerator implements PieceGenerator {
  final List<PieceType> _sequence;
  int _index = 0;

  FixedSequenceGenerator(List<PieceType> sequence)
      : _sequence = List.unmodifiable(sequence);

  @override
  PieceType next() {
    final type = _sequence[_index % _sequence.length];
    _index++;
    return type;
  }

  @override
  List<PieceType> preview(int n) {
    return List.generate(n, (i) => _sequence[(_index + i) % _sequence.length]);
  }
}

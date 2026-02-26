import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/game/game_state.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';
import 'package:explosive_tetris/game_engine/models/level_template.dart';
import 'package:explosive_tetris/game_engine/rules/randomizer.dart';

void main() {
  group('GameState initial', () {
    late GameState state;

    setUp(() {
      state = GameState(
        board: Board(10, 20),
        fallingPiece: null,
        phase: GamePhase.spawning,
        generator: FixedSequenceGenerator([PieceType.I]),
        level: defaultLevel,
      );
    });

    test('phase == spawning при создании', () {
      expect(state.phase, GamePhase.spawning);
    });

    test('fallingPiece == null при создании', () {
      expect(state.fallingPiece, isNull);
    });

    test('canArm == false при fallingPiece == null', () {
      expect(state.canArm, isFalse);
    });

    test('canDetonate == false при fallingPiece == null', () {
      expect(state.canDetonate, isFalse);
    });
  });

  group('GameState copyWith', () {
    late GameState state;

    setUp(() {
      state = GameState(
        board: Board(10, 20),
        fallingPiece: null,
        phase: GamePhase.spawning,
        generator: FixedSequenceGenerator([PieceType.I]),
        level: defaultLevel,
      );
    });

    test('copyWith(phase: lost) меняет phase', () {
      final newState = state.copyWith(phase: GamePhase.lost);
      expect(newState.phase, GamePhase.lost);
    });

    test('исходный state не изменился', () {
      state.copyWith(phase: GamePhase.lost);
      expect(state.phase, GamePhase.spawning);
    });
  });
}

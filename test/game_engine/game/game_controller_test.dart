import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/game/game_state.dart';
import 'package:explosive_tetris/game_engine/game/game_controller.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';
import 'package:explosive_tetris/game_engine/rules/randomizer.dart';

GameController _makeController({
  List<PieceType> sequence = const [PieceType.I],
  double gravityInterval = 0.5,
  Board? board,
}) {
  return GameController(
    initialState: GameState(
      board: board ?? Board(10, 20),
      fallingPiece: null,
      phase: GamePhase.spawning,
      generator: FixedSequenceGenerator(sequence),
    ),
    gravityInterval: gravityInterval,
  );
}

void main() {
  group('Spawn (tick step 2)', () {
    test('spawns piece and transitions to falling', () {
      final c = _makeController();
      c.tick(0.1);
      expect(c.state.phase, GamePhase.falling);
      expect(c.state.fallingPiece, isNotNull);
      expect(c.state.fallingPiece!.x, 3);
    });
  });

  group('Gravity (tick steps 3-4)', () {
    test('piece moves down after gravityInterval', () {
      final c = _makeController();
      c.tick(0.1); // spawn
      final yBefore = c.state.fallingPiece!.y;
      c.tick(0.5); // gravity
      expect(c.state.fallingPiece!.y, yBefore + 1);
    });
  });

  group('Lock (fixation)', () {
    test('piece locks when canMoveDown is false', () {
      final board = Board(10, 20);
      // I-piece at spawn: row 1, cols 3..6. Place blocks at row 2, cols 3..6.
      for (int x = 3; x <= 6; x++) {
        board.setCell(x, 2, const Cell.occupied());
      }
      final c = _makeController(board: board);
      c.tick(0.1); // spawn: I at y=0
      // I-piece occupies row 1 (y=1) at x=3..6. Below is row 2 which is blocked.
      // canMoveDown should be false, so gravity tick should lock.
      c.tick(0.5);
      expect(c.state.phase, GamePhase.spawning);
      expect(c.state.fallingPiece, isNull);
      // Check cells are occupied
      for (int x = 3; x <= 6; x++) {
        expect(board.isOccupied(x, 1), isTrue);
      }
    });
  });

  group('Loss on spawn', () {
    test('phase becomes lost when spawn position is blocked', () {
      final board = Board(10, 20);
      // Fill spawn area for I-piece: row 1, cols 3..6
      for (int x = 3; x <= 6; x++) {
        for (int y = 0; y <= 1; y++) {
          board.setCell(x, y, const Cell.occupied());
        }
      }
      final c = _makeController(board: board);
      c.tick(0.1);
      expect(c.state.phase, GamePhase.lost);
    });
  });

  group('won/lost no-op', () {
    test('tick does nothing when phase is won', () {
      final c = GameController(
        initialState: GameState(
          board: Board(10, 20),
          fallingPiece: null,
          phase: GamePhase.won,
          generator: FixedSequenceGenerator([PieceType.I]),
        ),
      );
      final stateBefore = c.state;
      c.tick(1.0);
      expect(c.state.phase, GamePhase.won);
      expect(c.state.fallingPiece, stateBefore.fallingPiece);
    });

    test('tick does nothing when phase is lost', () {
      final c = GameController(
        initialState: GameState(
          board: Board(10, 20),
          fallingPiece: null,
          phase: GamePhase.lost,
          generator: FixedSequenceGenerator([PieceType.I]),
        ),
      );
      c.tick(1.0);
      expect(c.state.phase, GamePhase.lost);
    });
  });

  group('moveLeft / moveRight', () {
    test('moveLeft decreases x by 1', () {
      final c = _makeController();
      c.tick(0.1); // spawn
      final xBefore = c.state.fallingPiece!.x;
      c.moveLeft();
      expect(c.state.fallingPiece!.x, xBefore - 1);
    });

    test('moveLeft at left wall is no-op', () {
      final c = _makeController();
      c.tick(0.1); // spawn at x=3
      // Move left until wall
      for (int i = 0; i < 10; i++) {
        c.moveLeft();
      }
      final x = c.state.fallingPiece!.x;
      c.moveLeft();
      expect(c.state.fallingPiece!.x, x);
    });

    test('moveRight at right wall is no-op', () {
      final c = _makeController();
      c.tick(0.1); // spawn at x=3
      // Move right until wall
      for (int i = 0; i < 10; i++) {
        c.moveRight();
      }
      final x = c.state.fallingPiece!.x;
      c.moveRight();
      expect(c.state.fallingPiece!.x, x);
    });
  });

  group('rotateCW', () {
    test('rotateCW changes piece shape for T-piece', () {
      final c = _makeController(sequence: [PieceType.T]);
      c.tick(0.1); // spawn
      final matrixBefore = c.state.fallingPiece!.piece.matrix;
      c.rotateCW();
      final matrixAfter = c.state.fallingPiece!.piece.matrix;
      expect(matrixAfter, isNot(equals(matrixBefore)));
    });

    test('rotateCW is no-op when rotation causes collision', () {
      // Place I-piece near right wall where rotation would collide
      final c = _makeController(sequence: [PieceType.I]);
      c.tick(0.1); // spawn at x=3
      // Move to right wall
      for (int i = 0; i < 10; i++) {
        c.moveRight();
      }
      // I-piece horizontal at right edge; rotating would go out of bounds
      c.rotateCW();
      expect(c.state.fallingPiece, isNotNull);
    });
  });

  group('softDrop', () {
    test('softDrop causes gravity step on next tick(0.0)', () {
      final c = _makeController();
      c.tick(0.1); // spawn
      final yBefore = c.state.fallingPiece!.y;
      c.softDrop();
      c.tick(0.0); // should trigger gravity
      expect(c.state.fallingPiece!.y, yBefore + 1);
    });
  });
}

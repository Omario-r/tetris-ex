import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/game_engine/game/game_state.dart';
import 'package:explosive_tetris/game_engine/game/game_controller.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/falling_piece.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';
import 'package:explosive_tetris/game_engine/models/level_template.dart';
import 'package:explosive_tetris/game_engine/models/target_mask.dart';
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
      level: defaultLevel,
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
          level: defaultLevel,
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
          level: defaultLevel,
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
    test('softDrop in phase=spawning is no-op', () {
      final c = _makeController();
      // phase is spawning, no fallingPiece
      expect(c.state.phase, GamePhase.spawning);
      c.softDrop();
      // state should not change
      expect(c.state.phase, GamePhase.spawning);
      expect(c.state.fallingPiece, isNull);
    });
    test('softDrop in phase=falling sets _gravityAccum to gravityInterval', () {
      final c = _makeController(gravityInterval: 0.5);
      c.tick(0.1); // spawn → falling
      final yBefore = c.state.fallingPiece!.y;
      c.softDrop();
      c.tick(0.0); // gravityAccum >= gravityInterval → gravity step
      expect(c.state.fallingPiece!.y, yBefore + 1);
    });
  });
  group('moveLeft no-op cases', () {
    test('moveLeft in phase=spawning is no-op', () {
      final c = _makeController();
      expect(c.state.phase, GamePhase.spawning);
      c.moveLeft();
      expect(c.state.phase, GamePhase.spawning);
      expect(c.state.fallingPiece, isNull);
    });
    test('moveLeft in phase=won is no-op', () {
      final c = GameController(
        initialState: GameState(
          board: Board(10, 20),
          fallingPiece: null,
          phase: GamePhase.won,
          generator: FixedSequenceGenerator([PieceType.I]),
          level: defaultLevel,
        ),
      );
      c.moveLeft();
      expect(c.state.phase, GamePhase.won);
      expect(c.state.fallingPiece, isNull);
    });
  });
  group('moveRight no-op cases', () {
    test('moveRight at right wall is no-op (x does not change)', () {
      final c = _makeController(sequence: [PieceType.I]);
      c.tick(0.1); // spawn
      // Move right until wall
      for (int i = 0; i < 10; i++) {
        c.moveRight();
      }
      final xAtWall = c.state.fallingPiece!.x;
      c.moveRight();
      expect(c.state.fallingPiece!.x, xAtWall);
    });
  });
  group('rotateCW additional cases', () {
    test('rotateCW changes piece shape in free space', () {
      final c = _makeController(sequence: [PieceType.T]);
      c.tick(0.1); // spawn
      final matrixBefore = c.state.fallingPiece!.piece.matrix;
      c.rotateCW();
      final matrixAfter = c.state.fallingPiece!.piece.matrix;
      expect(matrixAfter, isNot(equals(matrixBefore)));
    });
    test('rotateCW at wall where rotation is impossible is no-op', () {
      // Place blocks around I-piece so rotation is blocked
      final board = Board(10, 20);
      // I-piece spawns at x=3, y=1 (row 1). Block cells at row 0 and row 2
      // around x=3..6 to prevent vertical rotation
      for (int x = 3; x <= 6; x++) {
        board.setCell(x, 2, const Cell.occupied());
      }
      final c = _makeController(sequence: [PieceType.I], board: board);
      c.tick(0.1); // spawn horizontal I at x=3, y=1
      final matrixBefore = c.state.fallingPiece!.piece.matrix;
      c.rotateCW(); // vertical I would need rows 0..3 at col 3+, but row 2 blocked
      expect(c.state.fallingPiece!.piece.matrix, equals(matrixBefore));
    });
  });

  group('armExplosive', () {
    test('базовый: mode == explosive, armedUsed == true', () {
      final c = _makeController();
      c.tick(0.1); // spawn → falling
      c.armExplosive();
      expect(c.state.fallingPiece!.mode, PieceMode.explosive);
      expect(c.state.fallingPiece!.armedUsed, isTrue);
    });

    test('no-op при повторном вызове', () {
      final c = _makeController();
      c.tick(0.1);
      c.armExplosive();
      c.armExplosive();
      expect(c.state.fallingPiece!.mode, PieceMode.explosive);
      expect(c.state.fallingPiece!.armedUsed, isTrue);
    });

    test('no-op в phase=spawning', () {
      final c = _makeController();
      // phase == spawning, fallingPiece == null
      c.armExplosive();
      expect(c.state.phase, GamePhase.spawning);
      expect(c.state.fallingPiece, isNull);
    });

    test('canArm/canDetonate флаги', () {
      final c = _makeController();
      c.tick(0.1);
      expect(c.state.canArm, isTrue);
      expect(c.state.canDetonate, isFalse);
      c.armExplosive();
      expect(c.state.canArm, isFalse);
      expect(c.state.canDetonate, isTrue);
    });
  });

  group('Explosive падение', () {
    test('проходит сквозь блоки', () {
      final board = Board(10, 20);
      final c = _makeController(sequence: [PieceType.O], board: board);
      c.tick(0.1); // spawn O at x=3, y=0
      c.armExplosive();
      final yBefore = c.state.fallingPiece!.y;
      // Ставим блок прямо под фигурой
      board.setCell(3, yBefore + 2, const Cell.occupied());
      board.setCell(4, yBefore + 2, const Cell.occupied());
      c.tick(0.5); // gravity tick
      expect(c.state.fallingPiece!.y, greaterThan(yBefore));
      // Блок на board остался на месте
      expect(board.isOccupied(3, yBefore + 2), isTrue);
    });

    test('авто-детонация на дне → phase=spawning, fallingPiece=null', () {
      final board = Board(10, 20);
      final c = _makeController(sequence: [PieceType.O], board: board);
      c.tick(0.1); // spawn
      c.armExplosive();
      // Перемещаем фигуру вручную на дно через copyWith недоступно снаружи,
      // поэтому тикаем много раз пока не достигнем дна
      for (int i = 0; i < 40; i++) {
        if (c.state.phase != GamePhase.falling) break;
        c.tick(0.5);
      }
      expect(c.state.phase, GamePhase.spawning);
      expect(c.state.fallingPiece, isNull);
    });
  });

  group('detonate()', () {
    test('7) базовый: взрыв удаляет клетки под фигурой, phase=spawning', () {
      final board = Board(10, 20);
      final c = _makeController(sequence: [PieceType.I], board: board);
      c.tick(0.1); // spawn: I-piece at y=0, boardCells row=1 → y=1, x=3..6
      c.armExplosive();
      // Ставим occupied под фигурой (row 1, cols 3..6)
      for (int x = 3; x <= 6; x++) {
        board.setCell(x, 1, const Cell.occupied());
      }
      c.detonate();
      // Клетки под фигурой стали empty
      for (int x = 3; x <= 6; x++) {
        expect(board.isOccupied(x, 1), isFalse,
            reason: 'Cell ($x,1) should be empty after detonate');
      }
      expect(c.state.phase, GamePhase.spawning);
      expect(c.state.fallingPiece, isNull);
    });

    test('8) no-op в Normal-режиме', () {
      final c = _makeController(sequence: [PieceType.I]);
      c.tick(0.1); // spawn
      expect(c.state.fallingPiece!.mode, PieceMode.normal);
      c.detonate();
      expect(c.state.phase, GamePhase.falling);
      expect(c.state.fallingPiece, isNotNull);
    });

    test('9) no-op при phase=spawning', () {
      final c = _makeController(sequence: [PieceType.I]);
      // phase=spawning изначально
      expect(c.state.phase, GamePhase.spawning);
      c.detonate();
      expect(c.state.phase, GamePhase.spawning);
    });

    test('10) авто-детонация применяет взрыв: occupied клетки стали empty', () {
      final board = Board(10, 20);
      final c = _makeController(sequence: [PieceType.I], board: board);
      c.tick(0.1); // spawn
      c.armExplosive();
      // Тикаем до дна
      for (int i = 0; i < 40; i++) {
        if (c.state.phase != GamePhase.falling) break;
        // Ставим occupied в последней строке под фигурой перед последним тиком
        final fp = c.state.fallingPiece;
        if (fp != null) {
          for (final cell in fp.boardCells) {
            if (cell.y == board.height - 1 && board.isInside(cell.x, cell.y)) {
              board.setCell(cell.x, cell.y, const Cell.occupied());
            }
          }
        }
        c.tick(0.5);
      }
      expect(c.state.phase, GamePhase.spawning);
      expect(c.state.fallingPiece, isNull);
      // Все клетки последней строки в колонках I-piece должны быть пустыми
      for (int x = 3; x <= 6; x++) {
        expect(board.isOccupied(x, board.height - 1), isFalse);
      }
    });
  });

  group('checkWin — победа после фиксации', () {
    test('phase == won после фиксации, если все S заняты и H пуст', () {
      // S = row 19 (bottom), cols 3..6. I-piece locks there when hitting bottom.
      // I-piece matrix row 1 = XXXX. At y=18, boardCells y=19. canMoveDown → y=19 → row 20 out of bounds → locks.
      final mask = TargetMask(width: 4, height: 1, mask: 0xF);
      final level2 = LevelTemplate(
        boardWidth: 10,
        boardHeight: 20,
        targetMask: mask,
        targetX: 3,
        targetY: 19,
      );
      final board2 = Board(10, 20);
      final c = GameController(
        initialState: GameState(
          board: board2,
          fallingPiece: null,
          phase: GamePhase.spawning,
          generator: FixedSequenceGenerator([PieceType.I]),
          level: level2,
        ),
        gravityInterval: 0.5,
      );
      c.tick(0.1); // spawn
      // Drop to bottom
      for (int i = 0; i < 40; i++) {
        if (c.state.phase != GamePhase.falling) break;
        c.tick(0.5);
      }
      expect(c.state.phase, GamePhase.won);
      // Next tick is no-op
      c.tick(0.5);
      expect(c.state.phase, GamePhase.won);
    });
  });

  group('checkWin — победа после detonate()', () {
    test('phase == won после взрыва, если все S заняты и H пуст', () {
      // S = row 19 (bottom), cols 3..6. Pre-fill S. Explosive I-piece detonates above (no overlap with S).
      final mask = TargetMask(width: 4, height: 1, mask: 0xF);
      final level = LevelTemplate(
        boardWidth: 10,
        boardHeight: 20,
        targetMask: mask,
        targetX: 3,
        targetY: 19,
      );
      final board = Board(10, 20);
      // Fill S
      for (final (x, y) in level.S) {
        board.setCell(x, y, const Cell.occupied());
      }
      // H around S should be empty — check no occupied in H
      final c = GameController(
        initialState: GameState(
          board: board,
          fallingPiece: null,
          phase: GamePhase.spawning,
          generator: FixedSequenceGenerator([PieceType.I]),
          level: level,
        ),
        gravityInterval: 0.5,
      );
      c.tick(0.1); // spawn
      c.armExplosive();
      c.detonate(); // explode at top, S still filled, H empty
      expect(c.state.phase, GamePhase.won);
    });
  });

  group('checkWin — без победы', () {
    test('после фиксации S не заполнено → phase == spawning', () {
      final c = _makeController(sequence: [PieceType.I, PieceType.I]);
      c.tick(0.1); // spawn
      // Lock by dropping to bottom — defaultLevel S is large, one I won't fill it
      for (int i = 0; i < 40; i++) {
        if (c.state.phase != GamePhase.falling) break;
        c.tick(0.5);
      }
      expect(c.state.phase, GamePhase.spawning);
    });
  });

  group('dirtyHalo', () {
    test('все H пусты → dirtyHalo пустой', () {
      final c = _makeController();
      expect(c.state.dirtyHalo, isEmpty);
    });

    test('один блок в H → dirtyHalo содержит эту клетку', () {
      final board = Board(10, 20);
      final hCell = defaultLevel.H.first;
      board.setCell(hCell.$1, hCell.$2, const Cell.occupied());
      final c = _makeController(board: board);
      expect(c.state.dirtyHalo, contains(hCell));
      expect(c.state.dirtyHalo.length, 1);
    });
  });
}

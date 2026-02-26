import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explosive_tetris/game_engine/game/game_state.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/falling_piece.dart';
import 'package:explosive_tetris/game_engine/models/level_template.dart';
import 'package:explosive_tetris/game_engine/models/piece.dart';
import 'package:explosive_tetris/game_engine/rules/randomizer.dart';
import 'package:explosive_tetris/presentation/widgets/board_painter.dart';

/// Creates a [GameState] with an empty board and no falling piece.
GameState createEmptyState() {
  return GameState(
    board: Board(defaultLevel.boardWidth, defaultLevel.boardHeight),
    fallingPiece: null,
    phase: GamePhase.spawning,
    generator: SevenBagGenerator(seed: 42),
    level: defaultLevel,
  );
}

/// Creates a [GameState] with a block placed in the Halo region.
GameState createStateWithHaloBlock() {
  final board = Board(defaultLevel.boardWidth, defaultLevel.boardHeight);
  // Place a block in one of the Halo cells (e.g., first cell in H set)
  final haloCell = defaultLevel.H.first;
  board.setCell(haloCell.$1, haloCell.$2, const Cell.occupied());
  return GameState(
    board: board,
    fallingPiece: null,
    phase: GamePhase.spawning,
    generator: SevenBagGenerator(seed: 42),
    level: defaultLevel,
  );
}

/// Creates a [GameState] with an explosive I-piece at the specified position.
GameState createStateWithExplosivePiece(int x, int y) {
  final board = Board(defaultLevel.boardWidth, defaultLevel.boardHeight);
  final piece = PieceFactory.create(PieceType.I);
  final fallingPiece = FallingPiece(
    piece: piece,
    x: x,
    y: y,
    mode: PieceMode.explosive,
  );
  return GameState(
    board: board,
    fallingPiece: fallingPiece,
    phase: GamePhase.falling,
    generator: SevenBagGenerator(seed: 42),
    level: defaultLevel,
  );
}

void main() {
  group('BoardPainter', () {
    testWidgets('paints_without_exception', (WidgetTester tester) async {
      final state = createEmptyState();
      final painter = BoardPainter(state: state, cellSize: 30.0);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(300.0, 600.0)),
        returnsNormally,
      );
    });

    test('shouldRepaint_false_same_state', () {
      final state = createEmptyState();
      final painter1 = BoardPainter(state: state, cellSize: 30.0);
      final painter2 = BoardPainter(state: state, cellSize: 30.0);

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint_true_different_state', () {
      final emptyState = createEmptyState();
      final stateWithBlock = createStateWithHaloBlock();

      final painter1 = BoardPainter(state: emptyState, cellSize: 30.0);
      final painter2 = BoardPainter(state: stateWithBlock, cellSize: 30.0);

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    testWidgets('explosive_piece_does_not_throw', (WidgetTester tester) async {
      final state = createStateWithExplosivePiece(3, 0);
      final painter = BoardPainter(state: state, cellSize: 30.0, animValue: 0.5);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(300.0, 600.0)),
        returnsNormally,
      );
    });

    testWidgets('dirty_halo_does_not_throw', (WidgetTester tester) async {
      final state = createStateWithHaloBlock();
      final painter = BoardPainter(state: state, cellSize: 30.0);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(300.0, 600.0)),
        returnsNormally,
      );
    });
  });
}

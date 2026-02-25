import '../models/board.dart';
import '../models/falling_piece.dart';
import '../models/piece.dart';
import '../rules/collision.dart';
import 'game_state.dart';

class GameController {
  GameState _state;
  double _gravityAccum = 0.0;
  final double gravityInterval;

  GameController({
    required GameState initialState,
    this.gravityInterval = 0.5,
  }) : _state = initialState;

  GameState get state => _state;

  void moveLeft() {
    final fp = _state.fallingPiece;
    if (fp == null || _state.phase != GamePhase.falling) return;
    if (CollisionDetector.canMove(fp, _state.board, -1, 0)) {
      _state = _state.copyWith(fallingPiece: fp.copyWith(x: fp.x - 1));
    }
  }

  void moveRight() {
    final fp = _state.fallingPiece;
    if (fp == null || _state.phase != GamePhase.falling) return;
    if (CollisionDetector.canMove(fp, _state.board, 1, 0)) {
      _state = _state.copyWith(fallingPiece: fp.copyWith(x: fp.x + 1));
    }
  }

  void rotateCW() {
    final fp = _state.fallingPiece;
    if (fp == null || _state.phase != GamePhase.falling) return;
    if (CollisionDetector.canRotateCW(fp, _state.board)) {
      _state = _state.copyWith(
        fallingPiece: fp.copyWith(piece: fp.piece.rotateCW()),
      );
    }
  }

  void softDrop() {
    if (_state.fallingPiece == null || _state.phase != GamePhase.falling) return;
    _gravityAccum = gravityInterval;
  }

  void armExplosive() {
    // Stub — no-op (реализуем в D1)
  }

  void detonate() {
    // Stub — no-op (реализуем в D2)
  }

  void tick(double dt) {
    // Step 1
    if (_state.phase == GamePhase.won || _state.phase == GamePhase.lost) return;

    // Step 2
    if (_state.phase == GamePhase.spawning) {
      _gravityAccum = 0.0;
      final type = _state.generator.next();
      final fp = FallingPiece(
        piece: PieceFactory.create(type),
        x: 3,
        y: 0,
        mode: PieceMode.normal,
        armedUsed: false,
      );
      if (!CollisionDetector.isValidPosition(fp, _state.board)) {
        _state = _state.copyWith(phase: GamePhase.lost);
        return;
      }
      _state = _state.copyWith(
        fallingPiece: fp,
        phase: GamePhase.falling,
      );
      return;
    }

    // Step 3
    _gravityAccum += dt;
    if (_gravityAccum < gravityInterval) return;
    _gravityAccum -= gravityInterval;

    // Step 4 — Normal mode
    final fp = _state.fallingPiece!;
    if (fp.mode == PieceMode.normal) {
      if (CollisionDetector.canMoveDown(fp, _state.board)) {
        _state = _state.copyWith(fallingPiece: fp.copyWith(y: fp.y + 1));
      } else {
        // Lock piece
        final board = _state.board;
        for (final cell in fp.boardCells) {
          if (cell.y >= 0 && cell.y < board.height &&
              cell.x >= 0 && cell.x < board.width) {
            board.setCell(cell.x, cell.y, const Cell.occupied());
          }
        }
        _state = _state.copyWith(
          board: board,
          phase: GamePhase.spawning,
          clearFallingPiece: true,
        );
      }
    }
  }
}

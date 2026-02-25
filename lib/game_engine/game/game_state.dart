import '../models/board.dart';
import '../models/falling_piece.dart';
import '../rules/randomizer.dart';

enum GamePhase { spawning, falling, won, lost }

class GameState {
  final Board board;
  final FallingPiece? fallingPiece;
  final GamePhase phase;
  final PieceGenerator generator;

  const GameState({
    required this.board,
    required this.fallingPiece,
    required this.phase,
    required this.generator,
  });

  GameState copyWith({
    Board? board,
    FallingPiece? fallingPiece,
    GamePhase? phase,
    PieceGenerator? generator,
    bool clearFallingPiece = false,
  }) {
    return GameState(
      board: board ?? this.board,
      fallingPiece: clearFallingPiece ? null : (fallingPiece ?? this.fallingPiece),
      phase: phase ?? this.phase,
      generator: generator ?? this.generator,
    );
  }

  bool get canArm =>
      fallingPiece != null &&
      fallingPiece!.mode == PieceMode.normal &&
      !fallingPiece!.armedUsed;

  bool get canDetonate =>
      fallingPiece != null &&
      fallingPiece!.mode == PieceMode.explosive;
}

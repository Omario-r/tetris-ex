import '../models/board.dart';
import '../models/falling_piece.dart';
import '../models/level_template.dart';
import '../rules/randomizer.dart';

enum GamePhase { spawning, falling, won, lost }

class GameState {
  final Board board;
  final FallingPiece? fallingPiece;
  final GamePhase phase;
  final PieceGenerator generator;
  final LevelTemplate level;

  const GameState({
    required this.board,
    required this.fallingPiece,
    required this.phase,
    required this.generator,
    required this.level,
  });

  GameState copyWith({
    Board? board,
    FallingPiece? fallingPiece,
    GamePhase? phase,
    PieceGenerator? generator,
    LevelTemplate? level,
    bool clearFallingPiece = false,
  }) {
    return GameState(
      board: board ?? this.board,
      fallingPiece: clearFallingPiece ? null : (fallingPiece ?? this.fallingPiece),
      phase: phase ?? this.phase,
      generator: generator ?? this.generator,
      level: level ?? this.level,
    );
  }

  Set<(int, int)> get dirtyHalo =>
      level.H.where((cell) => board.isOccupied(cell.$1, cell.$2)).toSet();

  bool get canArm =>
      fallingPiece != null &&
      fallingPiece!.mode == PieceMode.normal &&
      !fallingPiece!.armedUsed;

  bool get canDetonate =>
      fallingPiece != null &&
      fallingPiece!.mode == PieceMode.explosive;
}

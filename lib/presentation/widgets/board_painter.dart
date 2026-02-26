import 'package:flutter/material.dart';
import '../../game_engine/game/game_state.dart';
import '../../game_engine/models/board.dart';
import '../../game_engine/models/falling_piece.dart';
import '../../game_engine/models/piece.dart';

class BoardPainter extends CustomPainter {
  const BoardPainter({
    required this.state,
    required this.cellSize,
    this.animValue = 0.0,
  });

  final GameState state;
  final double cellSize;
  final double animValue;

  static const Map<PieceType, Color> pieceColors = {
    PieceType.I: Colors.cyan,
    PieceType.O: Colors.yellow,
    PieceType.T: Colors.purple,
    PieceType.S: Colors.green,
    PieceType.Z: Colors.red,
    PieceType.J: Colors.blue,
    PieceType.L: Colors.orange,
  };

  Rect _cellRect(int x, int y) {
    return Rect.fromLTWH(
      x * cellSize,
      y * cellSize,
      cellSize - 1,
      cellSize - 1,
    );
  }

  List<({int x, int y})> _ghostCells(FallingPiece fp, Board board) {
    var ghostY = fp.y;
    while (true) {
      final nextY = ghostY + 1;
      bool canMove = true;
      for (final cell in fp.piece.cells) {
        final bx = fp.x + cell.x;
        final by = nextY + cell.y;
        if (by >= board.height || board.isOccupied(bx, by)) {
          canMove = false;
          break;
        }
      }
      if (!canMove) break;
      ghostY = nextY;
    }
    return fp.piece.cells
        .map((cell) => (x: fp.x + cell.x, y: ghostY + cell.y))
        .toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final board = state.board;
    final fp = state.fallingPiece;

    // a. Background
    final bgPaint = Paint()..color = Colors.grey.shade800;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, board.width * cellSize, board.height * cellSize),
      bgPaint,
    );

    // b. S zone (target)
    final sPaint = Paint()
      ..color = const Color(0xFF2962FF).withValues(alpha: 0.18);
    for (final cell in state.level.S) {
      canvas.drawRect(_cellRect(cell.$1, cell.$2), sPaint);
    }

    // c. Halo H
    final dirtyHalo = state.dirtyHalo;
    final haloPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.35);
    for (final cell in state.level.H) {
      if (dirtyHalo.contains(cell)) {
        canvas.drawRect(_cellRect(cell.$1, cell.$2), haloPaint);
      }
    }

    // d. Placed blocks
    final blockPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int y = 0; y < board.height; y++) {
      for (int x = 0; x < board.width; x++) {
        if (board.isOccupied(x, y)) {
          blockPaint.color = Colors.blueGrey;
          final rect = _cellRect(x, y);
          canvas.drawRect(rect, blockPaint);
          canvas.drawRect(rect, borderPaint);
        }
      }
    }

    if (fp != null) {
      final color = pieceColors[fp.piece.type] ?? Colors.white;

      // g. Ghost piece (Normal only)
      if (fp.mode == PieceMode.normal) {
        final ghostPaint = Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        for (final cell in _ghostCells(fp, board)) {
          canvas.drawRect(_cellRect(cell.x, cell.y), ghostPaint);
        }
      }

      // e/f. Falling piece
      if (fp.mode == PieceMode.normal) {
        // e. Normal
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final strokePaint = Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        for (final cell in fp.boardCells) {
          final rect = _cellRect(cell.x, cell.y);
          canvas.drawRect(rect, fillPaint);
          canvas.drawRect(rect, strokePaint);
        }
      } else {
        // f. Explosive
        final fillPaint = Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.fill;
        final strokeColor = Color.lerp(Colors.orange, Colors.red, animValue)!;
        final strokeWidth = lerpDouble(1.5, 3.0, animValue);
        final strokePaint = Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
        for (final cell in fp.boardCells) {
          final rect = _cellRect(cell.x, cell.y);
          canvas.drawRect(rect, fillPaint);
          canvas.drawRect(rect, strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return state != oldDelegate.state;
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;

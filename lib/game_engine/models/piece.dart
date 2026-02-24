/// Represents the type of tetromino piece.
enum PieceType { I, O, T, S, Z, J, L }

/// Represents a tetromino in a local 4×4 matrix.
class Piece {
  final PieceType type;
  final List<List<bool>> matrix; // 4×4, true = occupied

  const Piece(this.type, this.matrix);

  /// Returns a new Piece rotated clockwise (CW).
  /// Algorithm: transpose the 4×4 matrix, then reverse each row.
  Piece rotateCW() {
    // Create new 4x4 matrix
    final newMatrix = List.generate(4, (_) => List.filled(4, false));

    // Transpose: newMatrix[i][j] = matrix[j][i]
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        newMatrix[i][j] = matrix[j][i];
      }
    }

    // Reverse each row
    for (int i = 0; i < 4; i++) {
      newMatrix[i] = newMatrix[i].reversed.toList();
    }

    return Piece(type, newMatrix);
  }

  /// List of occupied cells (x,y) relative to (0,0) of the matrix.
  List<({int x, int y})> get cells {
    final result = <({int x, int y})>[];
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        if (matrix[y][x]) {
          result.add((x: x, y: y));
        }
      }
    }
    return result;
  }
}

/// Factory for creating initial forms of the 7 tetromino pieces.
class PieceFactory {
  /// Creates a piece of the specified type in its initial form.
  static Piece create(PieceType type) {
    switch (type) {
      case PieceType.I:
        return Piece(type, [
          [false, false, false, false],
          [true,  true,  true,  true ],
          [false, false, false, false],
          [false, false, false, false],
        ]);

      case PieceType.O:
        return Piece(type, [
          [false, true,  true,  false],
          [false, true,  true,  false],
          [false, false, false, false],
          [false, false, false, false],
        ]);

      case PieceType.T:
        return Piece(type, [
          [true,  true,  true,  false],
          [false, true,  false, false],
          [false, false, false, false],
          [false, false, false, false],
        ]);

      case PieceType.S:
        return Piece(type, [
          [false, true,  true,  false],
          [true,  true,  false, false],
          [false, false, false, false],
          [false, false, false, false],
        ]);

      case PieceType.Z:
        return Piece(type, [
          [true,  true,  false, false],
          [false, true,  true,  false],
          [false, false, false, false],
          [false, false, false, false],
        ]);

      case PieceType.J:
        return Piece(type, [
          [true,  false, false, false],
          [true,  true,  true,  false],
          [false, false, false, false],
          [false, false, false, false],
        ]);

      case PieceType.L:
        return Piece(type, [
          [false, false, true,  false],
          [true,  true,  true,  false],
          [false, false, false, false],
          [false, false, false, false],
        ]);
    }
  }
}

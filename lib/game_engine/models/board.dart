/// Represents the state of a cell on the game board.
enum CellState { empty, occupied }

/// Represents a single cell on the game board.
class Cell {
  final CellState state;

  const Cell.empty() : state = CellState.empty;
  const Cell.occupied() : state = CellState.occupied;

  bool get isEmpty => state == CellState.empty;
  bool get isOccupied => state == CellState.occupied;
}

/// Stores the state of the game field (grid width×height).
class Board {
  final int width;
  final int height;
  late final List<List<Cell>> _grid;

  /// Creates a new board with all cells initially empty.
  Board(this.width, this.height) {
    _grid = List.generate(
      height,
      (y) => List.generate(width, (x) => const Cell.empty()),
    );
  }

  /// Private constructor for copyWith method.
  Board._internal(this.width, this.height, this._grid);

  /// Returns true if (x,y) is inside the board boundaries.
  bool isInside(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  /// Returns the Cell at coordinates (x,y). Assumes (x,y) is inside the board.
  Cell getCell(int x, int y) {
    assert(isInside(x, y), 'Coordinates ($x, $y) are outside board bounds');
    return _grid[y][x];
  }

  /// Sets the Cell at coordinates (x,y). Assumes (x,y) is inside the board.
  void setCell(int x, int y, Cell cell) {
    assert(isInside(x, y), 'Coordinates ($x, $y) are outside board bounds');
    _grid[y][x] = cell;
  }

  /// Returns true if the cell is inside the board and occupied.
  /// Returns false if outside the board or empty.
  bool isOccupied(int x, int y) {
    if (!isInside(x, y)) return false;
    return _grid[y][x].isOccupied;
  }

  /// Clears the entire board (makes all cells empty).
  void clear() {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        _grid[y][x] = const Cell.empty();
      }
    }
  }

  /// Creates a deep copy of the Board (new grid, but same CellState values).
  Board copyWith() {
    final newGrid = List.generate(
      height,
      (y) => List.generate(width, (x) => _grid[y][x]),
    );
    return Board._internal(width, height, newGrid);
  }
}

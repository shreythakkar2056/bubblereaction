import 'cell.dart';

/// Represents the game grid and handles cell interactions and explosions.
class Grid {
  final int rows;
  final int cols;
  late List<List<Cell>> cells;

  Grid({this.rows = 9, this.cols = 6}) {
    cells = List.generate(rows, (r) => List.generate(cols, (c) => Cell(
      row: r,
      col: c,
      criticalMass: _calculateCriticalMass(r, c),
    )));
  }

  /// Calculates the critical mass for a cell based on its position.
  int _calculateCriticalMass(int row, int col) {
    if ((row == 0 || row == rows - 1) && (col == 0 || col == cols - 1)) {
      return 2; // Corner
    } else if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
      return 3; // Edge
    } else {
      return 4; // Center
    }
  }

  /// Returns the cell at the given position.
  Cell getCell(int row, int col) => cells[row][col];

  /// Returns a list of valid adjacent cell positions.
  List<Cell> getAdjacentCells(int row, int col) {
    final List<Cell> adj = [];
    if (row > 0) adj.add(cells[row - 1][col]);
    if (row < rows - 1) adj.add(cells[row + 1][col]);
    if (col > 0) adj.add(cells[row][col - 1]);
    if (col < cols - 1) adj.add(cells[row][col + 1]);
    return adj;
  }
} 
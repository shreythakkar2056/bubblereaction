import 'player.dart';

/// Represents a single cell in the Chain Reaction grid.
class Cell {
  /// Row position of the cell.
  final int row;

  /// Column position of the cell.
  final int col;

  /// The player who owns this cell, or null if empty.
  Player? owner;

  /// Number of orbs currently in this cell.
  int orbCount;

  /// The critical mass for this cell (when it explodes).
  final int criticalMass;

  Cell({
    required this.row,
    required this.col,
    this.owner,
    this.orbCount = 0,
    required this.criticalMass,
  });

  /// Alias for criticalMass to match maxCapacity API
  int get maxCapacity => criticalMass;

  /// Returns the owner player id, or null if empty
  int? get ownerId => owner?.id;

  /// Add an orb and set owner
  void addOrb(int playerId) {
    orbCount++;
    if (owner == null || owner!.id != playerId) {
      owner = Player(id: playerId, color: ''); // color is not used here
    }
  }

  /// Remove n orbs
  void removeOrbs(int n) {
    orbCount -= n;
    if (orbCount < 0) orbCount = 0;
  }

  /// Clear the owner
  void clearOwner() {
    owner = null;
  }

  /// Returns true if the cell is empty
  bool isEmpty() => orbCount == 0;

  /// Reset the cell to empty
  void reset() {
    orbCount = 0;
    owner = null;
  }

  /// Returns true if the cell is at or above critical mass.
  bool get isCritical => orbCount >= criticalMass;
} 
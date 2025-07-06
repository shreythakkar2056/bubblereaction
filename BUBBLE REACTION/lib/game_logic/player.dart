/// Represents a player in the Chain Reaction game.
class Player {
  /// Unique identifier for the player.
  final int id;

  /// Color associated with the player (as a string for now, can be improved later).
  final String color;

  /// Whether the player is still active in the game.
  bool isActive;

  Player({required this.id, required this.color, this.isActive = true});

  /// Eliminate the player
  void eliminate() {
    isActive = false;
  }

  /// Reset the player to active
  void reset() {
    isActive = true;
  }
} 
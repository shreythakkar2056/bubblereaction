import 'player.dart';

/// Enum representing the current status of the game.
enum GameStatus { inProgress, finished }

/// Tracks the current state of the game, including turn and status.
class GameState {
  /// Index of the current player's turn.
  int currentPlayerIndex;

  /// Current status of the game.
  GameStatus status;

  /// List of players in the game.
  final List<Player> players;

  GameState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.status = GameStatus.inProgress,
  });

  /// Returns the current player.
  Player get currentPlayer => players[currentPlayerIndex];

  /// Mark the game as finished
  void finishGame(int winnerId) {
    status = GameStatus.finished;
  }

  /// Advance to the next player's turn
  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  /// Reset the game state
  void reset() {
    status = GameStatus.inProgress;
    currentPlayerIndex = 0;
  }

  /// Returns true if the game is finished
  bool isGameFinished() => status == GameStatus.finished;
} 
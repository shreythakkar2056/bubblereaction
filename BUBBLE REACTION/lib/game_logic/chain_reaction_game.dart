import 'player.dart';
import 'cell.dart';

/// Main controller for the Chain Reaction game logic.
class ChainReactionGame {
  static const int rows = 9;
  static const int cols = 6;
  late List<List<Cell>> board;
  final List<Player> players;

  /// Tracks the number of orbs each player owns.
  final Map<int, int> playerOrbCounts = {};

  int movesMade = 0;
  final Set<int> playersMoved = {};

  // Migrate GameState fields
  int currentPlayerIndex = 0;
  bool _isFinished = false;

  ChainReactionGame({
    int? rowsOverride,
    int? colsOverride,
    required List<String> playerColors,
  })  : players = List.generate(
          playerColors.length,
          (i) => Player(id: i, color: playerColors[i]),
        ) {
    _initializeBoard(rowsOverride, colsOverride);
    _initializePlayerOrbCounts();
  }

  Player get currentPlayer => players[currentPlayerIndex];
  bool isGameFinished() => _isFinished;

  void finishGame(int winnerId) {
    _isFinished = true;
  }

  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void resetGame() {
    // Reset board
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        board[r][c].reset();
      }
    }
    // Reset players
    for (var player in players) {
      player.reset();
    }
    // Reset game state
    currentPlayerIndex = 0;
    _isFinished = false;
    // Reset counters
    movesMade = 0;
    playersMoved.clear();
    // Reset orb counts
    _initializePlayerOrbCounts();
  }

  /// Initialize the game board
  void _initializeBoard(int? rowsOverride, int? colsOverride) {
    int boardRows = rowsOverride ?? rows;
    int boardCols = colsOverride ?? cols;
    board = List.generate(
      boardRows, 
      (r) => List.generate(
        boardCols, 
        (c) => Cell(row: r, col: c, criticalMass: _calculateMaxCapacity(r, c, boardRows, boardCols))
      )
    );
  }

  /// Initialize player orb counts
  void _initializePlayerOrbCounts() {
    for (var player in players) {
      playerOrbCounts[player.id] = 0;
    }
  }

  /// Calculate maximum capacity for a cell based on its position
  int _calculateMaxCapacity(int r, int c, int totalRows, int totalCols) {
    // Corner cells hold 1 orb max before explosion
    if ((r == 0 && c == 0) || 
        (r == 0 && c == totalCols - 1) ||
        (r == totalRows - 1 && c == 0) || 
        (r == totalRows - 1 && c == totalCols - 1)) {
      return 1;
    }
    // Edge cells hold 2 orbs max
    else if (r == 0 || r == totalRows - 1 || c == 0 || c == totalCols - 1) {
      return 2;
    }
    // Center cells hold 3 orbs max
    else {
      return 3;
    }
  }

  int get rowCount => board.length;
  int get colCount => board[0].length;

  /// Maximum orbs a cell can hold before exploding based on position
  int maxOrbs(int r, int c) {
    if (r < 0 || r >= rowCount || c < 0 || c >= colCount) return 0;
    return board[r][c].maxCapacity;
  }

  /// Check if move is valid (cell is empty or belongs to player)
  bool isValidMove(int r, int c, int playerId) {
    if (r < 0 || r >= rowCount || c < 0 || c >= colCount) return false;
    if (isGameFinished()) return false;
    Cell cell = board[r][c];
    return cell.isEmpty() || cell.ownerId == playerId;
  }

  /// Makes a move for the current player at the given cell.
  /// Returns true if the move was successful.
  bool makeMove(int r, int c) {
    _ensureActivePlayer();
    if (isGameFinished()) return false;
    final player = currentPlayer;
    if (!isValidMove(r, c, player.id)) return false;
    board[r][c].addOrb(player.id);
    _handleExplosions(r, c, player.id);
    _updatePlayerOrbCounts();
    playersMoved.add(player.id);
    movesMade++;
    if (movesMade >= players.length) {
      _checkEliminations();
      _checkWinCondition();
      _ensureActivePlayer(); // ensure after eliminations
    }
    if (!isGameFinished()) {
      nextPlayer();
      _ensureActivePlayer(); // ensure after advancing turn
    }
    return true;
  }

  /// Handle chain reaction explosions
  void _handleExplosions(int r, int c, int playerId) {
    _explode(r, c, playerId);
  }

  /// Chain reaction explosion function
  void _explode(int r, int c, int playerId) {
    if (r < 0 || r >= rowCount || c < 0 || c >= colCount) return;
    Cell cell = board[r][c];
    int limit = cell.maxCapacity;
    if (cell.orbCount <= limit) return;
    // Cell explodes - remove excess orbs
    int orbsToDistribute = limit + 1;
    cell.removeOrbs(orbsToDistribute);
    // If cell becomes empty, clear owner
    if (cell.isEmpty()) {
      cell.clearOwner();
    }
    // Spread to neighbors (up, down, left, right)
    final directions = [
      [-1, 0], // up
      [1, 0],  // down
      [0, -1], // left
      [0, 1]   // right
    ];
    for (var direction in directions) {
      int newR = r + direction[0];
      int newC = c + direction[1];
      if (newR >= 0 && newR < rowCount && newC >= 0 && newC < colCount) {
        board[newR][newC].addOrb(playerId);
        // Recursively explode if needed
        _explode(newR, newC, playerId);
      }
    }
  }

  /// Check if player still has orbs on board
  bool playerAlive(int playerId) {
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        if (board[r][c].ownerId == playerId) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns the winner's player ID, or null if the game is still in progress.
  int? getWinnerId() {
    if (movesMade < players.length) return null;
    List<int> alivePlayers = [];
    for (var player in players) {
      if (playerAlive(player.id)) {
        alivePlayers.add(player.id);
      }
    }
    if (alivePlayers.length == 1) {
      return alivePlayers.first;
    }
    return null;
  }

  /// Get winner player object
  Player? getWinner() {
    int? winnerId = getWinnerId();
    if (winnerId != null) {
      return players.firstWhere((player) => player.id == winnerId);
    }
    return null;
  }

  /// Updates the orb counts for each player.
  void _updatePlayerOrbCounts() {
    // Reset all counts to 0
    for (var playerId in playerOrbCounts.keys) {
      playerOrbCounts[playerId] = 0;
    }
    // Count orbs for each player
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        Cell cell = board[r][c];
        if (!cell.isEmpty()) {
          int? ownerId = cell.ownerId;
          if (ownerId != null) {
            playerOrbCounts[ownerId] = (playerOrbCounts[ownerId] ?? 0) + cell.orbCount;
          }
        }
      }
    }
  }

  /// Checks and eliminates players with 0 orbs.
  void _checkEliminations() {
    if (movesMade < players.length) return; // Don't eliminate in the first round
    for (var player in players) {
      // Only eliminate if player has played at least once
      if (!playerAlive(player.id) && playersMoved.contains(player.id)) {
        player.eliminate();
      }
    }
  }

  /// Checks if there is a winner and updates game status.
  void _checkWinCondition() {
    final winner = getWinnerId();
    if (winner != null) {
      finishGame(winner);
    }
  }

  /// Get cell at position
  Cell getCell(int r, int c) {
    if (r < 0 || r >= rowCount || c < 0 || c >= colCount) {
      throw ArgumentError('Invalid cell position: (r, c)');
    }
    return board[r][c];
  }

  /// For UI: get cell orb count
  int getCellCount(int r, int c) {
    return getCell(r, c).orbCount;
  }

  /// For UI: get cell owner player ID
  int? getCellPlayer(int r, int c) {
    return getCell(r, c).ownerId;
  }

  /// For UI: get cell owner player object
  Player? getCellOwner(int r, int c) {
    int? ownerId = getCellPlayer(r, c);
    if (ownerId != null) {
      return players.firstWhere((player) => player.id == ownerId);
    }
    return null;
  }

  /// Get player orb count
  int getPlayerOrbCount(int playerId) {
    return playerOrbCounts[playerId] ?? 0;
  }

  /// Get all active players
  List<Player> getActivePlayers() {
    return players.where((player) => player.isActive).toList();
  }

  /// Get all eliminated players
  List<Player> getEliminatedPlayers() {
    return players.where((player) => !player.isActive).toList();
  }

  /// Get current game status
  String getGameStatus() {
    if (isGameFinished()) {
      Player? winner = getWinner();
      return winner != null ? 'Game Over - ${winner.color} Wins!' : 'Game Over';
    } else {
      return 'Current Player: ${currentPlayer.color}';
    }
  }

  /// Check if it's a specific player's turn
  bool isPlayerTurn(int playerId) {
    return currentPlayer.id == playerId;
  }

  /// Get total moves made
  int getTotalMoves() {
    return movesMade;
  }

  /// Check if minimum moves have been made (for elimination checking)
  bool hasMinimumMoves() {
    return movesMade >= players.length;
  }

  /// Prints the current state of the board (for debugging/demo).
  void printBoard() {
    print('=== Chain Reaction Board ===');
    print('Current Player: ${currentPlayer.color}');
    print('Moves Made: $movesMade');
    print('');
    for (int r = 0; r < rowCount; r++) {
      String line = '';
      for (int c = 0; c < colCount; c++) {
        Cell cell = board[r][c];
        if (cell.isEmpty()) {
          line += '.'.padRight(6);
        } else {
          String playerColor = players[cell.ownerId!].color.substring(0, 1);
          line += '$playerColor:${cell.orbCount}'.padRight(6);
        }
      }
      print('$r | $line');
    }
    print('');
    print('Player Orb Counts:');
    for (var player in players) {
      String status = player.isActive ? 'Active' : 'Eliminated';
      print('${player.color}: ${getPlayerOrbCount(player.id)} orbs ($status)');
    }
    print('========================');
  }

  /// Get board as a 2D list for serialization
  List<List<Map<String, dynamic>>> getBoardState() {
    return board.map((row) => 
      row.map((cell) => {
        'orbCount': cell.orbCount,
        'ownerId': cell.ownerId,
        'maxCapacity': cell.maxCapacity,
      }).toList()
    ).toList();
  }

  void _ensureActivePlayer() {
    int safety = 0;
    while (!isGameFinished() && !currentPlayer.isActive && safety < players.length) {
      nextPlayer();
      safety++;
    }
  }
} 
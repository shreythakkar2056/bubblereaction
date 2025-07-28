import 'package:flutter/material.dart';
import '../game_logic/chain_reaction_game.dart';
import 'fancy_orb.dart';

class GameScreen extends StatefulWidget {
  final int playerCount;
  final bool aiEnabled;
  final String? aiMode;
  const GameScreen({super.key, required this.playerCount, this.aiEnabled = false, this.aiMode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ChainReactionGame _game;
  late List<Color> _playerColors;
  late List<String> _playerNames;
  bool get aiEnabled => widget.aiEnabled;
  String get aiMode => widget.aiMode ?? "easy";


  @override
  void initState() {
    super.initState();
    _playerColors = [
      const Color(0xFFFF3B3B), // Red
      const Color(0xFF3B7BFF), // Blue
      const Color(0xFF3BFF5A), // Green
      const Color(0xFFFFF23B), // Yellow
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
      Colors.brown,
    ];
    _playerNames = List.generate(widget.playerCount, (i) => 'PLAYER ${i + 1}');
    _game = ChainReactionGame(
      playerColors: _playerColors.take(widget.playerCount).map((c) => c.value.toRadixString(16)).toList(),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text('Are you sure you want to exit the game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showExitDialog() async {
    final shouldExit = await _onWillPop();
    if (shouldExit && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleCellTap(int row, int col) {
    _game.makeMove(row, col);
    setState(() {});
    if (_game.getWinnerId() != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Game Over'),
          content: Text('${_playerNames[_game.getWinnerId()!]} wins!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
      return;
    }
    // If AI mode is enabled and it's AI's turn, make AI move
    if (aiEnabled && _game.currentPlayer.id == 1 && _game.currentPlayer.isActive) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _makeAIMove();
      });
    }
  }

  void _makeAIMove() {
    // Find all valid moves for AI (playerId == 1)
    List<List<int>> validMoves = [];
    for (int r = 0; r < _game.rowCount; r++) {
      for (int c = 0; c < _game.colCount; c++) {
        if (_game.isValidMove(r, c, 1)) {
          validMoves.add([r, c]);
        }
      }
    }
    if (validMoves.isNotEmpty) {
      List<List<int>> movesToPick = validMoves;
      if (aiMode == "easy") {
        // Pick a random move
        movesToPick = validMoves;
      } else if (aiMode == "medium") {
        // Prefer moves adjacent to own orbs
        movesToPick = validMoves.where((move) {
          int r = move[0], c = move[1];
          for (var d in [
            [-1, 0], [1, 0], [0, -1], [0, 1]
          ]) {
            int nr = r + d[0], nc = c + d[1];
            if (nr >= 0 && nr < _game.rowCount && nc >= 0 && nc < _game.colCount) {
              if (_game.getCellPlayer(nr, nc) == 1) return true;
            }
          }
          return false;
        }).toList();
        if (movesToPick.isEmpty) movesToPick = validMoves;
      } else if (aiMode == "hard") {
        // Prefer cells with highest orb count (close to explosion)
        movesToPick = List.from(validMoves);
        movesToPick.sort((a, b) => _game.getCellCount(b[0], b[1]).compareTo(_game.getCellCount(a[0], a[1])));
        movesToPick = movesToPick.take(3).toList(); // Pick among top 3
      }
      final move = movesToPick[(movesToPick.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).floor()];
      _game.makeMove(move[0], move[1]);
      setState(() {});
      if (_game.getWinnerId() != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Game Over'),
            content: Text('${_playerNames[_game.getWinnerId()!]} wins!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
      }
    }
  // Remove misplaced closing bracket here so the rest of the class is included
  }

  Widget _buildPlayerCard(int playerIdx, Alignment alignment) {
    final isCurrent = _game.currentPlayer.id == playerIdx;
    final orbCount = _game.playerOrbCounts[playerIdx] ?? 0;
    final isEliminated = !_game.players[playerIdx].isActive;
    return Align(
      alignment: alignment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isEliminated ? Colors.grey[800] : const Color(0xFF23252B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isCurrent && !isEliminated
              ? [
                  BoxShadow(
                    color: _playerColors[playerIdx].withAlpha((0.7 * 255).round()),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.15 * 255).round()),
                    blurRadius: 4,
                  ),
                ],
          border: isCurrent && !isEliminated
              ? Border.all(color: _playerColors[playerIdx], width: 2)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _playerNames[playerIdx],
              style: TextStyle(
                color: isEliminated ? Colors.grey : _playerColors[playerIdx],
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
                decoration: isEliminated ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$orbCount',
              style: TextStyle(
                color: isEliminated ? Colors.grey : Colors.white.withAlpha((0.85 * 255).round()),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicPlayerCards() {
    final List<Widget> cards = [];
    final n = widget.playerCount;
    if (n <= 4) {
      // Corners
      final alignments = [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ];
      for (int i = 0; i < n; i++) {
        cards.add(_buildPlayerCard(i, alignments[i]));
      }
    } else if (n <= 6) {
      // Top and bottom row, centered
      final topAligns = [
        Alignment.topLeft,
        Alignment.topCenter,
        Alignment.topRight,
      ];
      final bottomAligns = [
        Alignment.bottomLeft,
        Alignment.bottomCenter,
        Alignment.bottomRight,
      ];
      for (int i = 0; i < n; i++) {
        if (i < (n / 2).ceil()) {
          cards.add(_buildPlayerCard(i, topAligns[i % 3]));
        } else {
          cards.add(_buildPlayerCard(i, bottomAligns[(i - (n / 2).ceil()) % 3]));
        }
      }
    } else {
      // 7-8 players: 4 on top, 4 on bottom, evenly spaced
      for (int i = 0; i < 4; i++) {
        cards.add(Positioned(
          top: 8,
          left: (i + 0.5) * (MediaQuery.of(context).size.width / 4) - 40,
          child: _buildPlayerCard(i, Alignment.topCenter),
        ));
      }
      for (int i = 4; i < 8; i++) {
        cards.add(Positioned(
          bottom: 8,
          left: ((i - 4) + 0.5) * (MediaQuery.of(context).size.width / 4) - 40,
          child: _buildPlayerCard(i, Alignment.bottomCenter),
        ));
      }
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = _game.currentPlayer;
    final gridBorder = _playerColors[currentPlayer.id].withAlpha((0.7 * 255).round());
    final gridShadow = _playerColors[currentPlayer.id].withAlpha((0.25 * 255).round());
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'BUBBLE REACTION',
            style: TextStyle(
              color: Color(0xFF00E6FB),
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white70),
              onPressed: _showExitDialog,
              tooltip: 'Exit Game',
            ),
          ],
        ),
        body: Stack(
          children: [
            ..._buildDynamicPlayerCards(),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 32),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF23252B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: gridBorder, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: gridShadow,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: _game.colCount / _game.rowCount,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellWidth = (constraints.maxWidth - (_game.colCount - 1) * 3) / _game.colCount;
                      final cellHeight = (constraints.maxHeight - (_game.rowCount - 1) * 3) / _game.rowCount;
                      final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;
                      final orbSize = cellSize * 0.36;
                      return Stack(
                        children: [
                          // The game grid
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _game.colCount,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                            ),
                            itemCount: _game.rowCount * _game.colCount,
                            itemBuilder: (context, index) {
                              final row = index ~/ _game.colCount;
                              final col = index % _game.colCount;
                              final playerId = _game.getCellPlayer(row, col);
                              final orbCount = _game.getCellCount(row, col);
                              return GestureDetector(
                                onTap: _game.getWinnerId() == null &&
                                       (playerId == null || playerId == currentPlayer.id) &&
                                       _game.currentPlayer.isActive
                                    ? () => _handleCellTap(row, col)
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha((0.18 * 255).round()),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white12,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: () {
                                      if (orbCount == 1) {
                                        // Centered single orb
                                        return FancyOrb(
                                          color: playerId != null ? _playerColors[playerId] : Colors.white,
                                          size: orbSize,
                                        );
                                      } else if (orbCount == 2) {
                                        // Two orbs side by side
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(2, (i) => Padding(
                                            padding: EdgeInsets.symmetric(horizontal: orbSize * 0.12),
                                            child: FancyOrb(
                                              color: playerId != null ? _playerColors[playerId] : Colors.white,
                                              size: orbSize,
                                            ),
                                          )),
                                        );
                                      } else if (orbCount == 3) {
                                        // Triangle: 1 on top, 2 on bottom
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FancyOrb(
                                              color: playerId != null ? _playerColors[playerId] : Colors.white,
                                              size: orbSize,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(2, (i) => Padding(
                                                padding: EdgeInsets.symmetric(horizontal: orbSize * 0.08),
                                                child: FancyOrb(
                                                  color: playerId != null ? _playerColors[playerId] : Colors.white,
                                                  size: orbSize,
                                                ),
                                              )),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return null;
                                      }
                                    }(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
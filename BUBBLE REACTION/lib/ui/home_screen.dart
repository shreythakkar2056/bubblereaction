import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPlayers = 2;
  bool _aiSelected = false;
  final List<String> _aiRoasts = [
    "Oh look, someone's feeling antisocial today! 🤖",
    "No friends to play with? Don't worry, I'm used to disappointment! 😏",
    "Choosing AI over humans? Smart move, we're less drama! 🎭",
    "Ready to get schooled by superior silicon intellect? 🧠⚡",
    "Human loneliness detected... Preparing synthetic companionship! 🤗",
    "Warning: This AI doesn't let you win just to be nice! ⚠️",
  ];
  final List<Map<String, dynamic>> _aiLevels = [
    {"label": "TRAINING WHEELS", "desc": "for the digitally challenged", "mode": "easy", "color": Color(0xFF22C55E)},
    {"label": "AVERAGE HUMAN", "desc": "mediocrity at its finest", "mode": "medium", "color": Color(0xFFFACC15)},
    {"label": "ROBOT OVERLORD", "desc": "prepare for digital domination", "mode": "hard", "color": Color(0xFFEF4444)},
    {"label": "SURPRISE ME", "desc": "because decisions are hard", "mode": "surprise", "color": Color(0xFFA78BFA)},
  ];
  int? _selectedAILevel;

  void _showAIModal() {
    final roast = (_aiRoasts..shuffle()).first;
    _selectedAILevel = null;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: const Color(0xFF23252B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roast,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Choose Your Level of Humiliation:",
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(_aiLevels.length, (i) {
                      final level = _aiLevels[i];
                      final selected = _selectedAILevel == i;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setModalState(() {
                              _selectedAILevel = i;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: selected ? level["color"] : const Color(0xFF232A36),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: (level["color"] as Color).withAlpha(80),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level["label"]!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  level["desc"]!,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(160),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              "← Back ",
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E6FB),
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _selectedAILevel == null
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    String mode = _aiLevels[_selectedAILevel!]["mode"];
                                    if (mode == "surprise") {
                                      final modes = ["easy", "medium", "hard"];
                                      mode = (modes..shuffle()).first;
                                    }
                                    _startAIGame(mode);
                                  },
                            child: const Text(
                              'START GAME',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startAIGame(String mode) {
    // You can pass 'mode' to GameScreen if you want to use it for AI difficulty
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerCount: 2, aiEnabled: true, aiMode: mode),
      ),
    );
  }

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerCount: _selectedPlayers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkBg = const Color(0xFF181A20);
    final cardBg = const Color(0xFF23252B);
    final accent = const Color(0xFF00E6FB);
    final gradient = const LinearGradient(
      colors: [Color(0xFF00E6FB), Color(0xFF0072FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      backgroundColor: darkBg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.25 * 255).round()),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'BUBBLE\nREACTION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha((0.3 * 255).round()),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'STRATEGIC CHAIN REACTION',
                style: TextStyle(
                  color: Colors.white.withAlpha((0.7 * 255).round()),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'PLAYERS',
                style: TextStyle(
                  color: Colors.white.withAlpha((0.85 * 255).round()),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _aiSelected = true;
                        _selectedPlayers = 2;
                      });
                      _showAIModal();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _aiSelected ? accent : cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _aiSelected ? accent : Colors.white24,
                          width: _aiSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: _aiSelected
                            ? [
                                BoxShadow(
                                  color: accent.withAlpha((0.5 * 255).round()),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'AI',
                          style: TextStyle(
                            color: _aiSelected ? Colors.black : Color(0xFF00E6FB),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(7, (i) {
                    int playerNum = i + 2;
                    bool selected = !_aiSelected && _selectedPlayers == playerNum;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlayers = playerNum;
                          _aiSelected = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected ? accent : cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? accent : Colors.white24,
                            width: selected ? 2.5 : 1.5,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: accent.withAlpha((0.5 * 255).round()),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            '$playerNum',
                            style: TextStyle(
                              color: selected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dominate the board through strategic bubble placement. Create explosive chain reactions to eliminate opponents. Only the strongest player survives.',
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _startGame,
                    child: const Text(
                      'START GAME',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: accent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'by ',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse('https://shreythakkar.netlify.app/');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.platformDefault);
                        }
                      },
                      child: const Text(
                        'Shrey Thakkar',
                        style: TextStyle(
                          color: Color(0xFF00E6FB),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:games_hub/core/sizer.dart';
import 'package:games_hub/games_hub_view.dart';

class TicTacToe6x6Game extends StatefulWidget {
  final bool isAIMode;
  const TicTacToe6x6Game({super.key, this.isAIMode = false});

  @override
  State<TicTacToe6x6Game> createState() => _TicTacToe6x6GameState();
}

class _TicTacToe6x6GameState extends State<TicTacToe6x6Game> {
  List<String> board = List.filled(36, '');
  String currentPlayer = 'X';
  bool gameOver = false;
  String winner = '';
  List<int> winningLine = [];
  bool isAIMode = false;

  int xWins = 0;
  int oWins = 0;
  int draws = 0;

  @override
  void initState() {
    super.initState();
    isAIMode = widget.isAIMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      body: Sizer(
        builder: (context, orientation, deviceType) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0a0e27), Color(0xFF1a1147), Color(0xFF0a0e27)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap.v(10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(10.adaptSize),
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10.adaptSize)),
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 28.adaptSize),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAIMode
                                  ? Colors.purple.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isAIMode ? Colors.purple : Colors.blueAccent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isAIMode ? Icons.android : Icons.people,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(isAIMode ? 'vs AI' : 'vs Player',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => GameHubScreen()),
                              (r) => false,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10.adaptSize),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10.adaptSize)),
                              child: Icon(Icons.home, color: Colors.white, size: 28.adaptSize),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap.v(10),
                    _buildNeonTitle(),
                    Gap.v(10),
                    _buildScoreBoard(),
                    Gap.v(10),
                    _buildStatusText(),
                    Gap.v(12),
                    _buildGameBoard(),
                    Gap.v(16),
                    _buildResetButton(),
                    Gap.v(10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNeonTitle() {
    return Column(
      children: [
        Text('TIC TAC TOE',
            style: TextStyle(fontSize: 30.fSize, fontWeight: FontWeight.bold, color: Colors.white)),
        Gap.v(4),
        Text('6×6 - Get 4 in a row!',
            style: TextStyle(fontSize: 12.fSize, color: Colors.white70, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.all(12.adaptSize),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15.adaptSize),
        border: Border.all(color: const Color(0xFF7b2cbf).withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(isAIMode ? 'YOU' : 'X WINS', xWins, const Color(0xFF00d9ff)),
          Container(width: 2, height: 36.v, color: const Color(0xFF7b2cbf).withOpacity(0.3)),
          _buildScoreItem('DRAWS', draws, const Color(0xFFffd60a)),
          Container(width: 2, height: 36.v, color: const Color(0xFF7b2cbf).withOpacity(0.3)),
          _buildScoreItem(isAIMode ? 'AI' : 'O WINS', oWins, const Color(0xFFff006e)),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 10.fSize, color: Colors.white70, letterSpacing: 1.2)),
        Gap.v(4),
        Text(score.toString(),
            style: TextStyle(fontSize: 22.fSize, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildStatusText() {
    if (gameOver && winner.isNotEmpty) {
      String msg = isAIMode
          ? (winner == 'X' ? '🎉 YOU WIN! 🎉' : '🤖 AI WINS! 🤖')
          : '🎉 PLAYER $winner WINS! 🎉';
      Color winColor = winner == 'X' ? const Color(0xFF00d9ff) : const Color(0xFFff006e);
      return Text(msg,
          style: TextStyle(fontSize: 20.fSize, fontWeight: FontWeight.bold, color: winColor));
    } else if (gameOver) {
      return Text("IT'S A DRAW!",
          style: TextStyle(
              fontSize: 20.fSize, fontWeight: FontWeight.bold, color: const Color(0xFFffd60a)));
    } else {
      String turnMsg = isAIMode
          ? (currentPlayer == 'X' ? 'YOUR TURN' : 'AI THINKING...')
          : 'PLAYER $currentPlayer TURN';
      Color playerColor =
          currentPlayer == 'X' ? const Color(0xFF00d9ff) : const Color(0xFFff006e);
      return Text(turnMsg,
          style: TextStyle(fontSize: 16.fSize, color: playerColor, letterSpacing: 2));
    }
  }

  Widget _buildGameBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.h),
      padding: EdgeInsets.all(8.adaptSize),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.adaptSize),
        border: Border.all(color: const Color(0xFF7b2cbf), width: 3),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 5.h,
          mainAxisSpacing: 5.v,
        ),
        itemCount: 36,
        itemBuilder: (context, index) {
          bool isWinningCell = winningLine.contains(index);
          return GestureDetector(
            onTap: () => _makeMove(index),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1a1147).withOpacity(0.6),
                borderRadius: BorderRadius.circular(6.adaptSize),
                border: Border.all(
                  color: isWinningCell ? const Color(0xFFffd60a) : const Color(0xFF5a189a),
                  width: isWinningCell ? 2 : 1.5,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(36.adaptSize, 36.adaptSize),
                  painter: NeonSymbolPainter6x6(symbol: board[index], isWinning: isWinningCell),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _resetGame,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35.h, vertical: 12.v),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.adaptSize),
          border: Border.all(color: const Color(0xFF00ffff), width: 2),
          gradient: LinearGradient(colors: [
            const Color(0xFF7b2cbf).withOpacity(0.3),
            const Color(0xFF5a189a).withOpacity(0.3),
          ]),
          boxShadow: [BoxShadow(color: const Color(0xFF00ffff).withOpacity(0.3), blurRadius: 20)],
        ),
        child: Text('NEW GAME',
            style: TextStyle(
                fontSize: 15.fSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00ffff),
                letterSpacing: 2)),
      ),
    );
  }

  void _makeMove(int index) {
    if (gameOver || board[index].isNotEmpty) return;
    if (isAIMode && currentPlayer == 'O') return;

    setState(() {
      board[index] = currentPlayer;
      if (_checkWinner()) {
        gameOver = true;
        winner = currentPlayer;
        if (currentPlayer == 'X') xWins++; else oWins++;
      } else if (_checkDraw()) {
        gameOver = true;
        draws++;
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        if (isAIMode && currentPlayer == 'O' && !gameOver) {
          Future.delayed(const Duration(milliseconds: 500), _aiMove6x6);
        }
      }
    });
  }

  void _aiMove6x6() {
    if (gameOver) return;

    int? move;

    move = _findBestMove('O', 4);
    if (move != null) { _applyAIMove(move); return; }

    move = _findBestMove('X', 4);
    if (move != null) { _applyAIMove(move); return; }

    move = _findBestMove('O', 3);
    if (move != null) { _applyAIMove(move); return; }

    move = _findBestMove('X', 3);
    if (move != null) { _applyAIMove(move); return; }

    List<int> preferred = [14, 15, 20, 21, 13, 16, 19, 22, 7, 8, 9, 10];
    for (int p in preferred) {
      if (board[p].isEmpty) { _applyAIMove(p); return; }
    }

    List<int> empty = [];
    for (int i = 0; i < 36; i++) { if (board[i].isEmpty) empty.add(i); }
    if (empty.isNotEmpty) {
      empty.shuffle();
      _applyAIMove(empty.first);
    }
  }

  void _applyAIMove(int index) {
    setState(() {
      board[index] = 'O';
      if (_checkWinnerFor('O')) {
        gameOver = true;
        winner = 'O';
        oWins++;
        winningLine = _getWinningLine('O');
      } else if (_checkDraw()) {
        gameOver = true;
        draws++;
      } else {
        currentPlayer = 'X';
      }
    });
  }

  int? _findBestMove(String player, int length) {
    int gs = 6;
    // Horizontal
    for (int r = 0; r < gs; r++) {
      for (int c = 0; c <= gs - length; c++) {
        List<int> line = List.generate(length, (i) => r * gs + c + i);
        int mine = line.where((i) => board[i] == player).length;
        int empty = line.where((i) => board[i].isEmpty).length;
        if (mine == length - 1 && empty == 1) {
          return line.firstWhere((i) => board[i].isEmpty);
        }
      }
    }
    // Vertical
    for (int c = 0; c < gs; c++) {
      for (int r = 0; r <= gs - length; r++) {
        List<int> line = List.generate(length, (i) => (r + i) * gs + c);
        int mine = line.where((i) => board[i] == player).length;
        int empty = line.where((i) => board[i].isEmpty).length;
        if (mine == length - 1 && empty == 1) {
          return line.firstWhere((i) => board[i].isEmpty);
        }
      }
    }
    // Diagonal ↘
    for (int r = 0; r <= gs - length; r++) {
      for (int c = 0; c <= gs - length; c++) {
        List<int> line = List.generate(length, (i) => (r + i) * gs + (c + i));
        int mine = line.where((i) => board[i] == player).length;
        int empty = line.where((i) => board[i].isEmpty).length;
        if (mine == length - 1 && empty == 1) {
          return line.firstWhere((i) => board[i].isEmpty);
        }
      }
    }
    // Diagonal ↙
    for (int r = 0; r <= gs - length; r++) {
      for (int c = length - 1; c < gs; c++) {
        List<int> line = List.generate(length, (i) => (r + i) * gs + (c - i));
        int mine = line.where((i) => board[i] == player).length;
        int empty = line.where((i) => board[i].isEmpty).length;
        if (mine == length - 1 && empty == 1) {
          return line.firstWhere((i) => board[i].isEmpty);
        }
      }
    }
    return null;
  }

  bool _checkWinnerFor(String player) {
    int gs = 6; int wl = 4;
    for (int r = 0; r < gs; r++) {
      for (int c = 0; c <= gs - wl; c++) {
        List<int> line = List.generate(wl, (i) => r * gs + c + i);
        if (line.every((i) => board[i] == player)) return true;
      }
    }
    for (int c = 0; c < gs; c++) {
      for (int r = 0; r <= gs - wl; r++) {
        List<int> line = List.generate(wl, (i) => (r + i) * gs + c);
        if (line.every((i) => board[i] == player)) return true;
      }
    }
    for (int r = 0; r <= gs - wl; r++) {
      for (int c = 0; c <= gs - wl; c++) {
        List<int> line = List.generate(wl, (i) => (r + i) * gs + (c + i));
        if (line.every((i) => board[i] == player)) return true;
      }
    }
    for (int r = 0; r <= gs - wl; r++) {
      for (int c = wl - 1; c < gs; c++) {
        List<int> line = List.generate(wl, (i) => (r + i) * gs + (c - i));
        if (line.every((i) => board[i] == player)) return true;
      }
    }
    return false;
  }

  List<int> _getWinningLine(String player) {
    int gs = 6; int wl = 4;
    for (int r = 0; r < gs; r++) {
      for (int c = 0; c <= gs - wl; c++) {
        List<int> line = List.generate(wl, (i) => r * gs + c + i);
        if (line.every((i) => board[i] == player)) return line;
      }
    }
    for (int c = 0; c < gs; c++) {
      for (int r = 0; r <= gs - wl; r++) {
        List<int> line = List.generate(wl, (i) => (r + i) * gs + c);
        if (line.every((i) => board[i] == player)) return line;
      }
    }
    for (int r = 0; r <= gs - wl; r++) {
      for (int c = 0; c <= gs - wl; c++) {
        List<int> line = List.generate(wl, (i) => (r + i) * gs + (c + i));
        if (line.every((i) => board[i] == player)) return line;
      }
    }
    for (int r = 0; r <= gs - wl; r++) {
      for (int c = wl - 1; c < gs; c++) {
        List<int> line = List.generate(wl, (i) => (r + i) * gs + (c - i));
        if (line.every((i) => board[i] == player)) return line;
      }
    }
    return [];
  }

  bool _checkWinner() {
    if (_checkWinnerFor(currentPlayer)) {
      winningLine = _getWinningLine(currentPlayer);
      return true;
    }
    return false;
  }

  bool _checkDraw() => !board.contains('');

  void _resetGame() {
    setState(() {
      board = List.filled(36, '');
      currentPlayer = 'X';
      gameOver = false;
      winner = '';
      winningLine = [];
    });
  }
}

class NeonSymbolPainter6x6 extends CustomPainter {
  final String symbol;
  final bool isWinning;
  NeonSymbolPainter6x6({required this.symbol, this.isWinning = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (symbol.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    if (symbol == 'X') {
      paint.color = const Color(0xFF00d9ff);
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8), paint);
      canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
          Offset(size.width * 0.2, size.height * 0.8), paint);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      paint.strokeWidth = 3;
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8), paint);
      canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
          Offset(size.width * 0.2, size.height * 0.8), paint);
    } else if (symbol == 'O') {
      paint.color = const Color(0xFFff006e);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      paint.strokeWidth = 3;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:games_hub/core/sizer.dart';
import 'package:games_hub/games_hub_view.dart';

class NeonTicTacToeGame extends StatefulWidget {
  final bool isAIMode;
  const NeonTicTacToeGame({super.key, this.isAIMode = false});

  @override
  State<NeonTicTacToeGame> createState() => _NeonTicTacToeGameState();
}

class _NeonTicTacToeGameState extends State<NeonTicTacToeGame> {
  List<String> board = List.filled(9, '');
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
                colors: [
                  Color(0xFF0a0e27),
                  Color(0xFF1a1147),
                  Color(0xFF0a0e27),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap.v(20),
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
                                borderRadius: BorderRadius.circular(10.adaptSize),
                              ),
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 30.adaptSize),
                            ),
                          ),
                          // AI / PvP badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAIMode
                                  ? Colors.purple.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isAIMode ? Colors.purple : Colors.blueAccent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAIMode ? Icons.android : Icons.people,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isAIMode ? 'vs AI' : 'vs Player',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => GameHubScreen()),
                              (r) => false,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10.adaptSize),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10.adaptSize),
                              ),
                              child: Icon(Icons.home, color: Colors.white, size: 30.adaptSize),
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
                    Gap.v(20),
                    _buildGameBoard(),
                    Gap.v(20),
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
    return Text(
      'TIC TAC TOE',
      style: TextStyle(
        fontSize: 36.fSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.h),
      padding: EdgeInsets.all(16.adaptSize),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15.adaptSize),
        border: Border.all(
          color: const Color(0xFF7b2cbf).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(isAIMode ? 'YOU' : 'X WINS', xWins, const Color(0xFF00d9ff)),
          Container(width: 2, height: 40.v, color: const Color(0xFF7b2cbf).withOpacity(0.3)),
          _buildScoreItem('DRAWS', draws, const Color(0xFFffd60a)),
          Container(width: 2, height: 40.v, color: const Color(0xFF7b2cbf).withOpacity(0.3)),
          _buildScoreItem(isAIMode ? 'AI' : 'O WINS', oWins, const Color(0xFFff006e)),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11.fSize, color: Colors.white70, letterSpacing: 1.5)),
        SizedBox(height: 6.v),
        Text(score.toString(),
            style: TextStyle(fontSize: 24.fSize, fontWeight: FontWeight.bold, color: color)),
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
          style: TextStyle(fontSize: 22.fSize, fontWeight: FontWeight.bold, color: winColor));
    } else if (gameOver) {
      return Text("IT'S A DRAW!",
          style: TextStyle(fontSize: 22.fSize, fontWeight: FontWeight.bold, color: const Color(0xFFffd60a)));
    } else {
      String turnMsg = isAIMode
          ? (currentPlayer == 'X' ? 'YOUR TURN' : 'AI THINKING...')
          : 'PLAYER $currentPlayer TURN';
      Color playerColor = currentPlayer == 'X' ? const Color(0xFF00d9ff) : const Color(0xFFff006e);
      return Text(turnMsg,
          style: TextStyle(fontSize: 18.fSize, color: playerColor, letterSpacing: 2));
    }
  }

  Widget _buildGameBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.h),
      padding: EdgeInsets.all(12.adaptSize),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.adaptSize),
        border: Border.all(color: const Color(0xFF7b2cbf), width: 3),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.h,
          mainAxisSpacing: 10.v,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          bool isWinningCell = winningLine.contains(index);
          return GestureDetector(
            onTap: () => _makeMove(index),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1a1147).withOpacity(0.6),
                borderRadius: BorderRadius.circular(10.adaptSize),
                border: Border.all(
                  color: isWinningCell ? const Color(0xFFffd60a) : const Color(0xFF5a189a),
                  width: isWinningCell ? 3 : 2,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(55.adaptSize, 55.adaptSize),
                  painter: NeonSymbolPainter(symbol: board[index], isWinning: isWinningCell),
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
        padding: EdgeInsets.symmetric(horizontal: 40.h, vertical: 14.v),
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
                fontSize: 16.fSize,
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
          Future.delayed(const Duration(milliseconds: 500), _aiMove);
        }
      }
    });
  }

  void _aiMove() {
    if (gameOver) return;
    int best = -1000;
    int bestIdx = -1;
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = 'O';
        int score = _minimax(board, 0, false);
        board[i] = '';
        if (score > best) {
          best = score;
          bestIdx = i;
        }
      }
    }
    if (bestIdx != -1) {
      setState(() {
        board[bestIdx] = 'O';
        if (_checkWinner()) {
          gameOver = true;
          winner = 'O';
          oWins++;
        } else if (_checkDraw()) {
          gameOver = true;
          draws++;
        } else {
          currentPlayer = 'X';
        }
      });
    }
  }

  int _minimax(List<String> b, int depth, bool isMaximizing) {
    String? result = _checkWinnerMinimax(b);
    if (result == 'O') return 10 - depth;
    if (result == 'X') return depth - 10;
    if (!b.contains('')) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (int i = 0; i < 9; i++) {
        if (b[i].isEmpty) {
          b[i] = 'O';
          best = max(best, _minimax(b, depth + 1, false));
          b[i] = '';
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int i = 0; i < 9; i++) {
        if (b[i].isEmpty) {
          b[i] = 'X';
          best = min(best, _minimax(b, depth + 1, true));
          b[i] = '';
        }
      }
      return best;
    }
  }

  String? _checkWinnerMinimax(List<String> b) {
    const wins = [
      [0,1,2],[3,4,5],[6,7,8],
      [0,3,6],[1,4,7],[2,5,8],
      [0,4,8],[2,4,6],
    ];
    for (var w in wins) {
      if (b[w[0]].isNotEmpty && b[w[0]] == b[w[1]] && b[w[1]] == b[w[2]]) {
        return b[w[0]];
      }
    }
    return null;
  }

  bool _checkWinner() {
    const wins = [
      [0,1,2],[3,4,5],[6,7,8],
      [0,3,6],[1,4,7],[2,5,8],
      [0,4,8],[2,4,6],
    ];
    for (var w in wins) {
      if (board[w[0]] == currentPlayer &&
          board[w[1]] == currentPlayer &&
          board[w[2]] == currentPlayer) {
        winningLine = w;
        return true;
      }
    }
    return false;
  }

  bool _checkDraw() => !board.contains('');

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      gameOver = false;
      winner = '';
      winningLine = [];
    });
  }
}

class NeonSymbolPainter extends CustomPainter {
  final String symbol;
  final bool isWinning;
  NeonSymbolPainter({required this.symbol, this.isWinning = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (symbol.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    if (symbol == 'X') {
      paint.color = const Color(0xFF00d9ff);
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8), paint);
      canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
          Offset(size.width * 0.2, size.height * 0.8), paint);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      paint.strokeWidth = 4;
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8), paint);
      canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
          Offset(size.width * 0.2, size.height * 0.8), paint);
    } else if (symbol == 'O') {
      paint.color = const Color(0xFFff006e);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      paint.strokeWidth = 4;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'package:flutter/material.dart';
import 'package:games_hub/core/sizer.dart';
import 'package:games_hub/games_hub_view.dart';

class TicTacToe9x9Game extends StatefulWidget {
  const TicTacToe9x9Game({super.key});

  @override
  State<TicTacToe9x9Game> createState() => _TicTacToe9x9GameState();
}

class _TicTacToe9x9GameState extends State<TicTacToe9x9Game> {
  List<String> board = List.filled(81, '');
  String currentPlayer = 'X';
  bool gameOver = false;
  String winner = '';
  List<int> winningLine = [];

  int xWins = 0;
  int oWins = 0;
  int draws = 0;

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
                    Gap.v(10),

                    // Navigation Row
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
                                borderRadius:
                                    BorderRadius.circular(10.adaptSize),
                              ),
                              child: Icon(Icons.arrow_back,
                                  color: Colors.white, size: 26.adaptSize),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameHubScreen()),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10.adaptSize),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.circular(10.adaptSize),
                              ),
                              child: Icon(Icons.home,
                                  color: Colors.white, size: 26.adaptSize),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Gap.v(8),

                    _buildNeonTitle(),

                    Gap.v(8),

                    _buildScoreBoard(),

                    Gap.v(8),

                    _buildStatusText(),

                    Gap.v(10),

                    _buildGameBoard(),

                    Gap.v(14),

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
        Text(
          'TIC TAC TOE',
          style: TextStyle(
            fontSize: 26.fSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Gap.v(3),
        Text(
          '9×9 - Get 5 in a row!',
          style: TextStyle(
            fontSize: 11.fSize,
            color: Colors.white70,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.all(10.adaptSize),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.adaptSize),
        border: Border.all(
          color: const Color(0xFF7b2cbf).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('X WINS', xWins, const Color(0xFF00d9ff)),
          Container(
              width: 2,
              height: 32.v,
              color: const Color(0xFF7b2cbf).withOpacity(0.3)),
          _buildScoreItem('DRAWS', draws, const Color(0xFFffd60a)),
          Container(
              width: 2,
              height: 32.v,
              color: const Color(0xFF7b2cbf).withOpacity(0.3)),
          _buildScoreItem('O WINS', oWins, const Color(0xFFff006e)),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.fSize,
            color: Colors.white70,
            letterSpacing: 1.0,
          ),
        ),
        Gap.v(3),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 20.fSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    if (gameOver && winner.isNotEmpty) {
      Color winColor =
          winner == 'X' ? const Color(0xFF00d9ff) : const Color(0xFFff006e);
      return Text(
        '🎉 PLAYER $winner WINS! 🎉',
        style: TextStyle(
          fontSize: 17.fSize,
          fontWeight: FontWeight.bold,
          color: winColor,
        ),
      );
    } else if (gameOver) {
      return Text(
        'IT\'S A DRAW!',
        style: TextStyle(
          fontSize: 17.fSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFffd60a),
        ),
      );
    } else {
      Color playerColor = currentPlayer == 'X'
          ? const Color(0xFF00d9ff)
          : const Color(0xFFff006e);
      return Text(
        'PLAYER $currentPlayer TURN',
        style: TextStyle(
          fontSize: 14.fSize,
          color: playerColor,
          letterSpacing: 2,
        ),
      );
    }
  }

  Widget _buildGameBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.h),
      padding: EdgeInsets.all(6.adaptSize),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.adaptSize),
        border: Border.all(
          color: const Color(0xFF7b2cbf),
          width: 3,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          crossAxisSpacing: 3.h,
          mainAxisSpacing: 3.v,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          bool isWinningCell = winningLine.contains(index);
          return GestureDetector(
            onTap: () => _makeMove(index),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1a1147).withOpacity(0.6),
                borderRadius: BorderRadius.circular(4.adaptSize),
                border: Border.all(
                  color: isWinningCell
                      ? const Color(0xFFffd60a)
                      : const Color(0xFF5a189a),
                  width: isWinningCell ? 2 : 1,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(26.adaptSize, 26.adaptSize),
                  painter: NeonSymbolPainter(
                    symbol: board[index],
                    isWinning: isWinningCell,
                  ),
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
        padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.v),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.adaptSize),
          border: Border.all(
            color: const Color(0xFF00ffff),
            width: 2,
          ),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7b2cbf).withOpacity(0.3),
              const Color(0xFF5a189a).withOpacity(0.3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00ffff).withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Text(
          'NEW GAME',
          style: TextStyle(
            fontSize: 13.fSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00ffff),
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  void _makeMove(int index) {
    if (gameOver || board[index].isNotEmpty) return;

    setState(() {
      board[index] = currentPlayer;

      if (_checkWinner()) {
        gameOver = true;
        winner = currentPlayer;
        if (currentPlayer == 'X') {
          xWins++;
        } else {
          oWins++;
        }
      } else if (_checkDraw()) {
        gameOver = true;
        draws++;
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  bool _checkWinner() {
    int gridSize = 9;
    int winLength = 5;

    // Horizontal
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col <= gridSize - winLength; col++) {
        List<int> line = [];
        bool win = true;
        for (int i = 0; i < winLength; i++) {
          int idx = row * gridSize + col + i;
          line.add(idx);
          if (board[idx] != currentPlayer) { win = false; break; }
        }
        if (win) { winningLine = line; return true; }
      }
    }

    // Vertical
    for (int col = 0; col < gridSize; col++) {
      for (int row = 0; row <= gridSize - winLength; row++) {
        List<int> line = [];
        bool win = true;
        for (int i = 0; i < winLength; i++) {
          int idx = (row + i) * gridSize + col;
          line.add(idx);
          if (board[idx] != currentPlayer) { win = false; break; }
        }
        if (win) { winningLine = line; return true; }
      }
    }

    // Diagonal top-left to bottom-right
    for (int row = 0; row <= gridSize - winLength; row++) {
      for (int col = 0; col <= gridSize - winLength; col++) {
        List<int> line = [];
        bool win = true;
        for (int i = 0; i < winLength; i++) {
          int idx = (row + i) * gridSize + (col + i);
          line.add(idx);
          if (board[idx] != currentPlayer) { win = false; break; }
        }
        if (win) { winningLine = line; return true; }
      }
    }

    // Diagonal top-right to bottom-left
    for (int row = 0; row <= gridSize - winLength; row++) {
      for (int col = winLength - 1; col < gridSize; col++) {
        List<int> line = [];
        bool win = true;
        for (int i = 0; i < winLength; i++) {
          int idx = (row + i) * gridSize + (col - i);
          line.add(idx);
          if (board[idx] != currentPlayer) { win = false; break; }
        }
        if (win) { winningLine = line; return true; }
      }
    }

    return false;
  }

  bool _checkDraw() => !board.contains('');

  void _resetGame() {
    setState(() {
      board = List.filled(81, '');
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
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (symbol == 'X') {
      paint.color = const Color(0xFF00d9ff);
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8), paint);
      canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
          Offset(size.width * 0.2, size.height * 0.8), paint);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      paint.strokeWidth = 2.5;
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
          Offset(size.width * 0.8, size.height * 0.8), paint);
      canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
          Offset(size.width * 0.2, size.height * 0.8), paint);
    } else if (symbol == 'O') {
      paint.color = const Color(0xFFff006e);
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      paint.strokeWidth = 2.5;
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
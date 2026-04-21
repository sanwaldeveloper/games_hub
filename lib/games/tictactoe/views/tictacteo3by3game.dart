import 'package:flutter/material.dart';
import 'package:games_hub/core/sizer.dart';
import 'package:games_hub/games_hub_view.dart';


class NeonTicTacToeGame extends StatefulWidget {
  const NeonTicTacToeGame({super.key});

  @override
  State<NeonTicTacToeGame> createState() => _NeonTicTacToeGameState();
}

class _NeonTicTacToeGameState extends State<NeonTicTacToeGame> {
  List<String> board = List.filled(9, '');
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
              // ✅ FIX 1: SingleChildScrollView wrap kiya taake overflow na ho
              child: SingleChildScrollView(
                child: Column(
                  // ✅ FIX 2: mainAxisAlignment.center hata diya
                  // (center + scroll dono saath kaam nahi karte)
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap.v(20), // ✅ FIX 3: SizedBox ki jagah Gap.v use karo

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
                                  color: Colors.white, size: 30.adaptSize),
                            ),
                          ),
                          GestureDetector(
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
                                  color: Colors.white, size: 30.adaptSize),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Gap.v(10),

                    // Title
                    _buildNeonTitle(),

                    Gap.v(10),

                    // Score Board
                    _buildScoreBoard(),

                    Gap.v(10),

                    // Status Text
                    _buildStatusText(),

                    Gap.v(20), // ✅ 30 se 20 kiya — thoda space bachaya

                    // Game Board
                    _buildGameBoard(),

                    Gap.v(20),

                    // Reset Button
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
        fontSize: 36.fSize, // ✅ 40 se thoda chhota — overflow avoid karta hai
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.h),
      padding: EdgeInsets.all(16.adaptSize), // ✅ 20 se 16 kiya
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
          _buildScoreItem('X WINS', xWins, const Color(0xFF00d9ff)),
          Container(
              width: 2,
              height: 40.v,
              color: const Color(0xFF7b2cbf).withOpacity(0.3)),
          _buildScoreItem('DRAWS', draws, const Color(0xFFffd60a)),
          Container(
              width: 2,
              height: 40.v,
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
            fontSize: 11.fSize, // ✅ responsive font
            color: Colors.white70,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 6.v),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 24.fSize, // ✅ 28 se 24 kiya
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
          fontSize: 22.fSize,
          fontWeight: FontWeight.bold,
          color: winColor,
        ),
      );
    } else if (gameOver) {
      return Text(
        'IT\'S A DRAW!',
        style: TextStyle(
          fontSize: 22.fSize,
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
          fontSize: 18.fSize,
          color: playerColor,
          letterSpacing: 2,
        ),
      );
    }
  }

  Widget _buildGameBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.h),
      padding: EdgeInsets.all(12.adaptSize), // ✅ 15 se 12 kiya
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.adaptSize),
        border: Border.all(
          color: const Color(0xFF7b2cbf),
          width: 3,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.h, // ✅ 12 se 10 kiya
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
                  color: isWinningCell
                      ? const Color(0xFFffd60a)
                      : const Color(0xFF5a189a),
                  width: isWinningCell ? 3 : 2,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(55.adaptSize, 55.adaptSize), // ✅ 60 se 55 kiya
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
        padding: EdgeInsets.symmetric(horizontal: 40.h, vertical: 14.v),
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
            fontSize: 16.fSize, // ✅ 18 se 16 kiya
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
    List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (var combo in winningCombinations) {
      if (board[combo[0]] == currentPlayer &&
          board[combo[1]] == currentPlayer &&
          board[combo[2]] == currentPlayer) {
        winningLine = combo;
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

// NeonSymbolPainter bilkul same rahega — koi change nahi
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
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      paint.strokeWidth = 4;
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), size.width * 0.3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
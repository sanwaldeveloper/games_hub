import 'package:flutter/material.dart';
import 'package:games_hub/games/ballsortgame/ball_sort_app.dart';
import 'package:games_hub/games/emoji-pair-master/emoji-pair-master-view.dart';
import 'package:games_hub/games/chess/chess_screen.dart';
import 'package:games_hub/games/hungry_worm/components/game_screen.dart';
import 'package:games_hub/games/ludo/presentation/screens/splash_screen.dart';
import 'package:games_hub/games/sudoku/sudoku_screen.dart';
import 'package:games_hub/games/tictactoe/views/onboarding.dart';
import 'package:games_hub/games/word_search_game/screens/ws_home_screen.dart';
import 'package:games_hub/games/word_search_game/services/ws_game_provider.dart';
import 'package:provider/provider.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), 
      appBar: AppBar(
        title: const Text("Game Hub",style: TextStyle(color: Colors.white,)),
        backgroundColor: Colors.black, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            gameItem(
              Image.asset("assets/images/tic-tac-toe.png"),
              "TicTacToe",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
            ),
            gameItem(
              Image.asset("assets/images/chess.png"),
              "Chess",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChessGameScreen(),
                  ),
                );
              },
            ),
            gameItem(
              Image.asset("assets/images/sudoku.png"),
              "Sudoku",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SudokuScreen()),
                );
              },
            ),
            gameItem(
              Image.asset("assets/images/dice.png"),
              "Ludo",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LudoSplashScreen()),
                );
              },
            ),
            gameItem(
              Image.asset("assets/images/addon.png"),
              "Emoji Pair Master",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmojiPairMasterApp()),
                );
              },
            ),
             gameItem(
              Image.asset("assets/images/addon.png"),
              "HungrySnack",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HungryWormGameScreen ()),
                );
              },
            ),
            gameItem(
              Image.asset("assets/images/ballgame.png"),
              "BallSortGame",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BallSortApp ()),
                      
                );
              },
            ),
   gameItem(
    Image.asset("assets/images/addon.png"),
    "Word Search",
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => WSGameProvider()..initialize(),
            child: const WordSearchHome(),
          ),
        ),
      );
    },
  ),        ],
        ),
      ),
    );
  }

  Widget gameItem(
    Widget media,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F3460), Color(0xFF533483)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: media,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/injection.dart';
import 'package:games_hub/games/ludo/presentation/provider/game_provider.dart';
import 'package:games_hub/games/ludo/presentation/screens/game_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class LudoHomeScreen extends StatelessWidget {
  const LudoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Sellect Players Game",),
       // backgroundColor: Colors.transparent,
         flexibleSpace: Container(
    decoration: BoxDecoration(
       gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
          ),
    ),
  ),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: Colors.black,)),),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

              
                Text(
                  'Select Players',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                for (int i = 2; i <= 4; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                    child: ElevatedButton(
                      onPressed: () => _startGame(context, i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0083B0),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '$i Players',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, int playerCount) {
    final provider = getIt<GameProvider>()..startGame(playerCount);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const GameScreen(),
        ),
      ),
    );
  }
}
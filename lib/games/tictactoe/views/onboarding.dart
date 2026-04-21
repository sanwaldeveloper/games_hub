import 'package:flutter/material.dart';
import 'package:games_hub/games/tictactoe/views/sellect_level_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
        padding:  EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin : Alignment.topCenter,
              end : Alignment.bottomCenter,

              colors: [
                
                Color(0xffa748f1), Color(0xff3405b3) ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "TicTacToe",
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xffe8b64a),

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>SellectLevelScreen() ,));
                },
                child: Container(
                  height: 40,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Color(0xffe8b64a),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Play",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.play_arrow, color: Colors.black),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 40,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Color(0xffe8b64a),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Home",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.home, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    
    );
  }
}

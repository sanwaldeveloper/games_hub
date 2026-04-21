import 'package:flutter/material.dart';
import 'package:games_hub/games_hub_view.dart';
import 'package:games_hub/games/tictactoe/views/tictacteo3by3game.dart';

import 'package:games_hub/games/tictactoe/views/tictactoe6by6.dart';
import 'package:games_hub/games/tictactoe/views/tictactoe9by9game.dart';



class SellectLevelScreen extends StatefulWidget {
  const SellectLevelScreen({super.key});

  @override
  State<SellectLevelScreen> createState() => _SellectLevelScreenState();
}

class _SellectLevelScreenState extends State<SellectLevelScreen> {
  final List<String> levelTitles = ["3*3", "6*6", "9*9"];

  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin : Alignment.topCenter,
              end : Alignment.bottomCenter,

              colors: [
                
                Color(0xffa748f1), Color(0xff3405b3) ],
            ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){

                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => GameHubScreen(),));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
        
            const SizedBox(height: 30),
        
            const Text(
              "Sellect Level",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0xffecab3d),
              ),
            ),
        
            const SizedBox(height: 30),
        
            Text(
              levelTitles[currentIndex],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
        
            const SizedBox(height: 30),
        
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    children: [
                      levelItem(
                        context,
                        image: 'assets/images/3by3.jpg',
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(
                            builder: (context) => NeonTicTacToeGame(),));
                        },
                      ),
                      levelItem(
                        context,
                        image: 'assets/images/6by6.jpg',
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(
                            builder: (context) => TicTacToe6x6Game(),));
                        },
                      ),
                      levelItem(
                        context,
                        image: 'assets/images/9by9.jpg',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => TicTacToe9x9Game(),));
                        },
                      ),
                    ],
                  ),
        
                  Positioned(
                    left: 0,
                    child: Opacity(
                      opacity: currentIndex == 0 ? 0.4 : 1,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xffecab3d),
                        ),
                        onPressed: currentIndex == 0
                            ? null
                            : () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                      ),
                    ),
                  ),
        
                  Positioned(
                    right: 0,
                    child: Opacity(
                      opacity: currentIndex == 2 ? 0.4 : 1,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xffecab3d),
                        ),
                        onPressed: currentIndex == 2
                            ? null
                            : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 30),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 8,
                  width: currentIndex == index ? 8 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? const Color(0xffecab3d)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => TicTacToe6x6Game(),));
                },
                child: Container(
                  height:50,
                  width: double.infinity,
        
                  decoration: BoxDecoration(
                    color: Color(0xffe8b64a),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      Text(
                        "Vs",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.android, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => NeonTicTacToeGame(),));
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
        
                  decoration: BoxDecoration(
                    color: Color(0xffe8b64a),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.person, color: Colors.black),
                      Text(
                        "Vs",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.person, color: Colors.black),
                    ],
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

Widget levelItem(
  BuildContext context, {
  required String image,
  required VoidCallback onTap,
}) {
  return Center(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(image, fit: BoxFit.cover),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/presentation/screens/ludo_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class LudoSplashScreen extends StatefulWidget {
  const LudoSplashScreen({super.key});

  @override
  State<LudoSplashScreen> createState() => _LudoSplashScreenState();
}

class _LudoSplashScreenState extends State<LudoSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );  
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LudoHomeScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LUDO',
                  style: GoogleFonts.rubikVinyl(
                    fontSize: 72,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Get Ready to Play!',
                  style: GoogleFonts.poppins(fontSize: 24, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
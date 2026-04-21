import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/ball_sort_controller.dart';
import 'screens/ball_sort_game_screen.dart';

/// Entry point widget for Ball Sort Puzzle Game
/// Add this to your Game Hub navigation as a route or tab.
///
/// Usage in your Game Hub:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => const BallSortApp(),
///   ));
class BallSortApp extends StatelessWidget {
  const BallSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BallSortController()..initialize(),
      child: Consumer<BallSortController>(
        builder: (context, ctrl, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ball Sort Puzzle',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.light,
              ),
              fontFamily: 'Roboto',
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.dark,
              ),
              fontFamily: 'Roboto',
            ),
            themeMode: ctrl.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const BallSortGameScreen(),
          );
        },
      ),
    );
  }
}

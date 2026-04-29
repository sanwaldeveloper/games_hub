import 'package:flutter/material.dart';
import 'package:games_hub/games_hub_view.dart';
import 'package:provider/provider.dart';

// Chess providers
import 'games/chess/game_controller.dart';

// Ludo
import 'package:games_hub/games/ludo/injection.dart';

// ✅ FIX: WSStorageService import
import 'package:games_hub/games/word_search_game/services/ws_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection(); // GetIt mein GameProvider register hoga

  // ✅ FIX: SharedPreferences init — bina is ke kuch bhi save nahi hoga
  await WSStorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Chess
        ChangeNotifierProvider(create: (_) => GameController()),

        // ✅ Jab koi nayi game add karo, yahan add karo:
        // ChangeNotifierProvider(create: (_) => SnakeController()),
        // ChangeNotifierProvider(create: (_) => TicTacToeController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Games Hub',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: GameHubScreen(),
      ),
    );
  }
}
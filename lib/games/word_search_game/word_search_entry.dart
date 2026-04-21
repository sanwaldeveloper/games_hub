// games/word_search/word_search_home.dart
// ─────────────────────────────────────────────────────────────
// GAME HUB INTEGRATION:
// Add this to your GameHubScreen gameItem list:
//
  // gameItem(
  //   Image.asset("assets/images/addon.png"),
  //   "Word Search",
  //   () {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => ChangeNotifierProvider(
  //           create: (_) => WSGameProvider()..initialize(),
  //           child: const WordSearchHome(),
  //         ),
  //       ),
  //     );
  //   },
  // ),
//
// Also add to pubspec.yaml dependencies:
//   shared_preferences: ^2.2.2
//   provider: ^6.1.1       (already in your project)
//   confetti: ^0.7.0
//   flutter_animate: ^4.3.0
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ws_game_provider.dart';
import 'services/ws_storage_service.dart';
import 'screens/ws_home_screen.dart';

class WordSearchEntry extends StatefulWidget {
  const WordSearchEntry({super.key});

  @override
  State<WordSearchEntry> createState() => _WordSearchEntryState();
}

class _WordSearchEntryState extends State<WordSearchEntry> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await WSStorageService.init();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => WSGameProvider()..initialize(),
      child: const WordSearchHome(),
    );
  }
}

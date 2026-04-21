// games/word_search/widgets/ws_word_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ws_game_provider.dart';
import '../utils/ws_theme.dart';

class WSWordList extends StatelessWidget {
  const WSWordList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WSGameProvider>(builder: (context, gp, _) {
      final gs = gp.gameState;
      if (gs == null) return const SizedBox();

      int colorIdx = 0;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: gs.placedWords.map((pw) {
          final color = WSTheme.wordColors[colorIdx % WSTheme.wordColors.length];
          colorIdx++;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pw.isFound ? color : Colors.transparent,
              border: Border.all(
                color: pw.isFound ? color : Colors.white24,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pw.isFound)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.check, size: 13, color: Colors.white),
                  ),
                Text(
                  pw.word,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: pw.isFound ? Colors.white : Colors.white70,
                    decoration: pw.isFound ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

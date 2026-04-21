import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/domain/game_repository.dart';
import 'package:games_hub/games/ludo/domain/models/player.dart';

class GameProvider extends ChangeNotifier {
  final GameRepository _repository;

  GameProvider({required GameRepository repository})
      : _repository = repository;

  List<Player> players = [];
  int currentPlayerIndex = 0;
  int? diceValue;
  bool isGameOver = false;
  DateTime? startTime;
  bool canRollDice = true;
  List<Token> validTokens = [];

  void startGame(int playerCount) {
    players = _repository.initializePlayers(playerCount);
    currentPlayerIndex = 0;
    startTime = DateTime.now();
    isGameOver = false;
    canRollDice = true;
    diceValue = null;
    validTokens = [];
    notifyListeners();
  }

  void rollDice() {
    if (!canRollDice) return;

    diceValue = _repository.rollDice();
    final currentPlayer = players[currentPlayerIndex];

    validTokens = _repository.getValidTokens(currentPlayer, diceValue!);

    canRollDice = false;
    notifyListeners();

    if (validTokens.isEmpty) {
      // No valid move – wait a moment so player can see the dice result,
      // then move to next player.
      Future.delayed(const Duration(milliseconds: 800), () {
        _moveToNextPlayer();
      });
    } else if (validTokens.length == 1) {
      // Auto-select if only one option
      Future.delayed(const Duration(milliseconds: 400), () {
        selectToken(validTokens.first);
      });
    }
    // else: player must tap a token on the board
  }

  void selectToken(Token token) {
    if (diceValue == null) return;

    final currentPlayer = players[currentPlayerIndex];
    final updatedPlayer =
        _repository.moveToken(currentPlayer, token, diceValue!);

    final updatedPlayers = List<Player>.from(players);
    updatedPlayers[currentPlayerIndex] = updatedPlayer;

    // Handle collisions with OTHER players
    final movedToken = updatedPlayer.tokens[token.id];
    if (movedToken.position != null) {
      for (var i = 0; i < updatedPlayers.length; i++) {
        if (i == currentPlayerIndex) continue;
        final afterCollision = _repository.handleCollision(
          updatedPlayers[i],
          movedToken.position!,
          updatedPlayers,
        );
        updatedPlayers[i] = afterCollision;
      }
    }

    players = updatedPlayers;
    validTokens = [];

    // Check winner
    if (_repository.checkWinner(players[currentPlayerIndex])) {
      isGameOver = true;
      notifyListeners();
      return;
    }

    // Rolling a 6 grants another turn
    if (diceValue == 6) {
      diceValue = null;
      canRollDice = true;
      notifyListeners();
    } else {
      diceValue = null;
      _moveToNextPlayer();
    }
  }

  void _moveToNextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    diceValue = null;
    canRollDice = true;
    validTokens = [];
    notifyListeners();
  }
}
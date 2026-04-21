


import 'package:games_hub/games/ludo/domain/models/board_position.dart';
import 'package:games_hub/games/ludo/domain/models/player.dart';

abstract class GameRepository {
  List<Player> initializePlayers(int playerCount);
  bool isValidMove(Player player, Token token, int diceValue);
  List<Token> getValidTokens(Player player, int diceValue);
  Player moveToken(Player player, Token token, int diceValue);
  bool checkWinner(Player player);
  int rollDice();
  List<BoardPosition> getPlayerPath(int playerId);
  bool checkCollision(BoardPosition position, List<Player> players);
  Player handleCollision(Player currentPlayer, BoardPosition position, List<Player> players);
}
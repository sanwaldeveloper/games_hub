import 'dart:math';
import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/domain/game_repository.dart';
import 'package:games_hub/games/ludo/domain/models/board_position.dart';
import 'package:games_hub/games/ludo/domain/models/player.dart';

class GameRepositoryImpl implements GameRepository {
  final _random = Random();

  // ── Safe spots ────────────────────────────────────────────────────────────
  static final Set<BoardPosition> _safeSpots = {
    BoardPosition(6, 2),
    BoardPosition(8, 1),
    BoardPosition(1, 6),
    BoardPosition(2, 8),
    BoardPosition(6, 13),
    BoardPosition(8, 12),
    BoardPosition(12, 6),
    BoardPosition(13, 8),
  };

  // ── Home waiting positions ────────────────────────────────────────────────
  static final List<List<BoardPosition>> _homePositions = [
    [BoardPosition(1, 1), BoardPosition(4, 1), BoardPosition(1, 4), BoardPosition(4, 4)],
    [BoardPosition(10, 1), BoardPosition(13, 1), BoardPosition(10, 4), BoardPosition(13, 4)],
    [BoardPosition(10, 10), BoardPosition(13, 10), BoardPosition(10, 13), BoardPosition(13, 13)],
    [BoardPosition(1, 10), BoardPosition(4, 10), BoardPosition(1, 13), BoardPosition(4, 13)],
  ];

  // ── RED path ──────────────────────────────────────────────────────────────
  static final List<BoardPosition> _redPath = [
    BoardPosition(1, 6), BoardPosition(2, 6), BoardPosition(3, 6),
    BoardPosition(4, 6), BoardPosition(5, 6), BoardPosition(6, 5),
    BoardPosition(6, 4), BoardPosition(6, 3), BoardPosition(6, 2),
    BoardPosition(6, 1), BoardPosition(6, 0), BoardPosition(7, 0),
    BoardPosition(8, 0), BoardPosition(8, 1), BoardPosition(8, 2),
    BoardPosition(8, 3), BoardPosition(8, 4), BoardPosition(8, 5),
    BoardPosition(9, 6), BoardPosition(10, 6), BoardPosition(11, 6),
    BoardPosition(12, 6), BoardPosition(13, 6), BoardPosition(14, 6),
    BoardPosition(14, 7), BoardPosition(14, 8), BoardPosition(13, 8),
    BoardPosition(12, 8), BoardPosition(11, 8), BoardPosition(10, 8),
    BoardPosition(9, 8), BoardPosition(8, 9), BoardPosition(8, 10),
    BoardPosition(8, 11), BoardPosition(8, 12), BoardPosition(8, 13),
    BoardPosition(8, 14), BoardPosition(7, 14), BoardPosition(6, 14),
    BoardPosition(6, 13), BoardPosition(6, 12), BoardPosition(6, 11),
    BoardPosition(6, 10), BoardPosition(6, 9), BoardPosition(5, 8),
    BoardPosition(4, 8), BoardPosition(3, 8), BoardPosition(2, 8),
    BoardPosition(1, 8), BoardPosition(0, 8), BoardPosition(0, 7),
    BoardPosition(0, 6),
    // Home stretch
    BoardPosition(1, 7), BoardPosition(2, 7), BoardPosition(3, 7),
    BoardPosition(4, 7), BoardPosition(5, 7),
    // Centre
    BoardPosition(7, 7),
  ];

  // ── GREEN path ────────────────────────────────────────────────────────────
  static final List<BoardPosition> _greenPath = [
    BoardPosition(8, 1), BoardPosition(8, 2), BoardPosition(8, 3),
    BoardPosition(8, 4), BoardPosition(8, 5), BoardPosition(9, 6),
    BoardPosition(10, 6), BoardPosition(11, 6), BoardPosition(12, 6),
    BoardPosition(13, 6), BoardPosition(14, 6), BoardPosition(14, 7),
    BoardPosition(14, 8), BoardPosition(13, 8), BoardPosition(12, 8),
    BoardPosition(11, 8), BoardPosition(10, 8), BoardPosition(9, 8),
    BoardPosition(8, 9), BoardPosition(8, 10), BoardPosition(8, 11),
    BoardPosition(8, 12), BoardPosition(8, 13), BoardPosition(8, 14),
    BoardPosition(7, 14), BoardPosition(6, 14), BoardPosition(6, 13),
    BoardPosition(6, 12), BoardPosition(6, 11), BoardPosition(6, 10),
    BoardPosition(6, 9), BoardPosition(5, 8), BoardPosition(4, 8),
    BoardPosition(3, 8), BoardPosition(2, 8), BoardPosition(1, 8),
    BoardPosition(0, 8), BoardPosition(0, 7), BoardPosition(0, 6),
    BoardPosition(1, 6), BoardPosition(2, 6), BoardPosition(3, 6),
    BoardPosition(4, 6), BoardPosition(5, 6), BoardPosition(6, 5),
    BoardPosition(6, 4), BoardPosition(6, 3), BoardPosition(6, 2),
    BoardPosition(6, 1), BoardPosition(6, 0), BoardPosition(7, 0),
    BoardPosition(8, 0),
    // Home stretch
    BoardPosition(7, 1), BoardPosition(7, 2), BoardPosition(7, 3),
    BoardPosition(7, 4), BoardPosition(7, 5),
    // Centre
    BoardPosition(7, 7),
  ];

  // ── YELLOW path ───────────────────────────────────────────────────────────
  static final List<BoardPosition> _yellowPath = [
    BoardPosition(13, 8), BoardPosition(12, 8), BoardPosition(11, 8),
    BoardPosition(10, 8), BoardPosition(9, 8), BoardPosition(8, 9),
    BoardPosition(8, 10), BoardPosition(8, 11), BoardPosition(8, 12),
    BoardPosition(8, 13), BoardPosition(8, 14), BoardPosition(7, 14),
    BoardPosition(6, 14), BoardPosition(6, 13), BoardPosition(6, 12),
    BoardPosition(6, 11), BoardPosition(6, 10), BoardPosition(6, 9),
    BoardPosition(5, 8), BoardPosition(4, 8), BoardPosition(3, 8),
    BoardPosition(2, 8), BoardPosition(1, 8), BoardPosition(0, 8),
    BoardPosition(0, 7), BoardPosition(0, 6), BoardPosition(1, 6),
    BoardPosition(2, 6), BoardPosition(3, 6), BoardPosition(4, 6),
    BoardPosition(5, 6), BoardPosition(6, 5), BoardPosition(6, 4),
    BoardPosition(6, 3), BoardPosition(6, 2), BoardPosition(6, 1),
    BoardPosition(6, 0), BoardPosition(7, 0), BoardPosition(8, 0),
    BoardPosition(8, 1), BoardPosition(8, 2), BoardPosition(8, 3),
    BoardPosition(8, 4), BoardPosition(8, 5), BoardPosition(9, 6),
    BoardPosition(10, 6), BoardPosition(11, 6), BoardPosition(12, 6),
    BoardPosition(13, 6), BoardPosition(14, 6), BoardPosition(14, 7),
    BoardPosition(14, 8),
    // Home stretch
    BoardPosition(13, 7), BoardPosition(12, 7), BoardPosition(11, 7),
    BoardPosition(10, 7), BoardPosition(9, 7),
    // Centre
    BoardPosition(7, 7),
  ];

  // ── BLUE path ─────────────────────────────────────────────────────────────
  static final List<BoardPosition> _bluePath = [
    BoardPosition(6, 13), BoardPosition(6, 12), BoardPosition(6, 11),
    BoardPosition(6, 10), BoardPosition(6, 9), BoardPosition(5, 8),
    BoardPosition(4, 8), BoardPosition(3, 8), BoardPosition(2, 8),
    BoardPosition(1, 8), BoardPosition(0, 8), BoardPosition(0, 7),
    BoardPosition(0, 6), BoardPosition(1, 6), BoardPosition(2, 6),
    BoardPosition(3, 6), BoardPosition(4, 6), BoardPosition(5, 6),
    BoardPosition(6, 5), BoardPosition(6, 4), BoardPosition(6, 3),
    BoardPosition(6, 2), BoardPosition(6, 1), BoardPosition(6, 0),
    BoardPosition(7, 0), BoardPosition(8, 0), BoardPosition(8, 1),
    BoardPosition(8, 2), BoardPosition(8, 3), BoardPosition(8, 4),
    BoardPosition(8, 5), BoardPosition(9, 6), BoardPosition(10, 6),
    BoardPosition(11, 6), BoardPosition(12, 6), BoardPosition(13, 6),
    BoardPosition(14, 6), BoardPosition(14, 7), BoardPosition(14, 8),
    BoardPosition(13, 8), BoardPosition(12, 8), BoardPosition(11, 8),
    BoardPosition(10, 8), BoardPosition(9, 8), BoardPosition(8, 9),
    BoardPosition(8, 10), BoardPosition(8, 11), BoardPosition(8, 12),
    BoardPosition(8, 13), BoardPosition(8, 14), BoardPosition(7, 14),
    BoardPosition(6, 14),
    // Home stretch
    BoardPosition(7, 13), BoardPosition(7, 12), BoardPosition(7, 11),
    BoardPosition(7, 10), BoardPosition(7, 9),
    // Centre
    BoardPosition(7, 7),
  ];

  // ─────────────────────────────────────────────────────────────────────────

  @override
  List<BoardPosition> getPlayerPath(int playerId) {
    switch (playerId) {
      case 0: return _redPath;
      case 1: return _greenPath;
      case 2: return _yellowPath;
      case 3: return _bluePath;
      default: return _redPath;
    }
  }

  @override
  List<Player> initializePlayers(int playerCount) {
    final colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];
    return List.generate(playerCount, (i) {
      final path = getPlayerPath(i);
      final homePos = _homePositions[i];
      return Player(
        id: i,
        color: colors[i],
        path: path,
        tokens: List.generate(
          4,
          (j) => Token(
            id: j,
            pathPosition: -1,
            isHome: true,
            isFinished: false,
            position: homePos[j],
          ),
        ),
      );
    });
  }

  @override
  int rollDice() => _random.nextInt(6) + 1;

  @override
  bool isValidMove(Player player, Token token, int diceValue) {
    if (token.isFinished) return false;
    if (token.isHome) return diceValue == 6;
    final newPos = token.pathPosition + diceValue;
    return newPos <= player.path.length - 1;
  }

  @override
  List<Token> getValidTokens(Player player, int diceValue) {
    return player.tokens
        .where((t) => isValidMove(player, t, diceValue))
        .toList();
  }

  @override
  Player moveToken(Player player, Token token, int diceValue) {
    final path = player.path;

    int newPathPos;
    bool isFinished = false;

    if (token.isHome) {
      newPathPos = 0;
    } else {
      newPathPos = token.pathPosition + diceValue;
    }

    if (newPathPos >= path.length - 1) {
      newPathPos = path.length - 1;
      isFinished = true;
    }

    final newPosition = path[newPathPos];

    final updatedToken = token.copyWith(
      pathPosition: newPathPos,
      isHome: false,
      isFinished: isFinished,
      position: newPosition,
    );

    final updatedTokens = List<Token>.from(player.tokens);
    updatedTokens[token.id] = updatedToken;

    return player.copyWith(tokens: updatedTokens);
  }

  @override
  bool checkWinner(Player player) {
    return player.tokens.every((t) => t.isFinished);
  }

  @override
  bool checkCollision(BoardPosition position, List<Player> players) {
    if (_safeSpots.contains(position)) return false;
    if (position == BoardPosition(7, 7)) return false;

    int count = 0;
    for (final p in players) {
      for (final t in p.tokens) {
        if (!t.isHome && !t.isFinished && t.position == position) count++;
      }
    }
    return count > 1;
  }

  @override
  Player handleCollision(
    Player otherPlayer,
    BoardPosition attackerPos,
    List<Player> allPlayers,
  ) {
    if (_safeSpots.contains(attackerPos)) return otherPlayer;
    if (attackerPos == BoardPosition(7, 7)) return otherPlayer;

    bool changed = false;
    final updatedTokens = otherPlayer.tokens.map((t) {
      if (!t.isHome && !t.isFinished && t.position == attackerPos) {
        changed = true;
        final homePos = _homePositions[otherPlayer.id][t.id];
        return Token(
          id: t.id,
          pathPosition: -1,
          isHome: true,
          isFinished: false,
          position: homePos,
        );
      }
      return t;
    }).toList();

    return changed ? otherPlayer.copyWith(tokens: updatedTokens) : otherPlayer;
  }
}
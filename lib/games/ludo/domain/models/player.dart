import 'package:flutter/material.dart';
import 'package:games_hub/games/ludo/domain/models/board_position.dart';


class Player {
  final int id;
  final Color color;
  final List<Token> tokens;
  final bool isActive;
  final List<BoardPosition> path;

  const Player({
    required this.id,
    required this.color,
    required this.tokens,
    this.isActive = false,
    required this.path,
  });

  Player copyWith({
    int? id,
    Color? color,
    List<Token>? tokens,
    bool? isActive,
    List<BoardPosition>? path,
  }) {
    return Player(
      id: id ?? this.id,
      color: color ?? this.color,
      tokens: tokens ?? this.tokens,
      isActive: isActive ?? this.isActive,
      path: path ?? this.path,
    );
  }
}

class Token {
  final int id;
  final int pathPosition;
  final bool isHome;
  final bool isFinished;
  final BoardPosition? position;

  const Token({
    required this.id,
    this.pathPosition = -1,
    this.isHome = true,
    this.isFinished = false,
    this.position,
  });

  Token copyWith({
    int? id,
    int? pathPosition,
    bool? isHome,
    bool? isFinished,
    BoardPosition? position,
  }) {
    return Token(
      id: id ?? this.id,
      pathPosition: pathPosition ?? this.pathPosition,
      isHome: isHome ?? this.isHome,
      isFinished: isFinished ?? this.isFinished,
      position: position ?? this.position,
    );
  }
}
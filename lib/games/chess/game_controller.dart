// ============================================================
// game_controller.dart
// Full chess game logic: move generation, validation, check/
// checkmate/stalemate detection, castling, en passant, promotion
// ============================================================

import 'package:flutter/foundation.dart';
import 'piece_model.dart';
import 'dart:math';

enum GameStatus { playing, check, checkmate, stalemate }

class GameController extends ChangeNotifier {
  // 8x8 board: null = empty square
  late List<List<ChessPiece?>> board;

  PieceColor currentTurn = PieceColor.white;
  GameStatus gameStatus = GameStatus.playing;

  Position? selectedPosition;
  List<Position> validMoves = [];

  // Move history for undo
  List<ChessMove> moveHistory = [];

  // En passant target square (the square a pawn can capture into)
  Position? enPassantTarget;

  // For AI
  bool aiEnabled = false;
  PieceColor aiColor = PieceColor.black;

  GameController() {
    _initBoard();
  }

  // 
  // BOARD INITIALIZATION
  // 

  void _initBoard() {
    board = List.generate(8, (_) => List.filled(8, null));

    // Place pawns
    for (int col = 0; col < 8; col++) {
      board[1][col] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      board[6][col] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
    }

    // Place back-rank pieces
    final backRank = [
      PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen,
      PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook,
    ];

    for (int col = 0; col < 8; col++) {
      board[0][col] = ChessPiece(type: backRank[col], color: PieceColor.black);
      board[7][col] = ChessPiece(type: backRank[col], color: PieceColor.white);
    }

    currentTurn = PieceColor.white;
    gameStatus = GameStatus.playing;
    selectedPosition = null;
    validMoves = [];
    moveHistory = [];
    enPassantTarget = null;
  }

  void restartGame() {
    _initBoard();
    notifyListeners();
  }

  // 
  // SELECTION & MOVE EXECUTION
  // 

  void onSquareTapped(Position pos) {
    if (gameStatus == GameStatus.checkmate ||
        gameStatus == GameStatus.stalemate) {
      return;
    }

    final piece = board[pos.row][pos.col];

    // If a piece is already selected
    if (selectedPosition != null) {
      // Tapped a valid move square → execute move
      if (validMoves.contains(pos)) {
        _executeMove(selectedPosition!, pos);
        selectedPosition = null;
        validMoves = [];
        notifyListeners();
        // Trigger AI after player move
        if (aiEnabled && currentTurn == aiColor &&
            gameStatus == GameStatus.playing) {
          Future.delayed(const Duration(milliseconds: 400), _makeAiMove);
        }
        return;
      }
      // Tapped own piece → re-select
      if (piece != null && piece.color == currentTurn) {
        selectedPosition = pos;
        validMoves = _getLegalMoves(pos);
        notifyListeners();
        return;
      }
      // Tapped empty or enemy without valid move → deselect
      selectedPosition = null;
      validMoves = [];
      notifyListeners();
      return;
    }

    // No piece selected yet → select if own piece
    if (piece != null && piece.color == currentTurn) {
      selectedPosition = pos;
      validMoves = _getLegalMoves(pos);
      notifyListeners();
    }
  }

  void _executeMove(Position from, Position to) {
    final piece = board[from.row][from.col]!;
    final captured = board[to.row][to.col];
    bool isEnPassantMove = false;
    bool isCastlingMove = false;
    Position? rookFrom;
    Position? rookTo;
    ChessPiece? enPassantCaptured;

    // ── En passant capture ──
    if (piece.type == PieceType.pawn &&
        enPassantTarget != null &&
        to == enPassantTarget) {
      isEnPassantMove = true;
      int captureRow = piece.color == PieceColor.white ? to.row + 1 : to.row - 1;
      enPassantCaptured = board[captureRow][to.col];
      board[captureRow][to.col] = null;
    }

    // ── Castling ──
    if (piece.type == PieceType.king && !piece.hasMoved) {
      int colDiff = to.col - from.col;
      if (colDiff == 2) {
        // Kingside
        isCastlingMove = true;
        rookFrom = Position(from.row, 7);
        rookTo = Position(from.row, 5);
        board[from.row][5] = board[from.row][7]!.copyWith(hasMoved: true);
        board[from.row][7] = null;
      } else if (colDiff == -2) {
        // Queenside
        isCastlingMove = true;
        rookFrom = Position(from.row, 0);
        rookTo = Position(from.row, 3);
        board[from.row][3] = board[from.row][0]!.copyWith(hasMoved: true);
        board[from.row][0] = null;
      }
    }

    // Record move before modifying
    final move = ChessMove(
      from: from,
      to: to,
      movedPiece: piece,
      capturedPiece: isEnPassantMove ? enPassantCaptured : captured,
      isCastling: isCastlingMove,
      isEnPassant: isEnPassantMove,
      rookFrom: rookFrom,
      rookTo: rookTo,
      wasFirstMove: !piece.hasMoved,
    );

    // Move piece
    board[to.row][to.col] = piece.copyWith(hasMoved: true);
    board[from.row][from.col] = null;

    // ── Pawn promotion ──
    if (piece.type == PieceType.pawn) {
      if ((piece.color == PieceColor.white && to.row == 0) ||
          (piece.color == PieceColor.black && to.row == 7)) {
        board[to.row][to.col] =
            ChessPiece(type: PieceType.queen, color: piece.color, hasMoved: true);
      }
    }

    // ── Update en passant target ──
    if (piece.type == PieceType.pawn &&
        (from.row - to.row).abs() == 2) {
      int epRow = (from.row + to.row) ~/ 2;
      enPassantTarget = Position(epRow, to.col);
    } else {
      enPassantTarget = null;
    }

    moveHistory.add(move);

    // Switch turn
    currentTurn =
        currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Update game status
    _updateGameStatus();
  }

  void undoMove() {
    if (moveHistory.isEmpty) return;

    final move = moveHistory.removeLast();

    // Restore moved piece
    board[move.from.row][move.from.col] =
        move.movedPiece.copyWith(hasMoved: !move.wasFirstMove);
    board[move.to.row][move.to.col] = null;

    // Restore captured piece
    if (move.isEnPassant && move.capturedPiece != null) {
      int captureRow = move.movedPiece.color == PieceColor.white
          ? move.to.row + 1
          : move.to.row - 1;
      board[captureRow][move.to.col] = move.capturedPiece;
    } else if (move.capturedPiece != null) {
      board[move.to.row][move.to.col] = move.capturedPiece;
    }

    // Restore castling rook
    if (move.isCastling && move.rookFrom != null && move.rookTo != null) {
      board[move.rookFrom!.row][move.rookFrom!.col] =
          board[move.rookTo!.row][move.rookTo!.col]!.copyWith(hasMoved: false);
      board[move.rookTo!.row][move.rookTo!.col] = null;
    }

    // Restore en passant
    if (moveHistory.isNotEmpty) {
      final prev = moveHistory.last;
      if (prev.movedPiece.type == PieceType.pawn &&
          (prev.from.row - prev.to.row).abs() == 2) {
        enPassantTarget =
            Position((prev.from.row + prev.to.row) ~/ 2, prev.to.col);
      } else {
        enPassantTarget = null;
      }
    } else {
      enPassantTarget = null;
    }

    currentTurn =
        currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;

    selectedPosition = null;
    validMoves = [];
    gameStatus = GameStatus.playing;
    _updateGameStatus();
    notifyListeners();
  }

  // 
  // GAME STATUS
  // 

  void _updateGameStatus() {
    bool inCheck = isKingInCheck(currentTurn, board);
    bool hasLegal = _hasAnyLegalMove(currentTurn);

    if (!hasLegal) {
      gameStatus = inCheck ? GameStatus.checkmate : GameStatus.stalemate;
    } else {
      gameStatus = inCheck ? GameStatus.check : GameStatus.playing;
    }
  }

  bool _hasAnyLegalMove(PieceColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.color == color) {
          if (_getLegalMoves(Position(r, c)).isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  // 
  // LEGAL MOVE GENERATION
  // 

  /// Returns all legal moves for a piece at [pos] (filters out moves leaving king in check)
  List<Position> _getLegalMoves(Position pos) {
    final piece = board[pos.row][pos.col];
    if (piece == null) return [];

    final candidates = _getPseudoLegalMoves(pos, piece, board, enPassantTarget);
    final legal = <Position>[];

    for (final target in candidates) {
      if (!_moveLeavesKingInCheck(pos, target, piece)) {
        legal.add(target);
      }
    }

    return legal;
  }

  bool _moveLeavesKingInCheck(Position from, Position to, ChessPiece piece) {
    // Simulate the move on a copy of the board
    final simBoard = _copyBoard(board);

    // En passant capture
    if (piece.type == PieceType.pawn &&
        enPassantTarget != null &&
        to == enPassantTarget) {
      int captureRow =
          piece.color == PieceColor.white ? to.row + 1 : to.row - 1;
      simBoard[captureRow][to.col] = null;
    }

    // Castling
    if (piece.type == PieceType.king && !piece.hasMoved) {
      int colDiff = to.col - from.col;
      if (colDiff == 2) {
        simBoard[from.row][5] = simBoard[from.row][7];
        simBoard[from.row][7] = null;
      } else if (colDiff == -2) {
        simBoard[from.row][3] = simBoard[from.row][0];
        simBoard[from.row][0] = null;
      }
    }

    simBoard[to.row][to.col] = piece.copyWith(hasMoved: true);
    simBoard[from.row][from.col] = null;

    return isKingInCheck(piece.color, simBoard);
  }

  // 
  // PSEUDO-LEGAL MOVE GENERATION (per piece type)
  // 

  List<Position> _getPseudoLegalMoves(
    Position pos,
    ChessPiece piece,
    List<List<ChessPiece?>> b,
    Position? epTarget,
  ) {
    switch (piece.type) {
      case PieceType.pawn:
        return _pawnMoves(pos, piece, b, epTarget);
      case PieceType.rook:
        return _slidingMoves(pos, piece, b, [[1,0],[-1,0],[0,1],[0,-1]]);
      case PieceType.bishop:
        return _slidingMoves(pos, piece, b, [[1,1],[1,-1],[-1,1],[-1,-1]]);
      case PieceType.queen:
        return _slidingMoves(pos, piece, b,
            [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]);
      case PieceType.knight:
        return _knightMoves(pos, piece, b);
      case PieceType.king:
        return _kingMoves(pos, piece, b);
    }
  }

  List<Position> _pawnMoves(
    Position pos,
    ChessPiece piece,
    List<List<ChessPiece?>> b,
    Position? epTarget,
  ) {
    final moves = <Position>[];
    int dir = piece.color == PieceColor.white ? -1 : 1;
    int startRow = piece.color == PieceColor.white ? 6 : 1;

    // Single step forward
    Position oneStep = Position(pos.row + dir, pos.col);
    if (oneStep.isValid && b[oneStep.row][oneStep.col] == null) {
      moves.add(oneStep);

      // Double step from start
      Position twoStep = Position(pos.row + 2 * dir, pos.col);
      if (pos.row == startRow && b[twoStep.row][twoStep.col] == null) {
        moves.add(twoStep);
      }
    }

    // Diagonal captures
    for (int dc in [-1, 1]) {
      Position cap = Position(pos.row + dir, pos.col + dc);
      if (cap.isValid) {
        final target = b[cap.row][cap.col];
        if (target != null && target.color != piece.color) {
          moves.add(cap);
        }
        // En passant
        if (epTarget != null && cap == epTarget) {
          moves.add(cap);
        }
      }
    }
    return moves;
  }

  List<Position> _slidingMoves(
    Position pos,
    ChessPiece piece,
    List<List<ChessPiece?>> b,
    List<List<int>> directions,
  ) {
    final moves = <Position>[];
    for (final dir in directions) {
      int r = pos.row + dir[0];
      int c = pos.col + dir[1];
      while (r >= 0 && r < 8 && c >= 0 && c < 8) {
        final target = b[r][c];
        if (target == null) {
          moves.add(Position(r, c));
        } else {
          if (target.color != piece.color) moves.add(Position(r, c));
          break;
        }
        r += dir[0];
        c += dir[1];
      }
    }
    return moves;
  }

  List<Position> _knightMoves(
    Position pos,
    ChessPiece piece,
    List<List<ChessPiece?>> b,
  ) {
    final moves = <Position>[];
    const offsets = [
      [-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]
    ];
    for (final off in offsets) {
      final target = Position(pos.row + off[0], pos.col + off[1]);
      if (target.isValid) {
        final piece2 = b[target.row][target.col];
        if (piece2 == null || piece2.color != piece.color) {
          moves.add(target);
        }
      }
    }
    return moves;
  }

  List<Position> _kingMoves(
    Position pos,
    ChessPiece piece,
    List<List<ChessPiece?>> b,
  ) {
    final moves = <Position>[];
    const offsets = [
      [-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]
    ];
    for (final off in offsets) {
      final target = Position(pos.row + off[0], pos.col + off[1]);
      if (target.isValid) {
        final piece2 = b[target.row][target.col];
        if (piece2 == null || piece2.color != piece.color) {
          moves.add(target);
        }
      }
    }

    // Castling
    if (!piece.hasMoved) {
      _addCastlingMoves(pos, piece, b, moves);
    }

    return moves;
  }

  void _addCastlingMoves(
    Position kingPos,
    ChessPiece king,
    List<List<ChessPiece?>> b,
    List<Position> moves,
  ) {
    int row = kingPos.row;

    // Kingside
    final kRook = b[row][7];
    if (kRook != null &&
        kRook.type == PieceType.rook &&
        kRook.color == king.color &&
        !kRook.hasMoved &&
        b[row][5] == null &&
        b[row][6] == null &&
        !isKingInCheck(king.color, b) &&
        !_squareAttacked(Position(row, 5), king.color, b) &&
        !_squareAttacked(Position(row, 6), king.color, b)) {
      moves.add(Position(row, 6));
    }

    // Queenside
    final qRook = b[row][0];
    if (qRook != null &&
        qRook.type == PieceType.rook &&
        qRook.color == king.color &&
        !qRook.hasMoved &&
        b[row][1] == null &&
        b[row][2] == null &&
        b[row][3] == null &&
        !isKingInCheck(king.color, b) &&
        !_squareAttacked(Position(row, 3), king.color, b) &&
        !_squareAttacked(Position(row, 2), king.color, b)) {
      moves.add(Position(row, 2));
    }
  }

  
  // CHECK DETECTION
   

  bool isKingInCheck(PieceColor color, List<List<ChessPiece?>> b) {
    Position? kingPos;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = b[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          kingPos = Position(r, c);
          break;
        }
      }
      if (kingPos != null) break;
    }
    if (kingPos == null) return false;
    return _squareAttacked(kingPos, color, b);
  }

  /// Returns true if [pos] is attacked by any enemy piece
  bool _squareAttacked(
    Position pos,
    PieceColor defenderColor,
    List<List<ChessPiece?>> b,
  ) {
    PieceColor attackerColor =
        defenderColor == PieceColor.white ? PieceColor.black : PieceColor.white;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final attacker = b[r][c];
        if (attacker == null || attacker.color != attackerColor) continue;
        final aMoves =
            _getPseudoLegalMoves(Position(r, c), attacker, b, null);
        if (aMoves.contains(pos)) return true;
      }
    }
    return false;
  }

  // 
  // AI (RANDOM MOVES)
  // 

  void toggleAi() {
    aiEnabled = !aiEnabled;
    notifyListeners();
  }

  void _makeAiMove() {
    if (gameStatus != GameStatus.playing && gameStatus != GameStatus.check) return;
    if (currentTurn != aiColor) return;

    final allMoves = <MapEntry<Position, Position>>[];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.color == aiColor) {
          final pos = Position(r, c);
          for (final move in _getLegalMoves(pos)) {
            allMoves.add(MapEntry(pos, move));
          }
        }
      }
    }

    if (allMoves.isEmpty) return;

    final rand = Random();
    final chosen = allMoves[rand.nextInt(allMoves.length)];
    _executeMove(chosen.key, chosen.value);
    notifyListeners();
  }

  // 
  // UTILITIES
  // 

  List<List<ChessPiece?>> _copyBoard(List<List<ChessPiece?>> b) {
    return List.generate(8, (r) => List.generate(8, (c) => b[r][c]));
  }

  String get statusMessage {
    switch (gameStatus) {
      case GameStatus.check:
        return '${currentTurn == PieceColor.white ? "White" : "Black"} is in Check!';
      case GameStatus.checkmate:
        final winner =
            currentTurn == PieceColor.white ? 'Black' : 'White';
        return 'Checkmate! $winner wins! 🎉';
      case GameStatus.stalemate:
        return 'Stalemate! It\'s a draw!';
      case GameStatus.playing:
        return '${currentTurn == PieceColor.white ? "White" : "Black"}\'s turn';
    }
  }
}

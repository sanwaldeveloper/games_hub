enum PieceType { pawn, rook, knight, bishop, queen, king }

enum PieceColor { white, black }

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved; 

  ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  String get symbol {
    if (color == PieceColor.white) {
      switch (type) {
        case PieceType.king:   return '♔';
        case PieceType.queen:  return '♕';
        case PieceType.rook:   return '♖';
        case PieceType.bishop: return '♗';
        case PieceType.knight: return '♘';
        case PieceType.pawn:   return '♙';
      }
    } else {
      switch (type) {
        case PieceType.king:   return '♚';
        case PieceType.queen:  return '♛';
        case PieceType.rook:   return '♜';
        case PieceType.bishop: return '♝';
        case PieceType.knight: return '♞';
        case PieceType.pawn:   return '♟';
      }
    }
  }

  ChessPiece copyWith({PieceType? type, PieceColor? color, bool? hasMoved}) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}

/// Represents a board position
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row * 8 + col;

  @override
  String toString() => '($row, $col)';
}

/// Represents a single move (with optional metadata)
class ChessMove {
  final Position from;
  final Position to;
  final ChessPiece? capturedPiece;
  final bool isCastling;
  final bool isEnPassant;
  final PieceType? promotionType;
  final Position? rookFrom;   // For castling
  final Position? rookTo;     // For castling
  final ChessPiece movedPiece;
  final bool wasFirstMove; // To restore hasMoved on undo

  ChessMove({
    required this.from,
    required this.to,
    required this.movedPiece,
    this.capturedPiece,
    this.isCastling = false,
    this.isEnPassant = false,
    this.promotionType,
    this.rookFrom,
    this.rookTo,
    this.wasFirstMove = false,
  });
}

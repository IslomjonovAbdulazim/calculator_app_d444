enum PieceType { king, queen, rook, bishop, knight, pawn }

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
    const Map<PieceType, Map<PieceColor, String>> symbols = {
      PieceType.king: {PieceColor.white: '♔', PieceColor.black: '♚'},
      PieceType.queen: {PieceColor.white: '♕', PieceColor.black: '♛'},
      PieceType.rook: {PieceColor.white: '♖', PieceColor.black: '♜'},
      PieceType.bishop: {PieceColor.white: '♗', PieceColor.black: '♝'},
      PieceType.knight: {PieceColor.white: '♘', PieceColor.black: '♞'},
      PieceType.pawn: {PieceColor.white: '♙', PieceColor.black: '♟'},
    };
    return symbols[type]![color]!;
  }

  ChessPiece copy() {
    return ChessPiece(
      type: type,
      color: color,
      hasMoved: hasMoved,
    );
  }

  int get value {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 1000;
    }
  }
}
import 'chess_piece.dart';

enum GameMode { twoPlayer, vsAi }
enum Difficulty { easy, medium, hard }
enum GameStatus { playing, check, checkmate, stalemate }

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}

class Move {
  final Position from;
  final Position to;
  final ChessPiece? capturedPiece;

  Move(this.from, this.to, [this.capturedPiece]);
}

class GameState {
  List<List<ChessPiece?>> board = List.generate(8, (_) => List.filled(8, null));
  PieceColor currentPlayer = PieceColor.white;
  GameMode gameMode = GameMode.twoPlayer;
  Difficulty difficulty = Difficulty.medium;
  GameStatus status = GameStatus.playing;
  List<Move> moveHistory = [];
  List<Position> possibleMoves = [];
  Position? selectedSquare;

  GameState() {
    _initializeBoard();
  }

  void _initializeBoard() {
    // Black pieces
    board[0] = [
      ChessPiece(type: PieceType.rook, color: PieceColor.black),
      ChessPiece(type: PieceType.knight, color: PieceColor.black),
      ChessPiece(type: PieceType.bishop, color: PieceColor.black),
      ChessPiece(type: PieceType.queen, color: PieceColor.black),
      ChessPiece(type: PieceType.king, color: PieceColor.black),
      ChessPiece(type: PieceType.bishop, color: PieceColor.black),
      ChessPiece(type: PieceType.knight, color: PieceColor.black),
      ChessPiece(type: PieceType.rook, color: PieceColor.black),
    ];

    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
    }

    // White pieces
    board[7] = [
      ChessPiece(type: PieceType.rook, color: PieceColor.white),
      ChessPiece(type: PieceType.knight, color: PieceColor.white),
      ChessPiece(type: PieceType.bishop, color: PieceColor.white),
      ChessPiece(type: PieceType.queen, color: PieceColor.white),
      ChessPiece(type: PieceType.king, color: PieceColor.white),
      ChessPiece(type: PieceType.bishop, color: PieceColor.white),
      ChessPiece(type: PieceType.knight, color: PieceColor.white),
      ChessPiece(type: PieceType.rook, color: PieceColor.white),
    ];

    for (int i = 0; i < 8; i++) {
      board[6][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
    }
  }

  void resetGame() {
    board = List.generate(8, (_) => List.filled(8, null));
    currentPlayer = PieceColor.white;
    status = GameStatus.playing;
    moveHistory.clear();
    possibleMoves.clear();
    selectedSquare = null;
    _initializeBoard();
  }

  GameState copy() {
    GameState copy = GameState();
    copy.board = board.map((row) =>
        row.map((piece) => piece?.copy()).toList()).toList();
    copy.currentPlayer = currentPlayer;
    copy.gameMode = gameMode;
    copy.difficulty = difficulty;
    copy.status = status;
    copy.moveHistory = List.from(moveHistory);
    copy.possibleMoves = List.from(possibleMoves);
    copy.selectedSquare = selectedSquare;
    return copy;
  }
}
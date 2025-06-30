import 'dart:math';
import '../models/game_state.dart';
import '../models/chess_piece.dart';

class ChessEngine {
  List<Position> getValidMoves(GameState gameState, Position position) {
    ChessPiece? piece = gameState.board[position.row][position.col];
    if (piece == null) return [];

    List<Position> moves = [];

    switch (piece.type) {
      case PieceType.pawn:
        moves = _getPawnMoves(gameState, position, piece);
        break;
      case PieceType.rook:
        moves = _getRookMoves(gameState, position, piece);
        break;
      case PieceType.bishop:
        moves = _getBishopMoves(gameState, position, piece);
        break;
      case PieceType.knight:
        moves = _getKnightMoves(gameState, position, piece);
        break;
      case PieceType.queen:
        moves = _getQueenMoves(gameState, position, piece);
        break;
      case PieceType.king:
        moves = _getKingMoves(gameState, position, piece);
        break;
    }

    return moves.where((move) => _isValidMove(gameState, position, move)).toList();
  }

  List<Position> _getPawnMoves(GameState gameState, Position pos, ChessPiece piece) {
    List<Position> moves = [];
    int direction = piece.color == PieceColor.white ? -1 : 1;
    int row = pos.row;
    int col = pos.col;

    // Forward move
    if (_isInBounds(row + direction, col) &&
        gameState.board[row + direction][col] == null) {
      moves.add(Position(row + direction, col));

      // Double move from starting position
      if (!piece.hasMoved && _isInBounds(row + 2 * direction, col) &&
          gameState.board[row + 2 * direction][col] == null) {
        moves.add(Position(row + 2 * direction, col));
      }
    }

    // Diagonal captures
    for (int deltaCol in [-1, 1]) {
      if (_isInBounds(row + direction, col + deltaCol)) {
        ChessPiece? target = gameState.board[row + direction][col + deltaCol];
        if (target != null && target.color != piece.color) {
          moves.add(Position(row + direction, col + deltaCol));
        }
      }
    }

    return moves;
  }

  List<Position> _getRookMoves(GameState gameState, Position pos, ChessPiece piece) {
    List<Position> moves = [];
    List<List<int>> directions = [[0, 1], [0, -1], [1, 0], [-1, 0]];

    for (List<int> dir in directions) {
      moves.addAll(_getMovesInDirection(gameState, pos, piece, dir[0], dir[1]));
    }

    return moves;
  }

  List<Position> _getBishopMoves(GameState gameState, Position pos, ChessPiece piece) {
    List<Position> moves = [];
    List<List<int>> directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]];

    for (List<int> dir in directions) {
      moves.addAll(_getMovesInDirection(gameState, pos, piece, dir[0], dir[1]));
    }

    return moves;
  }

  List<Position> _getKnightMoves(GameState gameState, Position pos, ChessPiece piece) {
    List<Position> moves = [];
    List<List<int>> knightMoves = [
      [2, 1], [2, -1], [-2, 1], [-2, -1],
      [1, 2], [1, -2], [-1, 2], [-1, -2]
    ];

    for (List<int> move in knightMoves) {
      int newRow = pos.row + move[0];
      int newCol = pos.col + move[1];

      if (_isInBounds(newRow, newCol)) {
        ChessPiece? target = gameState.board[newRow][newCol];
        if (target == null || target.color != piece.color) {
          moves.add(Position(newRow, newCol));
        }
      }
    }

    return moves;
  }

  List<Position> _getQueenMoves(GameState gameState, Position pos, ChessPiece piece) {
    List<Position> moves = [];
    moves.addAll(_getRookMoves(gameState, pos, piece));
    moves.addAll(_getBishopMoves(gameState, pos, piece));
    return moves;
  }

  List<Position> _getKingMoves(GameState gameState, Position pos, ChessPiece piece) {
    List<Position> moves = [];

    for (int deltaRow = -1; deltaRow <= 1; deltaRow++) {
      for (int deltaCol = -1; deltaCol <= 1; deltaCol++) {
        if (deltaRow == 0 && deltaCol == 0) continue;

        int newRow = pos.row + deltaRow;
        int newCol = pos.col + deltaCol;

        if (_isInBounds(newRow, newCol)) {
          ChessPiece? target = gameState.board[newRow][newCol];
          if (target == null || target.color != piece.color) {
            moves.add(Position(newRow, newCol));
          }
        }
      }
    }

    return moves;
  }

  List<Position> _getMovesInDirection(GameState gameState, Position pos,
      ChessPiece piece, int deltaRow, int deltaCol) {
    List<Position> moves = [];

    for (int i = 1; i < 8; i++) {
      int newRow = pos.row + i * deltaRow;
      int newCol = pos.col + i * deltaCol;

      if (!_isInBounds(newRow, newCol)) break;

      ChessPiece? target = gameState.board[newRow][newCol];
      if (target == null) {
        moves.add(Position(newRow, newCol));
      } else {
        if (target.color != piece.color) {
          moves.add(Position(newRow, newCol));
        }
        break;
      }
    }

    return moves;
  }

  bool _isInBounds(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool _isValidMove(GameState gameState, Position from, Position to) {
    GameState testState = gameState.copy();
    ChessPiece? piece = testState.board[from.row][from.col];
    if (piece == null) return false;

    // Simulate move
    testState.board[to.row][to.col] = piece;
    testState.board[from.row][from.col] = null;

    return !_isInCheck(testState, piece.color);
  }

  bool _isInCheck(GameState gameState, PieceColor color) {
    Position? kingPos = _findKing(gameState, color);
    if (kingPos == null) return false;

    PieceColor opponentColor = color == PieceColor.white
        ? PieceColor.black : PieceColor.white;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = gameState.board[row][col];
        if (piece != null && piece.color == opponentColor) {
          List<Position> attacks = _getAttackingMoves(gameState, Position(row, col), piece);
          if (attacks.any((pos) => pos.row == kingPos.row && pos.col == kingPos.col)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  Position? _findKing(GameState gameState, PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = gameState.board[row][col];
        if (piece != null && piece.type == PieceType.king && piece.color == color) {
          return Position(row, col);
        }
      }
    }
    return null;
  }

  List<Position> _getAttackingMoves(GameState gameState, Position pos, ChessPiece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return _getPawnAttacks(pos, piece);
      default:
        return getValidMoves(gameState, pos);
    }
  }

  List<Position> _getPawnAttacks(Position pos, ChessPiece piece) {
    List<Position> attacks = [];
    int direction = piece.color == PieceColor.white ? -1 : 1;

    for (int deltaCol in [-1, 1]) {
      int newRow = pos.row + direction;
      int newCol = pos.col + deltaCol;
      if (_isInBounds(newRow, newCol)) {
        attacks.add(Position(newRow, newCol));
      }
    }

    return attacks;
  }

  void makeMove(GameState gameState, Move move) {
    ChessPiece? piece = gameState.board[move.from.row][move.from.col];
    if (piece != null) {
      piece.hasMoved = true;
      gameState.board[move.to.row][move.to.col] = piece;
      gameState.board[move.from.row][move.from.col] = null;
      gameState.moveHistory.add(move);
    }
  }

  void undoMove(GameState gameState) {
    if (gameState.moveHistory.isEmpty) return;

    Move lastMove = gameState.moveHistory.removeLast();
    ChessPiece? piece = gameState.board[lastMove.to.row][lastMove.to.col];

    if (piece != null) {
      gameState.board[lastMove.from.row][lastMove.from.col] = piece;
      gameState.board[lastMove.to.row][lastMove.to.col] = lastMove.capturedPiece;

      // Reset hasMoved if it was the first move
      if (gameState.moveHistory.where((m) =>
      m.from.row == lastMove.from.row &&
          m.from.col == lastMove.from.col).isEmpty) {
        piece.hasMoved = false;
      }
    }

    gameState.currentPlayer = gameState.currentPlayer == PieceColor.white
        ? PieceColor.black : PieceColor.white;
  }

  GameStatus getGameStatus(GameState gameState) {
    if (_isInCheck(gameState, gameState.currentPlayer)) {
      if (_hasValidMoves(gameState, gameState.currentPlayer)) {
        return GameStatus.check;
      } else {
        return GameStatus.checkmate;
      }
    } else if (!_hasValidMoves(gameState, gameState.currentPlayer)) {
      return GameStatus.stalemate;
    }

    return GameStatus.playing;
  }

  bool _hasValidMoves(GameState gameState, PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = gameState.board[row][col];
        if (piece != null && piece.color == color) {
          if (getValidMoves(gameState, Position(row, col)).isNotEmpty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Move? getBestMove(GameState gameState) {
    List<Move> allMoves = _getAllValidMoves(gameState, gameState.currentPlayer);
    if (allMoves.isEmpty) return null;

    switch (gameState.difficulty) {
      case Difficulty.easy:
        return allMoves[Random().nextInt(allMoves.length)];
      case Difficulty.medium:
        return _getMediumMove(gameState, allMoves);
      case Difficulty.hard:
        return _getHardMove(gameState, allMoves);
    }
  }

  List<Move> _getAllValidMoves(GameState gameState, PieceColor color) {
    List<Move> moves = [];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = gameState.board[row][col];
        if (piece != null && piece.color == color) {
          Position from = Position(row, col);
          List<Position> validMoves = getValidMoves(gameState, from);
          for (Position to in validMoves) {
            moves.add(Move(from, to, gameState.board[to.row][to.col]));
          }
        }
      }
    }

    return moves;
  }

  Move _getMediumMove(GameState gameState, List<Move> moves) {
    // Prioritize captures
    List<Move> captures = moves.where((m) => m.capturedPiece != null).toList();
    if (captures.isNotEmpty) {
      captures.sort((a, b) => b.capturedPiece!.value.compareTo(a.capturedPiece!.value));
      return captures.first;
    }

    return moves[Random().nextInt(moves.length)];
  }

  Move _getHardMove(GameState gameState, List<Move> moves) {
    int bestScore = -9999;
    Move? bestMove;

    for (Move move in moves) {
      GameState testState = gameState.copy();
      makeMove(testState, move);
      int score = _minimax(testState, 2, false, -10000, 10000);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? moves[Random().nextInt(moves.length)];
  }

  int _minimax(GameState gameState, int depth, bool isMaximizing, int alpha, int beta) {
    if (depth == 0) return _evaluatePosition(gameState);

    List<Move> moves = _getAllValidMoves(gameState, gameState.currentPlayer);

    if (isMaximizing) {
      int maxEval = -9999;
      for (Move move in moves) {
        GameState testState = gameState.copy();
        makeMove(testState, move);
        testState.currentPlayer = testState.currentPlayer == PieceColor.white
            ? PieceColor.black : PieceColor.white;
        int eval = _minimax(testState, depth - 1, false, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 9999;
      for (Move move in moves) {
        GameState testState = gameState.copy();
        makeMove(testState, move);
        testState.currentPlayer = testState.currentPlayer == PieceColor.white
            ? PieceColor.black : PieceColor.white;
        int eval = _minimax(testState, depth - 1, true, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  int _evaluatePosition(GameState gameState) {
    int score = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = gameState.board[row][col];
        if (piece != null) {
          int pieceValue = piece.value;
          if (piece.color == PieceColor.black) {
            score += pieceValue;
          } else {
            score -= pieceValue;
          }
        }
      }
    }

    return score;
  }
}
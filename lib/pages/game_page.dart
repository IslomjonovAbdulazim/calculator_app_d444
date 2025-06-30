import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/chess_piece.dart';
import '../widgets/chess_board.dart';
import '../widgets/game_controls.dart';
import '../services/chess_engine.dart';

class GamePage extends StatefulWidget {
  final GameMode gameMode;
  final Difficulty difficulty;

  GamePage({required this.gameMode, required this.difficulty});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameState gameState;
  late ChessEngine chessEngine;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    gameState.gameMode = widget.gameMode;
    gameState.difficulty = widget.difficulty;
    chessEngine = ChessEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getGameModeText()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ChessBoard(
                  gameState: gameState,
                  onSquareTapped: _onSquareTapped,
                ),
              ),
            ),
          ),
          GameControls(
            gameState: gameState,
            onUndo: _undoMove,
            onNewGame: _resetGame,
          ),
        ],
      ),
    );
  }

  String _getGameModeText() {
    if (gameState.gameMode == GameMode.twoPlayer) {
      return 'Two Players';
    } else {
      return 'vs Computer (${_getDifficultyText()})';
    }
  }

  String _getDifficultyText() {
    switch (gameState.difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  void _onSquareTapped(int row, int col) {
    if (gameState.status != GameStatus.playing) return;

    if (gameState.gameMode == GameMode.vsAi &&
        gameState.currentPlayer == PieceColor.black) return;

    Position tappedPosition = Position(row, col);

    if (gameState.selectedSquare == null) {
      _selectSquare(tappedPosition);
    } else if (gameState.selectedSquare == tappedPosition) {
      _deselectSquare();
    } else if (gameState.possibleMoves.contains(tappedPosition)) {
      _makeMove(gameState.selectedSquare!, tappedPosition);
    } else {
      _selectSquare(tappedPosition);
    }
  }

  void _selectSquare(Position position) {
    ChessPiece? piece = gameState.board[position.row][position.col];
    if (piece != null && piece.color == gameState.currentPlayer) {
      setState(() {
        gameState.selectedSquare = position;
        gameState.possibleMoves = chessEngine.getValidMoves(gameState, position);
      });
    }
  }

  void _deselectSquare() {
    setState(() {
      gameState.selectedSquare = null;
      gameState.possibleMoves.clear();
    });
  }

  void _makeMove(Position from, Position to) {
    ChessPiece? capturedPiece = gameState.board[to.row][to.col];
    Move move = Move(from, to, capturedPiece);

    chessEngine.makeMove(gameState, move);

    setState(() {
      gameState.selectedSquare = null;
      gameState.possibleMoves.clear();
      gameState.currentPlayer = gameState.currentPlayer == PieceColor.white
          ? PieceColor.black : PieceColor.white;
    });

    _checkGameStatus();

    if (gameState.gameMode == GameMode.vsAi &&
        gameState.currentPlayer == PieceColor.black &&
        gameState.status == GameStatus.playing) {
      Future.delayed(Duration(milliseconds: 500), _makeAiMove);
    }
  }

  void _makeAiMove() {
    Move? aiMove = chessEngine.getBestMove(gameState);
    if (aiMove != null) {
      chessEngine.makeMove(gameState, aiMove);
      setState(() {
        gameState.currentPlayer = PieceColor.white;
      });
      _checkGameStatus();
    }
  }

  void _checkGameStatus() {
    gameState.status = chessEngine.getGameStatus(gameState);
    if (gameState.status != GameStatus.playing) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    String message = '';
    switch (gameState.status) {
      case GameStatus.checkmate:
        PieceColor winner = gameState.currentPlayer == PieceColor.white
            ? PieceColor.black : PieceColor.white;
        message = '${winner == PieceColor.white ? "White" : "Black"} wins!';
        break;
      case GameStatus.stalemate:
        message = 'Stalemate - Draw!';
        break;
      case GameStatus.check:
        message = 'Check!';
        return;
      case GameStatus.playing:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('New Game'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Home'),
          ),
        ],
      ),
    );
  }

  void _undoMove() {
    if (gameState.moveHistory.isEmpty) return;

    chessEngine.undoMove(gameState);
    if (gameState.gameMode == GameMode.vsAi && gameState.moveHistory.isNotEmpty) {
      chessEngine.undoMove(gameState);
    }

    setState(() {
      gameState.selectedSquare = null;
      gameState.possibleMoves.clear();
      gameState.status = GameStatus.playing;
    });
  }

  void _resetGame() {
    setState(() {
      gameState.resetGame();
    });
  }
}
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/chess_piece.dart';

class GameControls extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onUndo;
  final VoidCallback onNewGame;

  GameControls({
    required this.gameState,
    required this.onUndo,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: gameState.moveHistory.isNotEmpty ? onUndo : null,
                icon: Icon(Icons.undo),
                label: Text('Undo'),
              ),
              ElevatedButton.icon(
                onPressed: onNewGame,
                icon: Icon(Icons.refresh),
                label: Text('New Game'),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildGameInfo(),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    String currentPlayerText = gameState.currentPlayer == PieceColor.white
        ? "White's turn" : "Black's turn";

    String statusText = '';
    Color statusColor = Colors.black;

    switch (gameState.status) {
      case GameStatus.check:
        statusText = ' - Check!';
        statusColor = Colors.red;
        break;
      case GameStatus.checkmate:
        statusText = ' - Checkmate!';
        statusColor = Colors.red;
        break;
      case GameStatus.stalemate:
        statusText = ' - Stalemate!';
        statusColor = Colors.orange;
        break;
      case GameStatus.playing:
        break;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentPlayerText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (statusText.isNotEmpty)
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Moves: ${gameState.moveHistory.length}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
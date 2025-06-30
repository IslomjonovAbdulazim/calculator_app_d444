import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/chess_piece.dart';
import 'chess_square.dart';

class ChessBoard extends StatelessWidget {
  final GameState gameState;
  final Function(int, int) onSquareTapped;

  ChessBoard({required this.gameState, required this.onSquareTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(8, (row) {
          return Expanded(
            child: Row(
              children: List.generate(8, (col) {
                return Expanded(
                  child: ChessSquare(
                    piece: gameState.board[row][col],
                    position: Position(row, col),
                    isSelected: gameState.selectedSquare?.row == row &&
                        gameState.selectedSquare?.col == col,
                    isPossibleMove: gameState.possibleMoves.any(
                          (pos) => pos.row == row && pos.col == col,
                    ),
                    isLightSquare: (row + col) % 2 == 0,
                    onTap: () => onSquareTapped(row, col),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import '../models/game_state.dart';

class ChessSquare extends StatelessWidget {
  final ChessPiece? piece;
  final Position position;
  final bool isSelected;
  final bool isPossibleMove;
  final bool isLightSquare;
  final VoidCallback onTap;

  ChessSquare({
    required this.piece,
    required this.position,
    required this.isSelected,
    required this.isPossibleMove,
    required this.isLightSquare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color squareColor = isLightSquare ? Colors.brown[200]! : Colors.brown[600]!;

    if (isSelected) {
      squareColor = Colors.yellow[400]!;
    } else if (isPossibleMove) {
      squareColor = Colors.green[300]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: squareColor,
          border: isPossibleMove
              ? Border.all(color: Colors.green[700]!, width: 2)
              : null,
        ),
        child: Center(
          child: piece != null
              ? Text(
            piece!.symbol,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          )
              : isPossibleMove
              ? Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
          )
              : null,
        ),
      ),
    );
  }
}
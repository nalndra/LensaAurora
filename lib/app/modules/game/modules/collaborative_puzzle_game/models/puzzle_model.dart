import 'package:flutter/material.dart';

class PuzzleModel {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final int numberOfPieces;
  final List<PuzzlePiece> pieces;
  final Size boardSize;

  PuzzleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.numberOfPieces,
    required this.pieces,
    required this.boardSize,
  });
}

class PuzzlePiece {
  final String id;
  final int gridX;
  final int gridY;
  Offset currentPosition;
  bool isPlaced;

  // For touch tracking
  int fingersOnThis = 0;

  PuzzlePiece({
    required this.id,
    required this.gridX,
    required this.gridY,
    required this.currentPosition,
    this.isPlaced = false,
  });

  // Get correct position in solution area
  Offset getCorrectPosition(Size solutionAreaSize, int totalCols) {
    double cellWidth = solutionAreaSize.width / totalCols;
    double cellHeight = solutionAreaSize.height / 3;
    
    return Offset(
      gridX * cellWidth + cellWidth / 2,
      gridY * cellHeight + cellHeight / 2,
    );
  }

  bool isWithinCorrectPosition(
    Offset position,
    Offset solutionAreaCenter,
    Size cellSize,
  ) {
    final correctPos = Offset(
      solutionAreaCenter.dx + (gridX - 1.5) * cellSize.width,
      solutionAreaCenter.dy + (gridY - 1) * cellSize.height,
    );

    return (position - correctPos).distance <= cellSize.width * 0.3;
  }

  void addFinger() => fingersOnThis++;
  void removeFinger() => fingersOnThis = (fingersOnThis - 1).clamp(0, 10);
  bool hasMultipleFinger() => fingersOnThis >= 2;
  bool isBeingTouched() => fingersOnThis > 0;
}

class GameStats {
  int totalMoves = 0;
  int functionalMoves = 0; // Moves that complete puzzle
  int coordinationMoves = 0; // Moves for negotiation
  int correctPlacements = 0;
  int incorrectAttempts = 0;
  Duration elapsedTime = Duration.zero;

  double get coordinationRate =>
      totalMoves > 0 ? coordinationMoves / totalMoves : 0;
}

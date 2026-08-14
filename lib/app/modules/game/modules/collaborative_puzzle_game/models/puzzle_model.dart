import 'package:flutter/material.dart';

class PuzzleModel {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final int numberOfPieces;
  final List<PuzzlePiece> pieces;
  final Size boardSize;
  final int gridCols;
  final int gridRows;

  /// width / height of the source image. Drives every adaptive dimension
  /// in the game board (preview, solution area, piece size) so the
  /// solution area always matches the picture 1:1 and pieces tile
  /// together into it without stretching or gaps.
  final double imageAspectRatio;

  PuzzleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.numberOfPieces,
    required this.pieces,
    required this.boardSize,
    required this.gridCols,
    required this.gridRows,
    required this.imageAspectRatio,
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

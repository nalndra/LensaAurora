import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/puzzle_model.dart';

class CollaborativePuzzleGameController extends GetxController {
  late RxList<PuzzleModel> puzzles;
  late Rx<PuzzleModel?> currentPuzzle;
  late RxList<PuzzlePiece> pieces;
  late Rx<PuzzlePiece?> selectedPiece;
  late Rx<Offset> dragOffset;
  late RxBool gameCompleted;
  late RxDouble progress;
  late Rx<GameStats> stats;

  final List<int> _touchedPiecesWithFingers = [];

  @override
  void onInit() {
    super.onInit();
    _initializePuzzles();
    currentPuzzle = Rx(null);
    pieces = RxList<PuzzlePiece>([]);
    selectedPiece = Rx(null);
    dragOffset = Rx(Offset.zero);
    gameCompleted = RxBool(false);
    progress = RxDouble(0);
    stats = Rx(GameStats());
  }

  void _initializePuzzles() {
    puzzles = RxList<PuzzleModel>([
      _createPuzzle(
        id: '1',
        title: 'Landscape',
        description: 'Pemandangan alam yang indah',
        imagePath: 'assets/images/landscape.jpg',
        pieces: 8,
      ),
      _createPuzzle(
        id: '2',
        title: 'Puzzle Together',
        description: 'Kolaborasi puzzle bersama',
        imagePath: 'assets/puzzletogether.jpg',
        pieces: 12,
      ),
    ]);
  }

  PuzzleModel _createPuzzle({
    required String id,
    required String title,
    required String description,
    required String imagePath,
    required int pieces,
  }) {
    final cols = (pieces / 2).ceil();
    final rows = 2;
    final puzzlePieces = <PuzzlePiece>[];

    for (int i = 0; i < pieces; i++) {
      final x = i % cols;
      final y = i ~/ cols;
      puzzlePieces.add(
        PuzzlePiece(
          id: 'piece_$i',
          gridX: x,
          gridY: y,
          currentPosition: Offset(
            (x * 100.0) + (y * 50.0),
            (y * 100.0) + (x * 30.0),
          ),
        ),
      );
    }

    return PuzzleModel(
      id: id,
      title: title,
      description: description,
      imagePath: imagePath,
      numberOfPieces: pieces,
      pieces: puzzlePieces,
      boardSize: Size(cols * 100, rows * 100),
    );
  }

  void startGame(String puzzleId) {
    final puzzle = puzzles.firstWhereOrNull((p) => p.id == puzzleId);
    if (puzzle != null) {
      currentPuzzle.value = puzzle;
      pieces.assignAll(puzzle.pieces);
      gameCompleted.value = false;
      progress.value = 0;
      stats.value = GameStats();
    }
  }

  // Enforced Collaboration: Handle multi-touch
  void onFingerDown(int pointerId, PuzzlePiece piece) {
    piece.addFinger();
    _touchedPiecesWithFingers.add(piece.fingersOnThis);

    if (piece.hasMultipleFinger()) {
      selectedPiece.value = piece;
    }
  }

  void onFingerUp(int pointerId, PuzzlePiece piece) {
    piece.removeFinger();

    // If piece loses collaborative touch, it can't move
    if (!piece.hasMultipleFinger()) {
      selectedPiece.value = null;
      _playOscillationAnimation(piece);
    }
  }

  void onPieceDragged(PuzzlePiece piece, Offset offset) {
    // Only allow drag if piece has 2+ fingers (collaborative)
    if (piece.hasMultipleFinger() && !piece.isPlaced) {
      piece.currentPosition = offset;
      dragOffset.value = offset;
      stats.value.totalMoves++;
    }
  }

  void onPieceReleased(PuzzlePiece piece, Offset releasePosition) {
    if (!piece.isPlaced && piece.hasMultipleFinger()) {
      // Check if placed correctly
      _checkPiecePlacement(piece, releasePosition);
    } else if (!piece.hasMultipleFinger()) {
      // Piece must be touched by 2 fingers - vibrate and reset
      _playRejectAnimation(piece);
    }
    selectedPiece.value = null;
  }

  void _checkPiecePlacement(PuzzlePiece piece, Offset position) {
    final puzzle = currentPuzzle.value;
    if (puzzle == null) return;

    // Simulate solution area (bottom center)
    final solutionAreaSize = Size(300, 200);
    final solutionAreaCenter = Offset(200, 350);
    final cellSize = Size(
      solutionAreaSize.width / (puzzle.numberOfPieces / 2).ceil(),
      solutionAreaSize.height / 2,
    );

    // Check if within solution area bounds
    final isInSolutionArea = position.dx > (solutionAreaCenter.dx - 150) &&
        position.dx < (solutionAreaCenter.dx + 150) &&
        position.dy > (solutionAreaCenter.dy - 100) &&
        position.dy < (solutionAreaCenter.dy + 100);

    if (isInSolutionArea &&
        piece.isWithinCorrectPosition(position, solutionAreaCenter, cellSize)) {
      _onCorrectPlacement(piece);
    } else if (isInSolutionArea) {
      _onIncorrectPlacement(piece);
    }
  }

  void _onCorrectPlacement(PuzzlePiece piece) {
    piece.isPlaced = true;
    stats.value.functionalMoves++;
    stats.value.correctPlacements++;
    
    _updateProgress();
    _playSuccessAnimation(piece);

    // Check if all pieces placed
    if (pieces.every((p) => p.isPlaced)) {
      _completeGame();
    }
  }

  void _onIncorrectPlacement(PuzzlePiece piece) {
    stats.value.coordinationMoves++; // Negotiation needed
    stats.value.incorrectAttempts++;
    _playErrorAnimation(piece);
  }

  void _updateProgress() {
    final placed = pieces.where((p) => p.isPlaced).length;
    progress.value = placed / pieces.length;
  }

  void _completeGame() {
    gameCompleted.value = true;
    _playCompletionAnimation();
  }

  void _playOscillationAnimation(PuzzlePiece piece) {
    // Visual feedback: piece oscillates when only 1 finger
    // This would be handled in the UI with animation
  }

  void _playRejectAnimation(PuzzlePiece piece) {
    // Visual & audio feedback: reject animation + sound
  }

  void _playSuccessAnimation(PuzzlePiece piece) {
    // Visual & audio feedback: green halo + beep
  }

  void _playErrorAnimation(PuzzlePiece piece) {
    // Visual & audio feedback: red halo + buzz
  }

  void _playCompletionAnimation() {
    // Victory animation + celebratory music
  }

  void resetGame() {
    if (currentPuzzle.value != null) {
      startGame(currentPuzzle.value!.id);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

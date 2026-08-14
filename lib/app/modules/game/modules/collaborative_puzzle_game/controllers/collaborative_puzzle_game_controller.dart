import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
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

  // Keys the view attaches to the board Stack and the solution-area
  // Container so placement checks can use the *actual* rendered geometry
  // instead of guessed pixel constants — this is what makes drop
  // detection work correctly at any screen size.
  final GlobalKey gameBoardKey = GlobalKey();
  final GlobalKey solutionAreaKey = GlobalKey();

  bool _scatterLaidOut = false;

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
        title: 'Starry Night',
        description: 'Lukisan langit malam penuh bintang',
        imagePath: 'assets/puzzle/starry-night-puzzle.png',
        pieces: 8,
        // Source image is 1280x1014.
        imageAspectRatio: 1280 / 1014,
      ),
    ]);
  }

  PuzzleModel _createPuzzle({
    required String id,
    required String title,
    required String description,
    required String imagePath,
    required int pieces,
    required double imageAspectRatio,
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
          // Real positions are assigned once the board's actual on-screen
          // size is known — see ensureScatterLayout below.
          currentPosition: Offset.zero,
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
      gridCols: cols,
      gridRows: rows,
      imageAspectRatio: imageAspectRatio,
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
      _scatterLaidOut = false;
    }
  }

  /// Scatters pieces across the "pieces" strip of the board using the
  /// piece size the view just computed from the image's real aspect
  /// ratio. Safe to call on every build — it only does work once per
  /// game (until [startGame] resets the flag).
  void ensureScatterLayout({
    required double areaWidth,
    required double areaTop,
    required double areaHeight,
    required double pieceWidth,
    required double pieceHeight,
  }) {
    if (_scatterLaidOut || pieces.isEmpty) return;
    _scatterLaidOut = true;

    final perRow = (areaWidth / pieceWidth).floor().clamp(1, pieces.length);
    for (var i = 0; i < pieces.length; i++) {
      final col = i % perRow;
      final row = i ~/ perRow;
      pieces[i].currentPosition = Offset(
        col * pieceWidth + pieceWidth / 2,
        areaTop + row * pieceHeight + pieceHeight / 2,
      );
    }
  }

  /// Rect of the solution-area Container, in coordinates local to the
  /// board Stack (i.e. directly usable as a piece's currentPosition).
  Rect? _solutionAreaRect() {
    final solutionCtx = solutionAreaKey.currentContext;
    final boardCtx = gameBoardKey.currentContext;
    if (solutionCtx == null || boardCtx == null) return null;

    final solutionBox = solutionCtx.findRenderObject() as RenderBox?;
    final boardBox = boardCtx.findRenderObject() as RenderBox?;
    if (solutionBox == null || boardBox == null) return null;
    if (!solutionBox.hasSize || !boardBox.hasSize) return null;

    final topLeft = solutionBox.localToGlobal(Offset.zero, ancestor: boardBox);
    return topLeft & solutionBox.size;
  }

  /// Converts a pointer's global screen position into a position local to
  /// the board Stack, so it lines up with Positioned(left/top: ...).
  Offset _toBoardLocal(Offset globalPosition) {
    final boardCtx = gameBoardKey.currentContext;
    final boardBox = boardCtx?.findRenderObject() as RenderBox?;
    if (boardBox == null || !boardBox.hasSize) return globalPosition;
    return boardBox.globalToLocal(globalPosition);
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

  void onPieceDragged(PuzzlePiece piece, Offset globalPosition) {
    // Only allow drag if piece has 2+ fingers (collaborative)
    if (piece.hasMultipleFinger() && !piece.isPlaced) {
      final local = _toBoardLocal(globalPosition);
      piece.currentPosition = local;
      dragOffset.value = local;
      stats.value.totalMoves++;
    }
  }

  void onPieceReleased(PuzzlePiece piece, Offset globalReleasePosition) {
    if (!piece.isPlaced && piece.hasMultipleFinger()) {
      // Check if placed correctly
      _checkPiecePlacement(piece, _toBoardLocal(globalReleasePosition));
    } else if (!piece.hasMultipleFinger()) {
      // Piece must be touched by 2 fingers - vibrate and reset
      _playRejectAnimation(piece);
    }
    selectedPiece.value = null;
  }

  void _checkPiecePlacement(PuzzlePiece piece, Offset boardLocalPosition) {
    final puzzle = currentPuzzle.value;
    final solutionRect = _solutionAreaRect();
    if (puzzle == null || solutionRect == null) return;

    final cellSize = Size(
      solutionRect.width / puzzle.gridCols,
      solutionRect.height / puzzle.gridRows,
    );

    final isInSolutionArea = solutionRect.contains(boardLocalPosition);
    final correctCellCenter = Offset(
      solutionRect.left + (piece.gridX + 0.5) * cellSize.width,
      solutionRect.top + (piece.gridY + 0.5) * cellSize.height,
    );
    final tolerance = cellSize.shortestSide * 0.4;
    final isCorrectCell =
        (boardLocalPosition - correctCellCenter).distance <= tolerance;

    if (isInSolutionArea && isCorrectCell) {
      _onCorrectPlacement(piece, correctCellCenter);
    } else if (isInSolutionArea) {
      _onIncorrectPlacement(piece);
    }
  }

  void _onCorrectPlacement(PuzzlePiece piece, Offset snapPosition) {
    piece.isPlaced = true;
    // Snap exactly onto its grid cell so correctly-placed pieces line up
    // into a clean assembled picture instead of resting wherever they
    // happened to be dropped within the tolerance radius.
    piece.currentPosition = snapPosition;
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
    Get.find<NavigationController>().setGameSessionActive(false);
    super.onClose();
  }
}

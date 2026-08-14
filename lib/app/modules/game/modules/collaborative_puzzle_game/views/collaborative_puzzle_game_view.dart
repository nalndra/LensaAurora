import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/widgets/confetti_burst.dart';
import 'package:lensaaurora/app/widgets/fade_slide_in.dart';
import 'package:lensaaurora/app/widgets/pressable_scale.dart';
import '../controllers/collaborative_puzzle_game_controller.dart';
import '../widgets/puzzle_piece_widget.dart';

class CollaborativePuzzleGameView
    extends GetView<CollaborativePuzzleGameController> {
  const CollaborativePuzzleGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Collaborative Puzzle Game'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.accentGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            // Header with progress and stats
            _buildGameHeader(),
            // Game board
            Expanded(
              child: controller.currentPuzzle.value != null
                  ? _buildGameBoard()
                  : _buildPuzzleSelection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildGameHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.currentPuzzle.value?.title ?? 'Select Puzzle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'Progress: ${(controller.progress.value * 100).toStringAsFixed(0)}%',
                  key: ValueKey(controller.progress.value),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.accentGreenDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: controller.progress.value),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppTheme.fieldFill,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          // Game stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.br16,
              boxShadow: AppTheme.shadowCard,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.touch_app_rounded,
                  'Total Moves',
                  '${controller.stats.value.totalMoves}',
                ),
                _buildStatItem(
                  Icons.check_circle_rounded,
                  'Correct',
                  '${controller.stats.value.correctPlacements}',
                ),
                _buildStatItem(
                  Icons.groups_rounded,
                  'Negotiations',
                  '${controller.stats.value.coordinationMoves}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.accentGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _buildPuzzleSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Puzzle:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          ...List.generate(controller.puzzles.length, (index) {
            final puzzle = controller.puzzles[index];
            return FadeSlideIn(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.space12),
                child: PressableScale(
                  onTap: () => controller.startGame(puzzle.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: AppTheme.br20,
                      color: Colors.white,
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: AppTheme.br16,
                          ),
                          child: const Icon(
                            Icons.extension_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                puzzle.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${puzzle.numberOfPieces} pieces',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: AppTheme.accentGreen, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    final puzzle = controller.currentPuzzle.value!;
    const gap = 16.0;

    return Stack(
      children: [
        // Background
        Container(color: AppTheme.bgLight),
        // Game area with pieces
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Cap the board width on large/desktop screens so pieces
                // stay a sane size, and center it within the available
                // space rather than stretching edge to edge.
                final contentWidth = constraints.maxWidth > 480
                    ? 480.0
                    : constraints.maxWidth;

                // Everything below is derived straight from the puzzle
                // image's real aspect ratio, so the target preview and
                // the solution area always end up exactly the same size
                // (1:1 with the picture) and pieces tile together without
                // stretching or leaving gaps.
                final previewHeight = contentWidth / puzzle.imageAspectRatio;
                final cellAspect =
                    puzzle.imageAspectRatio * puzzle.gridRows / puzzle.gridCols;
                final pieceWidth = contentWidth / puzzle.gridCols;
                final pieceHeight = pieceWidth / cellAspect;
                final solutionHeight = pieceHeight * puzzle.gridRows;
                final scatterRows =
                    (puzzle.numberOfPieces / puzzle.gridCols).ceil() + 1;
                final scatterHeight =
                    pieceHeight * scatterRows.clamp(2, 4);

                final scatterTop = previewHeight + gap;
                final solutionTop = scatterTop + scatterHeight + gap;
                final boardHeight = solutionTop + solutionHeight;

                controller.ensureScatterLayout(
                  areaWidth: contentWidth,
                  areaTop: scatterTop,
                  areaHeight: scatterHeight,
                  pieceWidth: pieceWidth,
                  pieceHeight: pieceHeight,
                );

                return Center(
                  child: SizedBox(
                    width: contentWidth,
                    height: boardHeight,
                    child: Stack(
                      key: controller.gameBoardKey,
                      clipBehavior: Clip.none,
                      children: [
                        // Target image area
                        Positioned(
                          top: 0,
                          left: 0,
                          width: contentWidth,
                          height: previewHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: AppTheme.br16,
                              color: Colors.white,
                              boxShadow: AppTheme.shadowCard,
                            ),
                            child: ClipRRect(
                              borderRadius: AppTheme.br16,
                              // BoxFit.fill is safe here (won't stretch)
                              // because previewHeight was derived from
                              // the image's own aspect ratio above.
                              child: Image.asset(
                                puzzle.imagePath,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Image not found',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Puzzle pieces scatter area (background only —
                        // pieces themselves are positioned directly on
                        // this Stack below, so their coordinates share
                        // the same space as the solution area).
                        Positioned(
                          top: scatterTop,
                          left: 0,
                          width: contentWidth,
                          height: scatterHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.fieldFill,
                              borderRadius: AppTheme.br16,
                            ),
                          ),
                        ),
                        // Solution area (target placement)
                        Positioned(
                          top: solutionTop,
                          left: 0,
                          width: contentWidth,
                          height: solutionHeight,
                          child: Container(
                            key: controller.solutionAreaKey,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.accentGreen,
                                width: 2,
                              ),
                              borderRadius: AppTheme.br16,
                              color: AppTheme.accentGreen.withValues(alpha: 0.06),
                            ),
                            child: controller.stats.value.correctPlacements == 0
                                ? Center(
                                    child: Text(
                                      '✂️ Solution Area\n(Drag pieces here)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppTheme.accentGreenDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        // Pieces — rendered last so they paint above both
                        // the scatter and solution area backgrounds.
                        ...List.generate(controller.pieces.length, (index) {
                          final piece = controller.pieces[index];
                          return PuzzlePieceWidget(
                            key: ValueKey(piece.id),
                            piece: piece,
                            imagePath: puzzle.imagePath,
                            gridCols: puzzle.gridCols,
                            gridRows: puzzle.gridRows,
                            pieceWidth: pieceWidth,
                            pieceHeight: pieceHeight,
                            isSelected:
                                controller.selectedPiece.value?.id == piece.id,
                            isPlaced: piece.isPlaced,
                            onFingerDown: () =>
                                controller.onFingerDown(index, piece),
                            onFingerUp: () =>
                                controller.onFingerUp(index, piece),
                            onDrag: (position) =>
                                controller.onPieceDragged(piece, position),
                            onRelease: (position) =>
                                controller.onPieceReleased(piece, position),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Completion overlay
        if (controller.gameCompleted.value) _buildCompletionOverlay(),
      ],
    );
  }

  Widget _buildCompletionOverlay() {
    return GestureDetector(
      onTap: () => controller.resetGame(),
      child: Container(
        color: Colors.black54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const ConfettiBurst(),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.br24,
                    boxShadow: AppTheme.shadowLg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.celebration_rounded,
                        size: 64,
                        color: AppTheme.accentGreenDark,
                      ),
                      const SizedBox(height: AppTheme.space16),
                      Text(
                        '🎉 Good Job! Puzzle Completed!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgLight,
                          borderRadius: AppTheme.br16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatItem(Icons.touch_app_rounded,
                                'Total Moves', '${controller.stats.value.totalMoves}'),
                            const SizedBox(width: AppTheme.space24),
                            _buildStatItem(Icons.groups_rounded, 'Negotiations',
                                '${controller.stats.value.coordinationMoves}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.space20),
                      SizedBox(
                        width: double.infinity,
                        child: AuroraPrimaryButton(
                          label: 'Play Again',
                          onPressed: () => controller.resetGame(),
                          height: 52,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

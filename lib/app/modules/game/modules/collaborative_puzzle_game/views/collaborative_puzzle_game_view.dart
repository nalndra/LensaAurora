import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import '../controllers/collaborative_puzzle_game_controller.dart';
import '../widgets/puzzle_piece_widget.dart';

class CollaborativePuzzleGameView
    extends GetView<CollaborativePuzzleGameController> {
  const CollaborativePuzzleGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborative Puzzle Game'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Progress: ${(controller.progress.value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: controller.progress.value,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Game stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Moves',
                  '${controller.stats.value.totalMoves}',
                ),
                _buildStatItem(
                  'Correct',
                  '${controller.stats.value.correctPlacements}',
                ),
                _buildStatItem(
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
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
          const Text(
            'Select a Puzzle:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.puzzles.map((puzzle) {
            return GestureDetector(
              onTap: () => controller.startGame(puzzle.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryBlue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primaryBlue.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.extension_outlined,
                        color: AppTheme.primaryBlue,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${puzzle.numberOfPieces} pieces',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: AppTheme.primaryBlue),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Stack(
      children: [
        // Background
        Container(
          color: Colors.grey[100],
        ),
        // Game area with pieces
        Positioned.fill(
          child: SingleChildScrollView(
            child: SizedBox(
              height: 600,
              child: Stack(
                children: [
                  // Target image area
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: controller.currentPuzzle.value != null
                            ? Image.asset(
                                controller.currentPuzzle.value!.imagePath,
                                fit: BoxFit.cover,
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
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Target Picture',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Puzzle pieces scatter area
                  Positioned(
                    top: 180,
                    left: 16,
                    right: 16,
                    height: 180,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        ...List.generate(
                          controller.pieces.length,
                          (index) {
                            final piece = controller.pieces[index];
                            return PuzzlePieceWidget(
                              key: ValueKey(piece.id),
                              piece: piece,
                              isSelected:
                                  controller.selectedPiece.value?.id ==
                                      piece.id,
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
                          },
                        ),
                      ],
                    ),
                  ),
                  // Solution area (target placement)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green.withOpacity(0.05),
                      ),
                      child: const Center(
                        child: Text(
                          '✂️ Solution Area\n(Drag pieces here)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Completion overlay
        if (controller.gameCompleted.value)
          _buildCompletionOverlay(),
      ],
    );
  }

  Widget _buildCompletionOverlay() {
    return GestureDetector(
      onTap: () => controller.resetGame(),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 64,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  '🎉 Good Job! Puzzle Completed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildStatItem('Total Moves',
                          '${controller.stats.value.totalMoves}'),
                      const SizedBox(height: 12),
                      _buildStatItem('Negotiations',
                          '${controller.stats.value.coordinationMoves}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.resetGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

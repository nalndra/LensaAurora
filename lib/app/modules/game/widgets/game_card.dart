import 'package:flutter/material.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../../game/models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onPlayPressed;

  const GameCard({
    super.key,
    required this.game,
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342,
      height: 427.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowLg,
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Image Section (Top - 65%)
          Expanded(
            flex: 65,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                color: Colors.grey[300],
                width: double.infinity,
                child: game.imageUrl.isNotEmpty
                    ? _buildBackgroundImage()
                    : _buildImagePlaceholder(),
              ),
            ),
          ),
          // Content Section (Bottom - 35%)
          Expanded(
            flex: 35,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(game.difficulty),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Level ${game.difficulty}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Title
                        Text(
                          game.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Description
                        Expanded(
                          child: Text(
                            game.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Play Now Button - Circular (left aligned)
                  SizedBox(
                    width: 140,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onPlayPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Play Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    // Check if it's an asset image (starts with 'assets/')
    if (game.imageUrl.startsWith('assets/')) {
      return Image.asset(
        game.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }
    // Otherwise treat it as network image
    return Image.network(
      game.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    final iconMap = {
      'social_interaction': Icons.people,
      'puzzle': Icons.extension,
      'memory': Icons.memory,
    };

    return Container(
      color: AppTheme.primaryBlue.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconMap[game.type] ?? Icons.gamepad,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              game.type.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppTheme.sageGreen;
      case 2:
        return AppTheme.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

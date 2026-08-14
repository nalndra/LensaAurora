import 'package:flutter/material.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/pressable_scale.dart';

class GameCatalogCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onPlayPressed;

  const GameCatalogCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPlayPressed,
      scaleDown: 0.98,
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppTheme.shadowLg,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              _buildImageBackground(),
              // Dark Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                ),
              ),
              // "Play" badge, top-right
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: AppTheme.brPill,
                    boxShadow: AppTheme.shadowCard,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 14, color: AppTheme.accentGreenDark),
                      const SizedBox(width: 4),
                      Text(
                        'Interaktif',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentGreenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      // Play Button (visual only — the whole card is
                      // already tappable via the outer PressableScale, so
                      // this doesn't carry its own tap handler to avoid a
                      // nested-gesture-detector double-fire).
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: AppTheme.brPill,
                          boxShadow: AppTheme.shadowButton(AppTheme.accentGreen),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Play Now',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageBackground() {
    if (imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    // Check if it's an asset image
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[GameCatalogCard] Asset image failed: $imageUrl');
          return _buildImagePlaceholder();
        },
      );
    }

    // Network image
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[GameCatalogCard] Network image failed: $imageUrl');
        return _buildImagePlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.accentGreen.withValues(alpha: 0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: AppTheme.accentGreen,
          ),
          const SizedBox(height: 8),
          Text(
            'Game Image',
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

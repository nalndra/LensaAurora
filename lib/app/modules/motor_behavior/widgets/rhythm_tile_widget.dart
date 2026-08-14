import 'package:flutter/material.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../models/rhythm_tile.dart';

class RhythmTileWidget extends StatelessWidget {
  const RhythmTileWidget({
    super.key,
    required this.tile,
    required this.laneWidth,
    required this.elapsedMs,
  });

  final RhythmTile tile;
  final double laneWidth;
  final int elapsedMs;

  Color get _color {
    switch (tile.result) {
      case TileResult.pending:
        return switch (tile.type) {
          TileType.tap => AppTheme.primaryBlue,
          TileType.hold => AppTheme.accentGreen,
          TileType.trace => AppTheme.accentGreenDark,
        };
      case TileResult.perfect:
        return Colors.green;
      case TileResult.good:
        return Colors.orange;
      case TileResult.miss:
        return Colors.red.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = laneWidth - 16;
    final resolved = tile.result != TileResult.pending;

    Widget content;
    switch (tile.type) {
      case TileType.tap:
        content = Icon(Icons.touch_app_rounded, color: Colors.white, size: 22);
        break;
      case TileType.hold:
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white70,
                size: 16,
              ),
              Icon(Icons.pan_tool_alt_rounded, color: Colors.white, size: 20),
            ],
          ),
        );
        break;
      case TileType.trace:
        content = CustomPaint(
          painter: _ZigzagPainter(tile: tile, width: width),
          size: Size(width, tile.heightPx),
        );
        break;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: resolved && tile.result == TileResult.miss ? 0.35 : 1.0,
      child: Container(
        width: width,
        height: tile.heightPx,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(
            tile.type == TileType.tap ? 14 : 18,
          ),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: tile.isHeld
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
        ),
        child: Center(child: content),
      ),
    );
  }
}

class _ZigzagPainter extends CustomPainter {
  _ZigzagPainter({required this.tile, required this.width});

  final RhythmTile tile;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const steps = 24;
    for (var i = 0; i <= steps; i++) {
      final progress = i / steps;
      final offset = tile.expectedTraceOffset(progress, width + 24);
      final x = width / 2 + offset;
      final y = progress * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZigzagPainter oldDelegate) => false;
}

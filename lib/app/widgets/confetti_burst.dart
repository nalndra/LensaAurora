import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight celebratory confetti burst — no external packages. Plays
/// once on mount and leaves the burst pieces settled at rest; wrap a
/// completion screen's content with this to celebrate a win.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    this.pieceCount = 24,
    this.colors = const [
      Color(0xFF20B2AA),
      Color(0xFF7AAACE),
      Color(0xFF9CD5FF),
      Color(0xFFFFD166),
      Color(0xFFEF476F),
    ],
  });

  final int pieceCount;
  final List<Color> colors;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    final rng = Random();
    _pieces = List.generate(widget.pieceCount, (i) {
      final angle = rng.nextDouble() * pi - (pi / 2) - (pi / 4);
      final speed = 160 + rng.nextDouble() * 160;
      return _ConfettiPiece(
        color: widget.colors[i % widget.colors.length],
        angle: angle,
        speed: speed,
        rotationSpeed: (rng.nextDouble() - 0.5) * 10,
        startX: rng.nextDouble(),
        size: 6 + rng.nextDouble() * 6,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_pieces, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ConfettiPiece {
  _ConfettiPiece({
    required this.color,
    required this.angle,
    required this.speed,
    required this.rotationSpeed,
    required this.startX,
    required this.size,
  });

  final Color color;
  final double angle;
  final double speed;
  final double rotationSpeed;
  final double startX;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_ConfettiPiece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const gravity = 480.0;
    final origin = Offset(size.width / 2, size.height * 0.35);

    for (final piece in pieces) {
      final elapsed = t * 1.4; // seconds
      final dx = cos(piece.angle) * piece.speed * elapsed;
      final dy = sin(piece.angle) * piece.speed * elapsed +
          0.5 * gravity * elapsed * elapsed;
      final fade = (1 - t).clamp(0.0, 1.0);

      final paint = Paint()..color = piece.color.withValues(alpha: fade);
      final pos = origin +
          Offset(dx + (piece.startX - 0.5) * size.width * 0.4, dy);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(piece.rotationSpeed * t * 2 * pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}

import 'package:flutter/material.dart';
import '../models/puzzle_model.dart';

class PuzzlePieceWidget extends StatefulWidget {
  final PuzzlePiece piece;
  final VoidCallback onFingerDown;
  final VoidCallback onFingerUp;
  final Function(Offset) onDrag;
  final Function(Offset) onRelease;
  final bool isSelected;
  final bool isPlaced;

  const PuzzlePieceWidget({
    super.key,
    required this.piece,
    required this.onFingerDown,
    required this.onFingerUp,
    required this.onDrag,
    required this.onRelease,
    this.isSelected = false,
    this.isPlaced = false,
  });

  @override
  State<PuzzlePieceWidget> createState() => _PuzzlePieceWidgetState();
}

class _PuzzlePieceWidgetState extends State<PuzzlePieceWidget>
    with TickerProviderStateMixin {
  late final AnimationController _oscillationController;
  late final AnimationController _placedPopController;

  @override
  void initState() {
    super.initState();
    _oscillationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _placedPopController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
      value: widget.isPlaced ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(PuzzlePieceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Oscillate when piece is single-touched
    if (widget.piece.fingersOnThis == 1 &&
        oldWidget.piece.fingersOnThis != 1) {
      _oscillationController.repeat(reverse: true);
    } else if (widget.piece.fingersOnThis != 1) {
      _oscillationController.stop();
    }
    // Little celebratory pop the moment a piece snaps into place.
    if (widget.isPlaced && !oldWidget.isPlaced) {
      _placedPopController.forward(from: 0);
    } else if (!widget.isPlaced) {
      _placedPopController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.piece.currentPosition.dx - 40,
      top: widget.piece.currentPosition.dy - 40,
      child: GestureDetector(
        onPanStart: (_) => widget.onFingerDown(),
        onPanUpdate: (details) => widget.onDrag(details.globalPosition),
        onPanEnd: (_) {
          widget.onRelease(widget.piece.currentPosition);
          widget.onFingerUp();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_oscillationController, _placedPopController]),
          builder: (context, child) {
            double offsetX = 0;
            if (_oscillationController.isAnimating) {
              offsetX = (Tween<double>(begin: -2, end: 2).evaluate(
                CurvedAnimation(
                  parent: _oscillationController,
                  curve: Curves.easeInOut,
                ),
              ));
            }

            // Overshoot-then-settle pop when the piece is placed; otherwise
            // stay at rest scale.
            final popScale = widget.isPlaced
                ? Curves.elasticOut.transform(_placedPopController.value)
                : 1.0;

            return Transform.translate(
              offset: Offset(offsetX, 0),
              child: Transform.scale(
                scale: popScale,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: _getPieceColor(),
                width: widget.isSelected ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                if (widget.piece.fingersOnThis == 1)
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                if (widget.isPlaced)
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isPlaced ? Icons.check_circle : Icons.touch_app,
                    color: _getPieceColor(),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fingers: ${widget.piece.fingersOnThis}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPieceColor() {
    if (widget.isPlaced) return Colors.green;
    if (widget.piece.fingersOnThis >= 2) return Colors.deepPurple;
    if (widget.piece.fingersOnThis == 1) return Colors.orange;
    return Colors.grey;
  }

  @override
  void dispose() {
    _oscillationController.dispose();
    _placedPopController.dispose();
    super.dispose();
  }
}

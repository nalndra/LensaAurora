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

  /// Source puzzle image and grid layout, so this piece can render its own
  /// slice of the picture instead of a blank placeholder box.
  final String imagePath;
  final int gridCols;
  final int gridRows;
  final double pieceWidth;
  final double pieceHeight;

  const PuzzlePieceWidget({
    super.key,
    required this.piece,
    required this.onFingerDown,
    required this.onFingerUp,
    required this.onDrag,
    required this.onRelease,
    required this.imagePath,
    required this.gridCols,
    required this.gridRows,
    required this.pieceWidth,
    required this.pieceHeight,
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

  // Enforced Collaboration requires two DISTINCT, simultaneous fingers on
  // the same piece. A single GestureDetector's pan recognizer only ever
  // tracks one active pointer per gesture, so a second finger landing
  // while the first is still down would never register. Listener reports
  // every individual pointer independently, so we track them ourselves.
  final Set<int> _activePointers = {};

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
      left: widget.piece.currentPosition.dx - widget.pieceWidth / 2,
      top: widget.piece.currentPosition.dy - widget.pieceHeight / 2,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _activePointers.add(event.pointer);
          widget.onFingerDown();
        },
        onPointerMove: (event) {
          // Only a drag while two (or more) distinct fingers are down —
          // this is the actual collaboration gate.
          if (_activePointers.length >= 2) {
            widget.onDrag(event.position);
          }
        },
        onPointerUp: (event) {
          // event.position is global, same as onPointerMove — the
          // controller converts it to board-local coordinates itself.
          // (piece.currentPosition is already board-local by this point,
          // so passing that here would get converted a second time.)
          widget.onRelease(event.position);
          widget.onFingerUp();
          _activePointers.remove(event.pointer);
        },
        onPointerCancel: (event) {
          widget.onFingerUp();
          _activePointers.remove(event.pointer);
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
            width: widget.pieceWidth,
            height: widget.pieceHeight,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  // The actual slice of the puzzle picture this piece
                  // represents, cropped out of the full image via an
                  // oversized image shifted into place with OverflowBox.
                  Positioned.fill(child: _buildImageSlice()),
                  if (widget.isPlaced)
                    const Positioned(
                      right: 2,
                      bottom: 2,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    )
                  else if (widget.piece.fingersOnThis > 0)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getPieceColor(),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.piece.fingersOnThis}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlice() {
    final sliceWidth = widget.pieceWidth * widget.gridCols;
    final sliceHeight = widget.pieceHeight * widget.gridRows;
    final alignX = widget.gridCols <= 1
        ? 0.0
        : (widget.piece.gridX / (widget.gridCols - 1)) * 2 - 1;
    final alignY = widget.gridRows <= 1
        ? 0.0
        : (widget.piece.gridY / (widget.gridRows - 1)) * 2 - 1;

    return OverflowBox(
      minWidth: sliceWidth,
      maxWidth: sliceWidth,
      minHeight: sliceHeight,
      maxHeight: sliceHeight,
      alignment: Alignment(alignX, alignY),
      child: Image.asset(
        widget.imagePath,
        width: sliceWidth,
        height: sliceHeight,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
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

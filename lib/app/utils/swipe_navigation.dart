import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';

/// Widget that wraps pages and enables swipe-to-navigate functionality
/// Supports left/right swipes to navigate between pages
class SwipeNavigationWrapper extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final int maxIndex; // 3 for 4 pages (0-3)

  const SwipeNavigationWrapper({
    required this.child,
    required this.currentIndex,
    required this.maxIndex,
    super.key,
  });

  @override
  State<SwipeNavigationWrapper> createState() => _SwipeNavigationWrapperState();
}

class _SwipeNavigationWrapperState extends State<SwipeNavigationWrapper> {
  late NavigationController navController;
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    navController = Get.find<NavigationController>();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
    _isDragging = true;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _currentPosition = details.globalPosition;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final delta = _currentPosition.dx - _startPosition.dx;
    const swipeThreshold = 50.0; // Minimum swipe distance

    // Swipe right -> go to previous page
    if (delta > swipeThreshold && widget.currentIndex > 0) {
      _navigateToPrevious();
    }
    // Swipe left -> go to next page
    else if (delta < -swipeThreshold && widget.currentIndex < widget.maxIndex) {
      _navigateToNext();
    }

    _isDragging = false;
  }

  void _navigateToNext() {
    final nextIndex = widget.currentIndex + 1;
    navController.changeIndex(nextIndex);

    switch (nextIndex) {
      case 0:
        navController.navigateToHome();
        break;
      case 1:
        navController.navigateToScan();
        break;
      case 2:
        navController.navigateToGame();
        break;
      case 3:
        navController.navigateToProfile();
        break;
    }
  }

  void _navigateToPrevious() {
    final previousIndex = widget.currentIndex - 1;
    navController.changeIndex(previousIndex);

    switch (previousIndex) {
      case 0:
        navController.navigateToHome();
        break;
      case 1:
        navController.navigateToScan();
        break;
      case 2:
        navController.navigateToGame();
        break;
      case 3:
        navController.navigateToProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

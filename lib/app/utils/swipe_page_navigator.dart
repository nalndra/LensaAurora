import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';

/// Custom page navigator dengan real-time drag animation
/// Features:
/// - Real-time page movement saat drag
/// - Show 2 pages simultaneously (50% each)
/// - Snap-back untuk < 50% drag, page switch untuk >= 50%
/// - Smooth animation dengan AnimationController
class SwipePageNavigator extends StatefulWidget {
  final int currentIndex;
  final int maxIndex; // 3 untuk 4 pages (0-3)
  final List<Widget> pages;

  const SwipePageNavigator({
    required this.currentIndex,
    required this.maxIndex,
    required this.pages,
    super.key,
  });

  @override
  State<SwipePageNavigator> createState() => _SwipePageNavigatorState();
}

class _SwipePageNavigatorState extends State<SwipePageNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Current drag offset (0 = no drag, -1 to 1 = full page left/right)
  double _dragOffset = 0;
  double _dragStartX = 0;
  bool _isDragging = false;
  bool _isAnimating = false; // Prevent overlapping animations
  
  late NavigationController _navController;

  @override
  void initState() {
    super.initState();
    _navController = Get.find<NavigationController>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animation.addListener(() {
      setState(() {
        _dragOffset = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    // Ignore drag if animation is in progress (one page at a time)
    if (_isAnimating) return;
    
    _isDragging = true;
    _dragStartX = details.globalPosition.dx;
    _animationController.stop();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final currentX = details.globalPosition.dx;
    final delta = currentX - _dragStartX;
    
    // Normalize delta to -1 to 1 range (full page left/right)
    final normalizedDelta = delta / screenWidth;
    
    // Calculate new offset
    double newOffset = _dragOffset + normalizedDelta;
    
    // ENFORCE ONE-PAGE-AT-A-TIME: Only allow dragging to adjacent pages
    // Left boundary (can't go beyond next page)
    if (newOffset < -1.0) {
      // Trying to drag past next page - apply heavy resistance
      newOffset = -1.0 + (newOffset + 1.0) * 0.2;
    }
    // Right boundary (can't go beyond previous page)
    if (newOffset > 1.0) {
      // Trying to drag past previous page - apply heavy resistance
      newOffset = 1.0 - (newOffset - 1.0) * 0.2;
    }
    
    // Additional boundary check for first/last page
    if (widget.currentIndex == 0 && newOffset > 0) {
      // At first page, prevent dragging right
      newOffset = newOffset * 0.3;
    } else if (widget.currentIndex == widget.maxIndex && newOffset < 0) {
      // At last page, prevent dragging left
      newOffset = newOffset * 0.3;
    }
    
    setState(() {
      _dragOffset = newOffset;
    });
    
    _dragStartX = currentX;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    const snapThreshold = 0.5; // 50% of screen width

    if (_dragOffset.abs() >= snapThreshold) {
      // Trigger page change - only to adjacent pages
      if (_dragOffset < 0 && widget.currentIndex < widget.maxIndex) {
        // Swiped left -> next page (only one page ahead)
        _isAnimating = true;
        _animateToNextPage();
      } else if (_dragOffset > 0 && widget.currentIndex > 0) {
        // Swiped right -> previous page (only one page back)
        _isAnimating = true;
        _animateToPreviousPage();
      } else {
        // Can't go further, snap back
        _snapBack();
      }
    } else {
      // Not enough drag, snap back
      _snapBack();
    }
  }

  void _snapBack() {
    _animation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward(from: 0);
    // No need to set _isAnimating here since snap-back doesn't change pages
  }

  void _animateToNextPage() {
    final nextIndex = widget.currentIndex + 1;
    
    _animation = Tween<double>(begin: _dragOffset, end: -1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward(from: 0).then((_) {
      // Only update index, don't do route navigation
      // MainShell will rebuild automatically via Obx
      _navController.changeIndex(nextIndex);
      
      // Reset offset
      setState(() {
        _dragOffset = 0;
        _isAnimating = false; // Allow next drag
      });
    });
  }

  void _animateToPreviousPage() {
    final previousIndex = widget.currentIndex - 1;
    
    _animation = Tween<double>(begin: _dragOffset, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward(from: 0).then((_) {
      // Only update index, don't do route navigation
      // MainShell will rebuild automatically via Obx
      _navController.changeIndex(previousIndex);
      
      // Reset offset
      setState(() {
        _dragOffset = 0;
        _isAnimating = false; // Allow next drag
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentPageIndex = widget.currentIndex;
    
    // Only show adjacent pages when actively dragging
    final showLeftPage = _dragOffset > 0 && currentPageIndex > 0;
    final showRightPage = _dragOffset < 0 && currentPageIndex < widget.maxIndex;
    
    // Previous/Left page (only when dragging right)
    final leftPageIndex = currentPageIndex - 1;
    // Next/Right page (only when dragging left)
    final rightPageIndex = currentPageIndex + 1;
    
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Left/Previous page (only rendered when dragging right AND not at first page)
          if (showLeftPage)
            Transform.translate(
              offset: Offset(
                -screenWidth + (_dragOffset * screenWidth),
                0,
              ),
              child: SizedBox(
                width: screenWidth,
                height: MediaQuery.of(context).size.height,
                child: widget.pages[leftPageIndex],
              ),
            ),
          
          // Current page (always rendered)
          Transform.translate(
            offset: Offset(_dragOffset * screenWidth, 0),
            child: SizedBox(
              width: screenWidth,
              height: MediaQuery.of(context).size.height,
              child: widget.pages[currentPageIndex],
            ),
          ),
          
          // Right/Next page (only rendered when dragging left AND not at last page)
          if (showRightPage)
            Transform.translate(
              offset: Offset(
                screenWidth + (_dragOffset * screenWidth),
                0,
              ),
              child: SizedBox(
                width: screenWidth,
                height: MediaQuery.of(context).size.height,
                child: widget.pages[rightPageIndex],
              ),
            ),
        ],
      ),
    );
  }
}

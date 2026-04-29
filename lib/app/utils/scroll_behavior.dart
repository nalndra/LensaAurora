import 'package:flutter/material.dart';

/// Custom scroll behavior that disables overscroll bounce/stretch
/// and applies clamping physics to prevent stretching at scroll limits
class NoOverscrollScrollBehavior extends ScrollBehavior {
  const NoOverscrollScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

/// Scroll physics with a visual indicator when reaching the end
/// Shows a subtle effect without stretching
class ClampingWithIndicatorPhysics extends ClampingScrollPhysics {
  const ClampingWithIndicatorPhysics({super.parent});

  @override
  ClampingWithIndicatorPhysics applyTo(ScrollPhysics? ancestor) {
    return ClampingWithIndicatorPhysics(parent: buildParent(ancestor));
  }
}

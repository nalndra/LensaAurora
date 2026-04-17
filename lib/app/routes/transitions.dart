import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';

/// Slide transition dari kanan ke kiri (forward/next page)
class SlideTransitionRight extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: curve ?? Curves.easeInOutCubic,
        ),
      ),
      child: child,
    );
  }

  @override
  Duration get duration => const Duration(milliseconds: 300);
}

/// Slide transition dari kiri ke kanan (backward/previous page)
class SlideTransitionLeft extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: curve ?? Curves.easeInOutCubic,
        ),
      ),
      child: child,
    );
  }

  @override
  Duration get duration => const Duration(milliseconds: 300);
}

/// Fade transition sederhana - munculin langsung tanpa slide
class FadeTransitionSimple extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: curve ?? Curves.easeInOutCubic,
        ),
      ),
      child: child,
    );
  }

  @override
  Duration get duration => const Duration(milliseconds: 200);
}

/// Slide transition adaptif berdasarkan arah navigasi
class AdaptiveSlideTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Coba ambil navigation controller untuk mendapat info arah
    try {
      final navController = Get.find<NavigationController>();
      final isForward = navController.isForward;
      final offset = isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

      return SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve ?? Curves.easeInOutCubic,
          ),
        ),
        child: child,
      );
    } catch (e) {
      // Jika controller tidak ditemukan, gunakan slide dari kanan sebagai default
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve ?? Curves.easeInOutCubic,
          ),
        ),
        child: child,
      );
    }
  }

  @override
  Duration get duration => const Duration(milliseconds: 350);
}

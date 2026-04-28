import 'package:get/get.dart';

class NavigationController extends GetxController {
  final selectedIndex = 0.obs;
  final animatingIndex = 0.obs; // For navbar smooth animation
  final isGameSessionActive = false.obs;
  int previousIndex = 0;
  late bool isForward;

  void changeIndex(int index) {
    isForward = index > selectedIndex.value;
    previousIndex = selectedIndex.value;
    selectedIndex.value = index;
  }

  /// Keep selected and visual navbar index in sync for route-based navigation.
  void syncIndex(int index) {
    changeIndex(index);
    animatingIndex.value = index;
  }

  /// Smoothly animate the navbar through all intermediate indices
  void animateNavbarToIndex(int targetIndex) {
    final currentIndex = animatingIndex.value;
    
    if (currentIndex == targetIndex) return;

    final stepDuration = Duration(milliseconds: 80);
    final isMovingForward = targetIndex > currentIndex;
    
    // Calculate steps to take
    final steps = (targetIndex - currentIndex).abs() + 1;
    
    for (int i = 1; i < steps; i++) {
      Future.delayed(stepDuration * i, () {
        if (isMovingForward) {
          animatingIndex.value = currentIndex + i;
        } else {
          animatingIndex.value = currentIndex - i;
        }
      });
    }
    
    // Ensure animatingIndex is set to target after all steps
    Future.delayed(stepDuration * steps, () {
      animatingIndex.value = targetIndex;
    });
  }

  void setGameSessionActive(bool active) {
    isGameSessionActive.value = active;
  }

  void navigateToHome() {
    syncIndex(0);
    Get.offNamed('/home');
  }

  void navigateToScan() {
    syncIndex(1);
    Get.offNamed('/scan');
  }

  void navigateToReports() {
    syncIndex(2);
    Get.offNamed('/reports');
  }

  void navigateToGame() {
    syncIndex(2);
    Get.offNamed('/game');
  }

  void navigateToProfile() {
    syncIndex(3);
    Get.offNamed('/profile');
  }
}

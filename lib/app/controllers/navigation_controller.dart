import 'package:get/get.dart';

class NavigationController extends GetxController {
  final selectedIndex = 0.obs;
  int previousIndex = 0;
  late bool isForward;

  void changeIndex(int index) {
    isForward = index > selectedIndex.value;
    previousIndex = selectedIndex.value;
    selectedIndex.value = index;
  }

  void navigateToHome() {
    changeIndex(0);
    Get.offNamed('/home');
  }

  void navigateToScan() {
    changeIndex(1);
    Get.offNamed('/scan');
  }

  void navigateToReports() {
    changeIndex(2);
    Get.offNamed('/reports');
  }

  void navigateToGame() {
    changeIndex(3);
    Get.offNamed('/game');
  }

  void navigateToProfile() {
    changeIndex(4);
    Get.offNamed('/profile');
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/home/views/home_view.dart';
import 'package:lensaaurora/app/modules/scan/views/scan_view.dart';
import 'package:lensaaurora/app/modules/game/views/game_view.dart';
import 'package:lensaaurora/app/modules/profile/views/profile_view.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/utils/swipe_page_navigator.dart';

/// Main navigation shell that manages all 4 main pages with swipe animation
class MainShell extends GetView<NavigationController> {
  const MainShell({super.key});

  static const List<String> pageNames = ['home', 'scan', 'game', 'profile'];
  static const int pageCount = 4;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        body: SwipePageNavigator(
          currentIndex: controller.selectedIndex.value,
          maxIndex: 3,
          pages: const [
            HomeView(),
            ScanView(),
            GameView(),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}

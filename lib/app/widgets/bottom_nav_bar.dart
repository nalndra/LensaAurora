import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/home/controllers/home_controller.dart';

class CustomBottomNavBar extends GetView<HomeController> {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: controller.selectedIndex.value,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => controller.changeIndex(index),
      ),
    );
  }
}

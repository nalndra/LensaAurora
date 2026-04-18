import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

class CustomBottomNavBar extends GetView<NavigationController> {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    // Use animatingIndex instead of selectedIndex for smooth transitions
    final isSelected = controller.animatingIndex.value == index;
    final icons = [Icons.home, Icons.camera_alt, Icons.assessment, Icons.sports_esports, Icons.person];
    final labels = ['Home', 'Scan', 'Reports', 'Games', 'Profile'];

    return GestureDetector(
      onTap: () => _navigateTo(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated box highlight
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      )
                    : null,
              ),
              child: Icon(
                icons[index],
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[index],
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    final currentIndex = controller.selectedIndex.value;

    if (currentIndex == index) return;

    // Update selectedIndex first to allow future navigation
    controller.changeIndex(index);

    // Change page instantly without animation
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/scan');
        break;
      case 2:
        Get.offNamed('/reports');
        break;
      case 3:
        Get.offNamed('/game');
        break;
      case 4:
        Get.offNamed('/profile');
        break;
    }

    // Animate navbar smoothly through all intermediate indices
    controller.animateNavbarToIndex(index);
  }
}

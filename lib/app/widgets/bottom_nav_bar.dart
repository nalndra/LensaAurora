import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

class CustomBottomNavBar extends GetView<NavigationController> {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Use selectedIndex as source of truth (always synced with current page)
      // This works for both swipe navigation and route-based navigation
      final selectedIndex = controller.selectedIndex.value;

      return Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / 4;

            return Stack(
              children: [
                /// 🔥 HIGHLIGHT - CENTERED PERFECTLY
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  left: itemWidth * selectedIndex + (itemWidth / 2) - 15,
                  top: 0,
                  child: _HighlightBar(),
                ),

                /// NAV ITEMS
                Row(
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: itemWidth,
                      child: _NavItem(index: index),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

/// =====================
/// 🔥 HIGHLIGHT WIDGET
/// =====================
class _HighlightBar extends StatelessWidget {
  const _HighlightBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// garis tipis ungu
        Container(
          width: 30,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.purple,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),

        /// subtle shine ke bawah
        SizedBox(
          width: 30,
          height: 8,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.purple.withOpacity(0.15),
                  AppTheme.purple.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// =====================
/// 🔘 NAV ITEM
/// =====================
class _NavItem extends GetView<NavigationController> {
  final int index;

  const _NavItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home,
      Icons.camera_alt,
      Icons.sports_esports,
      Icons.person,
    ];

    final labels = ['Home', 'Scan', 'Games', 'Profile'];

    return GestureDetector(
      onTap: () => _navigateTo(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () {
              final selected = controller.selectedIndex.value == index;
              return AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1.1 : 1.0,
                child: Icon(
                  icons[index],
                  size: 26,
                  color: selected ? AppTheme.purple : AppTheme.textLight,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Obx(
            () {
              final selected = controller.selectedIndex.value == index;
              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppTheme.purple : AppTheme.textLight,
                ),
                child: Text(labels[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    final currentIndex = controller.selectedIndex.value;
    if (currentIndex == index) return;

    controller.changeIndex(index);

    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/scan');
        break;
      case 2:
        Get.offNamed('/game');
        break;
      case 3:
        Get.offNamed('/profile');
        break;
    }

    controller.animateNavbarToIndex(index);
  }
}

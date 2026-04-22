import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

class ChatFAB extends GetView<NavigationController> {
  const ChatFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isGameSessionActive.value
          ? const SizedBox.shrink() // Hide when game is active
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFB5A7FF), // Lighter purple
                    Color(0xFF6338F1), // Darker purple
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6338F1).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Get.toNamed(Routes.CHAT);
                },
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const CircleBorder(),
                child: Image.asset(
                  'assets/logo/RoraiChat.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
            ),
    );
  }
}

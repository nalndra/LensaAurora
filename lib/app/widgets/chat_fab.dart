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
          : FloatingActionButton(
              onPressed: () {
                Get.toNamed(
                  Routes.CHAT,
                );
              },
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: const CircleBorder(),
              child: const Icon(Icons.chat_bubble_outline, size: 24),
            ),
    );
  }
}

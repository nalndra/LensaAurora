import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/accessibility_controller.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';

class ChatFAB extends GetView<NavigationController> {
  const ChatFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final a11y = Get.find<AccessibilityController>();
    return Obx(
      () => controller.isGameSessionActive.value
          ? const SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: a11y.accentGradient,
                border: Border.all(color: a11y.accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: a11y.accentColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => Get.toNamed(Routes.CHAT),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const CircleBorder(),
                tooltip: 'Chat RORAI',
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

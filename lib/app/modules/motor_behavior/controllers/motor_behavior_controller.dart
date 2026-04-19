import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';

enum MotorTestType { traceTest, tapTarget }
enum MotorTestState { menu, testing, completed }

class MotorBehaviorController extends GetxController {
  final testState = MotorTestState.menu.obs;
  final currentTest = Rx<MotorTestType?>(null);
  
  // Track which tests completed
  final traceTestCompleted = false.obs;
  final tapTargetCompleted = false.obs;
  
  // Trace Test variables
  final traceLevel = 0.obs; // 0: straight, 1: curve, 2: shape
  final traceDeviation = 0.obs;
  final traceOutOfBounds = 0.obs;
  final traceSmoothness = 0.obs;
  
  // Tap Target variables
  final tapReactionTime = 0.obs;
  final tapAccuracy = 0.obs;
  final tapConsistency = 0.obs;

  void selectTest(MotorTestType test) {
    currentTest.value = test;
    testState.value = MotorTestState.testing;
  }

  void completeTest() {
    if (currentTest.value == MotorTestType.traceTest) {
      // Trace test selesai, langsung lanjut ke Tap Target
      traceTestCompleted.value = true;
      currentTest.value = MotorTestType.tapTarget;
      testState.value = MotorTestState.testing;
    } else if (currentTest.value == MotorTestType.tapTarget) {
      // Tap Target selesai, semua test done
      tapTargetCompleted.value = true;
      testState.value = MotorTestState.completed;
      // Navigate back to scan after short delay
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(Routes.SCAN);
      });
    }
  }

  void _showTestTransitionMessage() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Trace Test Selesai',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Anda telah menyelesaikan Trace Test. Sekarang lanjut ke Tap Target Test untuk mengukur akurasi dan reaksi Anda.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              testState.value = MotorTestState.testing;
            },
            child: const Text('Lanjut ke Tap Target'),
          ),
        ],
      ),
    );
  }

  void resetToMenu() {
    testState.value = MotorTestState.menu;
    currentTest.value = null;
    traceTestCompleted.value = false;
    tapTargetCompleted.value = false;
  }
}

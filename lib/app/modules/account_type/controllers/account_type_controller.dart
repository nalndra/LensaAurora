import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../services/auth_service.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/navigation_controller.dart';

enum AccountRole { parent, personal }

class AccountTypeController extends GetxController {
  // Dependencies
  final authService = AuthService();
  final authController = Get.find<AuthController>();

  // Observable for selected role
  final Rx<AccountRole?> selectedRole = Rx<AccountRole?>(null);
  final isLoading = false.obs;
  final isNewUser = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Only set default selection if user doesn't already have a role
    // This prevents accidentally overriding a previously set role
    if (authController.userRole.value == null) {
      // New user - set default selection to parent role
      selectedRole.value = AccountRole.parent;
    } else {
      // User already has a role - set the UI selector to match
      if (authController.userRole.value == 'parent') {
        selectedRole.value = AccountRole.parent;
      } else {
        selectedRole.value = AccountRole.personal;
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Select a role
  void selectRole(AccountRole role) {
    selectedRole.value = role;
  }

  /// Continue button action
  /// Saves the selected role to Firestore and navigates to home
  Future<void> continueToNextStep() async {
    if (selectedRole.value == null) {
      Get.snackbar(
        'Pilihan Peran',
        'Silakan pilih salah satu peran',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Get user ID from authService directly as fallback
      final userId = authController.currentUser.value?.uid ?? authService.currentUser?.uid;

      if (userId == null) {
        print('DEBUG: userId is null');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'User tidak ditemukan. Silakan login ulang.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 255, 82, 82),
          colorText: const Color.fromARGB(255, 255, 255, 255),
        );
        return;
      }

      final roleString =
          selectedRole.value == AccountRole.parent ? 'parent' : 'personal';

      print('DEBUG: Selected role: $roleString for user: $userId');

      // Update local state immediately
      authController.userRole.value = roleString;
      
      // IMPORTANT: Save role to Firestore and WAIT for confirmation
      // Don't navigate until role is saved
      print('DEBUG: Saving role to Firestore (BLOCKING - waits for completion)...');
      try {
        await authService.setUserRole(userId, roleString);
        print('DEBUG: Role saved successfully to Firestore');
      } catch (saveError) {
        print('ERROR: Failed to save role to Firestore: $saveError');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal menyimpan role. Periksa koneksi internet dan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 255, 82, 82),
          colorText: const Color.fromARGB(255, 255, 255, 255),
        );
        return;
      }
      
      // Only navigate after role is successfully saved
      print('DEBUG: Role saved, navigating to home...');
      isLoading.value = false;
      Get.find<NavigationController>().syncIndex(0);
      Get.offAllNamed('/home');
      
    } catch (e) {
      print('DEBUG: Unexpected error in continueToNextStep: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 255, 82, 82),
        colorText: const Color.fromARGB(255, 255, 255, 255),
      );
    }
  }
}

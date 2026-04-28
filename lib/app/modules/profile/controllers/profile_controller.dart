import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/models/child_profile.dart';
import '../../../../app/controllers/auth_controller.dart';
import '../../../../app/controllers/navigation_controller.dart';
import '../models/user_profile.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final NavigationController _navigationController = Get.find<NavigationController>();
  
  final userProfile = Rxn<UserProfile>();
  final isEditing = false.obs;
  final childrenList = <ChildProfile>[].obs;
  final isLoadingChildren = false.obs;
  Worker? _userWorker;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _userWorker = ever(_authController.currentUser, (_) => _loadUserProfile());
    
    // Load children if user is parent
    if (_authController.userRole.value == 'parent') {
      _loadChildren();
    }
  }

  void _loadUserProfile() {
    // Get real data from AuthController
    final user = _authController.currentUser.value;
    
    userProfile.value = UserProfile(
      id: user?.uid ?? 'user001',
      fullName: user?.displayName ?? 'Pengguna',
      email: user?.email ?? 'Tidak ada email',
      phoneNumber: user?.phoneNumber ?? '-',
      address: '-',
      age: 0,
      profileImageUrl: user?.photoURL ?? '',
      joinDate: user?.metadata.creationTime ?? DateTime.now(),
      bio: 'Passionate about learning and self-improvement.',
      achievements: {
        'badges': [
          {'name': 'Quick Learner', 'icon': '🚀'},
          {'name': 'Consistent Player', 'icon': '🎮'},
          {'name': 'Social Master', 'icon': '👥'},
        ],
        'totalScore': 0,
        'level': 1,
      },
      totalGamesPlayed: 0,
      averageScore: 0.0,
    );
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
  }

  Future<void> logout() async {
    await _authController.logout();
    _navigationController.syncIndex(0);
    Get.offAllNamed('/login');
  }

  /// Load children for parent user
  Future<void> _loadChildren() async {
    try {
      isLoadingChildren.value = true;
      final userId = _authController.currentUser.value?.uid;
      
      if (userId != null) {
        final children = await _authController.authService.getChildren(userId);
        childrenList.assignAll(children);
      }
    } catch (e) {
      print('Error loading children: $e');
    } finally {
      isLoadingChildren.value = false;
    }
  }

  /// Add a new child (parent only)
  Future<bool> addChild(String name, int age) async {
    try {
      final userId = _authController.currentUser.value?.uid;
      if (userId == null) return false;

      final childId = DateTime.now().millisecondsSinceEpoch.toString();
      final newChild = ChildProfile(
        id: childId,
        name: name,
        age: age,
        createdAt: DateTime.now(),
      );

      // Update UI immediately (optimistic update)
      childrenList.add(newChild);
      print('DEBUG [addChild]: Added to UI list: $name');
      
      // Save to Firestore in background (non-blocking)
      _authController.authService.addChild(userId, newChild).then(
        (_) {
          print('DEBUG [addChild]: Child saved successfully to Firestore in background');
        },
      ).catchError((error) {
        print('WARNING [addChild]: Background child save failed: $error');
        // DON'T remove from list - keep it so user knows the data exists locally
        // Show error message instead
        Get.snackbar(
          'Peringatan',
          'Anak berhasil ditambahkan lokal, tapi gagal simpan ke database',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 255, 193, 7),
          colorText: Colors.black,
          duration: const Duration(seconds: 3),
        );
      });
      
      return true;
    } catch (e) {
      print('Error adding child: $e');
      return false;
    }
  }

  /// Delete a child
  Future<bool> deleteChild(String childId) async {
    try {
      final userId = _authController.currentUser.value?.uid;
      if (userId == null) return false;

      // Remove from local list immediately (optimistic update)
      final removedChild = childrenList.firstWhere((child) => child.id == childId);
      childrenList.removeWhere((child) => child.id == childId);
      print('DEBUG [deleteChild]: Removed from UI list: ${removedChild.name}');
      
      // Delete from Firestore in background (non-blocking)
      _authController.authService.deleteChild(userId, childId).then(
        (_) {
          print('DEBUG [deleteChild]: Child deleted successfully from Firestore in background');
        },
      ).catchError((error) {
        print('WARNING [deleteChild]: Background child delete failed: $error');
        // If delete failed, add back to local list
        childrenList.add(removedChild);
        Get.snackbar(
          'Error',
          'Gagal menghapus anak dari database',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 255, 82, 82),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      });
      
      return true;
    } catch (e) {
      print('Error deleting child: $e');
      return false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _navigationController.syncIndex(3);
  }

  @override
  void onClose() {
    _userWorker?.dispose();
    super.onClose();
  }
}

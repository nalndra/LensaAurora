import 'package:get/get.dart';
import '../../../../app/controllers/auth_controller.dart';
import '../models/user_profile.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  final userProfile = Rxn<UserProfile>();
  final isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
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
    Get.offAllNamed('/login');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

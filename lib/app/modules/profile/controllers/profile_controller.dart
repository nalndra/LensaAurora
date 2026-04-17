import 'package:get/get.dart';
import '../models/user_profile.dart';

class ProfileController extends GetxController {
  final userProfile = Rxn<UserProfile>();
  final isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    // Dummy data for Munawir
    userProfile.value = UserProfile(
      id: 'user001',
      fullName: 'Munawir',
      email: 'munawir@example.com',
      phoneNumber: '+62 812-3456-7890',
      address: 'Jakarta, Indonesia',
      age: 28,
      profileImageUrl: '',
      joinDate: DateTime(2023, 1, 15),
      bio: 'Passionate about learning and self-improvement through interactive games and social training.',
      achievements: {
        'badges': [
          {'name': 'Quick Learner', 'icon': '🚀'},
          {'name': 'Consistent Player', 'icon': '🎮'},
          {'name': 'Social Master', 'icon': '👥'},
        ],
        'totalScore': 3450,
        'level': 8,
      },
      totalGamesPlayed: 24,
      averageScore: 78.5,
    );
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
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

import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/auth_controller.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/services/gaze_results_service.dart';
import 'package:lensaaurora/app/models/child_profile.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  late GazeResultsService gazeResultsService;
  final authController = Get.find<AuthController>();

  // Observable metrics from Firestore
  final gazeAttentionScore = 0.obs; // 0-100
  final motorBehaviorScore = 0.obs; // 0-100 (currently 0)
  final cognitiveSkillScore = 0.obs; // 0-100 (currently 0)

  final isLoadingMetrics = false.obs;
  
  // Children management for parent users
  final childrenList = <ChildProfile>[].obs;
  final selectedChild = Rxn<ChildProfile>();
  final isLoadingChildren = false.obs;

  @override
  void onInit() {
    super.onInit();
    gazeResultsService = GazeResultsService();
    _loadMetrics();
    
    // Load children in background (only for parents)
    // Will be loaded when role becomes available or when user navigates to child section
    if (authController.userRole.value == 'parent') {
      _loadChildren();
    } else {
      // Listen for role changes in case user role is updated later
      ever(authController.userRole, (role) {
        if (role == 'parent' && childrenList.isEmpty) {
          _loadChildren();
        }
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().syncIndex(0);
    }
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  /// Load metrics from Firestore
  Future<void> _loadMetrics() async {
    try {
      isLoadingMetrics.value = true;

      // Get latest gaze score with 8-second timeout
      try {
        final gazeScore = await gazeResultsService
            .getLatestGazeScore()
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () {
                print('WARNING: getLatestGazeScore timeout');
                return null;
              },
            );
        gazeAttentionScore.value = gazeScore ?? 0;
      } catch (e) {
        print('Error loading gaze score: $e');
        gazeAttentionScore.value = 0;
      }

      // Motor Behavior - placeholder (no data yet)
      motorBehaviorScore.value = 0;

      // Cognitive Skill - placeholder (no data yet)
      cognitiveSkillScore.value = 0;
    } catch (e) {
      print('Error loading metrics: $e');
    } finally {
      isLoadingMetrics.value = false;
    }
  }

  /// Refresh metrics (call this when returning to home from gaze test)
  Future<void> refreshMetrics() async {
    await _loadMetrics();
  }

  /// Load children for parent user
  Future<void> _loadChildren() async {
    try {
      isLoadingChildren.value = true;
      final userId = authController.currentUser.value?.uid;
      
      if (userId != null) {
        // Get children with 8-second timeout
        try {
          final children = await authController.authService
              .getChildren(userId)
              .timeout(
                const Duration(seconds: 8),
                onTimeout: () {
                  print('WARNING: getChildren timeout');
                  return [];
                },
              );
          childrenList.assignAll(children);
          
          // Auto-select first child if available
          if (children.isNotEmpty && selectedChild.value == null) {
            selectedChild.value = children.first;
          }
        } catch (e) {
          print('Error loading children: $e');
        }
      }
    } catch (e) {
      print('Error in _loadChildren: $e');
    } finally {
      isLoadingChildren.value = false;
    }
  }

  /// Select a child for viewing their progress
  void selectChild(ChildProfile child) {
    selectedChild.value = child;
    _loadMetrics(); // Reload metrics for this child
  }

  /// Add a new child (parent only)
  Future<bool> addChild(String name, int age) async {
    try {
      final userId = authController.currentUser.value?.uid;
      if (userId == null) return false;

      final childId = DateTime.now().millisecondsSinceEpoch.toString();
      final newChild = ChildProfile(
        id: childId,
        name: name,
        age: age,
        createdAt: DateTime.now(),
      );

      await authController.authService.addChild(userId, newChild);
      childrenList.add(newChild);
      
      // Auto-select newly added child
      selectedChild.value = newChild;
      return true;
    } catch (e) {
      print('Error adding child: $e');
      return false;
    }
  }
}

import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/auth_controller.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/services/gaze_results_service.dart';
import 'package:lensaaurora/app/services/game_results_service.dart';
import 'package:lensaaurora/app/models/child_profile.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  late GazeResultsService gazeResultsService;
  late GameResultsService gameResultsService;
  final authController = Get.find<AuthController>();

  final gazeAttentionScore = 0.obs;
  final motorBehaviorScore = 0.obs;
  final cognitiveSkillScore = 0.obs;
  final weeklyProgressDelta = RxnInt();
  final overallRiskLabel = 'Belum Ditest'.obs;
  final overallRiskDescription =
      'Lakukan skrining gaze tracking untuk melihat status deteksi.'.obs;

  final isLoadingMetrics = false.obs;
  final childrenList = <ChildProfile>[].obs;
  final selectedChild = Rxn<ChildProfile>();
  final isLoadingChildren = false.obs;

  @override
  void onInit() {
    super.onInit();
    gazeResultsService = GazeResultsService();
    gameResultsService = GameResultsService();
    _loadMetrics();

    if (authController.userRole.value == 'parent') {
      _loadChildren();
    } else {
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

  Future<void> _loadMetrics() async {
    try {
      isLoadingMetrics.value = true;

      try {
        final gazeScore = await gazeResultsService
            .getLatestGazeScore()
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => null,
            );
        gazeAttentionScore.value = gazeScore ?? 0;
      } catch (e) {
        gazeAttentionScore.value = 0;
      }

      try {
        final cognitiveScore = await gameResultsService
            .getLatestCognitiveScore()
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => null,
            );
        cognitiveSkillScore.value = cognitiveScore ?? 0;
      } catch (e) {
        cognitiveSkillScore.value = 0;
      }

      motorBehaviorScore.value = 0;

      try {
        weeklyProgressDelta.value = await gameResultsService
            .getWeeklyProgressDelta()
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => null,
            );
      } catch (e) {
        weeklyProgressDelta.value = null;
      }

      _updateOverallRisk();
    } finally {
      isLoadingMetrics.value = false;
    }
  }

  void _updateOverallRisk() {
    final gaze = gazeAttentionScore.value;
    final cognitive = cognitiveSkillScore.value;

    if (gaze == 0 && cognitive == 0) {
      overallRiskLabel.value = 'Belum Ditest';
      overallRiskDescription.value =
          'Lakukan skrining gaze tracking dan mainkan game kognitif untuk melihat status.';
      return;
    }

    final combined = gaze > 0 && cognitive > 0
        ? ((gaze + cognitive) / 2).round()
        : (gaze > 0 ? gaze : cognitive);

    if (combined >= 70) {
      overallRiskLabel.value = 'Risiko\nRendah';
      overallRiskDescription.value =
          'Perkembangan menunjukkan tren positif berdasarkan data skrining dan game terbaru.';
    } else if (combined >= 40) {
      overallRiskLabel.value = 'Perlu\nPemantauan';
      overallRiskDescription.value =
          'Hasil skrining menunjukkan area yang perlu diperhatikan. Lakukan tes rutin.';
    } else {
      overallRiskLabel.value = 'Perlu\nEvaluasi';
      overallRiskDescription.value =
          'Disarankan konsultasi lebih lanjut dengan profesional terkait.';
    }
  }

  Future<void> refreshMetrics() async {
    await _loadMetrics();
  }

  Future<void> _loadChildren() async {
    try {
      isLoadingChildren.value = true;
      final userId = authController.currentUser.value?.uid;

      if (userId != null) {
        try {
          final children = await authController.authService
              .getChildren(userId)
              .timeout(
                const Duration(seconds: 8),
                onTimeout: () => [],
              );
          childrenList.assignAll(children);

          if (children.isNotEmpty && selectedChild.value == null) {
            selectedChild.value = children.first;
          }
        } catch (e) {
          // ignore
        }
      }
    } finally {
      isLoadingChildren.value = false;
    }
  }

  void selectChild(ChildProfile child) {
    selectedChild.value = child;
    _loadMetrics();
  }

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
      selectedChild.value = newChild;
      return true;
    } catch (e) {
      return false;
    }
  }

  void navigateToScan() {
    Get.find<NavigationController>().navigateToScan();
  }
}

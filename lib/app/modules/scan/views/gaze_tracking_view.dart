import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/modules/scan/controllers/gaze_tracking_controller.dart';
import 'package:lensaaurora/app/models/gaze_data.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import 'package:lensaaurora/app/widgets/test_step_header.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';

class GazeTrackingView extends GetView<GazeTrackingController> {
  const GazeTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent automatic back navigation
        // User must click an explicit button to go back
        Get.snackbar(
          'Info',
          'Silakan gunakan tombol "Kembali ke Menu" untuk kembali',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gaze Tracking'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Custom back button handling
              Get.snackbar(
                'Info',
                'Silakan gunakan tombol "Kembali ke Menu" untuk kembali',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: Obx(() {
          switch (controller.testState.value) {
            case TestState.idle:
              return _buildIdleState();
            case TestState.running:
              return _buildGazeTrackingContent();
            case TestState.completed:
              return _buildCompletionScreen();
            case TestState.aborted:
              return _buildAbortedScreen();
          }
        }),
      ),
    );
  }

  Widget _buildIdleState() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const TestStepHeader(currentStep: 1),
          // Camera preview with natural ratio (no squish).
          if (controller.isCameraReady.value)
            Expanded(child: _buildCameraPreviewCard())
          else
            Expanded(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom instruction panel
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceTint,
              borderRadius: AppTheme.br24,
              boxShadow: AppTheme.shadowCard,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.visibility,
                  color: AppTheme.primaryBlue,
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tes Gaze Tracking',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fokuskan mata ke titik di tengah layar selama 30 detik',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => AuroraPrimaryButton(
                    label: controller.isInitializing.value
                        ? 'Inisialisasi Kamera...'
                        : 'Mulai Test',
                    height: 48,
                    onPressed: controller.isCameraReady.value
                        ? _showTestConfirmationDialog
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Skip button (temporary)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.SPEECH_ANALYSIS),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Lewati Gaze Tracking',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTestConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.br20),
        title: const Text(
          'Konfirmasi Mulai Test',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Pastikan pencahayaan cukup dan wajah Anda terlihat jelas di kamera. Fokuskan mata ke titik di tengah layar selama 30 detik.',
          style: TextStyle(color: AppTheme.textDark, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.startGazeTest(duration: 30);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.br16),
            ),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }

  Widget _buildGazeTrackingContent() {
    return Column(
      children: [
        // Camera preview with natural ratio (no squish).
        if (controller.isCameraReady.value)
          Expanded(child: _buildCameraPreviewCard(showTrackingOverlay: true))
        else
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ),

        // Info panel at bottom - fixed height with all data
        _buildScanInfoPanel(),
      ],
    );
  }

  Widget _buildCameraPreviewCard({bool showTrackingOverlay = false}) {
    final previewAspectRatio =
        1 / controller.cameraController.value.aspectRatio;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: previewAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller.cameraController),
            if (showTrackingOverlay) ...[
              Container(color: Colors.black.withOpacity(0.12)),
              Center(
                child: Obx(
                  () => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getGazeIndicatorColor(),
                        width: 3,
                      ),
                      color: _getGazeIndicatorColor().withOpacity(0.1),
                    ),
                    child: Center(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getGazeIndicatorColor(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanInfoPanel() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceTint,
          borderRadius: AppTheme.br24,
          boxShadow: AppTheme.shadowCard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and description
            const Icon(Icons.visibility, color: AppTheme.primaryBlue, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Tes Gaze Tracking',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tersisa: ${controller.timeRemaining.value} detik',
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Status info - Data Points, FPS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.br12,
                boxShadow: AppTheme.shadowCard,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Data Points',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.gazeHistory.length}',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'FPS',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.gazeFPS.value}',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stop button
            AuroraPrimaryButton(
              label: 'Hentikan Test',
              height: 48,
              icon: const Icon(
                Icons.stop_circle_outlined,
                color: Colors.white,
                size: 20,
              ),
              gradient: LinearGradient(
                colors: [Colors.red.shade500, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () => controller.stopGazeTest(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbortedScreen() {
    return Container(
      color: AppTheme.bgLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: AppTheme.shadowLg,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Test Aborted',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tes gaze tracking telah dibatalkan',
              style: TextStyle(color: AppTheme.textLight, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              child: AuroraPrimaryButton(
                label: 'Ulangi',
                height: 48,
                icon: const Icon(Icons.replay, color: Colors.white, size: 20),
                onPressed: () {
                  controller.testState.value = TestState.idle;
                  controller.gazeHistory.clear();
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.refreshHomeMetricsIfAvailable();
                  Get.find<NavigationController>().syncIndex(0);
                  Get.offNamed(Routes.HOME);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textDark,
                  side: BorderSide(
                    color: AppTheme.textLight.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.br16),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGazeIndicatorColor() {
    final gazeData = controller.currentGaze.value;
    if (gazeData == null) {
      return Colors.grey;
    }

    switch (gazeData.direction) {
      case GazeDirection.center:
        return Colors.green;
      case GazeDirection.left:
        return Colors.orange;
      case GazeDirection.right:
        return Colors.orange;
      case GazeDirection.unknown:
        return Colors.red;
    }
  }

  Widget _buildCompletionScreen() {
    return Container(
      color: AppTheme.bgLight,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: AppTheme.shadowLg,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.primaryBlue,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tes Fokus Selesai',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Anda telah berhasil menyelesaikan tes gaze tracking. Data fokus Anda telah tercatat.\n\nSelanjutnya, kami akan melakukan tes Speech Analysis untuk mengevaluasi kemampuan berbicara dan artikulasi Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              AuroraPrimaryButton(
                label: 'Mulai Speech Analysis',
                onPressed: () {
                  Get.toNamed(Routes.SPEECH_ANALYSIS);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.refreshHomeMetricsIfAvailable();
                    Get.find<NavigationController>().syncIndex(0);
                    Get.offNamed(Routes.HOME);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali ke Menu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textDark,
                    side: BorderSide(
                      color: AppTheme.textLight.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.br16),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

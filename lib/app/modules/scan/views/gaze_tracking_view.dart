import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/scan/controllers/gaze_tracking_controller.dart';
import 'package:lensaaurora/app/models/gaze_data.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';

class GazeTrackingView extends GetView<GazeTrackingController> {
  const GazeTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaze Tracking - Step 1'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
      ),
      backgroundColor: Colors.black,
      body: Obx(
        () {
          switch (controller.testState.value) {
            case TestState.idle:
              return _buildIdleState();
            case TestState.running:
              return _buildGazeTrackingContent();
            case TestState.completed:
              return _buildTestResultsScreen();
            case TestState.aborted:
              return _buildAbortedScreen();
            default:
              return _buildIdleState();
          }
        },
      ),
    );
  }

  Widget _buildIdleState() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Camera preview at top - constrained with aspect ratio
          if (controller.isCameraReady.value)
            Expanded(
              child: Container(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: controller.cameraController.value.aspectRatio,
                  child: CameraPreview(controller.cameraController),
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                ),
              ),
            ),

          // Bottom instruction panel - fixed height
          Container(
            color: Colors.black.withOpacity(0.9),
            padding: const EdgeInsets.all(24),
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fokuskan mata ke titik di tengah layar selama 30 detik',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isCameraReady.value
                          ? _showTestConfirmationDialog
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        controller.isInitializing.value
                            ? 'Inisialisasi Kamera...'
                            : 'Mulai Test',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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
        title: const Text(
          'Konfirmasi Mulai Test',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Pastikan pencahayaan cukup dan wajah Anda terlihat jelas di kamera. Fokuskan mata ke titik di tengah layar selama 30 detik.',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.startGazeTest(duration: 30);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
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
        // Camera preview at top - same layout as idle state (not stretched)
        if (controller.isCameraReady.value)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: controller.cameraController.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera preview
                    CameraPreview(controller.cameraController),

                    // Semi-transparent overlay
                    Container(
                      color: Colors.black.withOpacity(0.15),
                    ),

                    // Center fixation point (only overlay on camera)
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
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              ),
            ),
          ),

        // Info panel at bottom - fixed height with all data
        _buildScanInfoPanel(),
      ],
    );
  }

  Widget _buildScanInfoPanel() {
    return Obx(
      () => Container(
        color: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and description
            const Icon(
              Icons.visibility,
              color: AppTheme.primaryBlue,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tes Gaze Tracking',
              style: TextStyle(
                color: Colors.white,
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Data Points',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.gazeHistory.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'FPS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.gazeFPS.value}',
                        style: const TextStyle(
                          color: Colors.white,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.stopGazeTest(),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Hentikan Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Obx(
      () => Container(
        color: Colors.black.withOpacity(0.95),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status info - Time, Data Points, FPS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Waktu',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.timeRemaining.value}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Data',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.gazeHistory.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'FPS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.gazeFPS.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stop button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.stopGazeTest(),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Hentikan Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbortedScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
                border: Border.all(
                  color: Colors.orange,
                  width: 3,
                ),
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
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tes gaze tracking telah dibatalkan',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.testState.value = TestState.idle;
                  controller.gazeHistory.clear();
                },
                icon: const Icon(Icons.replay),
                label: const Text('Ulangi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: OutlinedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsScreen() {
    final stats = controller.getGazeStatistics();

    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Completed badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.2),
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 40,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Tes Gaze Tracking Selesai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
            if (stats != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('Total Data Points', '${stats.gazePoints.length}'),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Fixation Center',
                      '${stats.centerFixationDuration.toStringAsFixed(1)} frames',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Fixation Left',
                      '${stats.leftFixationDuration.toStringAsFixed(1)} frames',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Fixation Right',
                      '${stats.rightFixationDuration.toStringAsFixed(1)} frames',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Gaze Switches',
                      '${stats.gazeSwitchCount}',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Avg Confidence',
                      '${(stats.averageConfidence * 100).toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Joint Attention Success',
                      '${stats.jointAttentionSuccessCount}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Reset to idle state and show confirmation dialog
                  controller.testState.value = TestState.idle;
                  controller.gazeHistory.clear();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _showTestConfirmationDialog();
                  });
                },
                icon: const Icon(Icons.replay),
                label: const Text('Ulangi Tes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(Routes.SCAN);
                  // TODO: Pass gaze statistics to next step (Speech Analysis)
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Lanjut ke Speech Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Menu'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
}

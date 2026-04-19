import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/motor_behavior/controllers/motor_behavior_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

class MotorBehaviorView extends GetView<MotorBehaviorController> {
  const MotorBehaviorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Behavior - Step 3'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.black,
      body: Obx(
        () {
          switch (controller.testState.value) {
            case MotorTestState.menu:
              return _buildMenuScreen();
            case MotorTestState.testing:
              if (controller.currentTest.value == MotorTestType.traceTest) {
                return _buildTraceTestScreen();
              } else {
                return _buildTapTargetScreen();
              }
            case MotorTestState.completed:
              return _buildCompletionScreen();
            default:
              return _buildMenuScreen();
          }
        },
      ),
    );
  }

  Widget _buildMenuScreen() {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.2),
                border: Border.all(
                  color: AppTheme.primaryBlue,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.pan_tool_alt,
                color: AppTheme.primaryBlue,
                size: 56,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Motor Behavior Test',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tes ini mengevaluasi koordinasi motorik, ketepatan, dan kontrol gerakan Anda. Ada dua jenis tes yang akan dilakukan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            // Trace Test Card (Info only)
            _buildInfoCard(
              title: 'Trace Test',
              description:
                  'Ikuti garis yang ditampilkan di layar. Test ini mengukur kehalusan gerakan, deviasi jalur, dan kontrol motorik Anda.',
              metrics: [
                'Deviasi jalur (jarak ke garis ideal)',
                'Keluar jalur (jumlah & durasi)',
                'Kehalusan gerak (smoothness)',
              ],
            ),
            const SizedBox(height: 16),
            // Tap Target Card (Info only)
            _buildInfoCard(
              title: 'Tap Target',
              description:
                  'Ketuk lingkaran saat muncul dengan seakurat mungkin. Test ini mengukur waktu reaksi, akurasi, dan konsistensi Anda.',
              metrics: [
                'Reaction time (waktu reaksi)',
                'Akurasi (hit/miss)',
                'Konsistensi (variasi waktu reaksi)',
              ],
            ),
            const SizedBox(height: 40),
            // Mulai Motor Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.selectTest(MotorTestType.traceTest),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Mulai Motor Behavior Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required List<String> metrics,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...metrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      metric,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraceTestScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.black.withOpacity(0.9),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trace Test',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    'Level ${controller.traceLevel.value + 1}/3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Drawing area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: AppTheme.primaryBlue,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gesture drawing area\n(Canvas akan diimplementasikan)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Controls
          Container(
            color: Colors.black.withOpacity(0.9),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.completeTest(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Selesai Trace Test'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapTargetScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.black.withOpacity(0.9),
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Tap Target Test',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Tap area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.3),
                        border: Border.all(
                          color: Colors.green,
                          width: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap the circle\n(Target akan bergerak acak)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Controls
          Container(
            color: Colors.black.withOpacity(0.9),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.completeTest(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Selesai Tap Target'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Container(
      color: Colors.black,
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
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  border: Border.all(
                    color: AppTheme.primaryBlue,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.primaryBlue,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Motor Behavior Test Selesai',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Semua tes telah berhasil diselesaikan. Data koordinasi motorik dan ketepatan Anda telah terekam. Analisis lengkap akan ditampilkan di layar hasil akhir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Menu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

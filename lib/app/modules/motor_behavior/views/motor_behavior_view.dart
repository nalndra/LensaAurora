import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/motor_behavior/controllers/motor_behavior_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';

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
      backgroundColor: AppTheme.bgLight,
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
          }
        },
      ),
    );
  }

  Widget _buildMenuScreen() {
    return Container(
      color: AppTheme.bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: AppTheme.shadowLg,
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
                color: AppTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tes ini mengevaluasi koordinasi motorik, ketepatan, dan kontrol gerakan Anda. Ada dua jenis tes yang akan dilakukan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textLight,
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
            AuroraPrimaryButton(
              label: 'Mulai Motor Behavior Test',
              onPressed: () => controller.selectTest(MotorTestType.traceTest),
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
        color: Colors.white,
        borderRadius: AppTheme.br20,
        boxShadow: AppTheme.shadowCard,
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
              color: AppTheme.textDark,
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
                        color: AppTheme.textLight,
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
      color: AppTheme.bgLight,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
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
                      color: AppTheme.textDark,
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
                color: Colors.white,
                borderRadius: AppTheme.br20,
                boxShadow: AppTheme.shadowCard,
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
                        color: AppTheme.textLight,
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
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AuroraPrimaryButton(
                  label: 'Selesai Trace Test',
                  gradient: AppTheme.greenGradient,
                  onPressed: () => controller.completeTest(),
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
      color: AppTheme.bgLight,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
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
                color: Colors.white,
                borderRadius: AppTheme.br20,
                boxShadow: AppTheme.shadowCard,
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
                        color: Colors.green.withValues(alpha: 0.15),
                        boxShadow: AppTheme.shadowButton(Colors.green),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap the circle\n(Target akan bergerak acak)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textLight,
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
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AuroraPrimaryButton(
                  label: 'Selesai Tap Target',
                  gradient: AppTheme.greenGradient,
                  onPressed: () => controller.completeTest(),
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
                'Motor Behavior Test Selesai',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Semua tes telah berhasil diselesaikan. Data koordinasi motorik dan ketepatan Anda telah terekam. Analisis lengkap akan ditampilkan di layar hasil akhir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              AuroraPrimaryButton(
                label: 'Kembali ke Menu',
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

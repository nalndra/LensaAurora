import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/speech_analysis/controllers/speech_analysis_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';

class SpeechAnalysisView extends GetView<SpeechAnalysisController> {
  const SpeechAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Analysis - Step 2'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Obx(
        () {
          switch (controller.testState.value) {
            case SpeechTestState.idle:
              return _buildPrepareScreen();
            case SpeechTestState.reading:
              return _buildReadingScreen();
            case SpeechTestState.completed:
              return _buildCompletionScreen();
            default:
              return _buildPrepareScreen();
          }
        },
      ),
    );
  }

  Widget _buildPrepareScreen() {
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
                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                boxShadow: AppTheme.shadowButton(AppTheme.primaryBlue),
              ),
              child: const Icon(
                Icons.mic_none,
                color: AppTheme.primaryBlue,
                size: 56,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Speech Analysis Test',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pada test ini, Anda akan diminta untuk membaca beberapa paragraf dengan jelas dan natural. Sistem akan menganalisis tingkat gugup, gangguan berbicara (stutter), dan kecepatan membaca Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: AppTheme.br20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Petunjuk:',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Baca paragraf dengan suara yang jelas\n'
                    '• Berbicara dengan tempo normal\n'
                    '• Hindari menghentikan atau mengulang\n'
                    '• Mikrofon harus berfungsi baik',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AuroraPrimaryButton(
              label: 'Mulai Tes Berbicara',
              onPressed: () => controller.startSpeechTest(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Progress indicator
          Obx(
            () => Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paragraf ${controller.currentParagraphIndex.value + 1}/${controller.paragraphs.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.mic, color: Colors.red, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: AppTheme.brPill,
                    child: LinearProgressIndicator(
                      value: (controller.currentParagraphIndex.value + 1) /
                          controller.paragraphs.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Paragraph to read
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: AppTheme.br20,
                    boxShadow: AppTheme.shadowButton(AppTheme.primaryBlue),
                  ),
                  child: Text(
                    controller.paragraphs[controller.currentParagraphIndex.value],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Control buttons
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Record button - Circular big button (fixed position)
                Obx(
                  () => Center(
                    child: GestureDetector(
                      onTap: controller.recordingExists.value
                          ? null
                          : () => controller.toggleRecording(),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.recordingExists.value
                              ? Colors.grey
                              : controller.isRecording.value
                                  ? Colors.red.shade600
                                  : AppTheme.primaryBlue,
                          boxShadow: controller.recordingExists.value
                              ? null
                              : AppTheme.shadowButton(
                                  controller.isRecording.value
                                      ? Colors.red
                                      : AppTheme.primaryBlue,
                                ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                controller.isRecording.value
                                    ? Icons.stop
                                    : Icons.mic,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.recordingExists.value
                                    ? 'Recorded'
                                    : controller.isRecording.value
                                        ? 'Stop'
                                        : 'Record',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Restart + Action buttons (side by side when recording exists)
                Obx(
                  () => controller.recordingExists.value
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    controller.restartRecording(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Mulai Ulang'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: BorderSide(
                                      color: Colors.orange
                                          .withValues(alpha: 0.6)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.br16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Lanjut button for paragraphs 1-2
                            if (controller.currentParagraphIndex.value <
                                controller.paragraphs.length - 1)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      controller.skipToNextParagraph(),
                                  icon: const Icon(Icons.skip_next),
                                  label: const Text('Lanjut'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppTheme.br16,
                                    ),
                                  ),
                                ),
                              )
                            // Selesai Membaca button for paragraph 3
                            else
                              Expanded(
                                child: AuroraPrimaryButton(
                                  label: 'Selesai Membaca',
                                  gradient: AppTheme.greenGradient,
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => controller.completeTest(),
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
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
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  boxShadow: AppTheme.shadowButton(AppTheme.primaryBlue),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.primaryBlue,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Speech Analysis Selesai',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Anda telah berhasil menyelesaikan tes analisis berbicara. Data suara dan pola berbicara Anda telah terekam dan dianalisis.\n\nSelanjutnya, kami akan melakukan tes Motor Behavior untuk mengevaluasi koordinasi motorik dan ketepatan Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              AuroraPrimaryButton(
                label: 'Mulai Motor Behavior Test',
                onPressed: () {
                  Get.toNamed(Routes.MOTOR_BEHAVIOR);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

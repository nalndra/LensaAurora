import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../controllers/speech_controller.dart';

class SpeechView extends GetView<SpeechController> {
  const SpeechView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Pidato'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
      ),
      backgroundColor: Colors.white,
      body: Obx(
        () => SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // Title
                const Text(
                  'Baca Paragraf dengan Jelas',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paragraf ${controller.currentParagraphIndex.value + 1} dari ${controller.paragraphs.length}',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // Paragraph text box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1FF),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.paragraphs[controller.currentParagraphIndex.value],
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 16,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 24),

                // Recording controls
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: controller.isRecording.value 
                          ? Colors.red 
                          : AppTheme.primaryBlue.withOpacity(0.12),
                      width: controller.isRecording.value ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Recording indicator
                      if (controller.isRecording.value)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Merekam...',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      else
                        const Icon(
                          Icons.mic_none,
                          color: AppTheme.primaryBlue,
                          size: 40,
                        ),
                      const SizedBox(height: 16),

                      // Record button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.isRecording.value
                              ? controller.stopRecording
                              : controller.startRecording,
                          icon: Icon(
                            controller.isRecording.value
                                ? Icons.stop_circle
                                : Icons.mic,
                          ),
                          label: Text(
                            controller.isRecording.value
                                ? 'Hentikan Rekam'
                                : 'Mulai Rekam',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isRecording.value
                                ? Colors.red.shade600
                                : AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Analyze button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.isAnalyzing.value
                              ? null
                              : controller.analyzeSpeech,
                          icon: const Icon(Icons.analytics),
                          label: Text(
                            controller.isAnalyzing.value
                                ? 'Menganalisis...'
                                : 'Analisis Pidato',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue.withOpacity(0.7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Analysis results
                if (controller.nervousnessLevel.value != 'Belum Dianalisis')
                  _buildAnalysisResults(),

                const SizedBox(height: 24),

                // Navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.currentParagraphIndex.value > 0
                            ? controller.previousParagraph
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Sebelumnya'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.currentParagraphIndex.value <
                                controller.paragraphs.length - 1
                            ? controller.nextParagraph
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Berikutnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Save speech analysis results and go to next module
                      Get.back();
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Selesai dan Lanjut'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Hasil Analisis',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnalysisRow(
            'Tingkat Gugup',
            controller.nervousnessLevel.value,
            _getNervousnessColor(controller.nervousnessLevel.value),
          ),
          const SizedBox(height: 8),
          _buildAnalysisRow(
            'Terbata-bata',
            controller.hasStuttering.value ? 'Ya' : 'Tidak',
            controller.hasStuttering.value ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 8),
          _buildAnalysisRow(
            'Kecepatan Bicara',
            controller.speechPace.value,
            _getPaceColor(controller.speechPace.value),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Akurasi Analisis',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
              Text(
                '${(controller.analysisConfidence.value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getNervousnessColor(String level) {
    switch (level) {
      case 'Rendah':
        return Colors.green;
      case 'Sedang':
        return Colors.orange;
      case 'Tinggi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaceColor(String pace) {
    switch (pace) {
      case 'Lambat':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      case 'Cepat':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

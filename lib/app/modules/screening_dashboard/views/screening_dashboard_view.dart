import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/screening_progress_widgets.dart';
import 'package:lensaaurora/app/modules/screening_dashboard/controllers/screening_dashboard_controller.dart';

class ScreeningDashboardView extends GetView<ScreeningDashboardController> {
  const ScreeningDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'Screening Progress & Rekomendasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: AppTheme.textDark,
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data screening...',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final profile = controller.screeningProfile.value;
          if (profile == null || !profile.isProfileComplete) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: controller.refreshScreeningData,
            color: AppTheme.primaryBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    _buildSummaryCard(),
                    const SizedBox(height: 24),

                    // Progress bars section
                    const Text(
                      'Hasil Skrining Domain',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProgressBars(),
                    const SizedBox(height: 24),

                    // Recommendations section
                    const Text(
                      'Rekomendasi Game Terarah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecommendations(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build empty state when no screening data
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 40,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Data Screening',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai screening untuk mendapatkan rekomendasi game yang dipersonalisasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.goToScreening('gaze_tracking');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Screening'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppTheme.br16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build summary card
  Widget _buildSummaryCard() {
    return Obx(
      () {
        final results = controller.screeningResults.value;
        if (results == null) return const SizedBox.shrink();

        return ScreeningSummaryCard(
          title: 'Status Perkembangan Anak',
          description: controller.summaryMessage.value,
          averageScore: results.averageScore.round(),
          areasNeedingHelp: results.areasNeedingImprovement,
        );
      },
    );
  }

  /// Build progress bars for each screening type
  Widget _buildProgressBars() {
    return Obx(
      () {
        final results = controller.screeningResults.value;
        if (results == null) return const SizedBox.shrink();

        return Column(
          children: [
            ScreeningProgressBar(
              label: 'Gaze Tracking & Attention',
              score: results.gazeScore,
              subtitle: ScreeningDashboardController.formatTestDate(results.gazeTestDate),
              progressColor: results.gazeScore >= 70 ? AppTheme.accentGreen : null,
              onTap: () => controller.goToScreening('gaze_tracking'),
            ),
            ScreeningProgressBar(
              label: 'Motor Behavior',
              score: results.motorScore,
              subtitle: ScreeningDashboardController.formatTestDate(results.motorTestDate),
              progressColor: results.motorScore >= 70 ? AppTheme.accentGreen : null,
              onTap: () => controller.goToScreening('motor_behavior'),
            ),
            ScreeningProgressBar(
              label: 'Speech Analysis',
              score: results.speechScore,
              subtitle: ScreeningDashboardController.formatTestDate(results.speechTestDate),
              progressColor: results.speechScore >= 70 ? AppTheme.accentGreen : null,
              onTap: () => controller.goToScreening('speech_analysis'),
            ),
            ScreeningProgressBar(
              label: 'Cognitive Skills',
              score: results.cognitiveScore,
              subtitle: ScreeningDashboardController.formatTestDate(results.cognitiveTestDate),
              progressColor: results.cognitiveScore >= 70 ? AppTheme.accentGreen : null,
            ),
          ],
        );
      },
    );
  }

  /// Build game recommendations
  Widget _buildRecommendations(BuildContext context) {
    return Obx(
      () {
        final recs = controller.recommendations;

        if (recs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.br16,
              boxShadow: AppTheme.shadowCard,
            ),
            child: Center(
              child: Text(
                'Tidak ada rekomendasi saat ini',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return Column(
          children: recs.map((rec) {
            return GameRecommendationCard(
              gameTitle: rec.gameName,
              reason: rec.reason,
              matchScore: rec.matchScore,
              skillToImprove: rec.skillToImprove,
              priority: rec.priority,
              onPlayGame: () => controller.playGame(rec.gameId, gameName: rec.gameName),
              onAddNote: () => _showAddNoteDialog(context, controller, rec.gameId, rec.gameName),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context, ScreeningDashboardController controller, String gameId, String gameTitle) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Catatan Terapis/Orang Tua: $gameTitle',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        content: TextField(
          controller: textController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tuliskan catatan atau observasi khusus...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                controller.addNote(gameId, text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

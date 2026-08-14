import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import 'package:lensaaurora/app/widgets/fade_slide_in.dart';
import 'package:lensaaurora/app/widgets/screening_area_card.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';
import '../controllers/scan_controller.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'Skrining',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Header Section with Title and Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai Skrining',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description with RichText
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppTheme.textLight,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Sesi pemeriksaan akan berlangsung selama ',
                        ),
                        TextSpan(
                          text: '15 menit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                        const TextSpan(
                          text: '. Kami akan menganalisis perkembangan dengan teknologi AI yang aman dan non-invasif.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Area Analisis Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceTint,
                  borderRadius: AppTheme.br24,
                  boxShadow: AppTheme.shadowCard,
                ),
                child: Column(
                  children: [
                    FadeSlideIn(
                      index: 0,
                      child: ScreeningAreaCard(
                        title: 'Gaze Tracking',
                        subtitle: 'Pola atensi visual',
                        icon: Icons.visibility,
                        onTap: () => Get.toNamed(Routes.GAZE_TRACKING),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      index: 1,
                      child: ScreeningAreaCard(
                        title: 'Speech Analysis',
                        subtitle: 'Linguistik & intonasi',
                        icon: Icons.mic,
                        onTap: () => Get.toNamed(Routes.SPEECH_ANALYSIS),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      index: 2,
                      child: ScreeningAreaCard(
                        title: 'Motor Behavior',
                        subtitle: 'Gerak motorik halus',
                        icon: Icons.accessibility_new_rounded,
                        onTap: () => Get.toNamed(Routes.MOTOR_BEHAVIOR),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Bottom Button Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SafeArea(
                child: AuroraPrimaryButton(
                  label: 'Mulai Scan',
                  onPressed: () => Get.toNamed(Routes.GAZE_TRACKING),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: const ChatFAB(),
    );
  }
}

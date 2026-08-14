import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import '../controllers/social_interaction_training_controller.dart';
import '../widgets/response_option_widget.dart';

class SocialInteractionTrainingView
    extends GetView<SocialInteractionTrainingController> {
  const SocialInteractionTrainingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Interaction Training'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scenario ${controller.currentScenarioIndex.value + 1}/${controller.scenarios.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Score: ${controller.score.value}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (controller.currentScenarioIndex.value + 1) /
                          controller.scenarios.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scenario content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scenario title
                    Text(
                      controller
                          .scenarios[controller.currentScenarioIndex.value]
                          .title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Scenario description
                    Text(
                      controller
                          .scenarios[controller.currentScenarioIndex.value]
                          .description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space16),
                    // Situation card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceTintBlue,
                        borderRadius: AppTheme.br20,
                        boxShadow: AppTheme.shadowCard,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📍 Situasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller
                                .scenarios[
                                    controller.currentScenarioIndex.value]
                                .situation,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Question
                    const Text(
                      '❓ Apa yang seharusnya kamu lakukan?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Response options
                    ...List.generate(
                      controller
                          .scenarios[controller.currentScenarioIndex.value]
                          .responses
                          .length,
                      (index) {
                        final response = controller
                            .scenarios[controller.currentScenarioIndex.value]
                            .responses[index];
                        return ResponseOptionWidget(
                          response: response,
                          isSelected: controller.selectedResponseId.value ==
                              response.id,
                          showFeedback: controller.showFeedback.value,
                          onSelected: () =>
                              controller.selectResponse(response.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Next button
            if (controller.showFeedback.value)
              Padding(
                padding: const EdgeInsets.all(16),
                child: AuroraPrimaryButton(
                  label: controller.currentScenarioIndex.value ==
                          controller.scenarios.length - 1
                      ? 'Selesai'
                      : 'Lanjut ke Scenario Berikutnya',
                  onPressed: () => controller.nextScenario(),
                  height: 52,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

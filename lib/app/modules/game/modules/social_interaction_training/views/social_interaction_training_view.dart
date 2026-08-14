import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/widgets/fade_slide_in.dart';
import '../controllers/social_interaction_training_controller.dart';
import '../widgets/response_option_widget.dart';

class SocialInteractionTrainingView
    extends GetView<SocialInteractionTrainingController> {
  const SocialInteractionTrainingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Social Interaction Training'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.accentGradient),
        ),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'Score: ${controller.score.value}',
                          key: ValueKey(controller.score.value),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: (controller.currentScenarioIndex.value + 1) /
                            controller.scenarios.length,
                      ),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: AppTheme.fieldFill,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(controller.currentScenarioIndex.value),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scenario title
                      Text(
                        controller
                            .scenarios[controller.currentScenarioIndex.value]
                            .title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Scenario description
                      Text(
                        controller
                            .scenarios[controller.currentScenarioIndex.value]
                            .description,
                        style: TextStyle(
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
                            Text(
                              '📍 Situasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller
                                  .scenarios[
                                      controller.currentScenarioIndex.value]
                                  .situation,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Question
                      Text(
                        '❓ Apa yang seharusnya kamu lakukan?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
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
                              .scenarios[
                                  controller.currentScenarioIndex.value]
                              .responses[index];
                          return FadeSlideIn(
                            index: index,
                            child: ResponseOptionWidget(
                              response: response,
                              isSelected:
                                  controller.selectedResponseId.value ==
                                      response.id,
                              showFeedback: controller.showFeedback.value,
                              onSelected: () =>
                                  controller.selectResponse(response.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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

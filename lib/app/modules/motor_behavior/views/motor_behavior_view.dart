import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import 'package:lensaaurora/app/widgets/confetti_burst.dart';
import 'package:lensaaurora/app/widgets/test_step_header.dart';
import '../controllers/motor_behavior_controller.dart';
import '../widgets/rhythm_tile_widget.dart';

class MotorBehaviorView extends GetView<MotorBehaviorController> {
  const MotorBehaviorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Behavior'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppTheme.bgLight,
      body: Obx(() {
        switch (controller.testState.value) {
          case MotorTestState.menu:
            return _buildMenuScreen();
          case MotorTestState.playing:
            return _buildGameScreen();
          case MotorTestState.completed:
            return _buildCompletionScreen();
        }
      }),
    );
  }

  Widget _buildMenuScreen() {
    return Container(
      color: AppTheme.bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const TestStepHeader(currentStep: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: AppTheme.shadowLg,
                    ),
                    child: const Icon(
                      Icons.pan_tool_alt,
                      color: AppTheme.primaryBlue,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Motor Behavior Test',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Balok akan jatuh dari atas layar. Ikuti instruksi setiap bentuk sebelum menyentuh garis target.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _legendCard(
                    icon: Icons.touch_app_rounded,
                    color: AppTheme.primaryBlue,
                    title: 'Kotak — Ketuk',
                    description:
                        'Ketuk sekali tepat saat balok menyentuh garis target.',
                  ),
                  const SizedBox(height: 12),
                  _legendCard(
                    icon: Icons.pan_tool_alt_rounded,
                    color: AppTheme.accentGreen,
                    title: 'Balok Panjang — Tahan',
                    description:
                        'Tekan dan tahan jari Anda sampai seluruh balok melewati garis.',
                  ),
                  const SizedBox(height: 12),
                  _legendCard(
                    icon: Icons.gesture_rounded,
                    color: AppTheme.accentGreenDark,
                    title: 'Zigzag — Tahan & Ikuti',
                    description:
                        'Tekan, tahan, dan gerakkan jari mengikuti garis zigzag yang bergerak.',
                  ),
                  const SizedBox(height: 32),
                  AuroraPrimaryButton(
                    label: 'Mulai Motor Behavior Test',
                    onPressed: () => controller.startGame(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.br20,
        boxShadow: AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppTheme.br16,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Container(
      color: AppTheme.bgLight,
      child: Column(
        children: [
          // HUD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.tilesResolved.value}/${MotorBehaviorController.totalTiles}',
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.comboCount.value > 1)
                    Text(
                      '🔥 Combo ${controller.comboCount.value}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    'Skor: ${controller.overallScorePercent}',
                    style: TextStyle(
                      color: AppTheme.accentGreenDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  controller.configureBoard(width, height);
                  final laneWidth = width / MotorBehaviorController.laneCount;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.br20,
                      boxShadow: AppTheme.shadowCard,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Lane separators
                        Row(
                          children: List.generate(
                            MotorBehaviorController.laneCount,
                            (i) => Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right:
                                        i <
                                            MotorBehaviorController.laneCount -
                                                1
                                        ? BorderSide(
                                            color: AppTheme.fieldFill,
                                            width: 2,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Hit line
                        Positioned(
                          top: controller.hitLineY,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                        // Falling tiles
                        Obx(() {
                          final elapsed = controller.elapsedMs;
                          return Stack(
                            children: controller.activeTiles.map((tile) {
                              return Positioned(
                                top: tile.topY(elapsed),
                                left: tile.lane * laneWidth + 8,
                                child: RhythmTileWidget(
                                  tile: tile,
                                  laneWidth: laneWidth,
                                  elapsedMs: elapsed,
                                ),
                              );
                            }).toList(),
                          );
                        }),
                        // Input zones (one per lane, full height)
                        Row(
                          children: List.generate(
                            MotorBehaviorController.laneCount,
                            (lane) => Expanded(
                              child: Listener(
                                behavior: HitTestBehavior.opaque,
                                onPointerDown: (e) =>
                                    controller.onLanePointerDown(
                                      lane,
                                      e.localPosition.dx,
                                    ),
                                onPointerMove: (e) =>
                                    controller.onLanePointerMove(
                                      lane,
                                      e.localPosition.dx,
                                    ),
                                onPointerUp: (_) =>
                                    controller.onLanePointerUp(lane),
                                onPointerCancel: (_) =>
                                    controller.onLanePointerUp(lane),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Container(
      color: AppTheme.bgLight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const ConfettiBurst(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: AppTheme.shadowLg,
                    ),
                    child: Text(
                      '${controller.overallScorePercent}',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Motor Behavior Test Selesai',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Koordinasi ketuk, tahan, dan lacak Anda telah terekam dan tersimpan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.br16,
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _scoreStat('Ketuk', controller.tapScores),
                        _scoreStat('Tahan', controller.holdScores),
                        _scoreStat('Zigzag', controller.traceScores),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuroraPrimaryButton(
                    label: 'Kembali ke Menu',
                    onPressed: () => controller.backToScan(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreStat(String label, List<double> scores) {
    final avg = scores.isEmpty
        ? 0
        : (scores.reduce((a, b) => a + b) / scores.length).round();
    return Column(
      children: [
        Text(
          '$avg',
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppTheme.textLight, fontSize: 11)),
      ],
    );
  }
}

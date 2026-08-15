import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/accessibility_controller.dart';
import 'package:lensaaurora/app/controllers/auth_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import 'package:lensaaurora/app/widgets/screening_progress_widgets.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final a11y = Get.find<AccessibilityController>();
    final userName = authController.currentUser.value?.displayName ?? 'User';

    return Obx(() {
      final accent = a11y.accentColor;
      final outline = a11y.useOutline.value;

      return Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _Header(
                    name: controller.selectedChild.value?.name ?? userName,
                    role: authController.userRole.value == 'parent'
                        ? 'Orang Tua'
                        : authController.userRole.value == 'personal'
                            ? 'Personal'
                            : 'Pengguna',
                    accent: accent,
                  ),
                ),
              ),
              if (authController.userRole.value == 'parent' &&
                  controller.childrenList.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.childrenList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final child = controller.childrenList[i];
                          final selected =
                              controller.selectedChild.value?.id == child.id;
                          return ChoiceChip(
                            label: Text(child.name),
                            selected: selected,
                            onSelected: (_) => controller.selectChild(child),
                            selectedColor: accent,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            side: BorderSide(color: accent),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatusBanner(
                      label: controller.overallRiskLabel.value
                          .replaceAll('\n', ' '),
                      description: controller.overallRiskDescription.value,
                      accent: accent,
                      outline: outline,
                      onScan: controller.navigateToScan,
                    ),
                    const SizedBox(height: 16),
                    _WeeklyRow(
                      delta: controller.weeklyProgressDelta.value,
                      accent: accent,
                      outline: outline,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Perkembangan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MetricTile(
                      title: 'Gaze & Attention',
                      score: controller.gazeAttentionScore.value,
                      icon: Icons.visibility_outlined,
                      color: AppTheme.primaryBlue,
                      accent: accent,
                      outline: outline,
                      onTap: () => controller.goToScreeningDomain('gaze'),
                    ),
                    const SizedBox(height: 10),
                    _MetricTile(
                      title: 'Motor Behavior',
                      score: controller.motorBehaviorScore.value,
                      icon: Icons.directions_run_outlined,
                      color: AppTheme.accentGreen,
                      accent: accent,
                      outline: outline,
                      onTap: () => controller.goToScreeningDomain('motor'),
                    ),
                    const SizedBox(height: 10),
                    _MetricTile(
                      title: 'Speech Analysis',
                      score: controller.speechScore.value,
                      icon: Icons.mic_outlined,
                      color: AppTheme.primaryDark,
                      accent: accent,
                      outline: outline,
                      onTap: () => controller.goToScreeningDomain('speech'),
                    ),
                    const SizedBox(height: 10),
                    _MetricTile(
                      title: 'Cognitive Skill',
                      score: controller.cognitiveSkillScore.value,
                      icon: Icons.psychology_outlined,
                      color: AppTheme.accentGreenDark,
                      accent: accent,
                      outline: outline,
                      onTap: () => controller.goToScreeningDomain('cognitive'),
                    ),
                    // Game Recommendations Section
                    if (controller.gameRecommendations.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Rekomendasi Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...controller.gameRecommendations.take(2).map((rec) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GameRecommendationCard(
                            gameTitle: rec.gameName,
                            reason: rec.reason,
                            matchScore: rec.matchScore,
                            skillToImprove: rec.skillToImprove,
                            priority: rec.priority,
                            onPlayGame: () => controller.playRecommendedGame(rec.gameId, rec.gameName),
                            onAddNote: () => _showAddNoteDialog(context, controller, rec.gameId, rec.gameName),
                          ),
                        );
                      }),
                      if (controller.gameRecommendations.length > 2)
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed('/screening-dashboard');
                            },
                            child: const Text(
                              'Lihat Semua Rekomendasi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                    ],
                    if (controller.gazeHistory.isNotEmpty ||
                        controller.speechHistory.isNotEmpty ||
                        controller.motorHistory.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Tren Skor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProgressChart(
                        gazeHistory: controller.gazeHistory,
                        speechHistory: controller.speechHistory,
                        motorHistory: controller.motorHistory,
                        outline: outline,
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: const ChatFAB(),
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.role,
    required this.accent,
  });

  final String name;
  final String role;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow: AppTheme.shadowCard,
          ),
          child: Icon(Icons.waving_hand_rounded, color: accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.label,
    required this.description,
    required this.accent,
    required this.outline,
    required this.onScan,
    this.onSimulate,
  });

  final String label;
  final String description;
  final Color accent;
  final bool outline;
  final VoidCallback onScan;
  final VoidCallback? onSimulate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.br24,
        border: outline
            ? Border.all(color: AppTheme.primaryDark, width: 2)
            : null,
        boxShadow: AppTheme.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppTheme.brPill,
            ),
            child: const Text(
              'STATUS TERKINI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text(
                      'Mulai Skrining',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.br16,
                        side: outline
                            ? BorderSide(color: AppTheme.primaryDark, width: 1.5)
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (onSimulate != null && label.contains('Belum')) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onSimulate,
                  icon: const Icon(Icons.auto_fix_high, size: 16, color: Colors.white),
                  label: const Text(
                    'Simulasi',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.br16),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyRow extends StatelessWidget {
  const _WeeklyRow({
    required this.delta,
    required this.accent,
    required this.outline,
  });

  final int? delta;
  final Color accent;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final hasDelta = delta != null;
    final deltaText = hasDelta ? '${delta! >= 0 ? '+' : ''}$delta%' : '—';
    final hint = hasDelta ? 'vs minggu lalu' : 'Belum ada perbandingan';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.br20,
        border: outline ? Border.all(color: accent, width: 2) : null,
        boxShadow: outline ? null : AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.trending_up_rounded, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progres mingguan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            deltaText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.score,
    required this.icon,
    required this.color,
    required this.accent,
    required this.outline,
    this.onTap,
  });

  final String title;
  final int score;
  final IconData icon;
  final Color color;
  final Color accent;
  final bool outline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final untested = score == 0;
    final status = untested
        ? 'Belum ditest'
        : score >= 80
            ? 'Sempurna'
            : score >= 60
                ? 'Optimal'
                : score >= 40
                    ? 'Baik'
                    : 'Perlu peningkatan';

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.br20,
        border: outline ? Border.all(color: accent, width: 2) : null,
        boxShadow: outline ? null : AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppTheme.br16,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEEF2F0),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                untested ? '—' : '$score%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: untested ? AppTheme.textLight : color,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({
    required this.gazeHistory,
    required this.speechHistory,
    required this.motorHistory,
    required this.outline,
  });

  final List<MapEntry<DateTime, int>> gazeHistory;
  final List<MapEntry<DateTime, int>> speechHistory;
  final List<MapEntry<DateTime, int>> motorHistory;
  final bool outline;

  static const _gazeColor = AppTheme.primaryBlue;
  static const _speechColor = AppTheme.primaryDark;
  static Color get _motorColor => AppTheme.accentGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.br20,
        border: outline ? Border.all(color: AppTheme.primaryBlue, width: 2) : null,
        boxShadow: outline ? null : AppTheme.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                _legendDot('Gaze', _gazeColor),
                const SizedBox(width: 14),
                _legendDot('Speech', _speechColor),
                const SizedBox(width: 14),
                _legendDot('Motor', _motorColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.fieldFill,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10, color: AppTheme.textLight),
                      ),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.primaryDark,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toInt()}',
                              const TextStyle(color: Colors.white, fontSize: 11),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  _series(gazeHistory, _gazeColor),
                  _series(speechHistory, _speechColor),
                  _series(motorHistory, _motorColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _series(List<MapEntry<DateTime, int>> history, Color color) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < history.length; i++)
          FlSpot(i.toDouble(), history[i].value.toDouble()),
      ],
      isCurved: true,
      curveSmoothness: 0.25,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        getDotPainter: (spot, percent, bar, index) =>
            FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0),
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

void _showAddNoteDialog(BuildContext context, HomeController controller, String gameId, String gameTitle) {
  final textController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Catatan Terapis: $gameTitle',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
      ),
      content: TextField(
        controller: textController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Tuliskan catatan atau instruksi khusus...',
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
              controller.addRecommendationNote(gameId, text);
              Navigator.pop(ctx);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

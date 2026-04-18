import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Reports'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => controller.reports.isEmpty
            ? const Center(
                child: Text('No reports available'),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      // Performance Overview
                      const Text(
                        'Performance Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPerformanceCards(),
                      const SizedBox(height: 24),
                      // Recent Games
                      const Text(
                        'Recent Game Sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildGameSessionsList(),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: const ChatFAB(),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildSummaryCard() {
    final report = controller.selectedReport.value!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.br16,
        boxShadow: AppTheme.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Summary',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.userName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assessment,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            report.summary,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards() {
    final report = controller.selectedReport.value!;
    return Row(
      children: [
        Expanded(
          child: _buildStatsCard(
            title: 'Average Score',
            value: "${report.getAverageScore().toStringAsFixed(1)}%",
            icon: Icons.trending_up,
            color: AppTheme.sageGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatsCard(
            title: 'Games Played',
            value: '${report.getTotalGamesPlayed()}',
            icon: Icons.sports_esports,
            color: AppTheme.cyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatsCard(
            title: 'Completion',
            value: '${report.getCompletedGames()}/${report.getTotalGamesPlayed()}',
            icon: Icons.check_circle,
            color: AppTheme.lightGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.br12,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSessionsList() {
    final report = controller.selectedReport.value!;
    return Column(
      children: List.generate(
        report.gameResults.length,
        (index) {
          final result = report.gameResults[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGameSessionCard(result),
          );
        },
      ),
    );
  }

  Widget _buildGameSessionCard(dynamic result) {
    Color performanceColor;
    IconData performanceIcon;

    switch (result.performance) {
      case 'Excellent':
        performanceColor = AppTheme.sageGreen;
        performanceIcon = Icons.star;
        break;
      case 'Good':
        performanceColor = AppTheme.cyan;
        performanceIcon = Icons.thumb_up;
        break;
      case 'Fair':
        performanceColor = Colors.orange;
        performanceIcon = Icons.info;
        break;
      default:
        performanceColor = Colors.red;
        performanceIcon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.br12,
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [performanceColor.withOpacity(0.8), performanceColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.sports_esports,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.gameTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Score: ${result.score}/${result.maxScore}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Time: ${result.getTimeString()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      performanceIcon,
                      color: performanceColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.performance,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: performanceColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.getAccuracy().toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

/// Widget untuk menampilkan progress bar dengan label dan score
class ScreeningProgressBar extends StatelessWidget {
  final String label;
  final int score; // 0-100
  final String? subtitle;
  final Color? progressColor;
  final bool showScore;
  final VoidCallback? onTap;
  final bool isLoading;

  const ScreeningProgressBar({
    super.key,
    required this.label,
    required this.score,
    this.subtitle,
    this.progressColor,
    this.showScore = true,
    this.onTap,
    this.isLoading = false,
  });

  /// Get color berdasarkan score
  Color _getProgressColor() {
    if (progressColor != null) return progressColor!;
    if (score >= 70) return AppTheme.accentGreen; // Green
    if (score >= 40) return AppTheme.accentOrange; // Orange/Warning
    return Colors.red; // Red
  }

  /// Get status text
  String _getStatusText() {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.br16,
          boxShadow: AppTheme.shadowCard,
          border: Border.all(
            color: _getProgressColor().withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row dengan label dan score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
                  ],
                ),
                if (showScore && !isLoading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(),
                        ),
                      ),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getProgressColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else if (isLoading)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: isLoading ? null : (score / 100.0).clamp(0.0, 1.0),
                backgroundColor: AppTheme.bgLight,
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan summary card dari screening results
class ScreeningSummaryCard extends StatelessWidget {
  final String title;
  final String description;
  final int averageScore;
  final List<String> areasNeedingHelp;
  final VoidCallback? onViewDetails;
  final bool isLoading;

  const ScreeningSummaryCard({
    super.key,
    required this.title,
    required this.description,
    required this.averageScore,
    required this.areasNeedingHelp,
    this.onViewDetails,
    this.isLoading = false,
  });

  Color _getStatusColor() {
    if (averageScore >= 70) return AppTheme.accentGreen;
    if (averageScore >= 40) return AppTheme.accentOrange;
    return Colors.red;
  }

  String _getRiskLabel() {
    if (averageScore >= 70) return 'Risiko Rendah';
    if (averageScore >= 40) return 'Perlu Pemantauan';
    return 'Perlu Evaluasi';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceTint,
        borderRadius: AppTheme.br24,
        boxShadow: AppTheme.shadowCard,
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title dengan risk badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$averageScore%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                    Text(
                      _getRiskLabel(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Areas needing help
          if (areasNeedingHelp.isNotEmpty) ...[
            const Text(
              'Fokus Improvement:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: areasNeedingHelp
                  .map((area) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.accentOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  area,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          // View Details button
          if (onViewDetails != null)
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusColor().withValues(alpha: 0.15),
                  foregroundColor: _getStatusColor(),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppTheme.br12),
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan game recommendations
class GameRecommendationCard extends StatelessWidget {
  final String gameTitle;
  final String reason;
  final int matchScore; // 0-100
  final String skillToImprove;
  final int priority; // 1-5
  final VoidCallback? onPlayGame;
  final VoidCallback? onAddNote;
  final String? noteText;

  const GameRecommendationCard({
    super.key,
    required this.gameTitle,
    required this.reason,
    required this.matchScore,
    required this.skillToImprove,
    required this.priority,
    this.onPlayGame,
    this.onAddNote,
    this.noteText,
  });

  Color _getPriorityColor() {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return AppTheme.accentOrange;
      case 3:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel() {
    switch (priority) {
      case 1:
        return 'High Priority';
      case 2:
        return 'Medium Priority';
      case 3:
        return 'Low Priority';
      default:
        return 'Optional';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.br16,
        boxShadow: AppTheme.shadowCard,
        border: Border(
          left: BorderSide(
            color: _getPriorityColor(),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title dengan priority badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPriorityColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getPriorityLabel(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getPriorityColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Skill improvement info
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: AppTheme.accentGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tingkatkan: $skillToImprove',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Match score bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Match Score',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$matchScore%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: matchScore / 100.0,
                        backgroundColor: AppTheme.bgLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (noteText != null && noteText!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.fieldFill,
                borderRadius: AppTheme.br12,
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_outlined, size: 16, color: AppTheme.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Catatan Terapis/Orang Tua: $noteText',
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Action Buttons: Play button & Add Note button
          Row(
            children: [
              if (onAddNote != null) ...[
                IconButton(
                  onPressed: onAddNote,
                  tooltip: 'Tambah Catatan Terapis',
                  icon: const Icon(Icons.note_add_outlined, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 8),
              ],
              if (onPlayGame != null)
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: onPlayGame,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Main Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: AppTheme.br12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan loading state
class ScreeningLoadingCard extends StatelessWidget {
  final String title;

  const ScreeningLoadingCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceTint,
        borderRadius: AppTheme.br16,
        boxShadow: AppTheme.shadowCard,
      ),
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
          const SizedBox(height: 12),
          const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

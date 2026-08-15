import 'package:flutter/foundation.dart';

/// Model untuk game recommendation berdasarkan screening results
class GameRecommendation {
  final String gameId;
  final String gameName;
  final String category; // 'cognitive', 'motor', 'speech'
  final int priority; // 1-5, dimana 1 adalah prioritas tertinggi
  final String reason; // Alasan mengapa game ini direkomendasikan
  final int matchScore; // 0-100, berapa persen cocok dengan profile user
  final String skillToImprove; // Skill apa yang akan ditingkatkan
  final double? intensityAdjustment; // 0.6-2.0, adjustment factor berdasarkan trend
  final String? insightMessage; // Additional context message

  GameRecommendation({
    required this.gameId,
    required this.gameName,
    required this.category,
    required this.priority,
    required this.reason,
    required this.matchScore,
    required this.skillToImprove,
    this.intensityAdjustment,
    this.insightMessage,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'gameName': gameName,
    'category': category,
    'priority': priority,
    'reason': reason,
    'matchScore': matchScore,
    'skillToImprove': skillToImprove,
    'intensityAdjustment': intensityAdjustment,
    'insightMessage': insightMessage,
  };
}

/// Screening Profile - Merangkum hasil screening user
class ScreeningProfile {
  final int gazeScore; // 0-100
  final int motorScore; // 0-100
  final int speechScore; // 0-100
  final int cognitiveScore; // 0-100
  final DateTime? lastGazeTestDate;
  final DateTime? lastMotorTestDate;
  final DateTime? lastSpeechTestDate;

  ScreeningProfile({
    required this.gazeScore,
    required this.motorScore,
    required this.speechScore,
    required this.cognitiveScore,
    this.lastGazeTestDate,
    this.lastMotorTestDate,
    this.lastSpeechTestDate,
  });

  /// Hitung score tertinggi
  int get highestScore => [gazeScore, motorScore, speechScore, cognitiveScore].reduce((a, b) => a > b ? a : b);

  /// Hitung score terendah yang perlu improvement
  int get lowestScore => [gazeScore, motorScore, speechScore, cognitiveScore].reduce((a, b) => a < b ? a : b);

  /// Hitung rata-rata score
  double get averageScore => (gazeScore + motorScore + speechScore + cognitiveScore) / 4;

  /// Check apakah user sudah pernah di-test
  bool get isProfileComplete => gazeScore > 0 || motorScore > 0 || speechScore > 0;
}

/// Service untuk merekomendasikan game berdasarkan screening results
class GameRecommendationService {
  static const String TAG = '[GameRecommendationService]';

  /// Daftar game yang tersedia dengan kategorinya
  static final _availableGames = [
    {
      'id': '1',
      'title': 'Social Interaction Training',
      'category': 'cognitive',
      'primarySkill': 'social_communication',
      'skillsImproved': ['social_interaction', 'communication', 'joint_attention'],
      'description': 'Latih kemampuan komunikasi dan interaksi sosial dengan simulasi percakapan',
    },
    {
      'id': '2',
      'title': 'Collaborative Puzzle Game',
      'category': 'motor',
      'primarySkill': 'motor_coordination',
      'skillsImproved': ['motor_coordination', 'collaboration', 'problem_solving'],
      'description': 'Puzzle game yang memerlukan kolaborasi 2 pemain - Enforced Collaboration',
    },
  ];

  /// Generate rekomendasi game berdasarkan screening profile
  /// Returns list sorted by priority (1 = highest)
  static List<GameRecommendation> generateRecommendations(ScreeningProfile profile) {
    try {
      if (!profile.isProfileComplete) {
        debugPrint('$TAG Profile belum lengkap. Tidak dapat generate rekomendasi.');
        return [];
      }

      final recommendations = <GameRecommendation>[];

      // Analisis scoring profile
      final scores = {
        'gaze': profile.gazeScore,
        'motor': profile.motorScore,
        'speech': profile.speechScore,
        'cognitive': profile.cognitiveScore,
      };

      // Sort by score untuk menentukan prioritas
      final sortedScores = scores.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

      debugPrint('$TAG Sorted scores: ${sortedScores.map((e) => '${e.key}=${e.value}').join(', ')}');

      // Recommend game untuk score terendah
      if (profile.gazeScore < profile.motorScore && profile.gazeScore < 70) {
        recommendations.addAll(_getGazeTrainingRecommendations(profile));
      }

      if (profile.motorScore < 70) {
        recommendations.addAll(_getMotorTrainingRecommendations(profile));
      }

      if (profile.speechScore < 70) {
        recommendations.addAll(_getSpeechTrainingRecommendations(profile));
      }

      // Jika semua score tinggi, rekomendasikan untuk improvement
      if (profile.averageScore >= 70) {
        recommendations.addAll(_getEnhancementRecommendations(profile));
      }

      // Sort by priority
      recommendations.sort((a, b) => a.priority.compareTo(b.priority));

      // Remove duplicates (keep highest priority)
      final uniqueRecommendations = <String, GameRecommendation>{};
      for (final rec in recommendations) {
        if (!uniqueRecommendations.containsKey(rec.gameId) ||
            rec.priority < uniqueRecommendations[rec.gameId]!.priority) {
          uniqueRecommendations[rec.gameId] = rec;
        }
      }

      debugPrint('$TAG Generated ${uniqueRecommendations.length} unique recommendations');
      return uniqueRecommendations.values.toList()..sort((a, b) => a.priority.compareTo(b.priority));
    } catch (e) {
      debugPrint('$TAG Error generating recommendations: $e');
      return [];
    }
  }

  /// Rekomendasi untuk meningkatkan Gaze Tracking
  static List<GameRecommendation> _getGazeTrainingRecommendations(ScreeningProfile profile) {
    final recommendations = <GameRecommendation>[];

    // Social Interaction Training membantu meningkatkan joint attention
    if (profile.gazeScore < 50) {
      recommendations.add(
        GameRecommendation(
          gameId: '1',
          gameName: 'Social Interaction Training',
          category: 'cognitive',
          priority: 1, // Prioritas tertinggi
          reason: 'Gaze tracking score rendah. Game ini melatih joint attention dan eye contact.',
          matchScore: _calculateMatchScore(profile.gazeScore, targetScore: 70, weight: 1.5),
          skillToImprove: 'Joint Attention & Eye Contact',
        ),
      );
    } else if (profile.gazeScore < 70) {
      recommendations.add(
        GameRecommendation(
          gameId: '1',
          gameName: 'Social Interaction Training',
          category: 'cognitive',
          priority: 2,
          reason: 'Gaze tracking score perlu ditingkatkan. Social Interaction Training dapat membantu.',
          matchScore: _calculateMatchScore(profile.gazeScore, targetScore: 70, weight: 1.2),
          skillToImprove: 'Joint Attention Improvement',
        ),
      );
    }

    return recommendations;
  }

  /// Rekomendasi untuk meningkatkan Motor Behavior
  static List<GameRecommendation> _getMotorTrainingRecommendations(ScreeningProfile profile) {
    final recommendations = <GameRecommendation>[];

    // Collaborative Puzzle Game membantu motor coordination dan collaboration
    if (profile.motorScore < 50) {
      recommendations.add(
        GameRecommendation(
          gameId: '2',
          gameName: 'Collaborative Puzzle Game',
          category: 'motor',
          priority: 1,
          reason: 'Motor behavior score rendah. Puzzle game melatih koordinasi motorik halus.',
          matchScore: _calculateMatchScore(profile.motorScore, targetScore: 70, weight: 1.5),
          skillToImprove: 'Fine Motor Coordination & Collaboration',
        ),
      );
    } else if (profile.motorScore < 70) {
      recommendations.add(
        GameRecommendation(
          gameId: '2',
          gameName: 'Collaborative Puzzle Game',
          category: 'motor',
          priority: 2,
          reason: 'Motor behavior score perlu ditingkatkan untuk koordinasi yang lebih baik.',
          matchScore: _calculateMatchScore(profile.motorScore, targetScore: 70, weight: 1.2),
          skillToImprove: 'Motor Skill Enhancement',
        ),
      );
    }

    return recommendations;
  }

  /// Rekomendasi untuk meningkatkan Speech/Communication
  static List<GameRecommendation> _getSpeechTrainingRecommendations(ScreeningProfile profile) {
    final recommendations = <GameRecommendation>[];

    // Social Interaction Training juga membantu speech
    if (profile.speechScore < 50) {
      recommendations.add(
        GameRecommendation(
          gameId: '1',
          gameName: 'Social Interaction Training',
          category: 'cognitive',
          priority: 2,
          reason: 'Speech score rendah. Game ini melatih komunikasi dan interaksi sosial.',
          matchScore: _calculateMatchScore(profile.speechScore, targetScore: 70, weight: 1.3),
          skillToImprove: 'Communication & Speech',
        ),
      );
    } else if (profile.speechScore < 70) {
      recommendations.add(
        GameRecommendation(
          gameId: '1',
          gameName: 'Social Interaction Training',
          category: 'cognitive',
          priority: 3,
          reason: 'Speech score perlu improvement. Tingkatkan dengan game interaktif.',
          matchScore: _calculateMatchScore(profile.speechScore, targetScore: 70, weight: 1.0),
          skillToImprove: 'Speech Improvement',
        ),
      );
    }

    return recommendations;
  }

  /// Rekomendasi untuk enhancement ketika semua score sudah tinggi
  static List<GameRecommendation> _getEnhancementRecommendations(ScreeningProfile profile) {
    final recommendations = <GameRecommendation>[];

    // Recommend both games untuk maintenance dan enhancement
    recommendations.add(
      GameRecommendation(
        gameId: '1',
        gameName: 'Social Interaction Training',
        category: 'cognitive',
        priority: 3,
        reason: 'Bagus! Pertahankan kemajuan dengan terus berlatih social interaction.',
        matchScore: 85,
        skillToImprove: 'Social Skills Maintenance',
      ),
    );

    recommendations.add(
      GameRecommendation(
        gameId: '2',
        gameName: 'Collaborative Puzzle Game',
        category: 'motor',
        priority: 3,
        reason: 'Skor bagus! Tingkatkan motor skills dengan puzzle yang lebih menantang.',
        matchScore: 85,
        skillToImprove: 'Advanced Motor Coordination',
      ),
    );

    return recommendations;
  }

  /// Calculate match score (0-100)
  /// Semakin rendah user score, semakin tinggi match score
  static int _calculateMatchScore(int userScore, {required int targetScore, required double weight}) {
    final gap = (targetScore - userScore).abs();
    final maxGap = targetScore;
    final baseScore = 100 - ((gap / maxGap) * 100);
    final weightedScore = baseScore * weight;
    return (weightedScore.clamp(0, 100)).round();
  }

  /// Get summary recommendation message untuk home screen
  static String getScreeningSummaryMessage(ScreeningProfile profile) {
    if (!profile.isProfileComplete) {
      return 'Mulai skrining untuk mendapatkan rekomendasi game yang dipersonalisasi';
    }

    final avg = profile.averageScore.round();

    if (avg >= 80) {
      return 'Sempurna! Perkembangan sangat baik. Lanjutkan latihan untuk hasil optimal.';
    } else if (avg >= 60) {
      return 'Perkembangan baik! Fokus pada area yang masih perlu ditingkatkan.';
    } else if (avg >= 40) {
      return 'Perkembangan cukup. Tingkatkan intensitas latihan dan game terapi.';
    } else {
      return 'Disarankan untuk lebih sering berlatih dan mengikuti game interaktif.';
    }
  }

  /// Get risk level berdasarkan profile
  static String getOverallRiskLevel(ScreeningProfile profile) {
    if (!profile.isProfileComplete) return 'Belum Ditest';

    final avg = profile.averageScore.round();
    if (avg >= 70) return 'Risiko Rendah';
    if (avg >= 40) return 'Perlu Pemantauan';
    return 'Perlu Evaluasi';
  }

  /// Get detailed diagnostic message
  static String getDetailedDiagnosticMessage(ScreeningProfile profile) {
    if (!profile.isProfileComplete) {
      return 'Lakukan skrining untuk mendapatkan hasil diagnostic yang akurat.';
    }

    final findings = <String>[];

    if (profile.gazeScore < 40) findings.add('⚠️ Gaze tracking rendah - perlu training joint attention');
    if (profile.motorScore < 40) findings.add('⚠️ Motor behavior rendah - perlu latihan koordinasi');
    if (profile.speechScore < 40) findings.add('⚠️ Speech score rendah - perlu training komunikasi');

    if (findings.isEmpty) {
      return '✅ Perkembangan menunjukkan tren positif berdasarkan data skrining terbaru.';
    }

    return findings.join('\n');
  }
}

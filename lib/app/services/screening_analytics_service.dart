import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Model untuk analytics & trend analysis
class ScreeningTrendAnalysis {
  final List<double> gazeScoreTrend; // Last N scores
  final List<double> motorScoreTrend;
  final List<double> speechScoreTrend;
  final List<double> cognitiveScoreTrend;
  final DateTime lastUpdated;

  // Trend directions
  final String gazeTrendDirection; // 'improving', 'declining', 'stable'
  final String motorTrendDirection;
  final String speechTrendDirection;
  final String cognitiveTrendDirection;

  // Improvement rates (percentage change)
  final double gazeImprovementRate;
  final double motorImprovementRate;
  final double speechImprovementRate;
  final double cognitiveImprovementRate;

  ScreeningTrendAnalysis({
    required this.gazeScoreTrend,
    required this.motorScoreTrend,
    required this.speechScoreTrend,
    required this.cognitiveScoreTrend,
    required this.lastUpdated,
    required this.gazeTrendDirection,
    required this.motorTrendDirection,
    required this.speechTrendDirection,
    required this.cognitiveTrendDirection,
    required this.gazeImprovementRate,
    required this.motorImprovementRate,
    required this.speechImprovementRate,
    required this.cognitiveImprovementRate,
  });

  /// Get overall trend (average of all trends)
  String get overallTrend {
    final directions = [gazeTrendDirection, motorTrendDirection, speechTrendDirection, cognitiveTrendDirection];
    final improvingCount = directions.where((d) => d == 'improving').length;
    final decliningCount = directions.where((d) => d == 'declining').length;

    if (improvingCount > decliningCount) return 'improving';
    if (decliningCount > improvingCount) return 'declining';
    return 'stable';
  }

  /// Get recommendation priorities based on trend
  List<String> getRecommendationPriorities() {
    final priorities = <String>[];

    if (motorTrendDirection == 'declining' || motorScoreTrend.lastOrNull == 0) {
      priorities.add('motor');
    }
    if (gazeTrendDirection == 'declining' || gazeScoreTrend.lastOrNull == 0) {
      priorities.add('gaze');
    }
    if (speechTrendDirection == 'declining' || speechScoreTrend.lastOrNull == 0) {
      priorities.add('speech');
    }
    if (cognitiveTrendDirection == 'declining' || cognitiveScoreTrend.lastOrNull == 0) {
      priorities.add('cognitive');
    }

    return priorities;
  }
}

/// Service untuk advanced analytics dan trend analysis
class ScreeningAnalyticsService {
  static const String TAG = '[ScreeningAnalyticsService]';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Analyze screening trends untuk last N tests
  Future<ScreeningTrendAnalysis> analyzeTrends({int historyCount = 5}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final gazeData = await _getScoreHistory('gaze_results', historyCount);
      final motorData = await _getScoreHistory('motor_results', historyCount);
      final speechData = await _getScoreHistory('speech_results', historyCount);
      final cognitiveData = await _getScoreHistory('game_results', historyCount);

      final analysis = ScreeningTrendAnalysis(
        gazeScoreTrend: gazeData['scores'],
        motorScoreTrend: motorData['scores'],
        speechScoreTrend: speechData['scores'],
        cognitiveScoreTrend: cognitiveData['scores'],
        lastUpdated: DateTime.now(),
        gazeTrendDirection: _calculateTrendDirection(gazeData['scores']),
        motorTrendDirection: _calculateTrendDirection(motorData['scores']),
        speechTrendDirection: _calculateTrendDirection(speechData['scores']),
        cognitiveTrendDirection: _calculateTrendDirection(cognitiveData['scores']),
        gazeImprovementRate: _calculateImprovementRate(gazeData['scores']),
        motorImprovementRate: _calculateImprovementRate(motorData['scores']),
        speechImprovementRate: _calculateImprovementRate(speechData['scores']),
        cognitiveImprovementRate: _calculateImprovementRate(cognitiveData['scores']),
      );

      debugPrint('$TAG Trend analysis completed. Overall trend: ${analysis.overallTrend}');
      return analysis;
    } catch (e) {
      debugPrint('$TAG Error analyzing trends: $e');
      rethrow;
    }
  }

  /// Get score history for specific test type
  Future<Map<String, dynamic>> _getScoreHistory(String collection, int limit) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return {'scores': [], 'dates': []};

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection(collection)
          .orderBy('testDate', descending: true)
          .limit(limit)
          .get();

      final scores = <double>[];
      final dates = <DateTime>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final score = (data['score'] as num?)?.toDouble() ?? 0;
        final date = (data['testDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        scores.add(score);
        dates.add(date);
      }

      // Reverse to get chronological order
      scores.reversed;
      dates.reversed;

      return {'scores': scores, 'dates': dates};
    } catch (e) {
      debugPrint('$TAG Error getting score history: $e');
      return {'scores': [], 'dates': []};
    }
  }

  /// Calculate trend direction based on score history
  String _calculateTrendDirection(List<double> scores) {
    if (scores.length < 2) return 'stable';

    final first = scores.last; // oldest
    final last = scores.first; // newest
    final difference = last - first;

    if (difference > 5) return 'improving';
    if (difference < -5) return 'declining';
    return 'stable';
  }

  /// Calculate improvement rate (percentage change from first to last)
  double _calculateImprovementRate(List<double> scores) {
    if (scores.length < 2 || scores.last == 0) return 0;

    final first = scores.last; // oldest
    final last = scores.first; // newest

    return ((last - first) / first) * 100;
  }

  /// Get recommendation adjustments based on trend
  /// Returns mapping of game category to intensity adjustment
  Future<Map<String, double>> getRecommendationAdjustments() async {
    try {
      final analysis = await analyzeTrends();

      return {
        'gaze': _getAdjustmentFactor(analysis.gazeImprovementRate),
        'motor': _getAdjustmentFactor(analysis.motorImprovementRate),
        'speech': _getAdjustmentFactor(analysis.speechImprovementRate),
        'cognitive': _getAdjustmentFactor(analysis.cognitiveImprovementRate),
      };
    } catch (e) {
      debugPrint('$TAG Error getting adjustments: $e');
      return {'gaze': 1.0, 'motor': 1.0, 'speech': 1.0, 'cognitive': 1.0};
    }
  }

  /// Get adjustment factor (0-2.0) based on improvement rate
  /// Higher factor = more intense recommendations
  double _getAdjustmentFactor(double improvementRate) {
    if (improvementRate < -20) return 2.0; // Declining rapidly - increase intensity
    if (improvementRate < -10) return 1.8;
    if (improvementRate < 0) return 1.5; // Declining slightly
    if (improvementRate < 5) return 1.0; // Stable
    if (improvementRate < 15) return 0.8; // Improving slightly
    return 0.6; // Improving well - reduce intensity
  }

  /// Generate insight message based on trends
  String generateInsightMessage(ScreeningTrendAnalysis analysis) {
    final trend = analysis.overallTrend;

    if (trend == 'improving') {
      final avgRate = (analysis.gazeImprovementRate +
              analysis.motorImprovementRate +
              analysis.speechImprovementRate +
              analysis.cognitiveImprovementRate) /
          4;

      if (avgRate > 20) {
        return '🎉 Prestasi luar biasa! Improvement rate ${avgRate.toStringAsFixed(1)}%. Terus pertahankan momentum ini!';
      } else {
        return '✅ Perkembangan positif terdeteksi. Lanjutkan latihan rutin untuk hasil optimal.';
      }
    } else if (trend == 'declining') {
      return '⚠️ Tren menurun terdeteksi. Tingkatkan intensitas latihan dan game terapi.';
    } else {
      return '△ Perkembangan stabil. Fokus pada area yang masih perlu ditingkatkan.';
    }
  }

  /// Estimate time to reach target score
  Future<Duration?> estimateTimeToTarget({
    required String testType,
    required int targetScore,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final collection = _getCollectionName(testType);
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection(collection)
          .orderBy('testDate', descending: true)
          .limit(4)
          .get();

      if (snapshot.docs.length < 2) return null;

      final scores = <double>[];
      final dates = <DateTime>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        scores.add((data['score'] as num?)?.toDouble() ?? 0);
        dates.add((data['testDate'] as Timestamp?)?.toDate() ?? DateTime.now());
      }

      // Calculate improvement rate (score per day)
      final timeDiff = dates.last.difference(dates.first).inDays;
      if (timeDiff == 0) return null;

      final scoreImprovement = scores.first - scores.last;
      final ratePerDay = scoreImprovement / timeDiff;

      if (ratePerDay <= 0) return null; // Not improving or declining

      final currentScore = scores.first;
      final scoreNeeded = targetScore - currentScore;

      if (scoreNeeded <= 0) return Duration.zero;

      final daysNeeded = (scoreNeeded / ratePerDay).toInt();
      return Duration(days: daysNeeded);
    } catch (e) {
      debugPrint('$TAG Error estimating time to target: $e');
      return null;
    }
  }

  String _getCollectionName(String testType) {
    switch (testType) {
      case 'gaze':
        return 'gaze_results';
      case 'motor':
        return 'motor_results';
      case 'speech':
        return 'speech_results';
      case 'cognitive':
        return 'game_results';
      default:
        return 'gaze_results';
    }
  }
}

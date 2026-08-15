import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk merangkum hasil screening seorang user
class ScreeningResultsSummary {
  final String userId;
  final int gazeScore; // 0-100, dari gaze tracking test
  final int motorScore; // 0-100, dari motor behavior test
  final int speechScore; // 0-100, dari speech analysis test
  final int cognitiveScore; // 0-100, dari game results
  final DateTime? gazeTestDate;
  final DateTime? motorTestDate;
  final DateTime? speechTestDate;
  final DateTime? cognitiveTestDate;
  final DateTime generatedAt;
  final String overallRiskLevel; // 'Risiko Rendah', 'Perlu Pemantauan', 'Perlu Evaluasi'
  final String diagnosticSummary;
  final Map<String, dynamic> additionalMetrics; // Gaze details, motor details, etc

  ScreeningResultsSummary({
    required this.userId,
    required this.gazeScore,
    required this.motorScore,
    required this.speechScore,
    required this.cognitiveScore,
    this.gazeTestDate,
    this.motorTestDate,
    this.speechTestDate,
    this.cognitiveTestDate,
    required this.generatedAt,
    required this.overallRiskLevel,
    required this.diagnosticSummary,
    required this.additionalMetrics,
  });

  /// Calculate average score across all tests
  double get averageScore => (gazeScore + motorScore + speechScore + cognitiveScore) / 4;

  /// Get highest score
  int get highestScore => [gazeScore, motorScore, speechScore, cognitiveScore].reduce((a, b) => a > b ? a : b);

  /// Get lowest score that needs improvement
  int get lowestScore => [gazeScore, motorScore, speechScore, cognitiveScore].reduce((a, b) => a < b ? a : b);

  /// Check if screening is complete
  bool get isComplete => gazeScore > 0 && motorScore > 0 && speechScore > 0;

  /// Get areas needing improvement (score < 60)
  List<String> get areasNeedingImprovement {
    final areas = <String>[];
    if (gazeScore < 60) areas.add('Gaze Tracking');
    if (motorScore < 60) areas.add('Motor Behavior');
    if (speechScore < 60) areas.add('Speech Analysis');
    if (cognitiveScore < 60) areas.add('Cognitive Skills');
    return areas;
  }

  /// Get all scores as map
  Map<String, int> get scoresMap => {
    'gaze': gazeScore,
    'motor': motorScore,
    'speech': speechScore,
    'cognitive': cognitiveScore,
  };

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'gazeScore': gazeScore,
    'motorScore': motorScore,
    'speechScore': speechScore,
    'cognitiveScore': cognitiveScore,
    'averageScore': averageScore,
    'gazeTestDate': gazeTestDate != null ? Timestamp.fromDate(gazeTestDate!) : null,
    'motorTestDate': motorTestDate != null ? Timestamp.fromDate(motorTestDate!) : null,
    'speechTestDate': speechTestDate != null ? Timestamp.fromDate(speechTestDate!) : null,
    'cognitiveTestDate': cognitiveTestDate != null ? Timestamp.fromDate(cognitiveTestDate!) : null,
    'generatedAt': Timestamp.fromDate(generatedAt),
    'overallRiskLevel': overallRiskLevel,
    'diagnosticSummary': diagnosticSummary,
    'additionalMetrics': additionalMetrics,
    'areasNeedingImprovement': areasNeedingImprovement,
  };

  /// Create from JSON
  factory ScreeningResultsSummary.fromJson(Map<String, dynamic> json) {
    return ScreeningResultsSummary(
      userId: json['userId'] as String,
      gazeScore: (json['gazeScore'] as num?)?.toInt() ?? 0,
      motorScore: (json['motorScore'] as num?)?.toInt() ?? 0,
      speechScore: (json['speechScore'] as num?)?.toInt() ?? 0,
      cognitiveScore: (json['cognitiveScore'] as num?)?.toInt() ?? 0,
      gazeTestDate: (json['gazeTestDate'] as Timestamp?)?.toDate(),
      motorTestDate: (json['motorTestDate'] as Timestamp?)?.toDate(),
      speechTestDate: (json['speechTestDate'] as Timestamp?)?.toDate(),
      cognitiveTestDate: (json['cognitiveTestDate'] as Timestamp?)?.toDate(),
      generatedAt: (json['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      overallRiskLevel: json['overallRiskLevel'] as String,
      diagnosticSummary: json['diagnosticSummary'] as String,
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Format score dengan warna status
  static String getScoreStatus(int score) {
    if (score >= 80) return '✅ Excellent';
    if (score >= 60) return '✓ Good';
    if (score >= 40) return '△ Fair';
    return '✗ Needs Improvement';
  }

  /// Get color code untuk score (0 = red, 1 = yellow, 2 = green)
  static int getScoreColorCode(int score) {
    if (score >= 70) return 2; // Green
    if (score >= 40) return 1; // Yellow
    return 0; // Red
  }
}

/// Model untuk tracking progress over time
class ScreeningProgressHistory {
  final List<ScreeningResultsSummary> history; // Sorted by date, newest first
  
  ScreeningProgressHistory({required this.history});

  /// Get latest screening result
  ScreeningResultsSummary? get latest => history.isNotEmpty ? history.first : null;

  /// Get previous screening result
  ScreeningResultsSummary? get previous => history.length > 1 ? history[1] : null;

  /// Calculate progress delta between latest and previous
  Map<String, int> getProgressDelta() {
    if (latest == null || previous == null) return {};

    return {
      'gaze': latest!.gazeScore - previous!.gazeScore,
      'motor': latest!.motorScore - previous!.motorScore,
      'speech': latest!.speechScore - previous!.speechScore,
      'cognitive': latest!.cognitiveScore - previous!.cognitiveScore,
    };
  }

  /// Get trend direction for each metric
  Map<String, String> getTrendDirection() {
    final delta = getProgressDelta();
    return delta.map((key, value) {
      if (value > 5) return MapEntry(key, 'up');
      if (value < -5) return MapEntry(key, 'down');
      return MapEntry(key, 'stable');
    });
  }

  /// Get average score improvement
  int getOverallProgressPercentage() {
    if (latest == null || previous == null) return 0;
    
    final latestAvg = latest!.averageScore;
    final previousAvg = previous!.averageScore;
    final change = latestAvg - previousAvg;
    
    return change.round();
  }
}

class GazeData {
  final DateTime timestamp;
  final GazeDirection direction; // left, center, right
  final double confidence; // 0.0 - 1.0
  final double headPitch; // -90 to 90 (up to down)
  final double headYaw; // -90 to 90 (left to right)
  final double headRoll; // -90 to 90 (tilt)

  GazeData({
    required this.timestamp,
    required this.direction,
    required this.confidence,
    required this.headPitch,
    required this.headYaw,
    required this.headRoll,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'direction': direction.toString(),
      'confidence': confidence,
      'headPitch': headPitch,
      'headYaw': headYaw,
      'headRoll': headRoll,
    };
  }
}

enum GazeDirection { left, center, right, unknown }

class GazeStatistics {
  final DateTime startTime;
  final DateTime endTime;
  final List<GazeData> gazePoints;
  
  // Metrics
  late final double centerFixationDuration; // seconds
  late final double leftFixationDuration; // seconds
  late final double rightFixationDuration; // seconds
  late final int gazeSwitchCount;
  late final double averageConfidence;
  late final int jointAttentionSuccessCount;
  late final double averageLatency; // milliseconds

  GazeStatistics({
    required this.startTime,
    required this.endTime,
    required this.gazePoints,
  }) {
    _calculateMetrics();
  }

  void _calculateMetrics() {
    final totalDuration = endTime.difference(startTime).inMilliseconds / 1000.0;

    // Calculate fixation durations
    centerFixationDuration = _calculateFixationDuration(GazeDirection.center);
    leftFixationDuration = _calculateFixationDuration(GazeDirection.left);
    rightFixationDuration = _calculateFixationDuration(GazeDirection.right);

    // Calculate gaze switches
    gazeSwitchCount = _calculateGazeSwitches();

    // Calculate average confidence
    averageConfidence = gazePoints.isEmpty
        ? 0.0
        : gazePoints.fold(0.0, (sum, gaze) => sum + gaze.confidence) /
            gazePoints.length;

    // Joint attention success (lihat center saat di-prompt)
    jointAttentionSuccessCount = gazePoints
        .where((g) => g.direction == GazeDirection.center && g.confidence > 0.7)
        .length;

    // Average latency (stub - dapat diperbaiki dengan event tracking)
    averageLatency = 0.0;
  }

  double _calculateFixationDuration(GazeDirection direction) {
    var totalDuration = 0.0;
    var currentFixationStart = 0;
    var inFixation = false;

    for (int i = 0; i < gazePoints.length; i++) {
      if (gazePoints[i].direction == direction) {
        if (!inFixation) {
          currentFixationStart = i;
          inFixation = true;
        }
      } else {
        if (inFixation) {
          totalDuration += (i - currentFixationStart).toDouble();
          inFixation = false;
        }
      }
    }

    if (inFixation) {
      totalDuration += (gazePoints.length - currentFixationStart).toDouble();
    }

    return totalDuration; // frames count, convert to seconds if needed
  }

  int _calculateGazeSwitches() {
    if (gazePoints.length < 2) return 0;

    var switches = 0;
    for (int i = 1; i < gazePoints.length; i++) {
      if (gazePoints[i].direction != gazePoints[i - 1].direction &&
          gazePoints[i].direction != GazeDirection.unknown &&
          gazePoints[i - 1].direction != GazeDirection.unknown) {
        switches++;
      }
    }
    return switches;
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'centerFixationDuration': centerFixationDuration,
      'leftFixationDuration': leftFixationDuration,
      'rightFixationDuration': rightFixationDuration,
      'gazeSwitchCount': gazeSwitchCount,
      'averageConfidence': averageConfidence,
      'jointAttentionSuccessCount': jointAttentionSuccessCount,
      'averageLatency': averageLatency,
      'totalDataPoints': gazePoints.length,
    };
  }
}

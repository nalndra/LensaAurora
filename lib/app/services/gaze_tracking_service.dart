import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math';
import 'dart:collection';

/// ASD Metrics Engine - Dart Implementation
/// Converts Python eye tracking logic to Dart for Flutter
class ASDMetricsEngine {
  late Queue<Map<String, double>> gazeHistory;
  late DateTime fixationStart;
  Map<String, double>? lastGazePos;

  // Core Metrics
  List<double> fixationDurations = [];
  List<Map<String, int>> fixationLocations = [];
  List<double> saccadeVelocities = [];
  List<double> saccadeAccuracies = [];
  Map<String, int> aoiCounts = {
    "EYES": 0,
    "MOUTH": 0,
    "SOCIAL": 0,
    "NON_SOCIAL": 0
  };
  late Queue<double> pupilSizes;
  List<bool> gazeFollowingEvents = [];
  List<double> gazeFollowingLatencies = [];

  int totalFrames = 0;
  late DateTime startTime;

  List<Map<String, double>> currentFixationPoints = [];

  // Adaptive Thresholds
  double SACCADE_VEL_THRESHOLD = 12.0; // Pixels per frame
  double FIXATION_MIN_TIME = 0.2; // Seconds (Clinical standard)
  Map<String, double>? STIMULUS_POS;

  ASDMetricsEngine({int bufferSize = 60}) {
    gazeHistory = Queue();
    fixationStart = DateTime.now();
    startTime = DateTime.now();
    pupilSizes = Queue();

    // Set max length
    // Note: Dart Queue doesn't have maxlen like Python's deque
    // We'll manage this manually in the update method
  }

  void update(
    Map<String, double> irisPos,
    FaceGeometry faceGeometry,
    double w,
    double h, {
    Map<String, double>? stimulusPos,
  }) {
    totalFrames++;
    DateTime currTime = DateTime.now();
    STIMULUS_POS = stimulusPos;

    // 1. Saccade & Fixation Logic
    if (lastGazePos != null) {
      double dist = _calculateDistance(irisPos, lastGazePos!);

      if (dist > SACCADE_VEL_THRESHOLD) {
        // Saccade occurring
        saccadeVelocities.add(dist);

        // End of a fixation?
        double fixDur =
            currTime.difference(fixationStart).inMilliseconds / 1000.0;
        if (fixDur > FIXATION_MIN_TIME && currentFixationPoints.isNotEmpty) {
          fixationDurations.add(fixDur);

          // Store mean location of the fixation
          Map<String, double> avgLoc = _calculateMeanLocation(
            currentFixationPoints,
          );
          fixationLocations.add({
            'x': avgLoc['x']!.toInt(),
            'y': avgLoc['y']!.toInt(),
          });

          // Saccade Accuracy
          if (STIMULUS_POS != null) {
            double acc =
                _calculateDistance(avgLoc, STIMULUS_POS!);
            saccadeAccuracies.add(acc);
          }
        }

        fixationStart = currTime;
        currentFixationPoints = [];
      } else {
        // Stable gaze (Fixation in progress)
        currentFixationPoints.add(irisPos);
      }
    }

    // 2. Visual Preference & AOI
    Map<String, double> eyeCenter = faceGeometry.eyeCenter;
    Map<String, double> mouthCenter = faceGeometry.mouthCenter;
    Map<String, double> faceCenter = faceGeometry.faceCenter;
    double faceRadius = faceGeometry.faceRadius;

    double distToEyes =
        _calculateDistance(irisPos, eyeCenter);
    double distToMouth =
        _calculateDistance(irisPos, mouthCenter);
    double distToFace =
        _calculateDistance(irisPos, faceCenter);

    // Calculate Social vs Non-Social Attention
    if (distToFace < faceRadius) {
      aoiCounts["SOCIAL"] = (aoiCounts["SOCIAL"] ?? 0) + 1;
      if (distToEyes < faceRadius * 0.3) {
        aoiCounts["EYES"] = (aoiCounts["EYES"] ?? 0) + 1;
      } else if (distToMouth < faceRadius * 0.3) {
        aoiCounts["MOUTH"] = (aoiCounts["MOUTH"] ?? 0) + 1;
      }
    } else {
      aoiCounts["NON_SOCIAL"] = (aoiCounts["NON_SOCIAL"] ?? 0) + 1;
    }

    // 3. Gaze Following Logic
    if (stimulusPos != null) {
      double distToStim = _calculateDistance(irisPos, stimulusPos);
      bool success = distToStim < (faceRadius * 0.8);
      gazeFollowingEvents.add(success);

      if (success) {
        double latency =
            currTime.difference(fixationStart).inMilliseconds / 1000.0;
        gazeFollowingLatencies.add(latency);
      }
    }

    // 4. Pupil Dilation
    double pupilRatio = faceGeometry.irisDiameter /
        max(faceGeometry.eyeWidth, 1);
    pupilSizes.add(pupilRatio);

    // Maintain max buffer size (60)
    if (pupilSizes.length > 150) {
      pupilSizes.removeFirst();
    }

    lastGazePos = irisPos;
    gazeHistory.add(irisPos);

    if (gazeHistory.length > 60) {
      gazeHistory.removeFirst();
    }
  }

  Map<String, dynamic> getReport() {
    double avgFix =
        fixationDurations.isNotEmpty ? fixationDurations.reduce((a, b) => a + b) / fixationDurations.length : 0;
    double avgSacVel =
        saccadeVelocities.isNotEmpty ? saccadeVelocities.reduce((a, b) => a + b) / saccadeVelocities.length : 0;
    double avgSacAcc =
        saccadeAccuracies.isNotEmpty ? saccadeAccuracies.reduce((a, b) => a + b) / saccadeAccuracies.length : 0;

    int totalAoi = (aoiCounts["SOCIAL"] ?? 0) + (aoiCounts["NON_SOCIAL"] ?? 0);
    double socialPref =
        totalAoi > 0 ? ((aoiCounts["SOCIAL"] ?? 0) / totalAoi) * 100 : 0;

    double gazeFollowRate = gazeFollowingEvents.isNotEmpty
        ? (gazeFollowingEvents.where((e) => e).length /
                gazeFollowingEvents.length) *
            100
        : 0;

    double avgLatency = gazeFollowingLatencies.isNotEmpty
        ? gazeFollowingLatencies.reduce((a, b) => a + b) /
            gazeFollowingLatencies.length
        : 0;

    // Pupil reactivity
    double pupilVar = _calculateStdDev(pupilSizes.toList());

    int eyeAoi = aoiCounts["EYES"] ?? 0;
    int socialAoi = aoiCounts["SOCIAL"] ?? 0;
    int mouthAoi = aoiCounts["MOUTH"] ?? 0;

    return {
      "avg_fixation": avgFix,
      "avg_saccade_vel": avgSacVel,
      "saccade_accuracy": avgSacAcc,
      "social_preference": socialPref,
      "aoi_eyes_pct": socialAoi > 0 ? (eyeAoi / socialAoi) * 100 : 0,
      "aoi_mouth_pct": socialAoi > 0 ? (mouthAoi / socialAoi) * 100 : 0,
      "gaze_following": gazeFollowRate,
      "gaze_latency": avgLatency,
      "pupil_dynamic": pupilVar,
      "total_frames": totalFrames,
    };
  }

  double _calculateDistance(Map<String, double> p1, Map<String, double> p2) {
    double dx = p1['x']! - p2['x']!;
    double dy = p1['y']! - p2['y']!;
    return sqrt(dx * dx + dy * dy);
  }

  Map<String, double> _calculateMeanLocation(
    List<Map<String, double>> points,
  ) {
    if (points.isEmpty) return {'x': 0, 'y': 0};

    double sumX = 0, sumY = 0;
    for (var p in points) {
      sumX += p['x'] ?? 0;
      sumY += p['y'] ?? 0;
    }

    return {
      'x': sumX / points.length,
      'y': sumY / points.length,
    };
  }

  double _calculateStdDev(List<double> values) {
    if (values.length < 2) return 0;

    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance = values
            .map((x) => pow(x - mean, 2))
            .reduce((a, b) => a + b) /
        values.length;
    return sqrt(variance);
  }
}

/// Face Geometry Data Class
class FaceGeometry {
  final Map<String, double> eyeCenter;
  final double eyeWidth;
  final Map<String, double> mouthCenter;
  final Map<String, double> faceCenter;
  final double faceRadius;
  final double irisDiameter;

  FaceGeometry({
    required this.eyeCenter,
    required this.eyeWidth,
    required this.mouthCenter,
    required this.faceCenter,
    required this.faceRadius,
    required this.irisDiameter,
  });
}

/// Extracts face geometry from FaceLandmarks
FaceGeometry extractFaceGeometry(Face face, double w, double h) {
  // Using face bounding box as reference
  Point<int> faceTopLeft =
      Point(face.boundingBox.left.toInt(), face.boundingBox.top.toInt());
  Point<int> faceBottomRight =
      Point(face.boundingBox.right.toInt(), face.boundingBox.bottom.toInt());

  double faceWidth = (faceBottomRight.x - faceTopLeft.x).toDouble();
  double faceHeight = (faceBottomRight.y - faceTopLeft.y).toDouble();

  // Approximate eye center (upper third of face)
  Point<int> eyeCenter = Point(
    (faceTopLeft.x + faceWidth / 2).toInt(),
    (faceTopLeft.y + faceHeight * 0.3).toInt(),
  );

  // Approximate mouth center (lower third)
  Point<int> mouthCenter = Point(
    (faceTopLeft.x + faceWidth / 2).toInt(),
    (faceTopLeft.y + faceHeight * 0.7).toInt(),
  );

  Point<int> faceCenter = Point(
    (faceTopLeft.x + faceWidth / 2).toInt(),
    (faceTopLeft.y + faceHeight / 2).toInt(),
  );

  double faceRadius = max(faceWidth, faceHeight) / 2;

  return FaceGeometry(
    eyeCenter: {'x': eyeCenter.x.toDouble(), 'y': eyeCenter.y.toDouble()},
    eyeWidth: faceWidth * 0.4,
    mouthCenter: {
      'x': mouthCenter.x.toDouble(),
      'y': mouthCenter.y.toDouble()
    },
    faceCenter: {
      'x': faceCenter.x.toDouble(),
      'y': faceCenter.y.toDouble()
    },
    faceRadius: faceRadius,
    irisDiameter: faceWidth * 0.1,
  );
}

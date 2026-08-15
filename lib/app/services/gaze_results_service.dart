import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GazeResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory cache for immediate UI updates
  static final Map<String, int> _cachedScores = {};

  /// Save gaze tracking results to Firestore
  Future<void> saveGazeResult({
    required Map<String, dynamic> gazeMetrics,
    required DateTime testStartTime,
    required DateTime testEndTime,
  }) async {
    try {
      final score = _calculateGazeScore(gazeMetrics);
      _cachedScores['gaze'] = score;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('[GazeResultsService] No user logged in, cached gaze score: $score');
        return;
      }

      // Create document path: /users/{uid}/gaze_results/{docId}
      final userGazeResultsRef =
          _firestore.collection('users').doc(currentUser.uid).collection('gaze_results');

      // Save the result
      await userGazeResultsRef.add({
        'userId': currentUser.uid,
        'testDate': Timestamp.fromDate(testStartTime),
        'testStartTime': Timestamp.fromDate(testStartTime),
        'testEndTime': Timestamp.fromDate(testEndTime),
        'durationSeconds': testEndTime.difference(testStartTime).inSeconds,
        'score': score,
        'metrics': {
          'avgFixation': gazeMetrics['avg_fixation'] ?? 0.0,
          'avgSaccadeVel': gazeMetrics['avg_saccade_vel'] ?? 0.0,
          'saccadeAccuracy': gazeMetrics['saccade_accuracy'] ?? 0.0,
          'socialPreference': gazeMetrics['social_preference'] ?? 0.0,
          'aoiEyesPct': gazeMetrics['aoi_eyes_pct'] ?? 0.0,
          'aoiMouthPct': gazeMetrics['aoi_mouth_pct'] ?? 0.0,
          'gazeFollowing': gazeMetrics['gaze_following'] ?? 0.0,
          'gazeLatency': gazeMetrics['gaze_latency'] ?? 0.0,
          'pupilDynamic': gazeMetrics['pupil_dynamic'] ?? 0.0,
          'totalFrames': gazeMetrics['total_frames'] ?? 0,
        },
        'createdAt': Timestamp.now(),
      });

      // Update user's latest gaze metrics (for easy access on homepage)
      await _firestore.collection('users').doc(currentUser.uid).set({
        'latestGazeScore': score,
        'latestGazeTestDate': Timestamp.fromDate(testStartTime),
        'latestGazeMetrics': {
          'socialPreference': gazeMetrics['social_preference'] ?? 0.0,
          'gazeFollowing': gazeMetrics['gaze_following'] ?? 0.0,
          'avgFixation': gazeMetrics['avg_fixation'] ?? 0.0,
          'directionDistribution': gazeMetrics['direction_distribution'] ?? {},
        },
      }, SetOptions(merge: true));

      debugPrint('[GazeResultsService] Gaze result saved successfully. Score: $score');
    } catch (e) {
      debugPrint('[GazeResultsService] Error saving gaze result: $e');
    }
  }

  /// Get latest gaze score for user
  Future<int?> getLatestGazeScore() async {
    try {
      if (_cachedScores.containsKey('gaze')) {
        return _cachedScores['gaze'];
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final scoreFromDoc = (userDoc.data()?['latestGazeScore'] as num?)?.toInt();
      if (scoreFromDoc != null && scoreFromDoc > 0) {
        _cachedScores['gaze'] = scoreFromDoc;
        return scoreFromDoc;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('gaze_results')
          .orderBy('testDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final score = (snapshot.docs.first.data()['score'] as num?)?.toInt();
        if (score != null && score > 0) {
          _cachedScores['gaze'] = score;
          return score;
        }
      }

      return scoreFromDoc ?? 0;
    } catch (e) {
      debugPrint('[GazeResultsService] Error getting latest gaze score: $e');
      return _cachedScores['gaze'];
    }
  }

  /// Get all gaze results for user (for history/reports)
  Future<List<Map<String, dynamic>>> getAllGazeResults() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('gaze_results')
          .orderBy('testDate', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('[GazeResultsService] Error getting gaze results: $e');
      return [];
    }
  }

  /// Calculate gaze score based on metrics
  int _calculateGazeScore(Map<String, dynamic> metrics) {
    final gazeFollowing = (metrics['gaze_following'] as num?)?.toDouble() ?? 0.0;
    final socialPref = (metrics['social_preference'] as num?)?.toDouble() ?? 0.0;
    final avgFixation = (metrics['avg_fixation'] as num?)?.toDouble() ?? 0.0;

    final fixationScore = (avgFixation / 0.5 * 100).clamp(0.0, 100.0);
    double score = (gazeFollowing * 0.40) + (socialPref * 0.35) + (fixationScore * 0.15) + (50 * 0.10);

    return score.toInt().clamp(0, 100);
  }

  /// Save motor behavior (rhythm test) results
  Future<void> saveMotorResult({
    required int score,
    required Map<String, dynamic> metrics,
    required DateTime testStartTime,
    required DateTime testEndTime,
  }) async {
    try {
      _cachedScores['motor'] = score;

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('motor_results')
          .add({
        'userId': currentUser.uid,
        'testDate': Timestamp.fromDate(testStartTime),
        'testStartTime': Timestamp.fromDate(testStartTime),
        'testEndTime': Timestamp.fromDate(testEndTime),
        'durationSeconds': testEndTime.difference(testStartTime).inSeconds,
        'score': score,
        'metrics': metrics,
        'createdAt': Timestamp.now(),
      });

      await _firestore.collection('users').doc(currentUser.uid).set({
        'latestMotorScore': score,
        'latestMotorTestDate': Timestamp.fromDate(testStartTime),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[GazeResultsService] Error saving motor result: $e');
    }
  }

  /// Get latest motor behavior score for user
  Future<int?> getLatestMotorScore() async {
    try {
      if (_cachedScores.containsKey('motor')) {
        return _cachedScores['motor'];
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final scoreFromDoc = (userDoc.data()?['latestMotorScore'] as num?)?.toInt();
      if (scoreFromDoc != null && scoreFromDoc > 0) {
        _cachedScores['motor'] = scoreFromDoc;
        return scoreFromDoc;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('motor_results')
          .orderBy('testDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final score = (snapshot.docs.first.data()['score'] as num?)?.toInt();
        if (score != null && score > 0) {
          _cachedScores['motor'] = score;
          return score;
        }
      }

      return scoreFromDoc ?? 0;
    } catch (e) {
      debugPrint('[GazeResultsService] Error getting latest motor score: $e');
      return _cachedScores['motor'];
    }
  }

  /// Get recent motor results for user (for history/graph)
  Future<List<Map<String, dynamic>>> getAllMotorResults() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('motor_results')
          .orderBy('testDate', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('[GazeResultsService] Error getting motor results: $e');
      return [];
    }
  }

  /// Save speech analysis (reading) results
  Future<void> saveSpeechResult({
    required int score,
    required Map<String, dynamic> metrics,
    required DateTime testStartTime,
    required DateTime testEndTime,
  }) async {
    try {
      _cachedScores['speech'] = score;

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('speech_results')
          .add({
        'userId': currentUser.uid,
        'testDate': Timestamp.fromDate(testStartTime),
        'testStartTime': Timestamp.fromDate(testStartTime),
        'testEndTime': Timestamp.fromDate(testEndTime),
        'durationSeconds': testEndTime.difference(testStartTime).inSeconds,
        'score': score,
        'metrics': metrics,
        'createdAt': Timestamp.now(),
      });

      await _firestore.collection('users').doc(currentUser.uid).set({
        'latestSpeechScore': score,
        'latestSpeechTestDate': Timestamp.fromDate(testStartTime),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[GazeResultsService] Error saving speech result: $e');
    }
  }

  /// Get latest speech analysis score for user
  Future<int?> getLatestSpeechScore() async {
    try {
      if (_cachedScores.containsKey('speech')) {
        return _cachedScores['speech'];
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final scoreFromDoc = (userDoc.data()?['latestSpeechScore'] as num?)?.toInt();
      if (scoreFromDoc != null && scoreFromDoc > 0) {
        _cachedScores['speech'] = scoreFromDoc;
        return scoreFromDoc;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('speech_results')
          .orderBy('testDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final score = (snapshot.docs.first.data()['score'] as num?)?.toInt();
        if (score != null && score > 0) {
          _cachedScores['speech'] = score;
          return score;
        }
      }

      return scoreFromDoc ?? 0;
    } catch (e) {
      debugPrint('[GazeResultsService] Error getting latest speech score: $e');
      return _cachedScores['speech'];
    }
  }

  /// Get recent speech results for user (for history/graph)
  Future<List<Map<String, dynamic>>> getAllSpeechResults() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('speech_results')
          .orderBy('testDate', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('[GazeResultsService] Error getting speech results: $e');
      return [];
    }
  }

  /// Save cognitive skill results
  Future<void> saveCognitiveResult({
    required DateTime testStartTime,
    required DateTime testEndTime,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cognitive_results')
          .add({
        'userId': currentUser.uid,
        'testDate': Timestamp.fromDate(testStartTime),
        'score': 0,
        'status': 'not_available',
        'createdAt': Timestamp.now(),
      });

      await _firestore.collection('users').doc(currentUser.uid).set({
        'latestCognitiveScore': 0,
        'latestCognitiveTestDate': Timestamp.fromDate(testStartTime),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[GazeResultsService] Error saving cognitive result: $e');
    }
  }
}

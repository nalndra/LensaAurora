import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GazeResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save gaze tracking results to Firestore
  Future<void> saveGazeResult({
    required Map<String, dynamic> gazeMetrics,
    required DateTime testStartTime,
    required DateTime testEndTime,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('[GazeResultsService] No user logged in');
        return;
      }

      // Create document path: /users/{uid}/gaze_results/{docId}
      final userGazeResultsRef =
          _firestore.collection('users').doc(currentUser.uid).collection('gaze_results');

      // Calculate score/percentage (0-100) based on metrics
      final score = _calculateGazeScore(gazeMetrics);

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
      rethrow;
    }
  }

  /// Get latest gaze score for user
  Future<int?> getLatestGazeScore() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      return userDoc.data()?['latestGazeScore']?.toInt() ?? 0;
    } catch (e) {
      debugPrint('[GazeResultsService] Error getting latest gaze score: $e');
      return null;
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
  /// Returns a percentage (0-100)
  int _calculateGazeScore(Map<String, dynamic> metrics) {
    // Weighted calculation based on clinical metrics
    // Gaze Following: 40% weight (most important for attention)
    // Social Preference: 35% weight (social interaction)
    // Fixation Stability: 15% weight (focus)
    // Other: 10% weight

    final gazeFollowing = (metrics['gaze_following'] as num?)?.toDouble() ?? 0.0;
    final socialPref = (metrics['social_preference'] as num?)?.toDouble() ?? 0.0;
    final avgFixation = (metrics['avg_fixation'] as num?)?.toDouble() ?? 0.0;

    // Normalize fixation to 0-100 scale (normal fixation is 0.2-0.5 seconds)
    final fixationScore = (avgFixation / 0.5 * 100).clamp(0.0, 100.0);

    // Calculate weighted score
    double score = (gazeFollowing * 0.40) + (socialPref * 0.35) + (fixationScore * 0.15) + (50 * 0.10);

    return score.toInt().clamp(0, 100);
  }

  /// Save motor behavior results (placeholder - returns 0)
  Future<void> saveMotorResult({
    required DateTime testStartTime,
    required DateTime testEndTime,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // For now, save placeholder data
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('motor_results')
          .add({
        'userId': currentUser.uid,
        'testDate': Timestamp.fromDate(testStartTime),
        'score': 0,
        'status': 'not_available',
        'createdAt': Timestamp.now(),
      });

      // Update user's latest motor score
      await _firestore.collection('users').doc(currentUser.uid).update({
        'latestMotorScore': 0,
        'latestMotorTestDate': Timestamp.fromDate(testStartTime),
      });
    } catch (e) {
      debugPrint('[GazeResultsService] Error saving motor result: $e');
    }
  }

  /// Save cognitive skill results (placeholder - returns 0)
  Future<void> saveCognitiveResult({
    required DateTime testStartTime,
    required DateTime testEndTime,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // For now, save placeholder data
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

      // Update user's latest cognitive score
      await _firestore.collection('users').doc(currentUser.uid).update({
        'latestCognitiveScore': 0,
        'latestCognitiveTestDate': Timestamp.fromDate(testStartTime),
      });
    } catch (e) {
      debugPrint('[GazeResultsService] Error saving cognitive result: $e');
    }
  }
}

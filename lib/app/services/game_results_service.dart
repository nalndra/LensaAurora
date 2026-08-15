import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GameResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static int? _cachedCognitiveScore;

  Future<void> saveGameResult({
    required String gameId,
    required String gameName,
    required int score,
    required int maxScore,
  }) async {
    try {
      final percentage = maxScore > 0 ? ((score / maxScore) * 100).round().clamp(0, 100) : 0;
      _cachedCognitiveScore = percentage;

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('game_results')
          .add({
        'gameId': gameId,
        'gameName': gameName,
        'score': score,
        'maxScore': maxScore,
        'percentage': percentage,
        'playedAt': Timestamp.now(),
      });

      await _firestore.collection('users').doc(currentUser.uid).set({
        'latestCognitiveScore': percentage,
        'latestCognitiveTestDate': Timestamp.now(),
        'latestGameId': gameId,
        'latestGameName': gameName,
      }, SetOptions(merge: true));

      debugPrint('[GameResultsService] Saved $gameName score: $percentage%');
    } catch (e) {
      debugPrint('[GameResultsService] Error saving game result: $e');
    }
  }

  Future<int?> getLatestCognitiveScore() async {
    try {
      if (_cachedCognitiveScore != null) {
        return _cachedCognitiveScore;
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final scoreFromDoc = (userDoc.data()?['latestCognitiveScore'] as num?)?.toInt();
      if (scoreFromDoc != null && scoreFromDoc > 0) {
        _cachedCognitiveScore = scoreFromDoc;
        return scoreFromDoc;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('game_results')
          .orderBy('playedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final pct = (snapshot.docs.first.data()['percentage'] as num?)?.toInt();
        if (pct != null && pct > 0) {
          _cachedCognitiveScore = pct;
          return pct;
        }
      }

      return scoreFromDoc ?? 0;
    } catch (e) {
      debugPrint('[GameResultsService] Error getting cognitive score: $e');
      return _cachedCognitiveScore;
    }
  }

  Future<int?> getWeeklyProgressDelta() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final twoWeeksAgo = now.subtract(const Duration(days: 14));

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('gaze_results')
          .where('testDate', isGreaterThan: Timestamp.fromDate(twoWeeksAgo))
          .orderBy('testDate', descending: true)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final thisWeekScores = <int>[];
      final lastWeekScores = <int>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final testDate = (data['testDate'] as Timestamp?)?.toDate();
        final score = (data['score'] as num?)?.toInt() ?? 0;
        if (testDate == null) continue;

        if (testDate.isAfter(weekAgo)) {
          thisWeekScores.add(score);
        } else {
          lastWeekScores.add(score);
        }
      }

      if (thisWeekScores.isEmpty || lastWeekScores.isEmpty) return null;

      final thisAvg = thisWeekScores.reduce((a, b) => a + b) / thisWeekScores.length;
      final lastAvg = lastWeekScores.reduce((a, b) => a + b) / lastWeekScores.length;

      return (thisAvg - lastAvg).round();
    } catch (e) {
      debugPrint('[GameResultsService] Error calculating weekly delta: $e');
      return null;
    }
  }
}

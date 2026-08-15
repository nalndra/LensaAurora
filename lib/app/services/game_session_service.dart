import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Model untuk tracking game session/recommendation interaction
class GameSession {
  final String id;
  final String gameId;
  final String gameName;
  final String recommendationSource; // 'home', 'dashboard', 'direct'
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? score;
  final int? maxScore;
  final Map<String, dynamic> metrics; // Game-specific metrics

  GameSession({
    required this.id,
    required this.gameId,
    required this.gameName,
    required this.recommendationSource,
    required this.startedAt,
    this.completedAt,
    this.score,
    this.maxScore,
    required this.metrics,
  });

  bool get isCompleted => completedAt != null;

  double? get performance => score != null && maxScore != null ? (score! / maxScore!) * 100 : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameId': gameId,
    'gameName': gameName,
    'recommendationSource': recommendationSource,
    'startedAt': Timestamp.fromDate(startedAt),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'score': score,
    'maxScore': maxScore,
    'metrics': metrics,
  };
}

/// Service untuk track game sessions dan recommendation interactions
class GameSessionService {
  static const String TAG = '[GameSessionService]';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Active session tracking
  final activeSession = Rxn<GameSession>();

  /// Start a new game session
  Future<GameSession> startGameSession({
    required String gameId,
    required String gameName,
    required String recommendationSource,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('$TAG No user logged in');
        throw Exception('User not authenticated');
      }

      final session = GameSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        gameId: gameId,
        gameName: gameName,
        recommendationSource: recommendationSource,
        startedAt: DateTime.now(),
        metrics: {},
      );

      activeSession.value = session;

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('game_sessions')
          .doc(session.id)
          .set({
        ...session.toJson(),
        'userId': currentUser.uid,
      });

      debugPrint('$TAG Game session started: $gameName (${session.id})');
      return session;
    } catch (e) {
      debugPrint('$TAG Error starting game session: $e');
      rethrow;
    }
  }

  /// Complete game session with results
  Future<void> completeGameSession({
    required String sessionId,
    required int score,
    required int maxScore,
    Map<String, dynamic>? additionalMetrics,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final completedAt = DateTime.now();
      final metrics = {
        ...(activeSession.value?.metrics ?? {}),
        ...(additionalMetrics ?? {}),
        'duration': completedAt.difference(activeSession.value?.startedAt ?? DateTime.now()).inSeconds,
      };

      // Update Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('game_sessions')
          .doc(sessionId)
          .update({
        'completedAt': Timestamp.fromDate(completedAt),
        'score': score,
        'maxScore': maxScore,
        'metrics': metrics,
      });

      // Update active session
      if (activeSession.value?.id == sessionId) {
        activeSession.value = GameSession(
          id: activeSession.value!.id,
          gameId: activeSession.value!.gameId,
          gameName: activeSession.value!.gameName,
          recommendationSource: activeSession.value!.recommendationSource,
          startedAt: activeSession.value!.startedAt,
          completedAt: completedAt,
          score: score,
          maxScore: maxScore,
          metrics: metrics,
        );
      }

      debugPrint('$TAG Game session completed: $sessionId');
    } catch (e) {
      debugPrint('$TAG Error completing game session: $e');
    }
  }

  /// Track recommendation interaction (viewed, clicked, played)
  Future<void> trackRecommendationInteraction({
    required String gameId,
    required String gameName,
    required String interactionType, // 'viewed', 'clicked', 'played', 'skipped'
    required String source, // 'home', 'dashboard'
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recommendation_interactions')
          .add({
        'gameId': gameId,
        'gameName': gameName,
        'interactionType': interactionType,
        'source': source,
        'timestamp': Timestamp.now(),
      });

      debugPrint('$TAG Tracked: $interactionType - $gameName');
    } catch (e) {
      debugPrint('$TAG Error tracking interaction: $e');
    }
  }

  /// Get game sessions history
  Future<List<GameSession>> getGameSessionsHistory({int limit = 10}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('game_sessions')
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return GameSession(
              id: data['id'] as String,
              gameId: data['gameId'] as String,
              gameName: data['gameName'] as String,
              recommendationSource: data['recommendationSource'] as String? ?? 'direct',
              startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
              score: (data['score'] as num?)?.toInt(),
              maxScore: (data['maxScore'] as num?)?.toInt(),
              metrics: data['metrics'] as Map<String, dynamic>? ?? {},
            );
          })
          .toList();
    } catch (e) {
      debugPrint('$TAG Error getting sessions history: $e');
      return [];
    }
  }

  /// Get total games played
  Future<int> getTotalGamesPlayed() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('game_sessions')
          .where('completedAt', isNotEqualTo: null)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('$TAG Error getting total games played: $e');
      return 0;
    }
  }

  /// Get average game performance
  Future<double> getAverageGamePerformance() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('game_sessions')
          .where('completedAt', isNotEqualTo: null)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      double totalPercentage = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final score = (data['score'] as num?)?.toDouble() ?? 0;
        final maxScore = (data['maxScore'] as num?)?.toDouble() ?? 100;
        if (maxScore > 0) {
          totalPercentage += (score / maxScore) * 100;
        }
      }

      return totalPercentage / snapshot.docs.length;
    } catch (e) {
      debugPrint('$TAG Error calculating average performance: $e');
      return 0;
    }
  }

  /// Clear active session
  void clearActiveSession() {
    activeSession.value = null;
  }
}

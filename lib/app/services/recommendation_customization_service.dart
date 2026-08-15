import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/services/game_recommendation_service.dart';

/// Model untuk recommendation customization
class RecommendationCustomization {
  final String id;
  final String preferredGameIds; // Comma-separated
  final String excludedGameIds; // Comma-separated
  final int minDifficultyLevel; // 1-5
  final int maxDifficultyLevel;
  final String preferredCategory; // 'all', 'motor', 'cognitive', 'speech'
  final bool autoNotify; // Notify when new recommendations available
  final int reminderIntervalDays; // Days between reminders
  final String intensityPreference; // 'light', 'moderate', 'intense'

  RecommendationCustomization({
    required this.id,
    this.preferredGameIds = '',
    this.excludedGameIds = '',
    this.minDifficultyLevel = 1,
    this.maxDifficultyLevel = 5,
    this.preferredCategory = 'all',
    this.autoNotify = true,
    this.reminderIntervalDays = 7,
    this.intensityPreference = 'moderate',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'preferredGameIds': preferredGameIds,
    'excludedGameIds': excludedGameIds,
    'minDifficultyLevel': minDifficultyLevel,
    'maxDifficultyLevel': maxDifficultyLevel,
    'preferredCategory': preferredCategory,
    'autoNotify': autoNotify,
    'reminderIntervalDays': reminderIntervalDays,
    'intensityPreference': intensityPreference,
  };

  factory RecommendationCustomization.fromJson(Map<String, dynamic> json) {
    return RecommendationCustomization(
      id: json['id'] as String,
      preferredGameIds: json['preferredGameIds'] as String? ?? '',
      excludedGameIds: json['excludedGameIds'] as String? ?? '',
      minDifficultyLevel: json['minDifficultyLevel'] as int? ?? 1,
      maxDifficultyLevel: json['maxDifficultyLevel'] as int? ?? 5,
      preferredCategory: json['preferredCategory'] as String? ?? 'all',
      autoNotify: json['autoNotify'] as bool? ?? true,
      reminderIntervalDays: json['reminderIntervalDays'] as int? ?? 7,
      intensityPreference: json['intensityPreference'] as String? ?? 'moderate',
    );
  }

  bool isGamePreferred(String gameId) => preferredGameIds.contains(gameId);
  bool isGameExcluded(String gameId) => excludedGameIds.contains(gameId);
}

/// Model untuk recommendation note
class RecommendationNote {
  final String id;
  final String recommendationId;
  final String gameId;
  final String authorType; // 'therapist', 'parent', 'user'
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // 'active', 'archived'

  RecommendationNote({
    required this.id,
    required this.recommendationId,
    required this.gameId,
    required this.authorType,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'recommendationId': recommendationId,
    'gameId': gameId,
    'authorType': authorType,
    'content': content,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'status': status,
  };

  factory RecommendationNote.fromJson(Map<String, dynamic> json) {
    return RecommendationNote(
      id: json['id'] as String,
      recommendationId: json['recommendationId'] as String,
      gameId: json['gameId'] as String,
      authorType: json['authorType'] as String,
      content: json['content'] as String,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      status: json['status'] as String? ?? 'active',
    );
  }
}

/// Service untuk manage recommendation customization dan notes
class RecommendationCustomizationService {
  static const String TAG = '[RecommendationCustomizationService]';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final customization = Rxn<RecommendationCustomization>();
  final recommendationNotes = <RecommendationNote>[].obs;

  /// Load customization settings
  Future<RecommendationCustomization> loadCustomization() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('settings')
          .doc('recommendation_customization')
          .get();

      if (!doc.exists) {
        // Create default customization
        final defaults = RecommendationCustomization(
          id: 'default_${currentUser.uid}',
        );
        await saveCustomization(defaults);
        customization.value = defaults;
        return defaults;
      }

      final custom = RecommendationCustomization.fromJson(doc.data()!);
      customization.value = custom;
      return custom;
    } catch (e) {
      debugPrint('$TAG Error loading customization: $e');
      rethrow;
    }
  }

  /// Save customization settings
  Future<void> saveCustomization(RecommendationCustomization custom) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('settings')
          .doc('recommendation_customization')
          .set(custom.toJson(), SetOptions(merge: true));

      customization.value = custom;
      debugPrint('$TAG Customization saved');
    } catch (e) {
      debugPrint('$TAG Error saving customization: $e');
    }
  }

  /// Update intensity preference
  Future<void> updateIntensityPreference(String intensity) async {
    try {
      final current = customization.value;
      if (current == null) return;

      final updated = RecommendationCustomization(
        id: current.id,
        preferredGameIds: current.preferredGameIds,
        excludedGameIds: current.excludedGameIds,
        minDifficultyLevel: current.minDifficultyLevel,
        maxDifficultyLevel: current.maxDifficultyLevel,
        preferredCategory: current.preferredCategory,
        autoNotify: current.autoNotify,
        reminderIntervalDays: current.reminderIntervalDays,
        intensityPreference: intensity,
      );

      await saveCustomization(updated);
    } catch (e) {
      debugPrint('$TAG Error updating intensity: $e');
    }
  }

  /// Add game to preferred list
  Future<void> addPreferredGame(String gameId) async {
    try {
      final current = customization.value;
      if (current == null) return;

      var preferred = current.preferredGameIds;
      if (!preferred.contains(gameId)) {
        preferred = preferred.isEmpty ? gameId : '$preferred,$gameId';
      }

      final updated = RecommendationCustomization(
        id: current.id,
        preferredGameIds: preferred,
        excludedGameIds: current.excludedGameIds,
        minDifficultyLevel: current.minDifficultyLevel,
        maxDifficultyLevel: current.maxDifficultyLevel,
        preferredCategory: current.preferredCategory,
        autoNotify: current.autoNotify,
        reminderIntervalDays: current.reminderIntervalDays,
        intensityPreference: current.intensityPreference,
      );

      await saveCustomization(updated);
    } catch (e) {
      debugPrint('$TAG Error adding preferred game: $e');
    }
  }

  /// Add game to excluded list
  Future<void> addExcludedGame(String gameId) async {
    try {
      final current = customization.value;
      if (current == null) return;

      var excluded = current.excludedGameIds;
      if (!excluded.contains(gameId)) {
        excluded = excluded.isEmpty ? gameId : '$excluded,$gameId';
      }

      final updated = RecommendationCustomization(
        id: current.id,
        preferredGameIds: current.preferredGameIds,
        excludedGameIds: excluded,
        minDifficultyLevel: current.minDifficultyLevel,
        maxDifficultyLevel: current.maxDifficultyLevel,
        preferredCategory: current.preferredCategory,
        autoNotify: current.autoNotify,
        reminderIntervalDays: current.reminderIntervalDays,
        intensityPreference: current.intensityPreference,
      );

      await saveCustomization(updated);
    } catch (e) {
      debugPrint('$TAG Error adding excluded game: $e');
    }
  }

  /// Add note to recommendation
  Future<void> addRecommendationNote({
    required String gameId,
    required String content,
    required String authorType,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final note = RecommendationNote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recommendationId: 'rec_$gameId',
        gameId: gameId,
        authorType: authorType,
        content: content,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recommendation_notes')
          .doc(note.id)
          .set(note.toJson());

      recommendationNotes.add(note);
      debugPrint('$TAG Note added for game: $gameId');
    } catch (e) {
      debugPrint('$TAG Error adding note: $e');
    }
  }

  /// Load notes for specific game
  Future<List<RecommendationNote>> loadNotesForGame(String gameId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recommendation_notes')
          .where('gameId', isEqualTo: gameId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RecommendationNote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('$TAG Error loading notes: $e');
      return [];
    }
  }

  /// Update note
  Future<void> updateNote(String noteId, String newContent) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recommendation_notes')
          .doc(noteId)
          .update({
        'content': newContent,
        'updatedAt': Timestamp.now(),
      });

      debugPrint('$TAG Note updated: $noteId');
    } catch (e) {
      debugPrint('$TAG Error updating note: $e');
    }
  }

  /// Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recommendation_notes')
          .doc(noteId)
          .update({'status': 'archived'});

      recommendationNotes.removeWhere((n) => n.id == noteId);
      debugPrint('$TAG Note archived: $noteId');
    } catch (e) {
      debugPrint('$TAG Error deleting note: $e');
    }
  }

  /// Apply customization to recommendations
  List<GameRecommendation> applyCustomization(
    List<GameRecommendation> recommendations,
  ) {
    final custom = customization.value;
    if (custom == null) return recommendations;

    return recommendations
        .where((rec) =>
            !custom.isGameExcluded(rec.gameId) &&
            (custom.preferredCategory == 'all' || rec.category == custom.preferredCategory))
        .toList();
  }
}

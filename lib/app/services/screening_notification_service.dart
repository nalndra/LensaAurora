import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Model untuk notification
class ScreeningNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'recommendation', 'reminder', 'achievement', 'alert'
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? actionData; // Data untuk action

  ScreeningNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'createdAt': Timestamp.fromDate(createdAt),
    'isRead': isRead,
    'actionData': actionData,
  };

  factory ScreeningNotification.fromJson(Map<String, dynamic> json) {
    return ScreeningNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      actionData: json['actionData'] as Map<String, dynamic>?,
    );
  }
}

/// Service untuk notification management
class ScreeningNotificationService {
  static const String TAG = '[ScreeningNotificationService]';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable untuk real-time notifications
  final notifications = <ScreeningNotification>[].obs;
  final unreadCount = 0.obs;

  /// Initialize notification listener
  void initializeNotificationListener() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        final notifs = snapshot.docs
            .map((doc) => ScreeningNotification.fromJson(doc.data()))
            .toList();

        notifications.assignAll(notifs);
        _updateUnreadCount();

        debugPrint('$TAG Loaded ${notifs.length} notifications');
      });
    } catch (e) {
      debugPrint('$TAG Error initializing listener: $e');
    }
  }

  /// Send recommendation notification
  Future<void> sendRecommendationNotification({
    required String gameId,
    required String gameName,
    required String reason,
    required int matchScore,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final notification = ScreeningNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Game Baru Direkomendasikan 🎮',
        message: '$gameName - $reason',
        type: 'recommendation',
        createdAt: DateTime.now(),
        actionData: {
          'gameId': gameId,
          'gameName': gameName,
          'matchScore': matchScore,
        },
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());

      debugPrint('$TAG Recommendation notification sent for $gameName');
    } catch (e) {
      debugPrint('$TAG Error sending recommendation notification: $e');
    }
  }

  /// Send screening reminder notification
  Future<void> sendScreeningReminder({
    required String testType, // 'gaze', 'motor', 'speech', 'cognitive'
    required DateTime lastTestDate,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final daysSinceTest = DateTime.now().difference(lastTestDate).inDays;
      final testTypeLabel = _getTestTypeLabel(testType);

      final notification = ScreeningNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Reminder: $testTypeLabel Screening ⏰',
        message: 'Sudah $daysSinceTest hari sejak test terakhir. Lakukan screening baru untuk hasil terbaru!',
        type: 'reminder',
        createdAt: DateTime.now(),
        actionData: {
          'testType': testType,
          'daysSinceTest': daysSinceTest,
        },
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());

      debugPrint('$TAG Reminder notification sent for $testType');
    } catch (e) {
      debugPrint('$TAG Error sending reminder: $e');
    }
  }

  /// Send achievement notification
  Future<void> sendAchievementNotification({
    required String achievement, // 'score_milestone', 'streak', 'first_game'
    required String description,
    required Map<String, dynamic>? data,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final notification = ScreeningNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Pencapaian! 🏆',
        message: description,
        type: 'achievement',
        createdAt: DateTime.now(),
        actionData: {
          'achievement': achievement,
          ...?(data ?? {}),
        },
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());

      debugPrint('$TAG Achievement notification sent: $achievement');
    } catch (e) {
      debugPrint('$TAG Error sending achievement notification: $e');
    }
  }

  /// Send alert notification
  Future<void> sendAlertNotification({
    required String title,
    required String message,
    required String severity, // 'info', 'warning', 'critical'
    Map<String, dynamic>? actionData,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final notification = ScreeningNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: 'alert',
        createdAt: DateTime.now(),
        actionData: {
          'severity': severity,
          ...?(actionData ?? {}),
        },
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());

      debugPrint('$TAG Alert notification sent: $severity');
    } catch (e) {
      debugPrint('$TAG Error sending alert: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        final notif = notifications[index];
        notifications[index] = ScreeningNotification(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          type: notif.type,
          createdAt: notif.createdAt,
          isRead: true,
          actionData: notif.actionData,
        );
      }

      _updateUnreadCount();
    } catch (e) {
      debugPrint('$TAG Error marking as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      for (final notif in notifications) {
        if (!notif.isRead) {
          await markAsRead(notif.id);
        }
      }
    } catch (e) {
      debugPrint('$TAG Error marking all as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      debugPrint('$TAG Error deleting notification: $e');
    }
  }

  /// Check and send screening reminders (should be called periodically)
  Future<void> checkAndSendReminders() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userData = await _firestore.collection('users').doc(currentUser.uid).get();
      final data = userData.data() ?? {};

      // Check if 7 days passed since last gaze test
      final lastGazeDate = (data['latestGazeTestDate'] as Timestamp?)?.toDate();
      if (lastGazeDate != null && DateTime.now().difference(lastGazeDate).inDays >= 7) {
        await sendScreeningReminder(testType: 'gaze', lastTestDate: lastGazeDate);
      }

      // Check if 7 days passed since last motor test
      final lastMotorDate = (data['latestMotorTestDate'] as Timestamp?)?.toDate();
      if (lastMotorDate != null && DateTime.now().difference(lastMotorDate).inDays >= 7) {
        await sendScreeningReminder(testType: 'motor', lastTestDate: lastMotorDate);
      }

      debugPrint('$TAG Reminder check completed');
    } catch (e) {
      debugPrint('$TAG Error checking reminders: $e');
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  String _getTestTypeLabel(String testType) {
    switch (testType) {
      case 'gaze':
        return 'Gaze Tracking';
      case 'motor':
        return 'Motor Behavior';
      case 'speech':
        return 'Speech Analysis';
      case 'cognitive':
        return 'Cognitive Skills';
      default:
        return 'Screening';
    }
  }
}

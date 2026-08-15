import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/services/screening_notification_service.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

/// Notification center view
class NotificationCenterView extends GetView<HomeController> {
  const NotificationCenterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.notificationService.unreadCount.value > 0) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    controller.notificationService.markAllAsRead();
                  },
                  child: const Text('Tandai Semua'),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final notifications = controller.notificationService.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak Ada Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return NotificationTile(
              notification: notif,
              onTap: () {
                if (!notif.isRead) {
                  controller.notificationService.markAsRead(notif.id);
                }
                _handleNotificationTap(notif);
              },
              onDismiss: () {
                controller.notificationService.deleteNotification(notif.id);
              },
            );
          },
        );
      }),
    );
  }

  void _handleNotificationTap(ScreeningNotification notif) {
    switch (notif.type) {
      case 'recommendation':
        final gameId = notif.actionData?['gameId'] as String?;
        if (gameId != null) {
          controller.playRecommendedGame(
            gameId,
            notif.actionData?['gameName'] ?? 'Game',
          );
        }
        break;
      case 'reminder':
        controller.goToScreeningDashboard();
        break;
      case 'achievement':
        // Show achievement detail
        Get.snackbar('Achievement', notif.message);
        break;
      default:
        break;
    }
  }
}

/// Individual notification tile
class NotificationTile extends StatelessWidget {
  final ScreeningNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: Colors.red.withOpacity(0.1),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: Material(
        color: notification.isRead ? Colors.transparent : AppTheme.primaryColor.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: notification.isRead ? Colors.grey : AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textGrey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _getNotificationIcon(notification.type),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'recommendation':
        icon = Icons.games;
        color = Colors.blue;
        break;
      case 'reminder':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 'alert':
        icon = Icons.warning_amber;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = AppTheme.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(left: 12),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d yang lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

// Import HomeController at top of file
import 'package:lensaaurora/app/modules/home/controllers/home_controller.dart';

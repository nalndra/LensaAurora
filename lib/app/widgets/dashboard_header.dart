import 'package:flutter/material.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.userRole,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hai, $userName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userRole,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          // Notification Icon
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications_outlined),
            iconSize: 24,
            color: AppTheme.textDark,
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

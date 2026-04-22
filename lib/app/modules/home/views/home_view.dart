import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import 'package:lensaaurora/app/controllers/auth_controller.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import 'package:lensaaurora/app/widgets/dashboard_header.dart';
import 'package:lensaaurora/app/widgets/progress_detail_card.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();
    final authController = Get.find<AuthController>();
    navController.changeIndex(0);
    
    final userName = authController.currentUser.value?.displayName ?? 'User';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                DashboardHeader(
                  userName: userName,
                  userRole: 'Orang Tua',
                  onNotificationTap: () {
                    // Handle notification tap
                  },
                ),
                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Status Card (Banner Utama)
                      _buildStatusCard(context),
                      const SizedBox(height: 24),
                      // Progress Label
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Progress Card (Weekly)
                      _buildProgressCard(),
                      const SizedBox(height: 20),
                      // CTA Card (Test Baru)
                      _buildCtaCard(),
                      const SizedBox(height: 24),
                      // Detail Perkembangan Header
                      const Text(
                        'Detail Perkembangan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress Detail Cards
                      ProgressDetailCard(
                        title: 'Gaze & Attention',
                        percentage: 62,
                        statusLabel: 'OPTIMAL',
                        statusColor: AppTheme.verdeTosca,
                        icon: Icons.visibility,
                        iconBgColor: AppTheme.purple,
                      ),
                      const SizedBox(height: 12),
                      ProgressDetailCard(
                        title: 'Motor Behavior',
                        percentage: 78,
                        statusLabel: 'SANGAT BAIK',
                        statusColor: AppTheme.successGreen,
                        icon: Icons.directions_run,
                        iconBgColor: AppTheme.purple,
                      ),
                      const SizedBox(height: 12),
                      ProgressDetailCard(
                        title: 'Cognitive Skill',
                        percentage: 85,
                        statusLabel: 'SEMPURNA',
                        statusColor: AppTheme.verdeTosca,
                        icon: Icons.psychology,
                        iconBgColor: AppTheme.purple,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const ChatFAB(),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    // Calculate dimensions based on screen size
    // Base dimensions: 382x273, scale to screen
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 20.0;
    final availableWidth = screenWidth - (horizontalPadding * 2);
    
    // Maintain aspect ratio 382:273 ≈ 1.4
    final cardHeight = availableWidth / 1.4;
    
    // Scale font sizes based on card height
    final titleFontSize = (cardHeight * 0.35).clamp(28.0, 48.0);
    final chipFontSize = (cardHeight * 0.08).clamp(10.0, 14.0);
    final descFontSize = (cardHeight * 0.12).clamp(12.0, 16.0);
    
    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.statusCardGradient,
        borderRadius: AppTheme.br16,
        boxShadow: AppTheme.shadowLg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'STATUS DETEKSI TERKINI',
              style: TextStyle(
                fontSize: chipFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Risk Status Title (Two lines)
          Text(
            'Risiko\nRendah',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'Perkembangan anak menunjukkan tren positif dan konsisten meningkat dibandingkan periode sebelumnya.',
            style: TextStyle(
              fontSize: descFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGreenPale,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Trend Icon and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Trend Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.verdeTosca.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF005D4B),
                  size: 22,
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF005D4B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SANGAT BAIK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Label
          const Text(
            'Progres Mingguan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          // Percentage and Comparison
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '+12%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'vs minggu lalu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCtaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.purple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppTheme.purple,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          // Text
          const Text(
            'Siap Tes Baru?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lakukan screening rutin untuk hasil akurat',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Button - matches login/register button style
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.purple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // Handle scan button press
            },
            child: const Text(
              'Mulai Scan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

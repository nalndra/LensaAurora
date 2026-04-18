import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';
import '../controllers/scan_controller.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => controller.scannedImage.value != null
            ? _buildScannedImageView()
            : _buildScannerView(),
      ),
      floatingActionButton: const ChatFAB(),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildScannerView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section - Mulai Skrining
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mulai Skrining',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: const Text(
                    'Sesi ini akan berlangsung selama kurang lebih 15 menit. Kami akan melakukan pemindaian awal terhadap indikator perkembangan saraf melalui teknologi AI yang aman dan non-invasif.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Area Analisis Utama Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AREA ANALISIS UTAMA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.remove_red_eye,
                  title: 'Gaze Tracking',
                  subtitle: 'Pola atensi visual',
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.audio_file,
                  title: 'Speech Analysis',
                  subtitle: 'Linguistik & intonasi',
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.accessibility,
                  title: 'Motor Behavior',
                  subtitle: 'Gerak motorik halus',
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 16),
                _buildAIFusionCard(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Preparation Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Persiapan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '3 Langkah Sederhana',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPreparationStep(
                  number: '1',
                  title: 'Cahaya Ruangan',
                  description: 'Pastikan ruangan cukup terang dan hindari silau langsung',
                ),
                const SizedBox(height: 12),
                _buildPreparationStep(
                  number: '2',
                  title: 'Lingkungan Tenang',
                  description: 'Kurangi kebisingan untuk hasil analisis yang lebih akurat',
                ),
                const SizedBox(height: 12),
                _buildPreparationStep(
                  number: '3',
                  title: 'Posisi Perangkat',
                  description: 'Letakkan perangkat pada jarak 30-40cm dari wajah Anda',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Start Screening Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(Routes.GAZE_TRACKING),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Mulai Skrining',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIFusionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Fusion Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Integrasi data cerdas',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showScreeningOptions() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Skrining',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.camera_alt,
              label: 'Gunakan Kamera',
              description: 'Ambil video langsung untuk analisis',
              onTap: () {
                Get.back();
                controller.captureFromCamera();
              },
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.image,
              label: 'Pilih dari Galeri',
              description: 'Gunakan video atau foto yang sudah ada',
              onTap: () {
                Get.back();
                controller.pickFromGallery();
              },
              color: AppTheme.sageGreen,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.br12,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.br12,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [AppTheme.cardShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanHistoryList() {
    return Column(
      children: List.generate(
        controller.scanHistory.length,
        (index) {
          final scan = controller.scanHistory[index];
          final formattedDate = _formatDate(scan['date']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.br12,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
                boxShadow: [AppTheme.cardShadow],
              ),
              child: Row(
                children: [
                  Text(
                    scan['icon'],
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScannedImageView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.file(
                controller.scannedImage.value!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.clearScannedImage(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.clearScannedImage();
                    controller.captureFromCamera();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return date.toString().split(' ')[0];
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/account_type_controller.dart';

class AccountTypeView extends GetView<AccountTypeController> {
  const AccountTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decoration - curved shape in bottom left
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9C88D8).withOpacity(0.25),
                    const Color(0xFFE8C1E0).withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Header title
                    Text(
                      'Pilih Peran Anda',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.black87,
                      ) ?? const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      'Pilihan ini akan memengaruhi pengalaman dan fitur yang Anda akses. '
                      'Mode Orang Tua membantu Anda mendampingi perkembangan anak, '
                      'sedangkan Mode Personal dirancang untuk individu berusia 16 tahun ke atas.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.6,
                        fontSize: 14,
                      ) ?? const TextStyle(
                        color: Colors.grey,
                        height: 1.6,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Role cards container
                    Obx(
                      () => Column(
                        children: [
                          // Parent role card
                          _buildRoleCard(
                            context,
                            role: AccountRole.parent,
                            isSelected: controller.selectedRole.value == AccountRole.parent,
                            title: 'Orang Tua',
                            description:
                                'Kelola profil anak Anda dan pantau perkembangan mereka',
                            onTap: () => controller.selectRole(AccountRole.parent),
                          ),
                          const SizedBox(height: 16),
                          // Personal role card
                          _buildRoleCard(
                            context,
                            role: AccountRole.personal,
                            isSelected: controller.selectedRole.value == AccountRole.personal,
                            title: 'Personal (16+ tahun)',
                            description: 'Akses khusus untuk pengguna dewasa dan individu penyandang ASD',
                            onTap: () => controller.selectRole(AccountRole.personal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Continue button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.continueToNextStep(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C4DFF),
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Lanjutkan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual role card widget
  Widget _buildRoleCard(
    BuildContext context, {
    required AccountRole role,
    required bool isSelected,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isPrimaryCard = role == AccountRole.parent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C4DFF)
                : Colors.grey[300] ?? Colors.grey,
            width: isSelected ? 2 : 1.5,
          ),
          gradient: isSelected && isPrimaryCard
              ? LinearGradient(
                colors: [
                  const Color(0xFF9C88D8).withOpacity(0.15),
                  const Color(0xFFE8C1E0).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
              : LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey[50] ?? Colors.white,
                ],
              ),
          boxShadow: isSelected
              ? [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
              : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ) ?? const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7C4DFF)
                          : Colors.grey[400] ?? Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF7C4DFF) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.5,
              ) ?? const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

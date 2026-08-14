import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import '../controllers/account_type_controller.dart';

class AccountTypeView extends GetView<AccountTypeController> {
  const AccountTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
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
                    AppTheme.primaryBlue.withValues(alpha: 0.25),
                    AppTheme.accentGreen.withValues(alpha: 0.15),
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
                        color: AppTheme.textDark,
                      ) ?? const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
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
                        color: AppTheme.textLight,
                        height: 1.6,
                        fontSize: 14,
                      ) ?? const TextStyle(
                        color: AppTheme.textLight,
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
                      () => AuroraPrimaryButton(
                        label: 'Lanjutkan',
                        isLoading: controller.isLoading.value,
                        onPressed: () => controller.continueToNextStep(),
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
          borderRadius: AppTheme.br24,
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGreen
                : AppTheme.textLight.withOpacity(0.2),
            width: isSelected ? 2 : 1.5,
          ),
          gradient: isSelected && isPrimaryCard
              ? LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.15),
                  AppTheme.lightCyan.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
              : LinearGradient(
                colors: [
                  Colors.white,
                  AppTheme.bgLight,
                ],
              ),
          boxShadow: isSelected
              ? AppTheme.shadowButton(AppTheme.accentGreen)
              : AppTheme.shadowCard,
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
                      color: AppTheme.textDark,
                    ) ?? const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
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
                          ? AppTheme.accentGreen
                          : AppTheme.textLight.withOpacity(0.5),
                      width: 2,
                    ),
                    color: isSelected ? AppTheme.accentGreen : Colors.transparent,
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
                color: AppTheme.textLight,
                fontSize: 13,
                height: 1.5,
              ) ?? const TextStyle(
                color: AppTheme.textLight,
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

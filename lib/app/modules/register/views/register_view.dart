import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import '../../../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isLarge = width > 600;
          final horizontalPadding = isLarge ? width * 0.18 : 24.0;

          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.accentGreenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(top: isLarge ? 28 : 20),
                  child: Column(
                    children: [
                      Text(
                        'Buat Akun Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLarge ? 22 : 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                  horizontalPadding, 32, horizontalPadding, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.space8),
                                  Text(
                                    'Mulai pengalaman digital eksklusif bersama LensaAurora hari ini',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textLight,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.space32),
                                  Form(
                                    key: controller.registerFormKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller:
                                              controller.registerNameController,
                                          keyboardType: TextInputType.name,
                                          validator: controller.validateName,
                                          decoration: const InputDecoration(
                                            labelText: 'Nama Anda',
                                            hintText: 'Nama Anda',
                                            prefixIcon: Icon(
                                                Icons.person_outline_rounded),
                                          ),
                                        ),
                                        const SizedBox(height: AppTheme.space16),
                                        TextFormField(
                                          controller:
                                              controller.registerEmailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: controller.validateEmail,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            hintText: 'contoh@email.com',
                                            prefixIcon: Icon(
                                                Icons.mail_outline_rounded),
                                          ),
                                        ),
                                        const SizedBox(height: AppTheme.space16),
                                        Obx(() => TextFormField(
                                              controller: controller
                                                  .registerPasswordController,
                                              obscureText: !controller
                                                  .isPasswordVisible.value,
                                              validator:
                                                  controller.validatePassword,
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                hintText:
                                                    'Masukkan password anda',
                                                prefixIcon: const Icon(
                                                    Icons.lock_outline_rounded),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    controller.isPasswordVisible
                                                            .value
                                                        ? Icons
                                                            .visibility_rounded
                                                        : Icons
                                                            .visibility_off_rounded,
                                                  ),
                                                  onPressed: controller
                                                      .togglePasswordVisibility,
                                                ),
                                              ),
                                            )),
                                        const SizedBox(height: AppTheme.space16),
                                        Obx(() => TextFormField(
                                              controller: controller
                                                  .registerConfirmPasswordController,
                                              obscureText: !controller
                                                  .isConfirmPasswordVisible
                                                  .value,
                                              validator: controller
                                                  .validatePasswordMatch,
                                              decoration: InputDecoration(
                                                labelText: 'Konfirmasi Password',
                                                hintText:
                                                    'Konfirmasi password anda',
                                                prefixIcon: const Icon(
                                                    Icons.lock_outline_rounded),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    controller
                                                            .isConfirmPasswordVisible
                                                            .value
                                                        ? Icons
                                                            .visibility_rounded
                                                        : Icons
                                                            .visibility_off_rounded,
                                                  ),
                                                  onPressed: controller
                                                      .toggleConfirmPasswordVisibility,
                                                ),
                                              ),
                                            )),
                                        const SizedBox(height: AppTheme.space16),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Obx(() => Checkbox(
                                                  value: controller
                                                      .agreedToTerms.value,
                                                  onChanged: (value) {
                                                    controller.agreedToTerms
                                                        .value = value ?? false;
                                                  },
                                                  activeColor:
                                                      AppTheme.accentGreen,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                )),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    text:
                                                        'Saya menyetujui semua ',
                                                    style: TextStyle(
                                                        color:
                                                            AppTheme.textLight,
                                                        fontSize: 14),
                                                    children: [
                                                      TextSpan(
                                                        text: 'syarat',
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .accentGreenDark,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {},
                                                      ),
                                                      const TextSpan(text: ' & '),
                                                      TextSpan(
                                                        text: 'ketentuan',
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .accentGreenDark,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {},
                                                      ),
                                                      const TextSpan(text: '.'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.space24),
                                        Obx(() => AuroraPrimaryButton(
                                              label: 'Daftar',
                                              isLoading:
                                                  controller.isLoading.value,
                                              onPressed: () async {
                                                if (!controller
                                                    .agreedToTerms.value) {
                                                  Get.snackbar(
                                                    'Perhatian',
                                                    'Anda harus menyetujui syarat & ketentuan',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    colorText: Colors.white,
                                                  );
                                                  return;
                                                }
                                                final success =
                                                    await controller.register();
                                                if (success) {
                                                  Get.offAllNamed(
                                                      '/account-type');
                                                }
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.space32),
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          'Atau masuk dengan',
                                          style: TextStyle(
                                              color: AppTheme.textLight),
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.space24),
                                  Obx(
                                    () => Center(
                                      child: AuroraSocialButton(
                                        onTap: controller.isLoading.value
                                            ? null
                                            : () async {
                                                final success = await controller
                                                    .signInWithGoogle();
                                                if (success) {
                                                  Get.offAllNamed(
                                                      '/account-type');
                                                }
                                              },
                                        child: Image.asset(
                                          'assets/logo/GoogleIcon.png',
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.space32),
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Sudah punya akun? ',
                                        style: TextStyle(
                                            color: AppTheme.textLight,
                                            fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: 'Sign In',
                                            style: TextStyle(
                                              color: AppTheme.accentGreenDark,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Get.back(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

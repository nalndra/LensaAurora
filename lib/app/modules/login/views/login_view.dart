import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/aurora_button.dart';
import '../../../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

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
              // Gradient hero background, visible behind the rounded sheet.
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
                child: Stack(
                  children: [
                    Positioned(
                      top: -70,
                      left: -50,
                      child: _Glow(
                          color: AppTheme.lightCyan.withValues(alpha: 0.22)),
                    ),
                    Positioned(
                      top: 40,
                      right: -60,
                      child: _Glow(
                          color: AppTheme.accentGreen.withValues(alpha: 0.25)),
                    ),
                  ],
                ),
              ),
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isLarge ? 36 : 28,
                              horizontal: horizontalPadding,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: isLarge ? 92 : 76,
                                  height: isLarge ? 92 : 76,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: AppTheme.shadowLg,
                                  ),
                                  child: Image.asset(
                                    'assets/logo/LensaAuroraLogo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.space16),
                                const Text(
                                  'LensaAurora',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                36,
                                horizontalPadding,
                                28,
                              ),
                              child: Form(
                                key: controller.loginFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Selamat Datang Kembali',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.space8),
                                    Text(
                                      'Masuk dan gunakan fitur-fitur menarik yang ada di LensaAurora',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppTheme.textLight,
                                        fontSize: isLarge ? 15 : 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.space32),
                                    TextFormField(
                                      controller: controller.loginEmailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.mail_outline_rounded),
                                        labelText: 'Email',
                                        hintText: 'contoh@email.com',
                                      ),
                                      validator: controller.validateEmail,
                                    ),
                                    const SizedBox(height: AppTheme.space16),
                                    Obx(
                                      () => TextFormField(
                                        controller:
                                            controller.loginPasswordController,
                                        obscureText:
                                            !controller.isPasswordVisible.value,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                              Icons.lock_outline_rounded),
                                          labelText: 'Password',
                                          hintText: 'Masukkan password anda',
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              controller.isPasswordVisible.value
                                                  ? Icons.visibility_rounded
                                                  : Icons.visibility_off_rounded,
                                            ),
                                            onPressed:
                                                controller.togglePasswordVisibility,
                                          ),
                                        ),
                                        validator: controller.validatePassword,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () =>
                                            Get.toNamed('/forgot-password'),
                                        child: const Text('Lupa Password?'),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.space8),
                                    Obx(
                                      () => AuroraPrimaryButton(
                                        label: 'Masuk',
                                        isLoading: controller.isLoading.value,
                                        onPressed: () async {
                                          final success =
                                              await controller.login();
                                          if (success) {
                                            await controller.checkLoginStatus();
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.space24),
                                    Row(
                                      children: [
                                        const Expanded(child: Divider()),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          child: Text(
                                            'Atau masuk dengan',
                                            style: TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const Expanded(child: Divider()),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.space20),
                                    Obx(
                                      () => Center(
                                        child: AuroraSocialButton(
                                          onTap: controller.isLoading.value
                                              ? null
                                              : () async {
                                                  final success = await controller
                                                      .signInWithGoogle();
                                                  if (success) {
                                                    await controller
                                                        .checkLoginStatus();
                                                  }
                                                },
                                          child: Image.asset(
                                            'assets/logo/GoogleIcon.png',
                                            height: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(height: AppTheme.space16),
                                    Center(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Belum punya akun? ',
                                          style: TextStyle(
                                              color: AppTheme.textLight,
                                              fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: 'Daftar',
                                              style: TextStyle(
                                                color: AppTheme.accentGreenDark,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap =
                                                    () => Get.toNamed('/register'),
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
                        ],
                      ),
                    ),
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

/// A large, softly-blurred circle used to add ambient depth to a gradient
/// background without a real ImageFilter blur (cheaper, works on web).
class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

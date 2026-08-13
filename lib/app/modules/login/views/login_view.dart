import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../../../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final isLarge = width > 600;
            final horizontalPadding = isLarge ? width * 0.18 : 24.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: isLarge ? 40 : 28),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.accentGradient,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: isLarge ? 12 : 6),
                            Image.asset(
                              'assets/logo/LensaAuroraLogo.png',
                              height: isLarge ? 120 : 90,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'LensaAurora',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding, vertical: 28),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Form(
                            key: controller.loginFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                const Text(
                                  'Selamat Datang Kembali',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Masuk dan gunakan fitur-fitur menarik yang ada di LensaAurora',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: isLarge ? 15 : 13,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: controller.loginEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    labelText: 'Email',
                                    hintText: 'contoh@email.com',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                  validator: controller.validateEmail,
                                ),
                                const SizedBox(height: 16),
                                Obx(
                                  () => TextFormField(
                                    controller: controller.loginPasswordController,
                                    obscureText: !controller.isPasswordVisible.value,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      labelText: 'Password',
                                      hintText: 'Masukkan password anda',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.isPasswordVisible.value
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: controller.togglePasswordVisibility,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                    ),
                                    validator: controller.validatePassword,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Get.toNamed('/forgot-password'),
                                    child: const Text(
                                      'Lupa Password?',
                                      style: TextStyle(
                                        color: AppTheme.accentGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () async {
                                            final success = await controller.login();
                                            if (success) {
                                              await controller.checkLoginStatus();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentGreen,
                                      minimumSize:
                                          Size(double.infinity, isLarge ? 56 : 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: AppTheme.primaryDark,
                                          width: 1.5,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Masuk',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(color: Colors.grey.shade300)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Text('Atau masuk dengan',
                                          style:
                                              TextStyle(color: Colors.grey.shade600)),
                                    ),
                                    Expanded(
                                        child: Divider(color: Colors.grey.shade300)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: controller.isLoading.value
                                          ? null
                                          : () async {
                                              final success =
                                                  await controller.signInWithGoogle();
                                              if (success) {
                                                await controller.checkLoginStatus();
                                              }
                                            },
                                      child: Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                              'assets/logo/GoogleIcon.png',
                                              height: 22),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Belum punya akun? ',
                                      style: TextStyle(color: Colors.grey.shade600),
                                      children: [
                                        TextSpan(
                                          text: 'Daftar',
                                          style: const TextStyle(
                                            color: AppTheme.accentGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => Get.toNamed('/register'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

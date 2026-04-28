import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import '../../../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF6338F1);

    return Scaffold(
      backgroundColor: primaryPurple,
      body: Stack(
        children: [
          // Background Purple Area (Top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.20,
            child: const SafeArea(
              child: Center(
                // Placeholder illustration or logo
              ),
            ),
          ),

          // Main White Container (Bottom)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mulai pengalaman digital eksklusif bersama\nLensaAurora hari ini',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form
                      Form(
                        key: controller.registerFormKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: controller.registerNameController,
                              labelText: 'Nama Anda',
                              keyboardType: TextInputType.name,
                              validator: controller.validateName,
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: controller.registerEmailController,
                              labelText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: controller.validateEmail,
                            ),
                            const SizedBox(height: 16),

                            Obx(() => _buildTextField(
                              controller: controller.registerPasswordController,
                              labelText: 'Password',
                              obscureText: !controller.isPasswordVisible.value,
                              suffixIcon: IconButton(
                                padding: const EdgeInsets.only(right: 12),
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                              validator: controller.validatePassword,
                            )),
                            const SizedBox(height: 16),

                            Obx(() => _buildTextField(
                              controller: controller.registerConfirmPasswordController,
                              labelText: 'Konfirmasi Password',
                              obscureText: !controller.isConfirmPasswordVisible.value,
                              suffixIcon: IconButton(
                                padding: const EdgeInsets.only(right: 12),
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                icon: Icon(
                                  controller.isConfirmPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: controller.toggleConfirmPasswordVisibility,
                              ),
                              validator: controller.validatePasswordMatch,
                            )),
                            const SizedBox(height: 16),

                            // Terms & Conditions
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Checkbox(
                                  value: controller.agreedToTerms.value ?? false,
                                  onChanged: (value) {
                                    controller.agreedToTerms.value = value ?? false;
                                  },
                                  activeColor: primaryPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Saya menyetujui semua ',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: 'syarat',
                                            style: const TextStyle(
                                              color: primaryPurple,
                                              decoration: TextDecoration.underline,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: TapGestureRecognizer()..onTap = () {},
                                          ),
                                          const TextSpan(text: ' & '),
                                          TextSpan(
                                            text: 'ketentuan',
                                            style: const TextStyle(
                                              color: primaryPurple,
                                              decoration: TextDecoration.underline,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: TapGestureRecognizer()..onTap = () {},
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Sign Up Button
                            Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () async {
                                      if (controller.agreedToTerms.value != true) {
                                        Get.snackbar(
                                          'Perhatian',
                                          'Anda harus menyetujui syarat & ketentuan',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.redAccent,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }
                                      final success = await controller.register();
                                      if (success) {
                                        // Navigate to account type selection for new users
                                        Get.offAllNamed('/account-type');
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                disabledBackgroundColor: Colors.grey.shade300,
                                minimumSize: const Size(double.infinity, 65),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Atau masuk dengan', style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: controller.isLoading.value 
                                  ? () {} 
                                  : () async {
                                      final success = await controller.signInWithGoogle();
                                      if (success) {
                                        // For Google sign in (could be new user), 
                                        // navigate to account-type to set role
                                        Get.offAllNamed('/account-type');
                                      }
                                    },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/logo/GoogleIcon.png', // ← ini path Flutter (BUKAN path C:\...)
                                    height: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildSocialBtn(
                              icon: Icons.apple,
                              color: Colors.black,
                              onTap: () {},
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),

                      // Footer
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Sudah punya akun? ',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: const TextStyle(
                                  color: primaryPurple,
                                  fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: labelText == 'Nama Anda'
            ? 'Nama Anda'
            : labelText == 'Email'
                ? 'contoh@email.com'
                : labelText == 'Password'
                    ? 'Masukkan password anda'
                    : 'Konfirmasi password anda',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF6338F1), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildSocialBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}


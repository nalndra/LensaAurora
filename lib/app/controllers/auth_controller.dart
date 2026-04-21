import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final authService = AuthService();

  // Observable states
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreedToTerms = false.obs;
  var currentUser = Rxn<User>();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController loginEmailController;
  late TextEditingController loginPasswordController;
  late TextEditingController registerNameController;
  late TextEditingController registerEmailController;
  late TextEditingController registerPasswordController;
  late TextEditingController registerConfirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    loginEmailController = TextEditingController();
    loginPasswordController = TextEditingController();
    registerNameController = TextEditingController();
    registerEmailController = TextEditingController();
    registerPasswordController = TextEditingController();
    registerConfirmPasswordController = TextEditingController();
    
    // Listen to auth changes
    currentUser.value = authService.currentUser;
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// ==================== VALIDATION ====================

  /// Validasi email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  /// Validasi password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validasi nama
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  /// Validasi password match
  String? validatePasswordMatch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != registerPasswordController.text) {
      return 'Password tidak sesuai';
    }
    return null;
  }

  /// ==================== LOGIN ====================

  Future<bool> login() async {
    try {
      if (!loginFormKey.currentState!.validate()) {
        return false;
      }

      isLoading.value = true;
      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text;

      final user = await authService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        currentUser.value = user;
        Get.snackbar(
          'Sukses',
          'Login berhasil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== LOGIN WITH GOOGLE ====================
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await authService.signInWithGoogle();

      if (user != null) {
        currentUser.value = user;
        Get.snackbar(
          'Sukses',
          'Login Google berhasil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat login Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== REGISTER ====================

  Future<bool> register() async {
    try {
      if (!registerFormKey.currentState!.validate()) {
        return false;
      }

      isLoading.value = true;
      final name = registerNameController.text.trim();
      final email = registerEmailController.text.trim();
      final password = registerPasswordController.text;

      // Check if email already exists
      final emailExists = await authService.emailExists(email);
      if (emailExists) {
        Get.snackbar(
          'Error',
          'Email sudah terdaftar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final user = await authService.register(
        email: email,
        password: password,
        name: name,
      );

      if (user != null) {
        currentUser.value = user;
        Get.snackbar(
          'Sukses',
          'Registrasi berhasil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== LOGOUT ====================

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await authService.logout();
      currentUser.value = null;
      
      // Clear form fields
      loginEmailController.clear();
      loginPasswordController.clear();
      registerNameController.clear();
      registerEmailController.clear();
      registerPasswordController.clear();
      registerConfirmPasswordController.clear();

      Get.snackbar(
        'Sukses',
        'Logout berhasil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== ERROR HANDLING ====================

  void _handleAuthException(FirebaseAuthException e) {
    String message = 'Terjadi kesalahan';

    switch (e.code) {
      case 'user-not-found':
        message = 'User tidak ditemukan';
        break;
      case 'wrong-password':
        message = 'Password salah';
        break;
      case 'invalid-email':
        message = 'Email tidak valid';
        break;
      case 'user-disabled':
        message = 'Akun ini telah dinonaktifkan';
        break;
      case 'email-already-in-use':
        message = 'Email sudah terdaftar';
        break;
      case 'operation-not-allowed':
        message = 'Operasi tidak diizinkan';
        break;
      case 'weak-password':
        message = 'Password terlalu lemah';
        break;
      case 'invalid-credential':
        message = 'Email atau password salah';
        break;
      case 'too-many-requests':
        message = 'Terlalu banyak percobaan login. Coba lagi nanti.';
        break;
      case 'network-request-failed':
        message = 'Gagal terhubung ke internet';
        break;
      default:
        message = e.message ?? 'Terjadi kesalahan';
    }

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// ==================== PASSWORD RECOVERY ====================

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Error',
          'Email tidak valid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;
      await authService.sendPasswordResetEmail(email);
      
      Get.snackbar(
        'Sukses',
        'Link reset password telah dikirim ke email Anda',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== SESSION CHECK ====================

  void checkLoginStatus() {
    if (authService.isLoggedIn) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }
}

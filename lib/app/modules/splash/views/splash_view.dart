import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().checkLoginStatus();
    } else {
      // Register controller if not yet registered
      Get.put(AuthController());
      Get.find<AuthController>().checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Image
              Image.asset(
                'assets/logo/LensaAuroraLogo.png',
                width: screenSize.width * 0.6,
                height: screenSize.width * 0.6,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              
              // App Name
              const Text(
                'Lensa Aurora',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Speech & Motor Behavior Analysis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),
              
              // Loading Indicator
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6338F1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

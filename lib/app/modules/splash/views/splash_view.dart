import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
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
    // Minimal delay for splash screen visibility (400ms instead of 2s)
    await Future.delayed(const Duration(milliseconds: 400));

    // Check login status
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().checkLoginStatus();
    } else {
      // Register controller if not yet registered
      Get.put(AuthController());
      await Get.find<AuthController>().checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Scale off the smaller dimension and cap it so wide/short viewports
    // (e.g. a desktop browser window) don't blow the column past its height.
    final logoSize = (screenSize.shortestSide * 0.34).clamp(96.0, 160.0);

    return Scaffold(
      body: Container(
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
            // Soft ambient glows for depth.
            Positioned(
              top: -80,
              right: -60,
              child: _Glow(color: AppTheme.lightCyan.withValues(alpha: 0.22)),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _Glow(color: AppTheme.accentGreen.withValues(alpha: 0.25)),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          padding: const EdgeInsets.all(AppTheme.space16),
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
                        const SizedBox(height: AppTheme.space32),
                        const Text(
                          'Lensa Aurora',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: AppTheme.space12),
                        Text(
                          'Speech & Motor Behavior Analysis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: AppTheme.space48),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.9),
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
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

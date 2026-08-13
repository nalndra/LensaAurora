import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/navigation_controller.dart';
import 'app/controllers/accessibility_controller.dart';
import 'app/widgets/accessibility_overlay.dart';
import 'app/utils/scroll_behavior.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lensa Aurora',
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 150),
      scrollBehavior: const NoOverscrollScrollBehavior(),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(NavigationController());
        Get.put(AccessibilityController(), permanent: true);
      }),
      builder: (context, child) {
        final accessibility = Get.find<AccessibilityController>();

        return Obx(() {
          final baseTheme = accessibility.applyToTheme(AppTheme.lightTheme);
          final scaledChild = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(accessibility.fontScale.value),
            ),
            child: Theme(
              data: baseTheme,
              child: child ?? const SizedBox.shrink(),
            ),
          );

          Widget content = scaledChild;
          if (accessibility.reduceOpacity.value) {
            content = Opacity(
              opacity: accessibility.opacityLevel.value,
              child: content,
            );
          }

          return Stack(
            children: [
              content,
              const AccessibilityOverlay(),
            ],
          );
        });
      },
    );
  }
}

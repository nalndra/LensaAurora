import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
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

  // Local key-value store backing AccessibilityController's persisted
  // settings (font, contrast, opacity, button position, etc.).
  await GetStorage.init();

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
          final fontScale = accessibility.fontScale.value;
          final currentFontFamily = accessibility.fontFamily;

          final rebuildKey = ValueKey(
            '${accessibility.useOutline.value}_'
            '${accessibility.useAltAccent.value}_'
            '${accessibility.highContrast.value}_'
            '${accessibility.selectedFont.value.name}_'
            '$fontScale',
          );

          Widget content = KeyedSubtree(
            key: rebuildKey,
            child: child ?? const SizedBox.shrink(),
          );

          if (accessibility.reduceOpacity.value) {
            content = Opacity(
              opacity: accessibility.opacityLevel.value,
              child: content,
            );
          }

          final textStyle = (baseTheme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
            fontFamily: currentFontFamily,
          );

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(fontScale),
            ),
            child: Theme(
              data: baseTheme,
              child: DefaultTextStyle(
                style: textStyle,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => Stack(
                        children: [
                          content,
                          const AccessibilityOverlay(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

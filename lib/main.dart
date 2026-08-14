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

          // Most screens read colors from AppTheme's static getters
          // directly instead of Theme.of(context), so a Theme change alone
          // doesn't repaint them (Flutter skips rebuilding `child` since
          // it's the same widget instance every time). Re-keying it forces
          // Flutter to tear down and rebuild the whole route tree whenever
          // a setting that changes those getters' output is toggled, so
          // Outline/Accent/Kontras actually take effect everywhere.
          final rebuildKey = ValueKey(
            '${accessibility.useOutline.value}_'
            '${accessibility.useAltAccent.value}_'
            '${accessibility.highContrast.value}',
          );

          final scaledChild = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(accessibility.fontScale.value),
            ),
            child: Theme(
              data: baseTheme,
              child: KeyedSubtree(
                key: rebuildKey,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );

          Widget content = scaledChild;
          if (accessibility.reduceOpacity.value) {
            content = Opacity(
              opacity: accessibility.opacityLevel.value,
              child: content,
            );
          }

          // GetMaterialApp's builder runs above the Navigator, so this Stack
          // sits outside the Overlay the Navigator provides. Widgets in
          // AccessibilityOverlay (e.g. the settings panel's Tooltip) need
          // their own Overlay ancestor or they throw "No Overlay widget
          // found" the moment they try to render.
          return Overlay(
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
          );
        });
      },
    );
  }
}

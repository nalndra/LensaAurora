import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';

import '../controllers/scan_controller.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NavigationController>(
      NavigationController(),
    );
    Get.lazyPut<ScanController>(
      () => ScanController(),
    );
  }
}

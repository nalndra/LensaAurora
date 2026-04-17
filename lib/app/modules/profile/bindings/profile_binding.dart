import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NavigationController>(
      NavigationController(),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}

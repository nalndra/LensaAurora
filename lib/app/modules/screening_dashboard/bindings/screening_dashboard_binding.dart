import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/screening_dashboard/controllers/screening_dashboard_controller.dart';

class ScreeningDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScreeningDashboardController>(
      () => ScreeningDashboardController(),
    );
  }
}

import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/scan/controllers/gaze_tracking_controller.dart';

class GazeTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GazeTrackingController>(
      () => GazeTrackingController(),
    );
  }
}

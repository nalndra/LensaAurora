import 'package:get/get.dart';
import '../../controllers/eye_tracking_controller.dart';

class EyeTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EyeTrackingController>(EyeTrackingController());
  }
}

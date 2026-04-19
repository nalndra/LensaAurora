import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/motor_behavior/controllers/motor_behavior_controller.dart';

class MotorBehaviorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MotorBehaviorController>(
      () => MotorBehaviorController(),
    );
  }
}

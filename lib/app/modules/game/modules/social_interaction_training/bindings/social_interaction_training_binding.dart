import 'package:get/get.dart';
import '../controllers/social_interaction_training_controller.dart';

class SocialInteractionTrainingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocialInteractionTrainingController>(
      () => SocialInteractionTrainingController(),
    );
  }
}

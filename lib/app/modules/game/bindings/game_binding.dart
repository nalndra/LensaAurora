import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';

import '../controllers/game_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NavigationController>(
      NavigationController(),
    );
    Get.lazyPut<GameController>(
      () => GameController(),
    );
  }
}

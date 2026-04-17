import 'package:get/get.dart';
import '../controllers/collaborative_puzzle_game_controller.dart';

class CollaborativePuzzleGameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollaborativePuzzleGameController>(
      () => CollaborativePuzzleGameController(),
    );
  }
}

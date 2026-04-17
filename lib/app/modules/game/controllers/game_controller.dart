import 'package:get/get.dart';
import '../models/game_model.dart';

class GameController extends GetxController {
  late RxList<GameModel> games;

  @override
  void onInit() {
    super.onInit();
    _initializeGames();
  }

  void _initializeGames() {
    games = RxList<GameModel>([
      GameModel(
        id: '1',
        title: 'Social Interaction Training',
        description:
            'Latih kemampuan komunikasi dan interaksi sosial dengan simulasi percakapan',
        imageUrl: 'assets/boneka_warnawarni.jpg',
        type: 'social_interaction',
        difficulty: 2,
      ),
      GameModel(
        id: '2',
        title: 'Collaborative Puzzle Game',
        description: 'Puzzle game yang memerlukan kolaborasi 2 pemain - Enforced Collaboration',
        imageUrl: 'assets/caleb-woods-ecRuhwPIW7c-unsplash.jpg',
        type: 'puzzle',
        difficulty: 2,
      ),
    ]);
  }

  void playGame(String gameId) {
    switch (gameId) {
      case '1':
        Get.toNamed('/social-interaction-training');
        break;
      case '2':
        Get.toNamed('/collaborative-puzzle-game');
        break;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

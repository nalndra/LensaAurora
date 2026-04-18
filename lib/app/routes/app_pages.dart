import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/game/bindings/game_binding.dart';
import '../modules/game/modules/collaborative_puzzle_game/bindings/collaborative_puzzle_game_binding.dart';
import '../modules/game/modules/collaborative_puzzle_game/views/collaborative_puzzle_game_view.dart';
import '../modules/game/modules/social_interaction_training/bindings/social_interaction_training_binding.dart';
import '../modules/game/modules/social_interaction_training/views/social_interaction_training_view.dart';
import '../modules/game/views/game_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/scan/bindings/scan_binding.dart';
import '../modules/scan/bindings/gaze_tracking_binding.dart';
import '../modules/scan/views/scan_view.dart';
import '../modules/scan/views/gaze_tracking_view.dart';
import 'transitions.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SCAN,
      page: () => const ScanView(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: _Paths.GAZE_TRACKING,
      page: () => const GazeTrackingView(),
      binding: GazeTrackingBinding(),
    ),
    GetPage(
      name: _Paths.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: _Paths.GAME,
      page: () => const GameView(),
      binding: GameBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SOCIAL_INTERACTION_TRAINING,
      page: () => const SocialInteractionTrainingView(),
      binding: SocialInteractionTrainingBinding(),
    ),
    GetPage(
      name: _Paths.COLLABORATIVE_PUZZLE_GAME,
      page: () => const CollaborativePuzzleGameView(),
      binding: CollaborativePuzzleGameBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
  ];
}

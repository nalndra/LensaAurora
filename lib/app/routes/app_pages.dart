import 'package:get/get.dart';

import '../modules/account_type/bindings/account_type_binding.dart';
import '../modules/account_type/views/account_type_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/game/modules/collaborative_puzzle_game/bindings/collaborative_puzzle_game_binding.dart';
import '../modules/game/modules/collaborative_puzzle_game/views/collaborative_puzzle_game_view.dart';
import '../modules/game/modules/social_interaction_training/bindings/social_interaction_training_binding.dart';
import '../modules/game/modules/social_interaction_training/views/social_interaction_training_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/motor_behavior/bindings/motor_behavior_binding.dart';
import '../modules/motor_behavior/views/motor_behavior_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/scan/bindings/gaze_tracking_binding.dart';
import '../modules/scan/views/gaze_tracking_view.dart';
import '../modules/speech/bindings/speech_binding.dart';
import '../modules/speech/views/speech_view.dart';
import '../modules/speech_analysis/bindings/speech_analysis_binding.dart';
import '../modules/speech_analysis/views/speech_analysis_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/terms/bindings/terms_binding.dart';
import '../modules/terms/views/terms_view.dart';
import '../views/main_shell.dart';
import '../views/main_shell_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const MainShell(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: _Paths.SCAN,
      page: () => const MainShell(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: _Paths.GAZE_TRACKING,
      page: () => const GazeTrackingView(),
      binding: GazeTrackingBinding(),
    ),
    GetPage(
      name: _Paths.GAME,
      page: () => const MainShell(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const MainShell(),
      binding: MainShellBinding(),
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
    GetPage(
      name: _Paths.SPEECH,
      page: () => const SpeechView(),
      binding: SpeechBinding(),
    ),
    GetPage(
      name: _Paths.SPEECH_ANALYSIS,
      page: () => const SpeechAnalysisView(),
      binding: SpeechAnalysisBinding(),
    ),
    GetPage(
      name: _Paths.MOTOR_BEHAVIOR,
      page: () => const MotorBehaviorView(),
      binding: MotorBehaviorBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.TERMS,
      page: () => const TermsView(),
      binding: TermsBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_TYPE,
      page: () => const AccountTypeView(),
      binding: AccountTypeBinding(),
    ),
  ];
}

import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/home/bindings/home_binding.dart';
import 'package:lensaaurora/app/modules/scan/bindings/scan_binding.dart';
import 'package:lensaaurora/app/modules/game/bindings/game_binding.dart';
import 'package:lensaaurora/app/modules/profile/bindings/profile_binding.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load all main page bindings
    HomeBinding().dependencies();
    ScanBinding().dependencies();
    GameBinding().dependencies();
    ProfileBinding().dependencies();
  }
}

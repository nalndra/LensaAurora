import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/speech_analysis/controllers/speech_analysis_controller.dart';

class SpeechAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpeechAnalysisController>(
      () => SpeechAnalysisController(),
    );
  }
}

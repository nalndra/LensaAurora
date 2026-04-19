import 'package:get/get.dart';

class SpeechController extends GetxController {
  // Speech analysis state
  RxBool isRecording = false.obs;
  RxBool isAnalyzing = false.obs;
  RxInt currentParagraphIndex = 0.obs;
  RxDouble confidenceScore = 0.0.obs;
  
  // Analysis results
  RxString nervousnessLevel = 'Belum Dianalisis'.obs; // High/Medium/Low
  RxBool hasStuttering = false.obs;
  RxString speechPace = 'Normal'.obs; // Slow/Normal/Fast
  RxDouble analysisConfidence = 0.0.obs;

  // Paragraphs for reading
  final List<String> paragraphs = [
    'Hari ini adalah hari yang cerah dan menyenangkan. Saya pergi ke taman untuk bermain dengan teman-teman saya. Kami bermain ayun, seluncuran, dan permainan lainnya.',
    'Kucing saya sangat lucu dan menyenangkan. Dia suka bermain dengan bola dan tali. Setiap hari kami bermain bersama dan dia sangat bahagia.',
    'Sekolah adalah tempat yang menyenangkan untuk belajar. Saya belajar matematika, bahasa Indonesia, dan sains. Guru-guru saya sangat baik dan membantu saya belajar.',
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void startRecording() {
    isRecording.value = true;
    // TODO: Implement actual speech recording with STT
  }

  void stopRecording() {
    isRecording.value = false;
    // TODO: Implement speech-to-text and analysis
  }

  Future<void> analyzeSpeech() async {
    isAnalyzing.value = true;
    
    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: Replace with actual ML analysis
    // For now, generate mock results
    nervousnessLevel.value = ['Rendah', 'Sedang', 'Tinggi'][DateTime.now().microsecond % 3];
    hasStuttering.value = DateTime.now().microsecond % 5 == 0;
    speechPace.value = ['Lambat', 'Normal', 'Cepat'][DateTime.now().microsecond % 3];
    analysisConfidence.value = 0.75 + (DateTime.now().microsecond % 25) / 100;
    
    isAnalyzing.value = false;
  }

  void nextParagraph() {
    if (currentParagraphIndex.value < paragraphs.length - 1) {
      currentParagraphIndex.value++;
    }
  }

  void previousParagraph() {
    if (currentParagraphIndex.value > 0) {
      currentParagraphIndex.value--;
    }
  }
}


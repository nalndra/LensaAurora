import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  RxDouble analysisConfidence = 0.0.obs; // 0.0 - 1.0

  // Paragraphs for reading
  final List<String> paragraphs = [
    'Hari ini adalah hari yang cerah dan menyenangkan. Saya pergi ke taman untuk bermain dengan teman-teman saya. Kami bermain ayun, seluncuran, dan permainan lainnya.',
    'Kucing saya sangat lucu dan menyenangkan. Dia suka bermain dengan bola dan tali. Setiap hari kami bermain bersama dan dia sangat bahagia.',
    'Sekolah adalah tempat yang menyenangkan untuk belajar. Saya belajar matematika, bahasa Indonesia, dan sains. Guru-guru saya sangat baik dan membantu saya belajar.',
  ];

  // STT
  late stt.SpeechToText _speech;
  String _lastTranscript = '';
  double _lastConfidence = 0.0;
  DateTime? _recordStart;

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
  }

  @override
  void onClose() {
    if (_speech.isListening) {
      _speech.stop();
    }
    super.onClose();
  }

  Future<void> startRecording() async {
    final available = await _speech.initialize(
        onStatus: (s) {
          print('STT status: $s');
        },
        onError: (e) {
          print('STT error: ${e.toJson()}');
          Get.snackbar('STT Error', e.errorMsg ?? 'Unknown');
        },
        debugLogging: true);
    if (!available) {
      Get.snackbar('Error', 'Speech recognition not available on this device');
      return;
    }

    _lastTranscript = '';
    _lastConfidence = 0.0;
    _recordStart = DateTime.now();
    isRecording.value = true;

    await _speech.listen(onResult: (result) {
      _lastTranscript = result.recognizedWords;
      _lastConfidence = result.confidence;
      print('STT result: ${result.recognizedWords} (conf: ${result.confidence})');
    }, listenFor: const Duration(seconds: 60));
  }

  Future<void> stopRecording() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    isRecording.value = false;

    // After stopping, run analysis on the captured transcript
    await analyzeSpeech();
  }

  Future<void> analyzeSpeech() async {
    isAnalyzing.value = true;

    final transcript = _lastTranscript.trim();
    final confidence = _lastConfidence;
    final recordEnd = DateTime.now();
    final durationSeconds = _recordStart == null ? 1.0 : recordEnd.difference(_recordStart!).inMilliseconds / 1000.0;

    // Basic text-based metrics
    final words = transcript.isEmpty ? <String>[] : transcript.split(RegExp(r'\s+'));
    final wordCount = words.length;
    final wpm = durationSeconds > 0 ? (wordCount / durationSeconds) * 60.0 : 0.0;

    // Heuristic for stuttering: repeated consecutive words count
    int repeated = 0;
    for (var i = 1; i < words.length; i++) {
      if (words[i].toLowerCase() == words[i - 1].toLowerCase()) repeated++;
    }

    // Determine nervousness roughly based on confidence and wpm
    String nervousness;
    if (confidence > 0.8 && wpm >= 90) {
      nervousness = 'Tinggi';
    } else if (confidence > 0.6 && wpm >= 70) {
      nervousness = 'Sedang';
    } else {
      nervousness = 'Rendah';
    }

    // Pace categorization
    String pace;
    if (wpm < 90) pace = 'Lambat';
    else if (wpm <= 150) pace = 'Normal';
    else pace = 'Cepat';

    // Analysis confidence: combine STT confidence and heuristics
    double score = (confidence * 0.6) + ((1.0 - (repeated / (wordCount > 0 ? wordCount : 1))) * 0.4);
    score = score.clamp(0.0, 1.0);

    // Update observable states
    nervousnessLevel.value = nervousness;
    hasStuttering.value = repeated > 0;
    speechPace.value = pace;
    analysisConfidence.value = score;

    // Save result to Firestore under users/{uid}/screenings
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('screenings')
            .doc();

        await docRef.set({
          'type': 'speech',
          'transcript': transcript,
          'wordCount': wordCount,
          'wpm': wpm,
          'repeatedWords': repeated,
          'nervousness': nervousness,
          'hasStuttering': repeated > 0,
          'pace': pace,
          'score': score,
          'sttConfidence': confidence,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('ERROR saving speech analysis: $e');
    }

    // small delay to show analyzing state
    await Future.delayed(const Duration(milliseconds: 400));
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


import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lensaaurora/app/services/gaze_results_service.dart';

enum SpeechTestState { idle, reading, completed }

class _ParagraphResult {
  _ParagraphResult({
    required this.transcript,
    required this.accuracy,
    required this.wpm,
    required this.repeatedWords,
    required this.confidence,
  });

  final String transcript;
  final double accuracy; // 0.0 - 1.0, how much of the target text was said
  final double wpm;
  final int repeatedWords;
  final double confidence; // STT engine confidence
}

class SpeechAnalysisController extends GetxController {
  final testState = SpeechTestState.idle.obs;

  final currentParagraphIndex = 0.obs;
  final nervousnessScore = 0.obs; // 0-100
  final stutteringScore = 0.obs; // repeated-word count
  final readingSpeedScore = 0.obs; // words per minute

  final isRecording = false.obs;
  final recordingExists = false.obs;

  final paragraphs = [
    'Hari ini adalah hari yang cerah dan menyenangkan. Saya pergi ke taman untuk bermain dengan teman-teman saya. Kami bermain ayun, seluncuran, dan permainan lainnya.',
    'Kucing saya sangat lucu dan menyenangkan. Dia suka bermain dengan bola dan tali. Setiap hari kami bermain bersama dan dia sangat bahagia.',
    'Sekolah adalah tempat yang menyenangkan untuk belajar. Saya belajar matematika, bahasa Indonesia, dan sains. Guru-guru saya sangat baik dan membantu saya belajar.',
  ];

  final _resultsService = GazeResultsService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  DateTime? _testStartTime;
  DateTime? _recordStart;
  String _lastTranscript = '';
  double _lastConfidence = 0.0;
  final List<_ParagraphResult> _paragraphResults = [];

  void startSpeechTest() {
    testState.value = SpeechTestState.reading;
    currentParagraphIndex.value = 0;
    _paragraphResults.clear();
    _testStartTime = DateTime.now();
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopAndAnalyzeParagraph();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onStatus: (s) => debugPrint('[SpeechAnalysis] STT status: $s'),
      onError: (e) => debugPrint('[SpeechAnalysis] STT error: ${e.errorMsg}'),
    );
    if (!available) {
      Get.snackbar(
        'Mikrofon tidak tersedia',
        'Periksa izin mikrofon di pengaturan perangkat Anda',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _lastTranscript = '';
    _lastConfidence = 0.0;
    _recordStart = DateTime.now();
    isRecording.value = true;

    await _speech.listen(
      onResult: (result) {
        _lastTranscript = result.recognizedWords;
        _lastConfidence = result.confidence;
      },
      listenFor: const Duration(seconds: 60),
    );
  }

  /// Detects how well the user actually read the target paragraph: how
  /// much of the target text was recognized (accuracy), how fast they
  /// spoke (wpm), and how many words they stumbled/repeated on.
  Future<void> _stopAndAnalyzeParagraph() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    isRecording.value = false;

    final target = paragraphs[currentParagraphIndex.value];
    final transcript = _lastTranscript.trim();
    final recordEnd = DateTime.now();
    final durationSeconds = _recordStart == null
        ? 1.0
        : recordEnd.difference(_recordStart!).inMilliseconds / 1000.0;

    final spokenWords =
        transcript.isEmpty ? <String>[] : transcript.split(RegExp(r'\s+'));
    final wpm = durationSeconds > 0
        ? (spokenWords.length / durationSeconds) * 60.0
        : 0.0;

    int repeated = 0;
    for (var i = 1; i < spokenWords.length; i++) {
      if (spokenWords[i].toLowerCase() == spokenWords[i - 1].toLowerCase()) {
        repeated++;
      }
    }

    final accuracy = _wordOverlapAccuracy(target, transcript);

    _paragraphResults.add(_ParagraphResult(
      transcript: transcript,
      accuracy: accuracy,
      wpm: wpm,
      repeatedWords: repeated,
      confidence: _lastConfidence,
    ));

    recordingExists.value = true;
  }

  /// Fraction of the target paragraph's words that showed up somewhere in
  /// what the user actually said — a simple, robust proxy for "did they
  /// read this paragraph" without needing exact word-order matching.
  double _wordOverlapAccuracy(String target, String spoken) {
    final targetWords = target
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (targetWords.isEmpty) return 0;

    final spokenWords = spoken
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toSet();

    final matched = targetWords.where(spokenWords.contains).length;
    return matched / targetWords.length;
  }

  void restartRecording() {
    isRecording.value = false;
    recordingExists.value = false;
    if (_paragraphResults.length > currentParagraphIndex.value) {
      _paragraphResults.removeLast();
    }
  }

  void skipToNextParagraph() {
    if (currentParagraphIndex.value < paragraphs.length - 1) {
      currentParagraphIndex.value++;
      isRecording.value = false;
      recordingExists.value = false;
    } else {
      completeTest();
    }
  }

  Future<void> completeTest() async {
    final testEndTime = DateTime.now();

    if (_paragraphResults.isEmpty) {
      testState.value = SpeechTestState.completed;
      return;
    }

    final avgAccuracy = _paragraphResults.map((r) => r.accuracy).reduce((a, b) => a + b) /
        _paragraphResults.length;
    final avgWpm = _paragraphResults.map((r) => r.wpm).reduce((a, b) => a + b) /
        _paragraphResults.length;
    final totalRepeated =
        _paragraphResults.fold<int>(0, (sum, r) => sum + r.repeatedWords);
    final avgConfidence =
        _paragraphResults.map((r) => r.confidence).reduce((a, b) => a + b) /
            _paragraphResults.length;

    readingSpeedScore.value = avgWpm.round().clamp(0, 300);
    stutteringScore.value = totalRepeated;
    // Reading fluently near a natural pace (90-150 wpm) with few
    // repeats reads as "calm"; very slow/fast or stumbling reads as
    // more nervous — this is a heuristic proxy, not a clinical measure.
    final paceDeviation = avgWpm < 90
        ? (90 - avgWpm) / 90
        : avgWpm > 150
            ? (avgWpm - 150) / 150
            : 0.0;
    final stutterPenalty = (totalRepeated / (_paragraphResults.length * 3)).clamp(0.0, 1.0);
    nervousnessScore.value =
        ((paceDeviation.clamp(0.0, 1.0) * 0.5 + stutterPenalty * 0.5) * 100)
            .round()
            .clamp(0, 100);

    // Overall score: mostly "did they actually read the text" (accuracy),
    // with STT confidence and low stuttering contributing.
    final score = ((avgAccuracy * 0.6) +
            (avgConfidence * 0.25) +
            ((1 - stutterPenalty) * 0.15))
        .clamp(0.0, 1.0) *
        100;

    try {
      await _resultsService.saveSpeechResult(
        score: score.round(),
        metrics: {
          'avgAccuracy': avgAccuracy,
          'avgWpm': avgWpm,
          'totalRepeatedWords': totalRepeated,
          'avgSttConfidence': avgConfidence,
          'paragraphsRead': _paragraphResults.length,
        },
        testStartTime: _testStartTime ?? testEndTime,
        testEndTime: testEndTime,
      );
    } catch (e) {
      debugPrint('[SpeechAnalysis] Error saving result: $e');
    }

    testState.value = SpeechTestState.completed;
  }

  @override
  void onClose() {
    if (_speech.isListening) {
      _speech.stop();
    }
    super.onClose();
  }
}

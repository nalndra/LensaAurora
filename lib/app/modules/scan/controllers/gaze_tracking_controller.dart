import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/modules/home/controllers/home_controller.dart';
import 'package:lensaaurora/app/models/gaze_data.dart';
import 'package:lensaaurora/app/services/gaze_detection_service.dart';
import 'package:lensaaurora/app/services/gaze_results_service.dart';

enum TestState { idle, running, completed, aborted }

class GazeTrackingController extends GetxController {
  late CameraController cameraController;
  late CameraDescription frontCamera;
  late GazeDetectionService gazeDetectionService;
  late GazeResultsService gazeResultsService;
  bool _isStreamRunning = false;
  bool _isProcessingFrame = false;
  DateTime? _fpsWindowStart;
  int _processedFramesInWindow = 0;

  late DateTime testStartTime;

  final isInitializing = false.obs;
  final isCameraReady = false.obs;
  final currentGaze = Rx<GazeData?>(null);
  final gazeHistory = <GazeData>[].obs;
  final testDuration = 30.obs; // seconds
  final timeRemaining = 30.obs;
  final testState = TestState.idle.obs;
  final gazeFPS = 0.obs; // frames per second

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeCamera();
    gazeDetectionService = GazeDetectionService();
    gazeResultsService = GazeResultsService();
  }

  Future<void> initializeCamera() async {
    try {
      isInitializing.value = true;

      // Get available cameras
      final cameras = await availableCameras();
      frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Initialize camera controller
      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController.initialize();
      isCameraReady.value = true;

      // NOTE: Image stream is NOT started here anymore!
      // It will be started only when startGazeTest() is called
      debugPrint('[🎥 GazeTrackingController] Camera initialized. Ready to start gaze detection.');
    } catch (e) {
      print('Error initializing camera: $e');
      Get.snackbar('Error', 'Failed to initialize camera: $e');
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _startGazeDetectionStream() async {
    try {
      if (_isStreamRunning) {
        print('Image stream already running');
        return;
      }

      _isStreamRunning = true;
      debugPrint('[🎥 GazeTrackingController] Starting image stream...');
      
      int frameCount = 0;
      cameraController.startImageStream((CameraImage image) async {
        if (_isProcessingFrame) return;
        _isProcessingFrame = true;

        frameCount++;
        if (frameCount % 100 == 0) {
          debugPrint('[🎥 GazeTrackingController] Processing frame $frameCount');
        }
        
        try {
          final gazeDataList = await gazeDetectionService.detectGazeFromImage(
            image,
            frontCamera,
          );

          if (gazeDataList != null && gazeDataList.isNotEmpty) {
            final primaryGaze = gazeDataList.first;
            currentGaze.value = primaryGaze;

            if (testState.value == TestState.running) {
              gazeHistory.add(primaryGaze);
              _updateFPS();
            }
          } else if (testState.value == TestState.running) {
            // Keep timeline populated so UI Data Points is not always zero
            final unknownGaze = GazeData(
              timestamp: DateTime.now(),
              direction: GazeDirection.unknown,
              confidence: 0.0,
              headPitch: 0.0,
              headYaw: 0.0,
              headRoll: 0.0,
            );
            currentGaze.value = unknownGaze;
            gazeHistory.add(unknownGaze);
            _updateFPS();
          }
        } catch (e) {
          debugPrint('[🎥 GazeTrackingController] Error processing frame: $e');
        } finally {
          _isProcessingFrame = false;
        }
      });
      
      debugPrint('[🎥 GazeTrackingController] Image stream started successfully');
    } catch (e) {
      print('Error starting image stream: $e');
      _isStreamRunning = false;
    }
  }

  Future<void> _stopGazeDetectionStream() async {
    try {
      if (_isStreamRunning && cameraController.value.isStreamingImages) {
        await cameraController.stopImageStream();
        _isStreamRunning = false;
        print('Image stream stopped');
      }
    } catch (e) {
      print('Error stopping image stream: $e');
      _isStreamRunning = false;
    }
  }

  void _updateFPS() {
    final now = DateTime.now();
    _fpsWindowStart ??= now;
    _processedFramesInWindow++;

    final elapsedMs = now.difference(_fpsWindowStart!).inMilliseconds;
    if (elapsedMs >= 1000) {
      gazeFPS.value = ((_processedFramesInWindow * 1000) / elapsedMs).round();
      _processedFramesInWindow = 0;
      _fpsWindowStart = now;
    }
  }

  Future<void> startGazeTest({int duration = 30}) async {
    try {
      // Ensure camera is ready
      if (!isCameraReady.value) {
        Get.snackbar('Error', 'Camera not ready. Please wait.');
        return;
      }

      testDuration.value = duration;
      timeRemaining.value = duration;
      gazeHistory.clear();
      gazeFPS.value = 0;
      _fpsWindowStart = null;
      _processedFramesInWindow = 0;
      currentGaze.value = null;
      testStartTime = DateTime.now();
      
      // Ensure image stream is running before starting test
      if (!_isStreamRunning) {
        print('Starting image stream before test...');
        await _startGazeDetectionStream();
        await Future.delayed(const Duration(milliseconds: 300)); // Brief delay to let stream stabilize
      }
      
      testState.value = TestState.running;
      print('Gaze test started at $testStartTime');

      // Countdown timer
      for (int i = duration; i > 0; i--) {
        await Future.delayed(const Duration(seconds: 1));
        timeRemaining.value = i - 1;
      }

      if (testState.value == TestState.running) {
        await completeGazeTest();
      }
    } catch (e) {
      print('Error during gaze test: $e');
    }
  }

  Future<void> stopGazeTest() async {
    testState.value = TestState.aborted;
    await _stopGazeDetectionStream();
  }

  Future<void> completeGazeTest() async {
    try {
      final testEndTime = DateTime.now();
      await _stopGazeDetectionStream();
      testState.value = TestState.completed;
      
      // Save the gaze results to Firestore
      print('Saving gaze results to Firestore...');
      
      // Create a simple report from collected gaze data
      final gazeMetrics = _calculateGazeMetricsFromHistory();
      
      await gazeResultsService.saveGazeResult(
        gazeMetrics: gazeMetrics,
        testStartTime: testStartTime,
        testEndTime: testEndTime,
      );
      
      print('Gaze results saved successfully');
    } catch (e) {
      print('Error completing gaze test: $e');
      debugPrintStack(label: 'Error saving gaze results');
    }
  }

  /// Calculate simple gaze metrics from collected gaze history
  Map<String, dynamic> _calculateGazeMetricsFromHistory() {
    if (gazeHistory.isEmpty) {
      return {
        'gaze_following': 0.0,
        'social_preference': 0.0,
        'avg_fixation': 0.0,
        'avg_saccade_vel': 0.0,
        'saccade_accuracy': 0.0,
        'aoi_eyes_pct': 0.0,
        'aoi_mouth_pct': 0.0,
        'gaze_latency': 0.0,
        'pupil_dynamic': 0.0,
        'total_frames': 0,
      };
    }

    // Approximate Python metrics from available mobile signals:
    // gaze direction timeline, confidence, and head pose deltas.
    final total = gazeHistory.length;
    final avgConfidence =
        gazeHistory.fold(0.0, (sum, gaze) => sum + gaze.confidence) / total;

    final centerCount =
        gazeHistory.where((g) => g.direction == GazeDirection.center).length;
    final leftCount =
        gazeHistory.where((g) => g.direction == GazeDirection.left).length;
    final rightCount =
        gazeHistory.where((g) => g.direction == GazeDirection.right).length;
    final unknownCount =
        gazeHistory.where((g) => g.direction == GazeDirection.unknown).length;

    final centerPct = (centerCount / total) * 100;
    final leftPct = (leftCount / total) * 100;
    final rightPct = (rightCount / total) * 100;
    final socialPreference = ((total - unknownCount) / total) * 100;

    // Fixation duration: average contiguous streak of same direction.
    final estimatedFps = gazeFPS.value > 0 ? gazeFPS.value.toDouble() : 15.0;
    final streakLengths = <int>[];
    var currentStreak = 1;
    for (var i = 1; i < gazeHistory.length; i++) {
      if (gazeHistory[i].direction == gazeHistory[i - 1].direction &&
          gazeHistory[i].direction != GazeDirection.unknown) {
        currentStreak++;
      } else {
        streakLengths.add(currentStreak);
        currentStreak = 1;
      }
    }
    streakLengths.add(currentStreak);
    final avgStreak = streakLengths.isEmpty
        ? 0.0
        : streakLengths.reduce((a, b) => a + b) / streakLengths.length;
    final avgFixation = avgStreak / estimatedFps;

    // Saccade velocity proxy from head yaw deltas.
    final yawDeltas = <double>[];
    for (var i = 1; i < gazeHistory.length; i++) {
      yawDeltas.add(
        (gazeHistory[i].headYaw - gazeHistory[i - 1].headYaw).abs(),
      );
    }
    final avgSaccadeVel = yawDeltas.isEmpty
        ? 0.0
        : yawDeltas.reduce((a, b) => a + b) / yawDeltas.length;

    // Saccade accuracy proxy (higher confidence -> higher accuracy).
    final saccadeAccuracy = (avgConfidence * 100).clamp(0.0, 100.0);

    // Gaze-following proxy: center gaze with adequate confidence.
    final followFrames = gazeHistory
        .where((g) => g.direction == GazeDirection.center && g.confidence >= 0.65)
        .length;
    final gazeFollowing = (followFrames / total) * 100;

    // Response latency proxy: time to first center fixation.
    double gazeLatency = 0.0;
    final firstCenterIndex = gazeHistory.indexWhere(
      (g) => g.direction == GazeDirection.center,
    );
    if (firstCenterIndex > 0) {
      gazeLatency = firstCenterIndex / estimatedFps;
    }

    // AOI proxies from direction buckets.
    final aoiEyesPct = centerPct;
    final aoiMouthPct = ((leftPct + rightPct) / 2).clamp(0.0, 100.0);

    return {
      'gaze_following': gazeFollowing,
      'social_preference': socialPreference,
      'avg_fixation': avgFixation,
      'avg_saccade_vel': avgSaccadeVel,
      'saccade_accuracy': saccadeAccuracy,
      'aoi_eyes_pct': aoiEyesPct,
      'aoi_mouth_pct': aoiMouthPct,
      'gaze_latency': gazeLatency,
      'pupil_dynamic': avgConfidence,
      'total_frames': total,
      'direction_distribution': {
        'center': centerPct,
        'left': leftPct,
        'right': rightPct,
        'unknown': (unknownCount / total) * 100,
      },
    };
  }

  GazeStatistics? getGazeStatistics() {
    if (gazeHistory.isEmpty) return null;

    return GazeStatistics(
      startTime: gazeHistory.first.timestamp,
      endTime: gazeHistory.last.timestamp,
      gazePoints: gazeHistory.toList(),
    );
  }

  @override
  Future<void> onClose() async {
    try {
      // Stop image stream first
      await _stopGazeDetectionStream();

      // Then dispose camera
      if (isCameraReady.value) {
        await cameraController.dispose();
        isCameraReady.value = false;
      }

      // Finally dispose gaze detection service
      await gazeDetectionService.dispose();
      
      print('GazeTrackingController disposed successfully');
    } catch (e) {
      print('Error during GazeTrackingController disposal: $e');
    }
    super.onClose();
  }

  Future<void> refreshHomeMetricsIfAvailable() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().refreshMetrics();
    }
  }
}

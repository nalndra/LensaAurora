import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/models/gaze_data.dart';
import 'package:lensaaurora/app/services/gaze_detection_service.dart';

enum TestState { idle, running, completed, aborted }

class GazeTrackingController extends GetxController {
  late CameraController cameraController;
  late CameraDescription frontCamera;
  late GazeDetectionService gazeDetectionService;
  bool _isStreamRunning = false;

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

      // Start image stream for gaze detection
      await _startGazeDetectionStream();
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
              // Calculate FPS
              _updateFPS();
            }
          }
        } catch (e) {
          debugPrint('[🎥 GazeTrackingController] Error processing frame: $e');
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
    // Simple FPS calculation (can be improved)
    if (gazeHistory.length > 0) {
      final timeDiff = gazeHistory.last.timestamp.difference(gazeHistory.first.timestamp).inMilliseconds;
      if (timeDiff > 0) {
        gazeFPS.value = ((gazeHistory.length / timeDiff) * 1000).toInt();
      }
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
      currentGaze.value = null;
      
      // Ensure image stream is running before starting test
      if (!_isStreamRunning) {
        print('Starting image stream before test...');
        await _startGazeDetectionStream();
        await Future.delayed(const Duration(milliseconds: 300)); // Brief delay to let stream stabilize
      }
      
      testState.value = TestState.running;
      print('Gaze test started');

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
    await _stopGazeDetectionStream();
    testState.value = TestState.completed;
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
}

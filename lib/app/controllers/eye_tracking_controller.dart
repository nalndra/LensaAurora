import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'dart:math';
import '../services/gaze_tracking_service.dart';

/// Eye Tracking Controller with GetX
class EyeTrackingController extends GetxController {
  final metricsEngine = ASDMetricsEngine();

  // Observables
  var isTracking = false.obs;
  var currentReport = Rxn<Map<String, dynamic>>();
  var debugInfo = "Initializing...".obs;
  var gazePoints = <Map<String, double>>[].obs;
  var stimulusPosition = Rxn<Map<String, double>>();

  // Camera
  late CameraController cameraController;
  late FaceDetector faceDetector;

  // Stimulus animation
  late Stopwatch stimulusStopwatch;
  double videoWidth = 0;
  double videoHeight = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
      ),
    );
    stimulusStopwatch = Stopwatch();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[0], // Front camera
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await cameraController.initialize();

        videoWidth = cameraController.value.previewSize?.width ?? 480;
        videoHeight = cameraController.value.previewSize?.height ?? 640;

        debugInfo.value = "Camera initialized. Tap START to begin tracking.";
      }
    } catch (e) {
      debugInfo.value = "Camera Error: $e";
    }
  }

  void startTracking() {
    isTracking.value = true;
    metricsEngine.totalFrames = 0;
    debugInfo.value = "Eye tracking started...";
    stimulusStopwatch.start();
    _startProcessingFrames();
  }

  void stopTracking() {
    isTracking.value = false;
    stimulusStopwatch.stop();
    debugInfo.value = "Tracking stopped. Processing results...";
    _generateFinalReport();
  }

  Future<void> _startProcessingFrames() async {
    if (!isTracking.value) return;

    try {
      final image = await cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final geometry = extractFaceGeometry(face, videoWidth, videoHeight);

        // Approximate gaze center (iris) - simplified
        // In production, use MediaPipe or advanced face mesh for precise iris detection
        Map<String, double> gazePos = _estimateGazePosition(face, geometry);

        // Update stimulus position (circular motion)
        Map<String, double> stim = _updateStimulusPosition();
        stimulusPosition.value = stim;

        // Update metrics engine
        metricsEngine.update(gazePos, geometry, videoWidth, videoHeight,
            stimulusPos: stim);

        // Update gaze history for visualization
        if (gazePoints.length > 50) {
          gazePoints.removeAt(0);
        }
        gazePoints.add(gazePos);

        // Update report every 30 frames
        if (metricsEngine.totalFrames % 30 == 0) {
          currentReport.value = metricsEngine.getReport();
          debugInfo.value =
              "Frames: ${metricsEngine.totalFrames} | Social Pref: ${currentReport.value!['social_preference'].toStringAsFixed(1)}%";
        }
      } else {
        debugInfo.value = "No face detected";
      }


      // Process next frame
      if (isTracking.value) {
        Future.delayed(Duration(milliseconds: 50), _startProcessingFrames);
      }
    } catch (e) {
      debugInfo.value = "Processing Error: $e";
    }
  }

  /// Estimate gaze position from face landmarks
  Map<String, double> _estimateGazePosition(
    Face face,
    FaceGeometry geometry,
  ) {
    // Simplified: Use face bounding box center as gaze estimate
    // For accurate eye tracking, you would:
    // 1. Use MediaPipe Face Mesh for 468 landmarks
    // 2. Calculate iris center from iris landmarks
    // 3. Perform gaze direction calculation

    // For now, use approximate eye region
    double gazeX =
        (face.boundingBox.left + face.boundingBox.right) / 2;
    double gazeY = (face.boundingBox.top +
            (face.boundingBox.bottom - face.boundingBox.top) * 0.35) //
        .toDouble();

    return {'x': gazeX, 'y': gazeY};
  }

  /// Update stimulus position (circular motion)
  Map<String, double> _updateStimulusPosition() {
    final t = stimulusStopwatch.elapsedMilliseconds / 1000.0;

    double stimX = videoWidth / 2 + cos(t) * (videoWidth / 3);
    double stimY = videoHeight / 2 + sin(t * 0.5) * (videoHeight / 4);

    return {'x': stimX, 'y': stimY};
  }

  void _generateFinalReport() {
    final finalReport = metricsEngine.getReport();
    currentReport.value = finalReport;

    // Diagnostic summary
    String diagnosis = "";
    if (finalReport['social_preference'] < 40) {
      diagnosis += "⚠️ LOW SOCIAL PREFERENCE\n";
    }
    if (finalReport['avg_fixation'] < 0.25) {
      diagnosis += "⚠️ LOW FIXATION STABILITY\n";
    }
    if (finalReport['gaze_following'] < 70) {
      diagnosis += "⚠️ REDUCED GAZE FOLLOWING\n";
    }
    if (diagnosis.isEmpty) {
      diagnosis = "✅ Results within normal range";
    }

    debugInfo.value = diagnosis;
  }

  @override
  void onClose() {
    cameraController.dispose();
    faceDetector.close();
    super.onClose();
  }
}

import 'dart:ui' show Size;
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lensaaurora/app/models/gaze_data.dart';

class GazeDetectionService {
  late FaceDetector _faceDetector;
  bool _isInitialized = false;
  static const String tag = '[GazeDetectionService]';

  GazeDetectionService() {
    _initializeFaceDetector();
  }

  void _log(String message) {
    final msg = '$tag $message';
    print(msg);
    debugPrint(msg);
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: false, // Disable for now
      enableTracking: true,
      minFaceSize: 0.08,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
    _isInitialized = true;
    _log('✅ Face detector initialized');
  }

  /// Detect faces and estimate gaze from CameraImage
  Future<List<GazeData>?> detectGazeFromImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) async {
    try {
      if (!_isInitialized) {
        _initializeFaceDetector();
      }

      final inputImage = _buildInputImage(cameraImage, camera);
      if (inputImage == null) {
        _log('❌ Failed to build InputImage');
        return null;
      }

      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        // Silently return null - don't spam logs
        return null;
      }

      _log('✅ DETECTED ${faces.length} face(s)');

      // Process each detected face
      final gazeDataList = <GazeData>[];
      for (var face in faces) {
        final gazeData = _estimateGaze(face);
        if (gazeData != null) {
          gazeDataList.add(gazeData);
        }
      }

      if (gazeDataList.isEmpty) {
        _log('⚠️ Gaze estimation failed for all faces');
        return null;
      }
      
      return gazeDataList;
    } catch (e) {
      _log('❌ Error in gaze detection: $e');
      return null;
    }
  }

  /// Build InputImage from CameraImage
  InputImage? _buildInputImage(CameraImage cameraImage, CameraDescription camera) {
    try {
      final planes = cameraImage.planes;
      if (planes.isEmpty) {
        _log('❌ No image planes found');
        return null;
      }
      final buffer = WriteBuffer();

      for (Plane plane in planes) {
        buffer.putUint8List(plane.bytes);
      }

      final bytes = buffer.done().buffer.asUint8List();
      _log('📷 Image bytes: ${bytes.length}, Planes: ${planes.length}, Format: ${cameraImage.format}');

      final imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );
      
      _log('📏 Size: ${imageSize.width}x${imageSize.height}');

      final inputImageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final inputImageFormat =
          InputImageFormatValue.fromRawValue(cameraImage.format.raw) ?? InputImageFormat.nv21;
      _log('🔄 Rotation: ${camera.sensorOrientation}');

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: inputImageRotation,
          format: inputImageFormat,
          bytesPerRow: planes.first.bytesPerRow,
        ),
      );
      
      _log('✅ InputImage created successfully');
      return inputImage;
    } catch (e) {
      _log('❌ Error building InputImage: $e');
      return null;
    }
  }

  /// Estimate gaze direction from Face object
  GazeData? _estimateGaze(Face face) {
    try {
      // Get head pose angles (approximation of gaze direction)
      final headYaw = face.headEulerAngleY ?? 0.0; // left/right
      final headPitch = face.headEulerAngleX ?? 0.0; // up/down
      final headRoll = face.headEulerAngleZ ?? 0.0; // tilt

      // Determine gaze direction based on head yaw
      // This is a simplified MVP approach
      GazeDirection direction = GazeDirection.unknown;
      double confidence = 0.0;

      if (headYaw.abs() < 15) {
        // Looking relatively straight (center)
        direction = GazeDirection.center;
        confidence = 1.0 - (headYaw.abs() / 15);
      } else if (headYaw > 15) {
        // Looking right
        direction = GazeDirection.right;
        confidence = 1.0 - ((headYaw - 15) / 60).clamp(0.0, 1.0);
      } else {
        // Looking left
        direction = GazeDirection.left;
        confidence = 1.0 - ((headYaw.abs() - 15) / 60).clamp(0.0, 1.0);
      }

      // Ensure confidence is between 0 and 1
      confidence = confidence.clamp(0.0, 1.0);

      return GazeData(
        timestamp: DateTime.now(),
        direction: direction,
        confidence: confidence,
        headPitch: headPitch,
        headYaw: headYaw,
        headRoll: headRoll,
      );
    } catch (e) {
      print('Error estimating gaze: $e');
      return null;
    }
  }

  /// Cleanup
  Future<void> dispose() async {
    await _faceDetector.close();
    _isInitialized = false;
  }
}

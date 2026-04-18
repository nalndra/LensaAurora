import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
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
      enableLandmarks: false, // Disable for now - may improve detection
      enableClassification: false, // Disable for now
      enableTracking: true,
      minFaceSize: 0.01, // Make very small to detect faces at any distance
      performanceMode: FaceDetectorMode.fast, // Use fast mode
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
      final buffer = BytesBuilder();

      for (Plane plane in planes) {
        buffer.add(plane.bytes);
      }

      final bytes = buffer.toBytes();
      _log('📷 Image bytes: ${bytes.length}, Planes: ${planes.length}, Format: ${cameraImage.format}');

      final imageSize = ui.Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );
      
      _log('📏 Size: ${imageSize.width}x${imageSize.height}');

      final camera0Rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      _log('🔄 Rotation: ${camera.sensorOrientation}');

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: InputImageRotation.rotation0deg, // Try without rotation first
          format: InputImageFormat.yuv420, // Try yuv420 instead of nv21
          bytesPerRow: cameraImage.planes[0].bytesPerRow,
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

      // Get eye landmarks if available
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];

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

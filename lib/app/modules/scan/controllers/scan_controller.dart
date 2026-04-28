import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';

class ScanController extends GetxController {
  final scannedImage = Rxn<File>();
  final scanHistory = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadScanHistory();
  }

  void _loadScanHistory() {
    // Dummy scan history
    scanHistory.addAll([
      {
        'id': '1',
        'title': 'Document Scan',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'type': 'document',
        'icon': '📄',
      },
      {
        'id': '2',
        'title': 'Receipt Scan',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'type': 'receipt',
        'icon': '🧾',
      },
      {
        'id': '3',
        'title': 'QR Code Scan',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'type': 'qrcode',
        'icon': '📱',
      },
    ]);
  }

  Future<void> captureFromCamera() async {
    try {
      isLoading.value = true;

      // Camera not supported on Windows
      if (Platform.isWindows) {
        Get.snackbar('Not Supported', 'Camera capture is not supported on Windows. Please use gallery instead.');
        isLoading.value = false;
        return;
      }

      // Request camera permission explicitly (mobile only)
      final PermissionStatus cameraStatus = await Permission.camera.request();

      if (cameraStatus.isDenied) {
        // Permission denied
        Get.snackbar('Permission Denied', 'Camera access is required to capture photos');
        isLoading.value = false;
        return;
      } else if (cameraStatus.isPermanentlyDenied) {
        // Permission permanently denied, open app settings
        Get.snackbar(
          'Permission Required',
          'Camera access is permanently denied. Please enable it in app settings.',
          mainButton: TextButton(
            onPressed: openAppSettings,
            child: const Text('Open Settings'),
          ),
        );
        isLoading.value = false;
        return;
      }

      // Permission granted, open camera
      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        scannedImage.value = File(photo.path);
        _addToHistory('Camera Capture', 'camera');
        Get.snackbar('Success', 'Image captured successfully!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFromGallery() async {
    try {
      isLoading.value = true;

      // Skip permission check on Windows
      if (!Platform.isWindows) {
        // Request storage permission (mobile only)
        final PermissionStatus storageStatus = await Permission.photos.request();

        if (storageStatus.isDenied) {
          Get.snackbar('Permission Denied', 'Storage access is required to pick photos');
          isLoading.value = false;
          return;
        } else if (storageStatus.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Storage access is permanently denied. Please enable it in app settings.',
            mainButton: TextButton(
              onPressed: openAppSettings,
              child: const Text('Open Settings'),
            ),
          );
          isLoading.value = false;
          return;
        }
      }

      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null) {
        scannedImage.value = File(photo.path);
        _addToHistory('Gallery Pick', 'gallery');
        Get.snackbar('Success', 'Image selected successfully!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _addToHistory(String title, String type) {
    scanHistory.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'date': DateTime.now(),
      'type': type,
      'icon': type == 'camera' ? '📷' : '🖼️',
    });
  }

  void clearScannedImage() {
    scannedImage.value = null;
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().syncIndex(1);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

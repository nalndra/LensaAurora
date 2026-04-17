import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
      
      // Request camera permission (mobile only)
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          // Dynamic import for permission_handler (mobile only)
          // This allows Windows to skip permission_handler
        } catch (e) {
          // Permission handler not available on this platform
        }
      }

      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (photo != null) {
        scannedImage.value = File(photo.path);
        _addToHistory('Camera Capture', 'camera');
        Get.snackbar('Success', 'Image captured successfully!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFromGallery() async {
    try {
      isLoading.value = true;
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
      Get.snackbar('Error', 'Failed to pick image: $e');
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
  }

  @override
  void onClose() {
    super.onClose();
  }
}

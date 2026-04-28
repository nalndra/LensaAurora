# 🧠 Eye Tracking Integration Guide - Lensa Aurora

## Ringkasan
Implementasi computer vision eye-tracking untuk ASD diagnostic menggunakan **Dart** (bukan Python langsung di mobile).

---

## 📋 Alternatif Implementasi

### ✅ **Opsi 1: Pure Dart (RECOMMENDED)**
- ✨ **Kelebihan**: Tanpa perlu server, berjalan native di mobile
- 📱 **Performance**: Fast & efficient  
- 🔌 **Dependencies**: google_mlkit_face_detection + image package
- ⚡ **Status**: Sudah diimplementasi di `lib/app/`

### 🔗 **Opsi 2: Backend FastAPI Server**
- 📡 **Cocok untuk**: Processing complex, high-accuracy gaze tracking
- 🖥️ **Contoh**: Python script → FastAPI server → Flutter HTTP calls
- ⏱️ **Latency**: ~200-500ms (tergantung network)

### 🔧 **Opsi 3: Native Android/iOS**
- 🎯 **Akurasi**: Tertinggi menggunakan native APIs
- 📚 **Kompleksitas**: Tinggi, perlu Kotlin + Swift

---

## 📦 Setup Langkah demi Langkah

### **Step 1: Update pubspec.yaml**
Sudah dilakukan. Verify dengan:
```bash
cd c:\Codes\Mobile\lensaaurora
flutter pub get
```

### **Step 2: Setup File Structure**
```
lib/app/
├── services/
│   └── gaze_tracking_service.dart        ✅ CREATED
├── controllers/
│   └── eye_tracking_controller.dart      ✅ CREATED
└── modules/
    └── eye_tracking/
        └── eye_tracking_scan_view.dart   ✅ CREATED
```

### **Step 3: Add Permissions** (Android + iOS)

#### **Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

#### **iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Dibutuhkan untuk eye tracking diagnostic ASD</string>
```

---

## 🚀 Cara Menggunakan di App

### **1. Buka Screen Eye Tracking**
```dart
// Di mana pun Anda ingin menampilkan scan
import 'package:lensaaurora/app/modules/eye_tracking/eye_tracking_scan_view.dart';

// Navigasi
Get.to(() => const EyeTrackingScanView());
```

### **2. Dari Routes** (Recommended)
Edit `lib/app/routes/app_pages.dart`:
```dart
import 'package:lensaaurora/app/modules/eye_tracking/eye_tracking_scan_view.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // ... existing routes
    GetPage(
      name: Routes.EYE_TRACKING,
      page: () => const EyeTrackingScanView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EyeTrackingController>(
          () => EyeTrackingController(),
        );
      }),
    ),
  ];
}
```

Edit `lib/app/routes/app_routes.dart`:
```dart
abstract class Routes {
  static const SPLASH = _Paths.SPLASH;
  static const EYE_TRACKING = _Paths.EYE_TRACKING;
  // ... existing routes
}

abstract class _Paths {
  static const SPLASH = '/splash';
  static const EYE_TRACKING = '/eye-tracking';
  // ... existing paths
}
```

### **3. Dari Scan Feature Existing**
Jika sudah ada scan module:
```dart
// Di dalam scan_controller.dart
void startEyeTracking() {
  Get.to(() => const EyeTrackingScanView());
}
```

---

## 📊 Metrik yang Dilacak

| Metrik | Deskripsi | Nilai Normal | ASD Indikator |
|--------|-----------|-------------|---------------|
| **Fixation Duration** | Durasi mata fokus | > 0.4s | < 0.3s = reduced attention |
| **Social Preference** | % waktu ke wajah | > 60% | < 40% = reduced social interest |
| **Eye Attention** | Fokus ke mata | > 30% | < 20% = poor eye contact |
| **Mouth Attention** | Fokus ke mulut | 10-20% | > 30% = verbal focus only |
| **Saccade Velocity** | Kecepatan mata bergerak | 10-15 px/f | Abnormal = >20 atau <5 |
| **Gaze Following** | Mengikuti stimulus | > 75% | < 50% = poor joint attention |
| **Response Latency** | Waktu respon | < 0.5s | > 1.0s = delayed response |
| **Pupil Reactivity** | Perubahan pupil | 0.05-0.15 | Flat = cognitive issues |

---

## 💻 Testing Lokal

### **Run di Emulator/Device**
```bash
flutter run
```

### **Build APK** (Android)
```bash
flutter build apk --release
```

### **Build IPA** (iOS)
```bash
flutter build ipa --release
```

---

## 🔧 Customization & Advanced

### **A. Tingkatkan Akurasi Iris Detection**
Saat ini menggunakan **Face Bounding Box**. Untuk iris yang presisi:

**Opsi**: Install MediaPipe Flutter plugin (jika tersedia):
```yaml
dependencies:
  google_mlkit_face_detection: ^0.10.0
  # Upcoming: mediapipe_face_mesh atau google_mlkit_commons
```

### **B. Tambahkan Backend Processing**
Jika ingin Python script tetap digunakan:

**Setup FastAPI Server**:
```python
# backend/server.py
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import cv2
import mediapipe as mp
import numpy as np
from detect_realtime import ASDMetricsEngine

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

engine = ASDMetricsEngine()

@app.post("/process-frame")
async def process_frame(file: UploadFile = File(...)):
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    # Process dengan Python code
    # ...
    
    return {"metrics": engine.get_report()}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

**Flutter HTTP Call**:
```dart
// Di eye_tracking_controller.dart
Future<void> processFrameOnServer(String imagePath) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.x.x:8000/process-frame'),
  );
  request.files.add(await http.MultipartFile.fromPath('file', imagePath));
  
  final response = await request.send();
  if (response.statusCode == 200) {
    final result = jsonDecode(await response.stream.bytesToString());
    currentReport.value = result['metrics'];
  }
}
```

### **C. Buat Result Report Screen**
```dart
class DiagnosticReportView extends StatelessWidget {
  final Map<String, dynamic> metrics;
  
  const DiagnosticReportView({required this.metrics});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ASD Diagnostic Report')),
      body: ListView(
        children: [
          _buildMetricCard('Social Preference', metrics['social_preference']),
          _buildMetricCard('Fixation Stability', metrics['avg_fixation']),
          _buildRecommendations(metrics),
        ],
      ),
    );
  }
}
```

---

## 🐛 Troubleshooting

| Issue | Solusi |
|-------|--------|
| Camera permission denied | Check AndroidManifest.xml & Info.plist + request runtime permissions |
| "No face detected" | Pastikan pencahayaan cukup, wajah visible di frame |
| Low FPS / Lag | Reduce frame processing rate atau gunakan lower resolution |
| Inaccurate gaze | Limitation dari face bounding box. Need MediaPipe FaceMesh |

---

## 📝 Next Steps

1. **Install packages**: `flutter pub get`
2. **Test di device**: `flutter run`
3. **Refine gaze detection** menggunakan MediaPipe (jika available di pub.dev)
4. **Add data persistence**: Simpan hasil ke Firestore
5. **Create result dashboard**: Visualisasi trends + history

---

## 🎯 Perbandingan: Python vs Dart Implementation

```
┌─────────────────────────┬──────────────────┬──────────────────┐
│ Aspek                   │ Python (Backend) │ Dart (Native)    │
├─────────────────────────┼──────────────────┼──────────────────┤
│ Complexity              │ Medium           │ High (MediaPipe) │
│ Latency                 │ 200-500ms        │ 50-150ms         │
│ Cost                    │ Server needed    │ None             │
│ Accuracy                │ High             │ Medium           │
│ Mobile Performance      │ Good             │ Excellent        │
│ Development Time        │ Fast             │ Moderate         │
└─────────────────────────┴──────────────────┴──────────────────┘
```

**Rekomendasi**: Mulai dengan **Dart Pure** untuk MVP, upgrade ke **Backend** jika butuh akurasi lebih tinggi.

---

## 📚 Resources

- [Google ML Kit Face Detection](https://pub.dev/packages/google_mlkit_face_detection)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [MediaPipe Docs](https://mediapipe.dev/)
- [GetX State Management](https://pub.dev/packages/get)


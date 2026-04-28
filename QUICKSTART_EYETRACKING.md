# 🚀 QUICK START - Eye Tracking Integration

## Langkah 1: Install Dependencies
```bash
cd c:\Codes\Mobile\lensaaurora
flutter pub get
```

## Langkah 2: Verify File Structure
Pastikan file ini sudah ada:
```
lib/app/
├── services/
│   └── gaze_tracking_service.dart        ✅ NEW - ASD Metrics Engine
├── controllers/
│   └── eye_tracking_controller.dart      ✅ NEW - Eye Tracking Logic
└── modules/
    └── eye_tracking/
        ├── bindings.dart                 ✅ NEW
        └── eye_tracking_scan_view.dart   ✅ NEW - UI Screen
```

## Langkah 3: Run App
```bash
flutter run
```

## Langkah 4: Navigate to Eye Tracking
Gunakan GetX route:
```dart
Get.toNamed(Routes.GAZE_TRACKING);
```

Atau direct navigate:
```dart
Get.to(() => const EyeTrackingScanView());
```

---

## 📱 Testing Flow

### Step 1: Tap "START" Button
- Kamera akan aktif
- Stimulus (white dot) akan mulai bergerak secara circular
- Dashboard akan menampilkan metrics real-time

### Step 2: Ikuti Stimulus
- Arahkan mata Anda ke white dot yang bergerak
- Sistem akan mencatat:
  - Fixation duration
  - Social preference (% waktu mata ke wajah)
  - Eye vs mouth focus
  - Gaze following success rate

### Step 3: Tap "STOP" Button
- Sistem akan generate final report
- Diagnostic summary akan ditampilkan
- Warna metrics:
  - 🟢 **Green**: Normal/Expected
  - 🟠 **Orange**: Reduced/Below threshold

### Step 4: Review Results
```
Contoh Output:
✅ Results within normal range
atau
⚠️ LOW SOCIAL PREFERENCE
⚠️ REDUCED GAZE FOLLOWING
```

---

## 🔧 Troubleshooting

### ❌ "Camera permission denied"
**Solusi**: 
```bash
# Windows: Izinkan app akses kamera di Settings > Privacy
# Android: Grant permission di app settings
# iOS: Check Info.plist NSCameraUsageDescription
```

### ❌ "No face detected"
**Solusi**:
- Pastikan pencahayaan cukup
- Wajah harus jelas di frame
- Distance: 20-50cm dari kamera

### ❌ Compilation Error
**Solusi**:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 💡 Integration Tips

### Integrate dengan Existing Scan Module
```dart
// Di scan_controller.dart
void startEyeTracking() {
  Get.toNamed(Routes.GAZE_TRACKING);
}
```

### Save Results to Firestore
```dart
// Di eye_tracking_controller.dart - tambahkan:
Future<void> saveResults() async {
  final report = metricsEngine.getReport();
  await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('eye_tracking_results')
    .add({
      'timestamp': DateTime.now(),
      'metrics': report,
      'duration': metricsEngine.totalFrames,
    });
}
```

### Custom Stimulus Position
```dart
// Customize stimulus motion
Map<String, double> _updateStimulusPosition() {
  final t = stimulusStopwatch.elapsedMilliseconds / 1000.0;
  
  // Figure-8 pattern
  double stimX = videoWidth / 2 + cos(t) * (videoWidth / 3);
  double stimY = videoHeight / 2 + sin(2 * t) * (videoHeight / 4);
  
  return {'x': stimX, 'y': stimY};
}
```

---

## 📊 Metrics Explanation

| Metrik | Arti |
|--------|------|
| **Fixation Duration** | Durasi mata fokus pada satu titik (detik) |
| **Social Preference** | % waktu menonton wajah vs background |
| **Eye Attention** | Fokus ke mata (indicator of eye contact) |
| **Mouth Attention** | Fokus ke mulut (alternative focus area) |
| **Gaze Following** | % keberhasilan mengikuti stimulus target |
| **Response Latency** | Waktu untuk merespon target baru |
| **Pupil Reactivity** | Perubahan ukuran pupil (stress/emotion indicator) |

---

## 🎯 Optimization untuk ASD Screening

### Enhance Accuracy:
1. **Increase sampling rate**: Reduce frame skip interval
2. **Multiple stimuli**: Test berbagai posisi & speed
3. **Environmental control**: Consistent lighting
4. **Session duration**: Min 60-90 seconds untuk valid data

### Add to Diagnostic Report:
```dart
String generateDiagnosis(Map<String, dynamic> metrics) {
  List<String> findings = [];
  
  if (metrics['social_preference'] < 40) {
    findings.add('Reduced social attention');
  }
  if (metrics['gaze_following'] < 70) {
    findings.add('Impaired joint attention');
  }
  if (metrics['avg_fixation'] < 0.25) {
    findings.add('Unstable fixations');
  }
  
  return findings.isEmpty 
    ? 'Within normal range' 
    : findings.join('\n');
}
```

---

## 📝 Next Steps

1. ✅ Run & test eye tracking screen
2. ✅ Adjust thresholds based on user testing
3. ⏳ Integrate with existing scan workflow
4. ⏳ Add Firestore persistence
5. ⏳ Create analytics dashboard
6. ⏳ Build multi-test protocol (sequential tests)

---

## 🔗 Related Documentation
- [IMPLEMENTATION_GUIDE_EYETRACKING.md](../IMPLEMENTATION_GUIDE_EYETRACKING.md)
- [Google ML Kit Face Detection](https://pub.dev/packages/google_mlkit_face_detection)
- [GetX Routes Documentation](https://pub.dev/packages/get)


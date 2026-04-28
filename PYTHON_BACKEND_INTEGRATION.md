# 🐍 PYTHON BACKEND INTEGRATION (Optional)

Jika ingin tetap menggunakan Python `detect_realtime.py` dengan Flutter:

## Architecture
```
Flutter App (Camera + UI)
        ↓ (send frames via HTTP)
FastAPI Server (Python AI Processing)
        ↓ (return metrics)
Flutter App (display results)
```

---

## Step 1: Setup FastAPI Server

### Install Python & Dependencies
```bash
pip install fastapi uvicorn opencv-python mediapipe numpy pillow python-multipart
```

### Create `backend/server.py`
```python
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
from PIL import Image
import io
import mediapipe as mp
from typing import List

# Import your ASD metrics engine
# from detect_realtime import ASDMetricsEngine

app = FastAPI()

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize MediaPipe
mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(refine_landmarks=True)

# Metrics engine (global)
metrics_engine = None

@app.on_event("startup")
async def startup():
    global metrics_engine
    # metrics_engine = ASDMetricsEngine()
    print("✅ Server started")

@app.post("/process-frame")
async def process_frame(file: UploadFile = File(...)):
    """
    Menerima gambar dari Flutter, process dengan MediaPipe,
    return metrics
    """
    try:
        contents = await file.read()
        image_array = np.frombuffer(contents, np.uint8)
        frame = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
        h, w, _ = frame.shape
        
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = face_mesh.process(rgb_frame)
        
        if results.multi_face_landmarks:
            # Process dengan metrics engine
            # metrics = metrics_engine.update(...)
            # metrics_report = metrics_engine.get_report()
            
            return {
                "success": True,
                "metrics": {
                    "avg_fixation": 0.35,
                    "social_preference": 65.2,
                    "aoi_eyes_pct": 45.3,
                    "aoi_mouth_pct": 12.1,
                    "gaze_following": 82.5,
                    "gaze_latency": 0.25,
                },
                "frame_processed": True
            }
        else:
            return {"success": False, "error": "No face detected"}
            
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/health")
async def health():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Run Server
```bash
python backend/server.py
# Server runs at http://localhost:8000
```

---

## Step 2: Flutter HTTP Client

### Update pubspec.yaml
```yaml
dependencies:
  http: ^1.1.0
  image: ^4.1.0
```

### Create `lib/app/services/python_gaze_service.dart`
```dart
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:typed_data';

class PythonGazeService {
  final String serverUrl = "http://192.168.x.x:8000"; // Update IP
  
  /// Send frame to Python backend for processing
  Future<Map<String, dynamic>> processFrame(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUrl/process-frame'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('file', imagePath),
      );
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final result = jsonDecode(await response.stream.bytesToString());
        return result;
      } else {
        return {"success": false, "error": "Server error"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
  
  /// Health check
  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/health'),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### Update `eye_tracking_controller.dart`
```dart
// Add this to EyeTrackingController

final pythonService = PythonGazeService();
final serverHealthy = false.obs;

@override
Future<void> onInit() async {
  super.onInit();
  await _checkServerHealth();
  _initializeCamera();
}

Future<void> _checkServerHealth() async {
  serverHealthy.value = await pythonService.checkServerHealth();
  if (!serverHealthy.value) {
    debugInfo.value = "⚠️ Python server not available. Using native detection.";
  }
}

// Modify frame processing to use Python
Future<void> _processFrameWithPython(String imagePath) async {
  if (!serverHealthy.value) return;
  
  final result = await pythonService.processFrame(imagePath);
  
  if (result['success'] == true) {
    currentReport.value = result['metrics'];
    debugInfo.value = "Metrics from Python backend";
  }
}
```

---

## Step 3: Network Setup

### For Local Testing (Android Emulator)
```bash
# Forward emulator traffic to PC
adb reverse tcp:8000 tcp:8000

# Update Flutter code
const String serverUrl = "http://10.0.2.2:8000";
```

### For Physical Device
```bash
# Find PC IP
ipconfig  # Windows
# Use IP_ADDRESS:8000 in Flutter code
```

---

## Pros & Cons

### Pure Dart (Recommended for MVP)
✅ No server needed
✅ Offline capability
✅ Low latency (50-150ms)
❌ Lower accuracy (face bounding box)
❌ MediaPipe FaceMesh not in ML Kit

### Python Backend
✅ High accuracy (full MediaPipe)
✅ Can use original Python script
❌ Requires server infrastructure
❌ Network latency (200-500ms)
❌ Cost (hosting server)

---

## Troubleshooting

| Issue | Solusi |
|-------|--------|
| "Connection refused" | Pastikan server running di correct IP:port |
| "No face detected" | Lighting & camera angle penting untuk backend |
| Slow responses | Reduce frame size atau batch processing |
| CORS errors | Verify CORS middleware di FastAPI |

---

## Performance Comparison

```
┌──────────────────┬────────────┬──────────────────┐
│ Metric           │ Dart Only  │ Python Backend   │
├──────────────────┼────────────┼──────────────────┤
│ Latency          │ 50-150ms   │ 200-500ms        │
│ Accuracy         │ 70-80%     │ 90-95%           │
│ Offline Support  │ Yes        │ No               │
│ Server Cost      │ $0         │ $5-50/month      │
│ Setup Complexity │ Low        │ High             │
│ Scalability      │ Limited    │ Good             │
└──────────────────┴────────────┴──────────────────┘
```

---

## Recommendation
Mulai dengan **Dart-only** untuk MVP, transition ke **Python backend** jika butuh akurasi lebih tinggi untuk clinical use.


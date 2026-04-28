import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'dart:math';
import '../../controllers/eye_tracking_controller.dart';

class EyeTrackingScanView extends StatefulWidget {
  const EyeTrackingScanView({Key? key}) : super(key: key);

  @override
  State<EyeTrackingScanView> createState() => _EyeTrackingScanViewState();
}

class _EyeTrackingScanViewState extends State<EyeTrackingScanView> {
  late EyeTrackingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EyeTrackingController());
  }

  @override
  void dispose() {
    Get.delete<EyeTrackingController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Tracking ASD Diagnostic'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GetBuilder<EyeTrackingController>(
        builder: (_) => Stack(
          children: [
            // Camera Preview
            CameraPreview(controller.cameraController),

            // Gaze Visualization Overlay
            _buildGazeOverlay(context),

            // Stimulus Dot
            Obx(
              () {
                if (controller.stimulusPosition.value == null) {
                  return SizedBox.expand();
                }
                final stim = controller.stimulusPosition.value!;
                return Positioned(
                  left: stim['x']! - 10,
                  top: stim['y']! - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'FOLLOW',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Metrics Dashboard
            _buildMetricsDashboard(),

            // Controls
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildGazeOverlay(BuildContext context) {
    return Obx(
      () {
        final gazePoints = controller.gazePoints;
        if (gazePoints.isEmpty) {
          return SizedBox.expand();
        }

        return CustomPaint(
          painter: GazePathPainter(gazePoints),
          child: SizedBox.expand(),
        );
      },
    );
  }

  Widget _buildMetricsDashboard() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        child: Obx(
          () {
            final report = controller.currentReport.value;
            if (report == null) {
              return const Text(
                'Initializing...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEURO-DIAGNOSTIC METRICS',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Divider(color: Colors.cyan, height: 8),
                _metricRow(
                  'Fixation Duration',
                  '${report['avg_fixation'].toStringAsFixed(2)}s',
                  report['avg_fixation'] > 0.4,
                ),
                _metricRow(
                  'Social Preference',
                  '${report['social_preference'].toStringAsFixed(1)}%',
                  report['social_preference'] > 60,
                ),
                _metricRow(
                  'Eye Attention',
                  '${report['aoi_eyes_pct'].toStringAsFixed(1)}%',
                  report['aoi_eyes_pct'] > 30,
                ),
                _metricRow(
                  'Mouth Attention',
                  '${report['aoi_mouth_pct'].toStringAsFixed(1)}%',
                  report['aoi_mouth_pct'] > 10,
                ),
                _metricRow(
                  'Saccade Velocity',
                  '${report['avg_saccade_vel'].toStringAsFixed(1)}px/f',
                  true,
                ),
                _metricRow(
                  'Saccade Accuracy',
                  '${max(0, 100 - report['saccade_accuracy'] / 2).toStringAsFixed(1)}%',
                  true,
                ),
                _metricRow(
                  'Gaze Following',
                  '${report['gaze_following'].toStringAsFixed(1)}%',
                  report['gaze_following'] > 70,
                ),
                _metricRow(
                  'Response Latency',
                  '${report['gaze_latency'].toStringAsFixed(2)}s',
                  report['gaze_latency'] < 1.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metricRow(String label, String value, bool isGood) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isGood ? Colors.lightGreen : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isGood ? Icons.check_circle : Icons.warning,
                color: isGood ? Colors.lightGreen : Colors.orange,
                size: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Obx(
            () => Text(
              controller.debugInfo.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: controller.isTracking.value
                    ? null
                    : () => controller.startTracking(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('START'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.isTracking.value
                    ? () => controller.stopTracking()
                    : null,
                icon: const Icon(Icons.stop),
                label: const Text('STOP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                label: const Text('EXIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom Painter untuk visualisasi gaze path
class GazePathPainter extends CustomPainter {
  final List<Map<String, double>> gazePoints;

  GazePathPainter(this.gazePoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (gazePoints.isEmpty) return;

    final paint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw gaze path
    for (int i = 1; i < gazePoints.length; i++) {
      final prev = gazePoints[i - 1];
      final curr = gazePoints[i];

      canvas.drawLine(
        Offset(prev['x']!, prev['y']!),
        Offset(curr['x']!, curr['y']!),
        paint,
      );
    }

    // Draw current gaze point
    final lastPoint = gazePoints.last;
    canvas.drawCircle(
      Offset(lastPoint['x']!, lastPoint['y']!),
      5.0,
      Paint()..color = Colors.purpleAccent,
    );
  }

  @override
  bool shouldRepaint(GazePathPainter oldDelegate) {
    return oldDelegate.gazePoints != gazePoints;
  }
}

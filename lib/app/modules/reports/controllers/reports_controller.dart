import 'package:get/get.dart';
import '../models/game_result.dart';
import '../models/report.dart';

class ReportsController extends GetxController {
  final reports = <Report>[].obs;
  final selectedReport = Rxn<Report>();

  @override
  void onInit() {
    super.onInit();
    _generateDummyReports();
  }

  void _generateDummyReports() {
    // Generate dummy game results
    final gameResults = [
      GameResult(
        id: '1',
        gameId: '1',
        gameTitle: 'Social Interaction Training',
        score: 850,
        maxScore: 1000,
        playTime: const Duration(minutes: 15, seconds: 30),
        playedAt: DateTime.now().subtract(const Duration(days: 2)),
        difficulty: 'Medium',
        completed: true,
        performance: 'Excellent',
      ),
      GameResult(
        id: '2',
        gameId: '2',
        gameTitle: 'Collaborative Puzzle Game',
        score: 720,
        maxScore: 900,
        playTime: const Duration(minutes: 22, seconds: 15),
        playedAt: DateTime.now().subtract(const Duration(days: 1)),
        difficulty: 'Hard',
        completed: true,
        performance: 'Good',
      ),
      GameResult(
        id: '3',
        gameId: '3',
        gameTitle: 'Emotion Recognition',
        score: 680,
        maxScore: 800,
        playTime: const Duration(minutes: 10, seconds: 45),
        playedAt: DateTime.now(),
        difficulty: 'Medium',
        completed: true,
        performance: 'Good',
      ),
      GameResult(
        id: '4',
        gameId: '1',
        gameTitle: 'Social Interaction Training',
        score: 920,
        maxScore: 1000,
        playTime: const Duration(minutes: 18, seconds: 20),
        playedAt: DateTime.now().subtract(const Duration(days: 3)),
        difficulty: 'Medium',
        completed: true,
        performance: 'Excellent',
      ),
    ];

    final report = Report(
      id: '1',
      userId: 'user001',
      userName: 'Munawir',
      gameResults: gameResults,
      generatedAt: DateTime.now(),
      summary: 'Performa yang sangat baik! Terus lanjutkan latihan untuk meningkatkan kemampuan interaksi sosial Anda.',
    );

    reports.add(report);
    selectedReport.value = report;
  }

  void selectReport(Report report) {
    selectedReport.value = report;
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

import 'game_result.dart';

class Report {
  final String id;
  final String userId;
  final String userName;
  final List<GameResult> gameResults;
  final DateTime generatedAt;
  final String summary;

  Report({
    required this.id,
    required this.userId,
    required this.userName,
    required this.gameResults,
    required this.generatedAt,
    required this.summary,
  });

  double getAverageScore() {
    if (gameResults.isEmpty) return 0;
    double total = 0;
    for (var result in gameResults) {
      total += result.getAccuracy();
    }
    return total / gameResults.length;
  }

  int getTotalGamesPlayed() {
    return gameResults.length;
  }

  int getCompletedGames() {
    return gameResults.where((r) => r.completed).length;
  }

  Duration getTotalPlayTime() {
    Duration total = Duration.zero;
    for (var result in gameResults) {
      total += result.playTime;
    }
    return total;
  }

  String getTotalPlayTimeString() {
    final total = getTotalPlayTime();
    final hours = total.inHours;
    final minutes = total.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int getMaxScore() {
    if (gameResults.isEmpty) return 0;
    return gameResults.fold<int>(0, (max, result) => result.score > max ? result.score : max);
  }
}

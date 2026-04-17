class GameResult {
  final String id;
  final String gameId;
  final String gameTitle;
  final int score;
  final int maxScore;
  final Duration playTime;
  final DateTime playedAt;
  final String difficulty;
  final bool completed;
  final String performance; // 'Excellent', 'Good', 'Fair', 'Poor'

  GameResult({
    required this.id,
    required this.gameId,
    required this.gameTitle,
    required this.score,
    required this.maxScore,
    required this.playTime,
    required this.playedAt,
    required this.difficulty,
    required this.completed,
    required this.performance,
  });

  double getAccuracy() {
    return (score / maxScore) * 100;
  }

  String getTimeString() {
    return '${playTime.inMinutes}m ${playTime.inSeconds.remainder(60)}s';
  }
}

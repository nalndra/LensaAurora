class GameModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String type; // 'social_interaction', 'puzzle', etc
  final int difficulty; // 1-5

  GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.difficulty,
  });
}

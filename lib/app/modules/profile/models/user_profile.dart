class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final int age;
  final String profileImageUrl;
  final DateTime joinDate;
  final String bio;
  final Map<String, dynamic> achievements;
  final int totalGamesPlayed;
  final double averageScore;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.age,
    required this.profileImageUrl,
    required this.joinDate,
    required this.bio,
    required this.achievements,
    required this.totalGamesPlayed,
    required this.averageScore,
  });
}

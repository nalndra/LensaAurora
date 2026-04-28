import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String? photoUrl;
  final DateTime createdAt;
  final Map<String, dynamic> testResults;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    this.photoUrl,
    required this.createdAt,
    this.testResults = const {},
  });

  /// Convert ChildProfile ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'photoUrl': photoUrl ?? '',
      'createdAt': Timestamp.fromDate(createdAt),
      'testResults': testResults,
    };
  }

  /// Create ChildProfile dari Firestore Map
  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      testResults: map['testResults'] ?? {},
    );
  }

  /// Create copy dengan override values
  ChildProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? photoUrl,
    DateTime? createdAt,
    Map<String, dynamic>? testResults,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      testResults: testResults ?? this.testResults,
    );
  }
}

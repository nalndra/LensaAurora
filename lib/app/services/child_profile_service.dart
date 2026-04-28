import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/child_profile.dart';
import '../modules/account_type/controllers/account_type_controller.dart';

class ChildProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all children for a parent user
  Future<List<ChildProfile>> getChildren(String parentUid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ChildProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting children: $e');
      rethrow;
    }
  }

  /// Get single child
  Future<ChildProfile?> getChild(String parentUid, String childId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .get();

      if (doc.exists) {
        return ChildProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting child: $e');
      rethrow;
    }
  }

  /// Add new child
  Future<String> addChild(
    String parentUid, {
    required String name,
    required int age,
    String? photoUrl,
  }) async {
    try {
      final childId = _firestore.collection('users').doc().id;

      final child = ChildProfile(
        id: childId,
        name: name,
        age: age,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .set(child.toMap());

      return childId;
    } catch (e) {
      print('Error adding child: $e');
      rethrow;
    }
  }

  /// Update child profile
  Future<void> updateChild(
    String parentUid,
    String childId, {
    String? name,
    int? age,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .update(updateData);
    } catch (e) {
      print('Error updating child: $e');
      rethrow;
    }
  }

  /// Delete child
  Future<void> deleteChild(String parentUid, String childId) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .delete();
    } catch (e) {
      print('Error deleting child: $e');
      rethrow;
    }
  }

  /// Update child's test result
  Future<void> updateChildTestResult(
    String parentUid,
    String childId,
    String testType,
    Map<String, dynamic> testData,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .update({
        'testResults.$testType': testData,
      });
    } catch (e) {
      print('Error updating test result: $e');
      rethrow;
    }
  }

  /// Get active child ID for user
  Future<String?> getActiveChild(String parentUid) async {
    try {
      final doc = await _firestore.collection('users').doc(parentUid).get();
      return doc.data()?['activeChildId'];
    } catch (e) {
      print('Error getting active child: $e');
      return null;
    }
  }

  /// Set active child
  Future<void> setActiveChild(String parentUid, String childId) async {
    try {
      await _firestore.collection('users').doc(parentUid).update({
        'activeChildId': childId,
      });
    } catch (e) {
      print('Error setting active child: $e');
      rethrow;
    }
  }

  /// Stream of children
  Stream<List<ChildProfile>> childrenStream(String parentUid) {
    return _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChildProfile.fromMap(doc.data()))
            .toList());
  }
}

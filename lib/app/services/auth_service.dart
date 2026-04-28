import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ganti dengan Project ID Firebase kamu
  static const String _projectId = 'lensaaurora';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1067543596698-nq5v6r1klj8n1gg1gpd910ciniroj4e8.apps.googleusercontent.com',
  );

  AuthService._internal() {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: false,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('DEBUG: Firestore offline persistence DISABLED');
    } catch (e) {
      print('DEBUG: Could not set Firestore settings: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static final Map<String, String> _roleCache = {}; // In-memory cache for all platforms

  // ─── LOCAL CACHE HELPERS ────────────────────────────────────────────────

  /// Simpan role ke cache (works on all platforms)
  void _saveRoleLocally(String uid, String role) {
    _roleCache[uid] = role;
    print('DEBUG: Role cached locally: $role');
  }

  /// Baca role dari cache
  String? _getRoleLocally(String uid) {
    return _roleCache[uid];
  }

  /// Hapus role dari cache saat logout
  void _clearRoleLocally(String uid) {
    _roleCache.remove(uid);
  }

  // ─── FIRESTORE REST API ──────────────────────────────────────────────────

  /// Tulis dokumen ke Firestore via REST API (bypass SDK yang hang)
  Future<bool> _writeFirestoreREST(String collection, String docId, Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final idToken = await user.getIdToken();
      final url = 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collection/$docId';

      // Convert data ke Firestore REST format
      final fields = <String, dynamic>{};
      data.forEach((key, value) {
        if (value == null) {
          fields[key] = {'nullValue': null};
        } else if (value is String) {
          fields[key] = {'stringValue': value};
        } else if (value is bool) {
          fields[key] = {'booleanValue': value};
        } else if (value is int) {
          fields[key] = {'integerValue': value.toString()};
        } else if (value is double) {
          fields[key] = {'doubleValue': value};
        }
        // Skip FieldValue.serverTimestamp() — akan di-handle terpisah
      });

      final response = await http.patch(
        Uri.parse('$url?updateMask.fieldPaths=${data.keys.where((k) => data[k] != null && data[k] is! _ServerTimestamp).join("&updateMask.fieldPaths=")}'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fields': fields}),
      ).timeout(const Duration(seconds: 10));

      print('DEBUG [REST]: Response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('ERROR [REST write]: $e');
      return false;
    }
  }

  /// Simplified REST write yang lebih reliable
  Future<bool> _setUserDataREST(String uid, Map<String, dynamic> simpleData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('ERROR [REST]: No current user');
        return false;
      }

      print('DEBUG [REST]: Getting ID token...');
      
      // Get ID token dengan timeout
      final idToken = await user.getIdToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('getIdToken timeout', const Duration(seconds: 5));
        },
      );
      
      print('DEBUG [REST]: Got ID token, making request...');

      // Build Firestore fields format
      final fields = <String, dynamic>{};
      simpleData.forEach((key, value) {
        if (value == null) {
          fields[key] = {'nullValue': null};
        } else if (value is String) {
          fields[key] = {'stringValue': value};
        } else if (value is bool) {
          fields[key] = {'booleanValue': value};
        }
      });

      // Tambah timestamp
      fields['updatedAt'] = {'timestampValue': DateTime.now().toUtc().toIso8601String()};

      final url = 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users/$uid';

      print('DEBUG [REST]: Sending PATCH to Firestore...');
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fields': fields}),
      ).timeout(const Duration(seconds: 10));

      print('DEBUG [REST]: Status ${response.statusCode} for uid=$uid');
      if (response.statusCode != 200) {
        print('DEBUG [REST]: Response body: ${response.body}');
        return false;
      }
      print('DEBUG [REST]: SUCCESS');
      return true;
    } on TimeoutException catch (e) {
      print('ERROR [REST]: Timeout - $e');
      return false;
    } catch (e) {
      print('ERROR [REST]: $e');
      return false;
    }
  }

  /// Baca dokumen dari Firestore via REST API
  Future<Map<String, dynamic>?> _getUserDataREST(String uid) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final idToken = await user.getIdToken();
      final url = 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users/$uid';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $idToken'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final fields = json['fields'] as Map<String, dynamic>?;
        if (fields == null) return {};

        // Convert dari Firestore format ke Map biasa
        final result = <String, dynamic>{};
        fields.forEach((key, value) {
          final v = value as Map<String, dynamic>;
          if (v.containsKey('stringValue')) result[key] = v['stringValue'];
          else if (v.containsKey('booleanValue')) result[key] = v['booleanValue'];
          else if (v.containsKey('nullValue')) result[key] = null;
          else if (v.containsKey('integerValue')) result[key] = int.tryParse(v['integerValue'].toString());
        });
        return result;
      } else if (response.statusCode == 404) {
        return null; // dokumen tidak ada
      }
      return null;
    } catch (e) {
      print('ERROR [REST read]: $e');
      return null;
    }
  }

  // ─── AUTH METHODS ────────────────────────────────────────────────────────

  Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        final refreshedUser = _auth.currentUser;
        if (refreshedUser == null) return null;

        // Coba tulis via REST (non-blocking)
        _setUserDataREST(refreshedUser.uid, {
          'uid': refreshedUser.uid,
          'email': refreshedUser.email ?? email,
          'name': name,
          'photoUrl': '',
          'isActive': 'true', // REST hanya string/bool sederhana
        }).then((success) {
          print('DEBUG [register]: REST write ${success ? "SUCCESS" : "FAILED"}');
        });

        return refreshedUser;
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Set user account role — pakai REST + localStorage cache
  Future<void> setUserRole(String uid, String role) async {
    try {
      print('DEBUG [setUserRole]: uid=$uid, role=$role');

      if (uid.isEmpty || role.isEmpty) throw Exception('Invalid uid or role');

      // 1. Simpan ke localStorage DULU (instant, tidak bisa gagal)
      _saveRoleLocally(uid, role);
      print('DEBUG [setUserRole]: Saved locally');

      // 2. Coba simpan ke Firestore via REST (dengan timeout)
      final success = await _setUserDataREST(uid, {
        'accountRole': role,
        'uid': uid,
      });

      if (success) {
        print('DEBUG [setUserRole]: SUCCESS via REST');
      } else {
        print('WARNING [setUserRole]: REST failed, but role is cached locally');
        // Tetap lanjut — role ada di localStorage
      }
    } catch (e) {
      print('ERROR [setUserRole]: $e');
      // Tetap simpan lokal walau ada error
      _saveRoleLocally(uid, role);
      // JANGAN rethrow — biar UI tetap bisa lanjut
    }
  }

  /// Get user account role — cek localStorage dulu, lalu Firestore
  Future<String?> getUserRole(String uid) async {
    // 1. Cek cache lokal dulu (instant)
    final localRole = _getRoleLocally(uid);
    if (localRole != null) {
      print('DEBUG [getUserRole]: Got from localStorage: $localRole');
      return localRole;
    }

    // 2. Coba fetch dari Firestore via REST
    try {
      print('DEBUG [getUserRole]: Fetching from REST...');
      final data = await _getUserDataREST(uid);
      final role = data?['accountRole'] as String?;
      if (role != null) {
        _saveRoleLocally(uid, role); // cache untuk next time
        print('DEBUG [getUserRole]: Got from REST: $role');
      }
      return role;
    } catch (e) {
      print('ERROR [getUserRole]: $e');
      return null;
    }
  }

  /// Check if user has set their account role
  Future<bool> hasUserSetRole(String uid) async {
    final role = await getUserRole(uid);
    return role != null;
  }

  Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email)
          .timeout(const Duration(seconds: 5));
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isNotEmpty) await _setUserDataREST(uid, data);

    if (name != null && _auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(name);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Cek apakah user baru via REST
        final existing = await _getUserDataREST(user.uid);
        if (existing == null) {
          await _setUserDataREST(user.uid, {
            'uid': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? 'Pengguna',
            'photoUrl': user.photoURL ?? '',
            'isActive': 'true',
          });
        }
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      // Hapus cache lokal saat logout
      if (uid != null) _clearRoleLocally(uid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  // ─── CHILD PROFILE METHODS ───────────────────────────────────────────────

  Future<void> addChild(String parentId, ChildProfile child) async {
    await _firestore
        .collection('users').doc(parentId)
        .collection('children').doc(child.id)
        .set(child.toMap());
  }

  Future<List<ChildProfile>> getChildren(String parentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users').doc(parentId)
          .collection('children')
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => ChildProfile.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting children: $e');
      return [];
    }
  }

  Future<ChildProfile?> getChild(String parentId, String childId) async {
    try {
      final doc = await _firestore
          .collection('users').doc(parentId)
          .collection('children').doc(childId)
          .get();
      if (doc.exists) return ChildProfile.fromMap(doc.data()!);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateChild(String parentId, ChildProfile child) async {
    await _firestore
        .collection('users').doc(parentId)
        .collection('children').doc(child.id)
        .update(child.toMap());
  }

  Future<void> deleteChild(String parentId, String childId) async {
    await _firestore
        .collection('users').doc(parentId)
        .collection('children').doc(childId)
        .delete();
  }
}

// Helper class (tidak dipakai langsung, hanya untuk type check)
class _ServerTimestamp {}
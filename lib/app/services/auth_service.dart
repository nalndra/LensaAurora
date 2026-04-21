import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Menggunakan Client ID. Jika Anda run di Web, Anda WAJIB memberikan Web Client ID 
  // (Didapat dari Firebase Console -> Authentication -> Sign-in Method -> Google -> Web SDK configuration)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1067543596698-nq5v6r1klj8n1gg1gpd910ciniroj4e8.apps.googleusercontent.com', 
  );

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Register dengan email dan password
  Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Update display name (tidak perlu ditunggu/await agar lebih cepat)
        user.updateDisplayName(name).catchError((_) {});

        // Build data
        try {
          // Tambahkan timeout untuk mencegah infinite loading jika Firestore belum online/dikonfigurasi
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'name': name,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'photoUrl': '',
            'isActive': true,
          }).timeout(const Duration(seconds: 5));
        } catch (e) {
          // Abaikan error firestore (misal rules belum di-set) yang penting auth berhasil
          print("Firestore error: $e");
        }

        return user;
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Login dengan email dan password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Update last login time (tanpa ditunggu/await agar tidak menyangkut)
      if (user != null) {
        _firestore.collection('users').doc(user.uid).update({
          'lastLogin': Timestamp.now(),
        }).catchError((_) {});
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email).timeout(const Duration(seconds: 5));
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': Timestamp.now(),
      };

      if (name != null) {
        updateData['name'] = name;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      await _firestore.collection('users').doc(uid).update(updateData);

      // Also update FirebaseAuth display name if provided
      if (name != null && _auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(name);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        try {
          final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get().timeout(const Duration(seconds: 3));

          if (!doc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'email': user.email,
              'name': user.displayName ?? 'Pengguna',
              'createdAt': Timestamp.now(),
              'updatedAt': Timestamp.now(),
              'photoUrl': user.photoURL ?? '',
              'isActive': true,
            }).timeout(const Duration(seconds: 3));
          }
        } catch (e) {
            print("Firestore Google Login error: $e");
        }
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Verify email
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get user email verification status
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
}

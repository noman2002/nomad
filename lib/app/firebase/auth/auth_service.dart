import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create account with email and password
  static Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in anonymously (for testing)
  static Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Sign out
  static Future<void> signOut() => _auth.signOut();

  /// Delete account
  static Future<void> deleteAccount() async {
    await currentUser?.delete();
  }
}

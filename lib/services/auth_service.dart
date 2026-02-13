import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      // Use updateEmail for immediate change. Note: might require recent login.
      // If this fails with 'requires-recent-login', you may need to re-authenticate.
      // ignore: deprecated_member_use
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      // Fallback to verification if updateEmail fails or is restricted
      try {
        await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      } catch (innerError) {
        rethrow;
      }
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

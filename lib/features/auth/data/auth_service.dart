import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('FirebaseAuth unavailable: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      final auth = _auth;
      if (auth == null) return null;

      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final auth = _auth;
      if (auth == null) return null;

      UserCredential result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final auth = _auth;
      if (auth == null) return;

      await auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Get current user
  User? get currentUser => _auth?.currentUser;

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final auth = _auth;
      if (auth == null) return;

      await auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to $email');
    } catch (e) {
      debugPrint('Error sending password reset: $e');
      rethrow;
    }
  }
}
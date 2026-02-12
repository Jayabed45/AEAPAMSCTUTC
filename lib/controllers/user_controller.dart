import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;

  UserController() {
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        loadUserProfile(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);

      // Save FCM token after successful login
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await NotificationService().saveTokenToDatabase(token);
      }
    } on FirebaseAuthException catch (e) {
      _error = e.code;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final credential = await _authService.signUp(email, password);
      if (credential != null && credential.user != null) {
        // Generate username from email (remove everything after @)
        String username = email.split('@')[0];

        // Create initial user profile in Firestore
        final newUser = UserModel(
          fullName: username, // Use username as default full name
          phoneNumber: '',
          email: email,
          username: username,
          profileImageUrl: 'https://i.pravatar.cc/300',
          role: 'User',
          organization: 'AEAPAMSCTUTC',
        );

        await _apiService.createUserProfile(credential.user!.uid, newUser);
      }
      // Immediately sign out after registration so the user has to log in
      await _authService.signOut();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUserProfile([String? uid]) async {
    final targetUid = uid ?? _authService.currentUser?.uid;
    if (targetUid == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.fetchUserProfile(targetUid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapscore/features/auth/helpers/api_service_helper.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  User? _user;
  String? _userId;
  bool _isLoading = true;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Cancel any existing subscription first
    await _authSubscription?.cancel();

    _authSubscription =
        _authService.authStateChanges.listen((User? user) async {
      _isLoading = true;
      _user = user;
      notifyListeners();

      if (user != null) {
        try {
          final userData =
              await _apiService.getUserByFirebaseId(userId: user.uid);
          if (userData.isNotEmpty) {
            _userId = userData['id'];
          } else {
            print('User not found in DB, will create new record.');
          }
        } catch (e) {
          print('Error fetching user data (non-critical): $e');
        }
      } else {
        _userId = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null) {
        _user = credential.user;
        notifyListeners();
      }
      return credential;
    } catch (e) {
      print("Error in Google Sign In: $e");
      await signOut(); // Ensure we clean up if there's an error
      return null;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      // Explicitly clear user data
      _user = null;
      _userId = null;

      // Force a refresh of the auth state
      await _initializeAuth();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen if user is null or user.uid is null then redirect to unauthenticatedRoute
  // else if user is authenticated then redirect to authenticatedRoute
  // else show CircularProgressIndicator

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _authService.signInWithEmailPassword(email, password);
  }

  Future<void> sendEmailResetPassword(String email) async {
    await _authService.sendEmailResetPassword(email);
  }

  Future<UserCredential> registerWithEmailPassword(
      String email, String password, String name) async {
    return await _authService.registerWithEmailPassword(email, password, name);
  }

  Future<void> refreshAuthState() async {
    _isLoading = true;
    notifyListeners();

    _user = FirebaseAuth.instance.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  // Set MongoDB user ID and save it to secure storage
  void setUserId(String id) async {
    _userId = id;
    notifyListeners();
  }

  User? get user => _user;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _userId != null;
}

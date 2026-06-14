import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/utils.dart';

/// [AuthNotifier] — manages and listens to the Firebase Authentication state changes.
/// Serves as the [Listenable] for GoRouter to automatically trigger redirects.
class AuthNotifier extends ChangeNotifier {
  StreamSubscription<User?>? _subscription;
  User? _user;

  AuthNotifier() {
    try {
      Firebase.app();
      _user = FirebaseAuth.instance.currentUser;
      _subscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _user = user;
        AppLogger.i('Auth state changed: User is ${_user != null ? _user!.email : "Logged Out"}');
        notifyListeners();
      });
    } catch (e) {
      AppLogger.w('Firebase is not initialized. Running AuthNotifier in disconnected mode. Details: $e');
    }
  }

  bool _isAuthenticatedOverride = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticatedOverride || _user != null;

  /// Specifically for testing and layout verification in headless widget tests.
  void setAuthenticatedOverride(bool value) {
    _isAuthenticatedOverride = value;
    notifyListeners();
  }

  String get userEmail => _user?.email ?? '';
  String get userName => _user?.displayName ?? _user?.email?.split('@').first ?? 'User';
  String? get userPhotoUrl => _user?.photoURL;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

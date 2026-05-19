import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? user;
  bool isLoading = true;
  String? error;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      user = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final userData = await _authService.getUserData(firebaseUser.uid);
      user = userData;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    error = null;
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);
      if (result == null) {
        error = 'Unable to retrieve user data. Please contact support.';
        return false;
      }
      user = result;
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    required String department,
  }) async {
    error = null;
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
        department: department,
      );
      if (result == null) {
        error = 'Failed to create user account.';
        return false;
      }
      user = result;
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      user = null;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

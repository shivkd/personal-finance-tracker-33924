import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// PUBLIC_INTERFACE
class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  User? user;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    user = Supabase.instance.client.auth.currentUser;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      user = response.user;
      isLoading = false;
      notifyListeners();
      return user != null;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // PUBLIC_INTERFACE
  Future<bool> register(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      user = response.user;
      isLoading = false;
      notifyListeners();
      return user != null;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // PUBLIC_INTERFACE
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    user = null;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  bool isLoggedIn() {
    user = Supabase.instance.client.auth.currentUser;
    return user != null;
  }
}

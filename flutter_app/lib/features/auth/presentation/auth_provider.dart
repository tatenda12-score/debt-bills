import 'package:flutter/material.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecureStorage _secureStorage;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  
  AuthProvider(this._authService, this._secureStorage);

  AuthState get state => _state;
  User? get currentUser => _currentUser;

  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.getToken();
    if (token == null) {
      _setUnauthenticated();
      return;
    }

    try {
      _currentUser = await _authService.getCurrentUser();
      _state = AuthState.authenticated;
    } catch (e) {
      // If token is invalid/expired, it throws AuthException or similar
      await _secureStorage.deleteToken();
      _setUnauthenticated();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final token = await _authService.login(email, password);
    await _secureStorage.saveToken(token);
    _currentUser = await _authService.getCurrentUser();
    _state = AuthState.authenticated;
    notifyListeners();
  }

  Future<void> register(String email, String password, String fullName) async {
    await _authService.register(email, password, fullName);
    // After registration, auto-login
    await login(email, password);
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
    _setUnauthenticated();
    notifyListeners();
  }

  void _setUnauthenticated() {
    _state = AuthState.unauthenticated;
    _currentUser = null;
  }
}

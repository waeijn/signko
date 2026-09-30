import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../core/api_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith(
      {UserModel? user,
      bool? isLoading,
      String? error,
      bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token != null && token.isNotEmpty) {
        // Fetch user profile to validate token
        final response = await ApiService.get('/auth/me');
        if (response.statusCode == 200) {
          final user = UserModel.fromJson(jsonDecode(response.body));
          state = state.copyWith(user: user, isLoading: false, error: null);
          return;
        } else {
          // Invalid or expired token
          await prefs.remove('jwt_token');
        }
      }
    } catch (e) {
      // Network error silently fails to login screen
    }
    state = state.copyWith(isLoading: false);
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = UserModel.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        state = state.copyWith(user: user, isLoading: false);
        return true;
      } else {
        final errorMsg =
            jsonDecode(response.body)['detail'] ?? 'Registration failed';
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error occurred');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // FastAPI OAuth2PasswordRequestForm expects x-www-form-urlencoded
      final response = await ApiService.postForm('/auth/login', {
        'username': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = UserModel.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        state = state.copyWith(user: user, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
            isLoading: false, error: 'Invalid email or password');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error occurred');
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    state = state.copyWith(clearUser: true, isLoading: false, error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

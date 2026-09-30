import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// The AuthState holds the current user. If null, the user is logged out.
class AuthState {
  final UserModel? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith({UserModel? user, bool? isLoading, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkInitialAuth();
  }

  void _checkInitialAuth() {
    // For now, we will start as logged out.
    // In the future, we would check SharedPreferences for a JWT token here.
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For development, we bypass actual backend validation and instantly log in the default user.
    final mockUser = UserModel.defaultUser();
    
    state = state.copyWith(user: mockUser, isLoading: false);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(clearUser: true, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

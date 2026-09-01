import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/storage/user_storage.dart';

// 3 possible states of the user
enum AuthStatus { loading, authenticated, unauthenticated }

class AuthNotifier extends StateNotifier<AuthStatus> {
  
  AuthNotifier() : super(AuthStatus.loading) {
    _checkToken(); // auto runs when app starts
  }

  // Runs once on app start — checks if token exists
  Future<void> _checkToken() async {
    final token = await TokenStorage.getToken();
    state = token != null 
        ? AuthStatus.authenticated 
        : AuthStatus.unauthenticated;
  }

  Future<void> login(
    String token, {
    String? refresh_token,
    String? name,
    String? email,
  }) async {
    await TokenStorage.saveTokens(
      access_token: token,
      refresh_token: refresh_token,
    );
    if (name != null || email != null) {
      await UserStorage.saveUser(
        name: name ?? 'Nutri User',
        email: email ?? '',
      );
    }
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    await UserStorage.clearUser();
    state = AuthStatus.unauthenticated;
  }
}

// Global provider — accessible anywhere in the app
final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>(
  (ref) => AuthNotifier(),
);

import 'package:google_sign_in/google_sign_in.dart';
import '../config/api_config.dart';

class GoogleAuthService {
  static GoogleSignIn? _google_sign_in;

  static GoogleSignIn get _client {
    if (ApiConfig.googleServerClientId.isEmpty) {
      throw Exception(
        'Google Web Client ID not set. Paste it into '
        'lib/core/config/google_client_config.dart (googleServerClientId) '
        'or run: flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com',
      );
    }

    _google_sign_in ??= GoogleSignIn(
      serverClientId: ApiConfig.googleServerClientId,
      scopes: const ['email', 'profile'],
    );
    return _google_sign_in!;
  }

  static Future<
      ({
        String? id_token,
        String? access_token,
        String? display_name,
        String? email,
      })> signIn() async {
    final account = await _client.signIn();
    if (account == null) {
      throw Exception('Google sign-in cancelled');
    }

    final auth = await account.authentication;
    final id_token = auth.idToken;

    if (id_token == null || id_token.isEmpty) {
      throw Exception('Could not get Google ID token');
    }

    return (
      id_token: id_token,
      access_token: auth.accessToken,
      display_name: account.displayName,
      email: account.email,
    );
  }
}

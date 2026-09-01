import 'dart:io';

import 'package:flutter/foundation.dart';
import 'google_client_config.dart' as google_client;

class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _envApiKey = String.fromEnvironment('API_KEY');
  static const String _envGoogleClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const bool _useDeviceLocalhost = bool.fromEnvironment(
    'API_USE_LOCALHOST',
  );
  static const bool _useAndroidEmulator = bool.fromEnvironment(
    'API_ANDROID_EMULATOR',
  );

  static String get googleServerClientId {
    if (_envGoogleClientId.isNotEmpty) {
      return _envGoogleClientId;
    }
    return google_client.googleServerClientId;
  }

  static const String _localLanIp = '10.181.63.75';
  static const String _androidEmulatorHost = '10.0.2.2';
  static const int port = 8080;

  static String get apiHost {
    if (_useDeviceLocalhost) {
      return '127.0.0.1';
    }
    if (Platform.isAndroid && _useAndroidEmulator) {
      return _androidEmulatorHost;
    }
    return _localLanIp;
  }

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:$port';
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://$apiHost:$port';
    }

    return 'http://localhost:$port';
  }

  static String get apiKey {
    if (_envApiKey.isNotEmpty) {
      return _envApiKey;
    }
    return 'sb_publishable_bTcZhsBlhHiPzj4wz2kF9Q_fHtilOFp';
  }
}

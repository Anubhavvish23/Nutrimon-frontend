import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../errors/app_error_kind.dart';
import '../errors/api_error_mapper.dart';
import '../../../core/services/phone_auth_service.dart';
import '../storage/token_storage.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  static String _timeoutMessage(String url) {
    final host = Uri.tryParse(url)?.host ?? ApiConfig.apiHost;
    if (host == '127.0.0.1' || host == 'localhost') {
      return 'Request timed out at $url. Run: adb reverse tcp:${ApiConfig.port} tcp:${ApiConfig.port} (phone USB), then hot restart. Backend must be running (air).';
    }
    return 'Request timed out at $url. Campus/public Wi‑Fi often blocks phone→PC. Use launch config "NutriFit (USB)" + adb reverse, or phone hotspot + update api_config.dart IP ($host). Backend must be running on port ${ApiConfig.port}.';
  }

  static String _unreachableMessage(String url) {
    final host = Uri.tryParse(url)?.host ?? ApiConfig.apiHost;
    if (host == '127.0.0.1' || host == 'localhost') {
      return 'Cannot reach $url. Run adb reverse tcp:${ApiConfig.port} tcp:${ApiConfig.port} with the phone connected by USB.';
    }
    return 'Cannot reach $url. Same Wi‑Fi as PC, backend on port ${ApiConfig.port}, and api_config.dart LAN IP must match ipconfig (now ${ApiConfig.apiHost}).';
  }

  static Future<Map<String, String>> _headers({bool with_auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-API-Key': ApiConfig.apiKey,
    };
    if (with_auth) {
      await ensureFreshAccessToken();
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Completer<bool>? _refresh_completer;

  static Future<void> ensureFreshAccessToken() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;
    final expiring = await TokenStorage.is_expiring_soon();
    if (!expiring) return;
    await _tryRefreshToken();
  }

  static Future<bool> _tryRefreshToken() async {
    final in_flight = _refresh_completer;
    if (in_flight != null) return in_flight.future;

    final completer = Completer<bool>();
    _refresh_completer = completer;
    try {
      final ok = await _refreshTokenOnce();
      completer.complete(ok);
      return ok;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refresh_completer = null;
    }
  }

  static Future<bool> _refreshTokenOnce() async {
    final firebase_token = await PhoneAuthService.fresh_id_token();
    if (firebase_token != null && firebase_token.isNotEmpty) {
      await TokenStorage.saveToken(firebase_token);
      return true;
    }

    final refresh_token = await TokenStorage.getRefreshToken();
    if (refresh_token == null || refresh_token.isEmpty) return false;

    final result = await _post('/auth/refresh', {
      'refresh_token': refresh_token,
    });
    if (result['success'] != true) return false;

    final data = result['data'] as Map<String, dynamic>?;
    final access_token = data?['access_token']?.toString();
    final next_refresh = data?['refresh_token']?.toString();
    if (access_token == null || access_token.isEmpty) return false;

    await TokenStorage.saveTokens(
      access_token: access_token,
      refresh_token: next_refresh,
    );
    return true;
  }

  static Future<Map<String, dynamic>> _parseResponse(
    http.Response response, {
    required bool with_auth,
    required bool already_retried,
    required Future<Map<String, dynamic>> Function() retry,
  }) async {
    final response_body = response.body.trim();
    Map<String, dynamic>? data;

    if (response_body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response_body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        if (response.statusCode != 200) {
          final kind = appErrorKindFromStatusCode(response.statusCode);
          return _failure(
            kind,
            'Server error (${response.statusCode}): ${response_body.length > 120 ? '${response_body.substring(0, 120)}...' : response_body}',
          );
        }
      }
    }

    if (response.statusCode == 200) {
      return {'success': true, 'data': data ?? <String, dynamic>{}};
    }

    if (response.statusCode == 401 && with_auth && !already_retried) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) return retry();
      return _failure(
        AppErrorKind.unauthorized,
        'Session expired. Please log in again.',
      );
    }

    final kind = appErrorKindFromStatusCode(response.statusCode);
    return _failure(
      kind,
      data?['error']?.toString() ?? 'Request failed (${response.statusCode})',
    );
  }

  static Future<bool> _hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  static Map<String, dynamic> _failure(
    AppErrorKind error_kind,
    String error,
  ) {
    return {
      'success': false,
      'error': error,
      'error_kind': error_kind.name,
    };
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    bool with_auth = false,
  }) async {
    final url = '${ApiConfig.baseUrl}$path';

    if (!await _hasConnection()) {
      return _failure(
        AppErrorKind.offline,
        'No internet connection. Turn on mobile data or Wi‑Fi.',
      );
    }

    Future<Map<String, dynamic>> send({bool already_retried = false}) async {
      final response = await http
          .get(Uri.parse(url), headers: await _headers(with_auth: with_auth))
          .timeout(_timeout);
      return _parseResponse(
        response,
        with_auth: with_auth,
        already_retried: already_retried,
        retry: () => send(already_retried: true),
      );
    }

    try {
      return await send();
    } on SocketException {
      return _failure(
        AppErrorKind.serverUnreachable,
        _unreachableMessage(url),
      );
    } on TimeoutException {
      return _failure(AppErrorKind.timeout, _timeoutMessage(url));
    } catch (e) {
      return _failure(AppErrorKind.unknown, 'Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> request_body, {
    bool with_auth = false,
    Duration? timeout,
  }) async {
    final url = '${ApiConfig.baseUrl}$path';
    final request_timeout = timeout ?? _timeout;

    if (!await _hasConnection()) {
      return _failure(
        AppErrorKind.offline,
        'No internet connection. Turn on mobile data or Wi‑Fi.',
      );
    }

    Future<Map<String, dynamic>> send({bool already_retried = false}) async {
      final response = await http
          .post(
            Uri.parse(url),
            headers: await _headers(with_auth: with_auth),
            body: jsonEncode(request_body),
          )
          .timeout(request_timeout);
      return _parseResponse(
        response,
        with_auth: with_auth,
        already_retried: already_retried,
        retry: () => send(already_retried: true),
      );
    }

    try {
      return await send();
    } on SocketException {
      return _failure(
        AppErrorKind.serverUnreachable,
        _unreachableMessage(url),
      );
    } on TimeoutException {
      return _failure(
        AppErrorKind.timeout,
        _timeoutMessage(url),
      );
    } catch (e) {
      return _failure(
        AppErrorKind.unknown,
        'Network error: $e',
      );
    }
  }

  static Future<Map<String, dynamic>> signup({
    String? name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return _post('/auth/signup', {
      if (name != null && name.isNotEmpty) 'name': name,
      'email': email,
      'password': password,
      'phone': phone ?? '',
    });
  }

  static Future<Map<String, dynamic>> loginWithGoogle({
    required String id_token,
    String? access_token,
    String? name,
  }) async {
    return _post('/auth/google', {
      'id_token': id_token,
      if (access_token != null && access_token.isNotEmpty)
        'access_token': access_token,
      if (name != null && name.isNotEmpty) 'name': name,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return _post('/auth/forgot-password', {
      'email': email,
    });
  }

  static Future<void> registerFCMToken({
    required String token,
    String? user_id,
  }) async {
    final result = await _post(
      '/notifications/register-token',
      {
        'fcm_token': token,
        if (user_id != null) 'user_id': user_id,
      },
      with_auth: true,
    );

    if (result['success'] != true) {
      assert(() {
        debugPrint('FCM token registration failed: ${result['error']}');
        return true;
      }());
    }

    await saveUserProfile({
      'fcm_tokens': [token],
    });
  }

  static Future<Map<String, dynamic>> fetchDidYouKnowFacts() async {
    return _get('/facts/did-you-know');
  }

  static Future<Map<String, dynamic>> fetchRecipes({
    bool? is_veg,
    String? tag,
    String? meal_goal,
  }) async {
    final query = <String, String>{};
    if (is_veg != null) {
      query['is_veg'] = is_veg.toString();
    }
    if (tag != null && tag.isNotEmpty) {
      query['tag'] = tag;
    }
    if (meal_goal != null && meal_goal.isNotEmpty) {
      query['meal_goal'] = meal_goal;
    }

    var path = '/recipes';
    if (query.isNotEmpty) {
      path =
          '$path?${query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    }
    return _get(path);
  }

  static Future<Map<String, dynamic>> fetchSymptomsCatalog({
    String? severity,
  }) async {
    var path = '/symptoms/catalog';
    if (severity != null && severity.isNotEmpty) {
      path = '$path?severity=${Uri.encodeComponent(severity)}';
    }
    return _get(path);
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    return _get('/users/me/profile', with_auth: true);
  }

  static Future<Map<String, dynamic>> saveUserProfile(
    Map<String, dynamic> body,
  ) async {
    return _put('/users/me/profile', body, with_auth: true);
  }

  static Future<Map<String, dynamic>> generateMealPlan(
    Map<String, dynamic> body,
  ) async {
    return _post('/plans/generate', body, with_auth: true);
  }

  static Future<Map<String, dynamic>> analyzeSymptoms(
    Map<String, dynamic> body,
  ) async {
    return _post('/symptoms/analyze', body, with_auth: true);
  }

  static Future<Map<String, dynamic>> spinFridgeRoulette(
    Map<String, dynamic> body,
  ) async {
    return _post(
      '/fridge/spin',
      body,
      with_auth: true,
      timeout: const Duration(seconds: 60),
    );
  }

  static Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> request_body, {
    bool with_auth = false,
  }) async {
    final url = '${ApiConfig.baseUrl}$path';

    if (!await _hasConnection()) {
      return _failure(
        AppErrorKind.offline,
        'No internet connection. Turn on mobile data or Wi‑Fi.',
      );
    }

    Future<Map<String, dynamic>> send({bool already_retried = false}) async {
      final response = await http
          .put(
            Uri.parse(url),
            headers: await _headers(with_auth: with_auth),
            body: jsonEncode(request_body),
          )
          .timeout(_timeout);
      return _parseResponse(
        response,
        with_auth: with_auth,
        already_retried: already_retried,
        retry: () => send(already_retried: true),
      );
    }

    try {
      return await send();
    } on SocketException {
      return _failure(
        AppErrorKind.serverUnreachable,
        _unreachableMessage(url),
      );
    } on TimeoutException {
      return _failure(
        AppErrorKind.timeout,
        _timeoutMessage(url),
      );
    } catch (e) {
      return _failure(
        AppErrorKind.unknown,
        'Network error: $e',
      );
    }
  }
}

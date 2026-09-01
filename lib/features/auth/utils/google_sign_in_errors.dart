const String debugSha1Fingerprint =
    '66:67:2C:01:DB:EF:07:E9:BB:D7:E0:2E:74:D6:1C:10:2E:E7:15:ED';

String googleSignInErrorMessage(Object error) {
  final message = error.toString();

  if (message.contains('GOOGLE_SERVER_CLIENT_ID') ||
      message.contains('googleServerClientId') ||
      message.contains('Google Web Client ID not set')) {
    return 'Set your Google Web Client ID in lib/core/config/google_client_config.dart';
  }

  if (message.contains('cancelled') || message.contains('canceled')) {
    return '';
  }

  if (message.contains('ApiException: 10') ||
      message.contains('DEVELOPER_ERROR') ||
      message.contains('sign_in_failed')) {
    return 'Google Sign-In is not configured for this device build. '
        'In Firebase → Project settings → Android app, add this debug SHA-1, '
        'then download a fresh google-services.json and rebuild the app.\n\n'
        'SHA-1: $debugSha1Fingerprint';
  }

  if (message.contains('PlatformException')) {
    final code_match = RegExp(r'code:\s*([^,]+)').firstMatch(message);
    final details_match = RegExp(r'details:\s*([^,}]+)').firstMatch(message);
    final code = code_match?.group(1)?.trim();
    final details = details_match?.group(1)?.trim();

    if (code == 'sign_in_failed' || details?.contains('10') == true) {
      return 'Google Sign-In is not configured for this device build. '
          'Add this SHA-1 in Firebase Android app settings, download '
          'google-services.json again, then uninstall and reinstall the app.\n\n'
          'SHA-1: $debugSha1Fingerprint';
    }

    return message
        .replaceFirst('PlatformException(', '')
        .replaceAll(RegExp(r'\)$'), '')
        .trim();
  }

  return message.replaceFirst('Exception: ', '');
}

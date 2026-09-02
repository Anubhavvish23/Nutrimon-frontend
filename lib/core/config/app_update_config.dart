class AppUpdateConfig {
  static const String _env_check_url = String.fromEnvironment('UPDATE_CHECK_URL');

  static const String default_site_url =
      'https://nutrimorning-frontend.vercel.app';

  static String get version_check_url {
    if (_env_check_url.isNotEmpty) return _env_check_url;
    return '$default_site_url/version.json';
  }

  static String get site_base_url {
    final check_url = version_check_url;
    const suffix = '/version.json';
    if (check_url.endsWith(suffix)) {
      return check_url.substring(0, check_url.length - suffix.length);
    }
    return default_site_url;
  }
}

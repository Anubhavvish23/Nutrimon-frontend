import 'app_error_kind.dart';

AppErrorKind appErrorKindFromStatusCode(int status_code) {
  if (status_code == 404) return AppErrorKind.notFound;
  if (status_code == 401 || status_code == 403) {
    return AppErrorKind.unauthorized;
  }
  if (status_code >= 500) return AppErrorKind.server;
  if (status_code == 408) return AppErrorKind.timeout;
  return AppErrorKind.unknown;
}

AppErrorKind? appErrorKindFromResultKey(String? key) {
  if (key == null) return null;
  for (final kind in AppErrorKind.values) {
    if (kind.name == key) return kind;
  }
  return null;
}

AppErrorKind appErrorKindFromResult(Map<String, dynamic> result) {
  final from_key = appErrorKindFromResultKey(
    result['error_kind'] as String?,
  );
  if (from_key != null) return from_key;
  return AppErrorKind.unknown;
}

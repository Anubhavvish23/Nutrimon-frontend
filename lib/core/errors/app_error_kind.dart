import '../config/app_brand.dart';

enum AppErrorKind {
  offline,
  serverUnreachable,
  notFound,
  unauthorized,
  server,
  timeout,
  unknown,
}

extension AppErrorKindCopy on AppErrorKind {
  String get title {
    switch (this) {
      case AppErrorKind.offline:
        return 'No connection';
      case AppErrorKind.serverUnreachable:
        return "Can't reach server";
      case AppErrorKind.notFound:
        return 'Page not found';
      case AppErrorKind.unauthorized:
        return 'Access denied';
      case AppErrorKind.server:
        return 'Server hiccup';
      case AppErrorKind.timeout:
        return 'Taking too long';
      case AppErrorKind.unknown:
        return 'Something went wrong';
    }
  }

  String get subtitle {
    switch (this) {
      case AppErrorKind.offline:
        return 'Turn on mobile data or Wi‑Fi to keep ${AppBrand.name} running.';
      case AppErrorKind.serverUnreachable:
        return 'Your internet works, but we cannot reach ${AppBrand.name} right now.';
      case AppErrorKind.notFound:
        return 'This screen wandered off the menu. Let us get you back.';
      case AppErrorKind.unauthorized:
        return 'Please sign in again to continue.';
      case AppErrorKind.server:
        return 'Our servers need a breather. Try again in a moment.';
      case AppErrorKind.timeout:
        return 'The request timed out. Check your connection and retry.';
      case AppErrorKind.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

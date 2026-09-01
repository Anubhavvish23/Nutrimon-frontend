import 'package:flutter/material.dart';
import '../widgets/error/app_error_screen.dart';
import 'api_error_mapper.dart';

Future<void> showApiErrorFromResult(
  BuildContext context,
  Map<String, dynamic> result, {
  VoidCallback? on_retry,
}) {
  if (result['success'] == true) return Future.value();
  return showAppErrorScreen(
    context,
    kind: appErrorKindFromResult(result),
    message: result['error']?.toString(),
    on_retry: on_retry,
  );
}

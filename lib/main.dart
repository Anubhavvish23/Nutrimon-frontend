import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_brand.dart';
import 'core/config/api_config.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(() {
    debugPrint('NutriMorning API: ${ApiConfig.baseUrl}');
    return true;
  }());

  try {
    await Firebase.initializeApp();
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase/notification init failed: $e');
  }

  runApp(
    const ProviderScope(
      child: NutriMorningApp(),
    ),
  );
}

class NutriMorningApp extends ConsumerWidget {
  const NutriMorningApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme_mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppBrand.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme_mode,
      routerConfig: router,
      builder: (context, child) {
        return ConnectivityGate(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

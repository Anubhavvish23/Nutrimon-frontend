import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_brand.dart';
import 'core/config/api_config.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/app_startup.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  assert(() {
    debugPrint('NutriMorning API: ${ApiConfig.baseUrl}');
    return true;
  }());

  AppStartup.begin();

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

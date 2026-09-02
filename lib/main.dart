import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_brand.dart';
import 'core/config/api_config.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/api_service.dart';
import 'core/services/app_startup.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(() {
    debugPrint('NutriMorning API: ${ApiConfig.baseUrl}');
    return true;
  }());

  await SharedPreferences.getInstance();
  AppStartup.begin();

  runApp(
    const ProviderScope(
      child: NutriMorningApp(),
    ),
  );
}

class NutriMorningApp extends ConsumerStatefulWidget {
  const NutriMorningApp({super.key});

  @override
  ConsumerState<NutriMorningApp> createState() => _NutriMorningAppState();
}

class _NutriMorningAppState extends ConsumerState<NutriMorningApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ApiService.ensureFreshAccessToken();
    }
  }

  @override
  Widget build(BuildContext context) {
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

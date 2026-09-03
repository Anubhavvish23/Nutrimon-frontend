import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_brand.dart';
import 'core/config/api_config.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/api_service.dart';
import 'core/services/app_startup.dart';
import 'core/services/app_update_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_update_dialog.dart';
import 'core/widgets/connectivity_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(() {
    debugPrint('NutriMorning API: ${ApiConfig.baseUrl}');
    return true;
  }());

  await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  await NotificationService.register_background_handler();
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

  Future<void> _check_update_on_resume() async {
    final update = await AppUpdateService.check_for_update();
    if (!mounted || update == null) return;

    final router = ref.read(routerProvider);
    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    await showAppUpdateDialog(context, update);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ApiService.ensureFreshAccessToken();
      NotificationService.ensure_reminders_scheduled();
      _check_update_on_resume();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/terms_acceptance_provider.dart';
import '../../features/auth/widgets/post_login_setup.dart';
import '../../features/profile/providers/current_user_provider.dart';
import '../services/app_update_service.dart';
import '../services/cloud_profile_bootstrap.dart';
import 'app_update_dialog.dart';
import 'premium/premium_bottom_nav.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _setup_started = false;
  bool _update_checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run_post_login_setup());
  }

  Future<void> _check_for_app_update() async {
    if (_update_checked || !mounted) return;
    _update_checked = true;

    final update = await AppUpdateService.check_for_update();
    if (!mounted || update == null) return;
    await showAppUpdateDialog(context, update);
  }

  Future<void> _run_post_login_setup() async {
    if (_setup_started || !mounted) return;

    for (var i = 0; i < 40; i++) {
      if (!mounted) return;
      if (ref.read(cloudProfileLoadedProvider)) break;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    if (!mounted) return;
    _setup_started = true;

    final terms_accepted = await ref
        .read(termsAcceptedProvider.notifier)
        .is_current_version_accepted();
    if (!terms_accepted && mounted) {
      await showPostLoginTermsDialog(context, ref);
    }

    if (!mounted) return;
    ref.invalidate(currentUserProvider);
    await _check_for_app_update();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(cloudProfileLoadedProvider, (previous, next) {
      if (next && !_setup_started) {
        _run_post_login_setup();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.child,
      bottomNavigationBar: const PremiumBottomNav(),
    );
  }
}

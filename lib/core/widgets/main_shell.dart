import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/terms_acceptance_provider.dart';
import '../../features/auth/widgets/post_login_setup.dart';
import '../../features/profile/providers/current_user_provider.dart';
import 'premium/premium_bottom_nav.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _setup_started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run_post_login_setup());
  }

  Future<void> _run_post_login_setup() async {
    if (_setup_started || !mounted) return;
    _setup_started = true;

    final terms_accepted = await ref
        .read(termsAcceptedProvider.notifier)
        .is_current_version_accepted();
    if (!terms_accepted && mounted) {
      await showPostLoginTermsDialog(context, ref);
    }

    if (!mounted) return;
    ref.invalidate(currentUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.child,
      bottomNavigationBar: const PremiumBottomNav(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/show_api_error.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/app_brand.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_logo.dart';
import '../utils/auth_session_helper.dart';
import '../utils/google_sign_in_errors.dart';
import '../widgets/auth_ui_helpers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _email_controller = TextEditingController();
  final _password_controller = TextEditingController();
  final _confirm_password_controller = TextEditingController();

  bool _obscure_password = true;
  bool _obscure_confirm = true;
  bool _is_loading = false;

  @override
  void dispose() {
    _email_controller.dispose();
    _password_controller.dispose();
    _confirm_password_controller.dispose();
    super.dispose();
  }

  Future<void> _handle_email_signup() async {
    if (_email_controller.text.trim().isEmpty ||
        _password_controller.text.isEmpty) {
      _show_message('Please fill all required fields');
      return;
    }

    if (_password_controller.text != _confirm_password_controller.text) {
      _show_message('Passwords do not match');
      return;
    }

    setState(() => _is_loading = true);
    try {
      final email = _email_controller.text.trim();
      final result = await ApiService.signup(
        email: email,
        password: _password_controller.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        await completeAuthSession(
          ref,
          result['data'] as Map<String, dynamic>,
          fallback_email: email,
        );
      } else {
        await showApiErrorFromResult(
          context,
          result,
          on_retry: _handle_email_signup,
        );
      }
    } finally {
      if (mounted) setState(() => _is_loading = false);
    }
  }

  Future<void> _handle_google_signup() async {
    setState(() => _is_loading = true);
    try {
      await handleGoogleSignIn(ref);
    } catch (e) {
      if (!mounted) return;
      final message = googleSignInErrorMessage(e);
      if (message.isNotEmpty) _show_message(message);
    } finally {
      if (mounted) setState(() => _is_loading = false);
    }
  }

  void _show_message(String text, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? const Color(0xFF1DB954) : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom_inset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboard_open = bottom_inset > 0;
    final app = context.app;

    return Scaffold(
      backgroundColor: app.scaffold,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(28, 0, 28, 24 + bottom_inset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: keyboard_open ? 16 : 48),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: app.glow,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: const AppLogo(size: 52),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get started',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Create your ${AppBrand.name} account',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: app.text_muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: keyboard_open ? 24 : 36),
              AuthGoogleButton(
                label: 'Sign up with Google',
                enabled: !_is_loading,
                on_pressed: _handle_google_signup,
              ),
              SizedBox(height: keyboard_open ? 16 : 24),
              Row(
                children: [
                  Expanded(child: Divider(color: app.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: app.text_muted)),
                  ),
                  Expanded(child: Divider(color: app.border)),
                ],
              ),
              const SizedBox(height: 20),
              _build_input(
                controller: _email_controller,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboard_type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _build_input(
                controller: _password_controller,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscure_password,
                suffix_icon: IconButton(
                  icon: Icon(
                    _obscure_password
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: app.text_muted,
                  ),
                  onPressed: () =>
                      setState(() => _obscure_password = !_obscure_password),
                ),
              ),
              const SizedBox(height: 12),
              _build_input(
                controller: _confirm_password_controller,
                hint: 'Confirm password',
                icon: Icons.lock_outline,
                obscure: _obscure_confirm,
                suffix_icon: IconButton(
                  icon: Icon(
                    _obscure_confirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: app.text_muted,
                  ),
                  onPressed: () =>
                      setState(() => _obscure_confirm = !_obscure_confirm),
                ),
              ),
              SizedBox(height: keyboard_open ? 16 : 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _is_loading ? null : _handle_email_signup,
                  child: _is_loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create account'),
                ),
              ),
              SizedBox(height: keyboard_open ? 16 : 32),
              AuthSwitchLink(
                prompt: 'Already have an account?',
                action_label: 'Log in',
                on_action: () => context.go('/login'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build_input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboard_type,
    bool obscure = false,
    Widget? suffix_icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard_type,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: context.app.text_muted),
        suffixIcon: suffix_icon,
      ),
    );
  }
}

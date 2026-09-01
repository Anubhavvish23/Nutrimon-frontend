import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/app_error_kind.dart';
import '../../../core/errors/show_api_error.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/error/app_error_screen.dart';
import '../utils/auth_session_helper.dart';
import '../utils/google_sign_in_errors.dart';
import '../widgets/auth_ui_helpers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

  // Validation
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final result = await ApiService.login(
      email: email,
      password: password,
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
        on_retry: _handleLogin,
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  Future<void> _handleGoogleLogin() async {
    try {
      setState(() => _isLoading = true);
      await handleGoogleSignIn(ref);
    } catch (e) {
      if (!mounted) return;
      final message = googleSignInErrorMessage(e);
      if (message.isEmpty) return;
      await showAppErrorScreen(
        context,
        kind: AppErrorKind.unknown,
        message: message,
        on_retry: _handleGoogleLogin,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom_inset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboard_open = bottom_inset > 0;

    final app = context.app;
    final text_theme = Theme.of(context).textTheme;

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
              SizedBox(height: keyboard_open ? 16 : 60),

              Row(
                children: [
                  const AppLogo(size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: text_theme.headlineMedium,
                        ),
                        Text(
                          'Log in to your account',
                          style: text_theme.bodyMedium?.copyWith(
                            color: app.text_muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: keyboard_open ? 28 : 52),

              _buildInput(
                controller: _emailController,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _buildInput(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF888888),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: app.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: keyboard_open ? 20 : 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),

              SizedBox(height: keyboard_open ? 16 : 24),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(color: Color(0xFF888888)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                ],
              ),

              SizedBox(height: keyboard_open ? 16 : 24),

              AuthGoogleButton(
                label: 'Continue with Google',
                enabled: !_isLoading,
                on_pressed: _handleGoogleLogin,
              ),

              SizedBox(height: keyboard_open ? 20 : 40),

              AuthSwitchLink(
                prompt: "Don't have an account?",
                action_label: 'Sign up',
                on_action: () => context.go('/signup'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: context.app.text_muted),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
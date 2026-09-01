import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/show_api_error.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme_extension.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email_controller = TextEditingController();
  bool _is_loading = false;
  bool _email_sent = false;

  @override
  void dispose() {
    _email_controller.dispose();
    super.dispose();
  }

  bool _is_valid_email(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _sendResetLink() async {
    final email = _email_controller.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email address'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_is_valid_email(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _is_loading = true);

    try {
      final result = await ApiService.forgotPassword(email: email);
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _email_sent = true);
        final message = result['data']?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: context.app.accent,
            ),
          );
        }
      } else {
        await showApiErrorFromResult(
          context,
          result,
          on_retry: _sendResetLink,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send reset link: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _is_loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom_inset = MediaQuery.viewInsetsOf(context).bottom;
    final app = context.app;
    final on_surface = context.on_surface;

    return Scaffold(
      backgroundColor: app.scaffold,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: app.scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: on_surface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(28, 0, 28, 24 + bottom_inset),
          child: _email_sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final app = context.app;
    final on_surface = context.on_surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          '📬',
          style: TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Forgot password?',
          style: TextStyle(
            color: on_surface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the email you used to sign up. We will send you a link to reset your password.',
          style: TextStyle(
            color: app.text_muted,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _email_controller,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: TextStyle(color: on_surface),
          decoration: InputDecoration(
            hintText: 'Email address',
            hintStyle: TextStyle(color: app.text_muted),
            prefixIcon: Icon(Icons.email_outlined, color: app.text_muted),
            filled: true,
            fillColor: app.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: app.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: app.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: app.accent),
            ),
          ),
          onSubmitted: (_) => _sendResetLink(),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _is_loading ? null : _sendResetLink,
            child: _is_loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Send reset link',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Back to login',
              style: TextStyle(color: app.text_muted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final app = context.app;
    final on_surface = context.on_surface;

    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: app.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            color: app.accent,
            size: 44,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: on_surface,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'If an account exists for ${_email_controller.text.trim()}, you will receive a password reset link shortly.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: app.text_muted,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              'Back to login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Steps: 0 = enter email, 1 = enter otp + new password
  int _step = 0;

  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _obscureNew = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirm = ValueNotifier(true);

  String? _errorMessage;
  String? _successMessage;
  Timer? _msgTimer;

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryTextColor = Color(0xFF64748B);

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _isLoading.dispose();
    _obscureNew.dispose();
    _obscureConfirm.dispose();
    _msgTimer?.cancel();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() { _errorMessage = msg; _successMessage = null; });
    _msgTimer?.cancel();
    _msgTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    setState(() { _successMessage = msg; _errorMessage = null; });
  }

  Future<void> _handleSendCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    _isLoading.value = true;
    final result = await ApiService.forgotPassword(_emailController.text.trim());
    if (!mounted) return;
    _isLoading.value = false;
    if (result['success']) {
      setState(() => _step = 1);
      _showSuccess('Reset code sent. Check your email.');
    } else {
      _showError(result['message'] ?? 'Failed to send reset code');
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    _isLoading.value = true;
    final result = await ApiService.resetPassword(
      _emailController.text.trim(),
      _otpController.text.trim(),
      _newPasswordController.text,
    );
    if (!mounted) return;
    _isLoading.value = false;
    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully. Please sign in.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      _showError(result['message'] ?? 'Failed to reset password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  borderRadius: 24,
                  child: _step == 0 ? _buildEmailStep() : _buildResetStep(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset_rounded, size: 40, color: primaryColor),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: secondaryTextColor, fontSize: 14), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildAlert() {
    if (_errorMessage != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600, fontSize: 13))),
        ]),
      );
    }
    if (_successMessage != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(_successMessage!, style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w600, fontSize: 13))),
        ]),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader('Forgot Password', 'Enter your email and we\'ll send a reset code.'),
          const SizedBox(height: 32),
          _buildAlert(),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Please enter your email' : null,
            onFieldSubmitted: (_) => _handleSendCode(),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, loading, _) => FilledButton(
              onPressed: loading ? null : _handleSendCode,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Reset Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader('Reset Password', 'Enter the code sent to your email and your new password.'),
          const SizedBox(height: 32),
          _buildAlert(),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 4),
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Reset Code',
              prefixIcon: Icon(Icons.pin_rounded, size: 20),
              counterText: '',
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Enter the 6-digit code' : null,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _obscureNew,
            builder: (context, obscure, _) => TextFormField(
              controller: _newPasswordController,
              obscureText: obscure,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: secondaryTextColor),
                  onPressed: () => _obscureNew.value = !_obscureNew.value,
                ),
              ),
              validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _obscureConfirm,
            builder: (context, obscure, _) => TextFormField(
              controller: _confirmPasswordController,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: secondaryTextColor),
                  onPressed: () => _obscureConfirm.value = !_obscureConfirm.value,
                ),
              ),
              validator: (v) => v != _newPasswordController.text ? 'Passwords do not match' : null,
              onFieldSubmitted: (_) => _handleResetPassword(),
            ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, loading, _) => FilledButton(
              onPressed: loading ? null : _handleResetPassword,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() { _step = 0; _errorMessage = null; _successMessage = null; }),
            child: const Text('Use a different email', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}

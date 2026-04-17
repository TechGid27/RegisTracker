import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Use ValueNotifier to update specific widgets instead of the whole screen
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;
  Timer? _errorTimer;

  // Constants for performance and clean look
  static const Color primaryNavy = Color(0xFF1A237E);
  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isLoading.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _clearErrorWithDelay() {
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _errorMessage != null) {
        setState(() => _errorMessage = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryNavy),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: RepaintBoundary(
                  // Isolate expensive painting (like glass blur) from the rest of the app
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    borderRadius: 24,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _RegisterHeader(), // Const prevents unnecessary rebuilds
                          const SizedBox(height: 32),

                          if (_errorMessage != null) _buildErrorAlert(),

                          Row(
                            children: [
                              Expanded(
                                child: _buildInput(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  icon: Icons.person_outline,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInput(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  icon: Icons.badge_outlined,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInput(
                            controller: _emailController,
                            label: 'Institutional Email',
                            icon: Icons.alternate_email_rounded,
                            kbType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          _buildInput(
                            controller: _studentIdController,
                            label: 'Student ID Number',
                            icon: Icons.numbers_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // Password field with listener
                          ValueListenableBuilder(
                            valueListenable: _obscurePassword,
                            builder: (context, obscure, _) {
                              return _buildPasswordInput(
                                controller: _passwordController,
                                label: 'Password',
                                obscure: obscure,
                                toggle: () => _obscurePassword.value = !_obscurePassword.value,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password field with listener
                          ValueListenableBuilder(
                            valueListenable: _obscureConfirmPassword,
                            builder: (context, obscure, _) {
                              return _buildPasswordInput(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                obscure: obscure,
                                isConfirm: true,
                                toggle: () => _obscureConfirmPassword.value = !_obscureConfirmPassword.value,
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                          _buildRegisterButton(),
                          const SizedBox(height: 16),
                          const _RegisterFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildErrorAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? kbType,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: kbType,
      textInputAction: textInputAction,
      style: const TextStyle(color: darkText, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: secondaryText, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryNavy, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: darkText, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: secondaryText, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_person_outlined, color: primaryNavy, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: secondaryText, size: 18),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (!isConfirm && val.length < 6) return 'Min 6 characters';
        if (isConfirm && val != _passwordController.text) return 'Mismatch';
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, _) {
        return FilledButton(
          onPressed: loading ? null : _handleRegister,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: primaryNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Register Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  // --- LOGIC ---

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;
    if (_errorMessage != null) setState(() => _errorMessage = null);

    final userData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'studentId': _studentIdController.text.trim(),
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text.trim(),
    };

    try {
      final result = await ApiService.register(userData);
      if (!mounted) return;

      if (result['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        setState(() => _errorMessage = result['message'] ?? 'Registration failed');
        _clearErrorWithDelay();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Connection failed. Please check your network.');
      _clearErrorWithDelay();
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

}

// --- SUB-WIDGETS (Isolating static content) ---

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_add_rounded, size: 40, color: Color(0xFF1A237E)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create Account',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A237E), letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'Fill in your student details',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      ],
    );
  }
}

class _RegisterFooter extends StatelessWidget {
  const _RegisterFooter();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?", style: TextStyle(color: Color(0xFF64748B))),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
        ),
      ],
    );
  }
}
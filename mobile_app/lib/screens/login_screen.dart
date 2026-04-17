import 'dart:async';
import 'package:flutter/material.dart';
import 'student_dashboard.dart';
import 'staff_dashboard.dart';
import 'admin_dashboard.dart';
import 'superadmin_dashboard.dart';
import 'register_screen.dart';
import 'public_lookup_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ValueNotifiers para sa granular rebuilds (Performance Boost)
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  String? _errorMessage;
  Timer? _errorTimer;

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color secondaryTextColor = Color(0xFF64748B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _isLoading.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
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
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: RepaintBoundary(
                  // Gi-isolate ang painting para dili mo-lag ang animations over glass blur
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    borderRadius: 24,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LoginHeader(), // Constant widget
                          const SizedBox(height: 32),

                          if (_errorMessage != null) _buildErrorAlert(),

                          _buildEmailField(),
                          const SizedBox(height: 18),

                          ValueListenableBuilder(
                            valueListenable: _obscurePassword,
                            builder: (context, isObscure, _) {
                              return _buildPasswordField(isObscure);
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildLoginButton(),
                          const SizedBox(height: 16),

                          _buildTrackButton(),
                          const SizedBox(height: 32),

                          const _LoginFooter(),
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

  // ================= UI COMPONENTS =================

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: const InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your email';
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isObscure) {
    return TextFormField(
      controller: _passwordController,
      obscureText: isObscure,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: secondaryTextColor,
          ),
          onPressed: () => _obscurePassword.value = !_obscurePassword.value,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

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
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, _) {
        return FilledButton(
          onPressed: loading ? null : _handleLogin,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildTrackButton() {
    return OutlinedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PublicLookupScreen()),
      ),
      icon: const Icon(Icons.track_changes_rounded, size: 18),
      label: const Text('Track Document Status'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: primaryColor.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;
    if (_errorMessage != null) setState(() => _errorMessage = null);

    try {
      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true && result['user'] != null) {
        final user = UserModel.fromJson(result['user']);
        await AuthService.saveUser(user, token: result['token']);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => _getDashboard(user)),
        );
      } else {
        _showError(result['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      _showError('Server connection failed');
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  Widget _getDashboard(UserModel user) {
    switch (user.role) {
      case UserRole.admin:
        return AdminDashboard(user: user);
      case UserRole.staff:
        return StaffDashboard(user: user);
      case UserRole.student:
      default:
        return StudentDashboard(user: user);
    }
  }
}

// Gi-isolate as Const para dili sigeg rebuild ang static content
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.description_rounded, size: 60, color: Color(0xFF1A237E)),
        SizedBox(height: 16),
        Text(
          'RegisTrack',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A237E)),
        ),
        SizedBox(height: 4),
        Text(
          'Sign in to your student portal',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("New student?", style: TextStyle(color: Color(0xFF64748B))),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
          ),
        ),
      ],
    );
  }
}
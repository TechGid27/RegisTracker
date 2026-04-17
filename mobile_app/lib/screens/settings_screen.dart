import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  bool _isLoading = true;

  // Edit profile form
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _studentIdCtrl;
  late TextEditingController _departmentCtrl;
  final ValueNotifier<bool> _isSavingProfile = ValueNotifier(false);

  // Change password form
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final ValueNotifier<bool> _isSavingPassword = ValueNotifier(false);
  final ValueNotifier<bool> _obscureCurrent = ValueNotifier(true);
  final ValueNotifier<bool> _obscureNew = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirm = ValueNotifier(true);

  String? _profileError;
  String? _profileSuccess;
  String? _passwordError;
  String? _passwordSuccess;
  Timer? _msgTimer;

  static const _navy = Color(0xFF1A237E);
  static const _slate = Color(0xFF64748B);
  static const _dark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _studentIdCtrl = TextEditingController();
    _departmentCtrl = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _studentIdCtrl.dispose();
    _departmentCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _isSavingProfile.dispose();
    _isSavingPassword.dispose();
    _obscureCurrent.dispose();
    _obscureNew.dispose();
    _obscureConfirm.dispose();
    _msgTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _firstNameCtrl.text = user?.firstName ?? '';
      _lastNameCtrl.text = user?.lastName ?? '';
      _emailCtrl.text = user?.email ?? '';
      _studentIdCtrl.text = user?.studentId ?? '';
      _departmentCtrl.text = user?.department ?? '';
      _isLoading = false;
    });
  }

  void _setMsg({
    String? profileError,
    String? profileSuccess,
    String? passwordError,
    String? passwordSuccess,
  }) {
    _msgTimer?.cancel();
    setState(() {
      _profileError = profileError;
      _profileSuccess = profileSuccess;
      _passwordError = passwordError;
      _passwordSuccess = passwordSuccess;
    });
    _msgTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _profileError = null;
          _profileSuccess = null;
          _passwordError = null;
          _passwordSuccess = null;
        });
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    if (_user == null) return;
    _isSavingProfile.value = true;

    final result = await ApiService.updateUser(_user!.id!, {
      'id': _user!.id,
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'studentId': _studentIdCtrl.text.trim(),
      'department': _departmentCtrl.text.trim(),
      'role': _user!.role.name,
    });

    if (!mounted) return;
    _isSavingProfile.value = false;

    if (result['success'] == true) {
      final updated = UserModel(
        id: _user!.id,
        email: _emailCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        role: _user!.role,
        studentId: _studentIdCtrl.text.trim().isEmpty ? null : _studentIdCtrl.text.trim(),
        department: _departmentCtrl.text.trim().isEmpty ? null : _departmentCtrl.text.trim(),
      );
      await AuthService.saveUser(updated, token: await AuthService.getToken());
      setState(() => _user = updated);
      _setMsg(profileSuccess: 'Profile updated successfully');
    } else {
      _setMsg(profileError: result['message'] ?? 'Failed to update profile');
    }
  }

  Future<void> _savePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    if (_user == null) return;
    _isSavingPassword.value = true;

    final result = await ApiService.updateUser(_user!.id!, {
      'id': _user!.id,
      'currentPassword': _currentPassCtrl.text,
      'newPassword': _newPassCtrl.text,
      'confirmPassword': _confirmPassCtrl.text,
    });

    if (!mounted) return;
    _isSavingPassword.value = false;

    if (result['success'] == true) {
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      _setMsg(passwordSuccess: 'Password changed successfully');
    } else {
      _setMsg(passwordError: result['message'] ?? 'Failed to change password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                  children: [
                    // ── Profile avatar ──
                    _buildAvatarCard(),
                    const SizedBox(height: 24),

                    // ── Edit Profile ──
                    _buildSectionLabel('EDIT PROFILE'),
                    const SizedBox(height: 10),
                    _buildProfileForm(),
                    const SizedBox(height: 24),

                    // ── Change Password ──
                    _buildSectionLabel('CHANGE PASSWORD'),
                    const SizedBox(height: 10),
                    _buildPasswordForm(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: _navy.withValues(alpha: 0.08),
            child: const Icon(Icons.person_rounded, size: 36, color: _navy),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?.fullName ?? '—',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _dark),
                ),
                const SizedBox(height: 4),
                Text(_user?.email ?? '', style: const TextStyle(color: _slate, fontSize: 13)),
                if (_user?.studentId != null) ...[
                  const SizedBox(height: 4),
                  Text('ID: ${_user!.studentId}', style: const TextStyle(color: _slate, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
    );
  }

  Widget _buildProfileForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _profileFormKey,
        child: Column(
          children: [
            if (_profileError != null) _buildAlert(_profileError!, isError: true),
            if (_profileSuccess != null) _buildAlert(_profileSuccess!, isError: false),
            Row(
              children: [
                Expanded(child: _buildField(_firstNameCtrl, 'First Name', Icons.person_outline)),
                const SizedBox(width: 12),
                Expanded(child: _buildField(_lastNameCtrl, 'Last Name', Icons.badge_outlined)),
              ],
            ),
            const SizedBox(height: 14),
            _buildField(_emailCtrl, 'Email', Icons.alternate_email_rounded,
                kbType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _buildField(_studentIdCtrl, 'Student ID', Icons.numbers_rounded, required: false),
            const SizedBox(height: 14),
            _buildField(_departmentCtrl, 'Department', Icons.school_outlined, required: false),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: _isSavingProfile,
              builder: (_, saving, __) => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          children: [
            if (_passwordError != null) _buildAlert(_passwordError!, isError: true),
            if (_passwordSuccess != null) _buildAlert(_passwordSuccess!, isError: false),
            _buildPasswordField(_currentPassCtrl, 'Current Password', _obscureCurrent),
            const SizedBox(height: 14),
            _buildPasswordField(_newPassCtrl, 'New Password', _obscureNew, minLength: 6),
            const SizedBox(height: 14),
            _buildPasswordField(_confirmPassCtrl, 'Confirm New Password', _obscureConfirm, isConfirm: true),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: _isSavingPassword,
              builder: (_, saving, __) => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving ? null : _savePassword,
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? kbType,
    bool required = true,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: kbType,
      style: const TextStyle(fontWeight: FontWeight.w500, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _buildPasswordField(
    TextEditingController ctrl,
    String label,
    ValueNotifier<bool> obscure, {
    int minLength = 0,
    bool isConfirm = false,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: obscure,
      builder: (_, isObscure, __) => TextFormField(
        controller: ctrl,
        obscureText: isObscure,
        style: const TextStyle(fontWeight: FontWeight.w500, color: _dark),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
          suffixIcon: IconButton(
            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, size: 20, color: _slate),
            onPressed: () => obscure.value = !obscure.value,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          if (minLength > 0 && v.length < minLength) return 'Min $minLength characters';
          if (isConfirm && v != _newPassCtrl.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  Widget _buildAlert(String message, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isError ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red.shade700 : Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

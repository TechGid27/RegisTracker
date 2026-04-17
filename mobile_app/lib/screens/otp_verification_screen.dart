import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import 'login_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  static const int _resendCooldown = 60;
  static const Color primaryNavy = Color(0xFF1A237E);
  static const Color secondaryText = Color(0xFF64748B);

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isResending = ValueNotifier(false);
  final ValueNotifier<int> _countdown = ValueNotifier(_resendCooldown);

  String? _errorMessage;
  String? _successMessage;
  Timer? _countdownTimer;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _isLoading.dispose();
    _isResending.dispose();
    _countdown.dispose();
    _countdownTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown.value = _resendCooldown;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown.value <= 1) {
        t.cancel();
        _countdown.value = 0;
      } else {
        _countdown.value--;
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    setState(() {
      _successMessage = message;
      _errorMessage = null;
    });
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all fields are filled
    if (_otpValue.length == _otpLength) {
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    final otp = _otpValue;
    if (otp.length < _otpLength) {
      _showError('Please enter the complete 6-digit code');
      return;
    }

    _isLoading.value = true;
    if (_errorMessage != null) setState(() => _errorMessage = null);

    try {
      final result = await ApiService.verifyEmail(widget.email, otp);
      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccess('Email verified successfully!');
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      } else {
        _showError(result['message'] ?? 'Invalid or expired OTP');
        _clearOtp();
      }
    } catch (e) {
      _showError('Connection failed. Please try again.');
      _clearOtp();
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  Future<void> _handleResend() async {
    if (_countdown.value > 0) return;

    _isResending.value = true;
    try {
      final result = await ApiService.resendOtp(widget.email);
      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccess('A new code has been sent to your email');
        _clearOtp();
        _startCountdown();
      } else {
        _showError(result['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      _showError('Connection failed. Please try again.');
    } finally {
      if (mounted) _isResending.value = false;
    }
  }

  void _clearOtp() {
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
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
                constraints: const BoxConstraints(maxWidth: 450),
                child: RepaintBoundary(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    borderRadius: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _OtpHeader(),
                        const SizedBox(height: 8),
                        _buildEmailHint(),
                        const SizedBox(height: 32),

                        if (_errorMessage != null) _buildAlert(_errorMessage!, isError: true),
                        if (_successMessage != null) _buildAlert(_successMessage!, isError: false),

                        _buildOtpFields(),
                        const SizedBox(height: 32),

                        _buildVerifyButton(),
                        const SizedBox(height: 20),

                        _buildResendRow(),
                      ],
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

  Widget _buildEmailHint() {
    return Text(
      'Enter the 6-digit code sent to\n${widget.email}',
      textAlign: TextAlign.center,
      style: const TextStyle(color: secondaryText, fontSize: 14, height: 1.5),
    );
  }

  Widget _buildAlert(String message, {required bool isError}) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color.shade900, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) {
        return SizedBox(
          width: 46,
          height: 56,
          child: TextFormField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryNavy,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryNavy.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryNavy, width: 2),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) => _onOtpChanged(i, val),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, loading, _) {
        return FilledButton(
          onPressed: loading ? null : _handleVerify,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: primaryNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Verify Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        );
      },
    );
  }

  Widget _buildResendRow() {
    return ValueListenableBuilder(
      valueListenable: _countdown,
      builder: (context, seconds, _) {
        return ValueListenableBuilder(
          valueListenable: _isResending,
          builder: (context, resending, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't receive a code?", style: TextStyle(color: secondaryText)),
                const SizedBox(width: 4),
                if (resending)
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryNavy),
                  )
                else if (seconds > 0)
                  Text(
                    'Resend in ${seconds}s',
                    style: const TextStyle(color: secondaryText, fontWeight: FontWeight.w600),
                  )
                else
                  TextButton(
                    onPressed: _handleResend,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(
                      'Resend',
                      style: TextStyle(fontWeight: FontWeight.w900, color: primaryNavy),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OtpHeader extends StatelessWidget {
  const _OtpHeader();

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
          child: const Icon(Icons.mark_email_read_rounded, size: 40, color: Color(0xFF1A237E)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

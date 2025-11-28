import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/services/auth_service.dart';

enum PasswordResetStep { codeVerification, passwordUpdate }

class ForgotPasswordScreen extends StatefulWidget {
  final String email;
  final bool sendCodeOnInit;

  const ForgotPasswordScreen({
    super.key,
    required this.email,
    this.sendCodeOnInit = false,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  PasswordResetStep _step = PasswordResetStep.codeVerification;
  String? _bannerMessage;
  bool _isErrorMessage = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _isResettingPassword = false;
  String? _validatedCode;

  @override
  void initState() {
    super.initState();
    if (widget.sendCodeOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestCode());
    }
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showBanner(String message, {bool isError = false}) {
    setState(() {
      _bannerMessage = message;
      _isErrorMessage = isError;
    });
  }

  Future<void> _requestCode() async {
    setState(() => _isSendingCode = true);
    try {
      await AuthService.requestPasswordReset(widget.email);
      _showBanner('Hemos enviado un nuevo código a ${widget.email}.');
    } catch (_) {
      _showBanner('No pudimos enviar el código. Intenta nuevamente.',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _otpControllers.map((c) => c.text.trim()).join();
    final email = widget.email;

    if (code.length != 4 || code.contains(RegExp(r'[^0-9]'))) {
      _showBanner('Ingresa los 4 dígitos del código recibido.', isError: true);
      return;
    }

    setState(() => _isVerifyingCode = true);
    try {
      await AuthService.verifyResetCode(email, code);
      setState(() {
        _step = PasswordResetStep.passwordUpdate;
        _validatedCode = code;
      });
      _showBanner('Código verificado. Ahora ingresa tu nueva contraseña.');
    } catch (_) {
      _showBanner('El código no es válido o ha expirado.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isVerifyingCode = false);
      }
    }
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final email = widget.email;

    if (password.length < 8) {
      _showBanner('La contraseña debe tener al menos 8 caracteres.',
          isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showBanner('Las contraseñas no coinciden.', isError: true);
      return;
    }

    if (_validatedCode == null) {
      _showBanner('Primero verifica tu código de seguridad.', isError: true);
      return;
    }

    setState(() => _isResettingPassword = true);
    try {
      await AuthService.resetPasswordWithCode(email, _validatedCode!, password);
      _showBanner('Tu contraseña ha sido actualizada.');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      _showBanner('No pudimos actualizar la contraseña. Intenta nuevamente.',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  void _handleOtpChange(String value, int index) {
    if (value.length == 1 && index < _otpFocusNodes.length - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _step == PasswordResetStep.codeVerification
                    ? _buildVerificationCard(key: const ValueKey('code-card'))
                    : _buildUpdatePasswordCard(
                        key: const ValueKey('password-card'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard({Key? key}) {
    final emailPreview = widget.email;

    return Card(
      key: key,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.verified_user,
                  color: Colors.black38,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ingresa el código de verificación',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInlineBanner(),
            if (_bannerMessage != null) const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emailPreview,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isSendingCode ? null : _requestCode,
                  child: _isSendingCode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reenviar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: List.generate(
                4,
                (index) => SizedBox(
                  width: 56,
                  height: 64,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _handleOtpChange(value, index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isVerifyingCode ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isVerifyingCode
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatePasswordCard({Key? key}) {
    final userLabel = widget.email;

    return Card(
      key: key,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(Icons.person, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  userLabel,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Country user since April 2017',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Text(
                  'Actualiza tu contraseña',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa y confirma la nueva contraseña',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInlineBanner(),
            const SizedBox(height: 28),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter New Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isResettingPassword ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isResettingPassword
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineBanner() {
    if (_bannerMessage == null) {
      return const SizedBox.shrink();
    }
    final isError = _isErrorMessage;
    final bgColor = isError ? Colors.red[50] : Colors.grey[100];
    final iconData = isError ? Icons.error_outline : Icons.verified_outlined;
    final iconColor = isError ? Colors.red[600] : AppColors.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError ? Colors.red[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _bannerMessage!,
              style: TextStyle(
                color: isError ? Colors.red[800] : Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

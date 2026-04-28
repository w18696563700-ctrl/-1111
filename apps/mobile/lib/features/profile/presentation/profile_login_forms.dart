import 'package:flutter/material.dart';
import 'package:mobile/core/auth/auth_action_result_presenter.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';

class PhoneOtpLoginForm extends StatelessWidget {
  const PhoneOtpLoginForm({
    super.key,
    required this.mobileController,
    required this.otpController,
    required this.sending,
    required this.loggingIn,
    required this.agreedToLegal,
    required this.remainingSeconds,
    required this.coolingDown,
    required this.onSendOtp,
    required this.onLogin,
  });

  final TextEditingController mobileController;
  final TextEditingController otpController;
  final bool sending;
  final bool loggingIn;
  final bool agreedToLegal;
  final int remainingSeconds;
  final bool coolingDown;
  final VoidCallback onSendOtp;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _LoginTextField(
          controller: mobileController,
          icon: Icons.phone_iphone_rounded,
          label: '手机号',
          hintText: '请输入手机号',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _LoginTextField(
          controller: otpController,
          icon: Icons.password_rounded,
          label: '验证码',
          hintText: '请输入验证码',
          keyboardType: TextInputType.number,
          suffix: TextButton(
            onPressed: !agreedToLegal || sending || loggingIn || coolingDown
                ? null
                : onSendOtp,
            child: Text(
              authCooldownButtonLabel(
                sending: sending,
                remainingSeconds: remainingSeconds,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _PrimaryLoginButton(
          label: loggingIn ? '登录中' : '验证码登录',
          loading: loggingIn,
          onPressed: !agreedToLegal || sending || loggingIn ? null : onLogin,
        ),
      ],
    );
  }
}

class PasswordLoginForm extends StatelessWidget {
  const PasswordLoginForm({
    super.key,
    required this.mobileController,
    required this.passwordController,
    required this.loggingIn,
    required this.sending,
    required this.agreedToLegal,
    required this.passwordObscured,
    required this.onTogglePasswordVisible,
    required this.onLogin,
  });

  final TextEditingController mobileController;
  final TextEditingController passwordController;
  final bool loggingIn;
  final bool sending;
  final bool agreedToLegal;
  final bool passwordObscured;
  final VoidCallback onTogglePasswordVisible;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _LoginTextField(
          controller: mobileController,
          icon: Icons.phone_iphone_rounded,
          label: '手机号',
          hintText: '请输入手机号',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _LoginTextField(
          controller: passwordController,
          icon: Icons.lock_outline_rounded,
          label: '密码',
          hintText: '请输入登录密码',
          obscureText: passwordObscured,
          suffix: IconButton(
            tooltip: passwordObscured ? '显示密码' : '隐藏密码',
            onPressed: onTogglePasswordVisible,
            icon: Icon(
              passwordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        const SizedBox(height: 18),
        _PrimaryLoginButton(
          label: loggingIn ? '登录中' : '账号密码登录',
          loading: loggingIn,
          onPressed: !agreedToLegal || sending || loggingIn ? null : onLogin,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(ProfileIdentityRoutes.passwordReset),
            child: const Text('忘记密码'),
          ),
        ),
      ],
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.icon,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix == null
            ? null
            : Padding(padding: const EdgeInsets.only(right: 6), child: suffix),
        filled: true,
        fillColor: const Color(0xFFFFFCF8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE7DED2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE7DED2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFC17A22), width: 1.4),
        ),
      ),
    );
  }
}

class _PrimaryLoginButton extends StatelessWidget {
  const _PrimaryLoginButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFD8902E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE7D8C4),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

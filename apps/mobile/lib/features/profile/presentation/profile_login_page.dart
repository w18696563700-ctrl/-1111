import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/auth_action_result_presenter.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/auth/otp_send_cooldown_controller.dart';
import 'package:mobile/features/profile/presentation/profile_identity_legal_pages.dart';
import 'package:mobile/features/profile/presentation/profile_login_forms.dart';
import 'package:mobile/features/profile/presentation/profile_login_frame.dart';
import 'package:mobile/features/profile/presentation/profile_login_notice.dart';
import 'package:mobile/features/profile/presentation/profile_login_types.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class OnePageLoginEntryPage extends StatefulWidget {
  const OnePageLoginEntryPage({super.key});

  @override
  State<OnePageLoginEntryPage> createState() => _LoginEntryPageState();
}

class _LoginEntryPageState extends State<OnePageLoginEntryPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final OtpSendCooldownController _cooldownController =
      OtpSendCooldownController();
  AuthActionResult<OtpSendView>? _sendResult;
  AuthActionResult<SessionEnvelope>? _loginResult;
  AuthActionKind _loginResultKind = AuthActionKind.login;
  LoginEntryMode _mode = LoginEntryMode.otp;
  bool _sending = false;
  bool _loggingIn = false;
  bool _agreedToLegal = false;
  bool _passwordObscured = true;
  String? _lastOtpSendMobile;

  @override
  void dispose() {
    _cooldownController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_sending || _loggingIn || _cooldownController.isCoolingDown) {
      return;
    }
    if (!_ensureLegalAccepted()) {
      return;
    }
    setState(() {
      _sending = true;
      _sendResult = null;
    });

    final result = await AuthConsumerLayer.instance.sendOtp(
      mobile: _mobileController.text,
    );
    if (!mounted) {
      return;
    }
    if (result.state == AppPageState.content && result.data != null) {
      _cooldownController.start(result.data!.cooldownSeconds);
      _lastOtpSendMobile = _mobileController.text.trim();
    }
    setState(() {
      _sendResult = result;
      _sending = false;
    });
  }

  Future<void> _loginWithOtp() async {
    if (!_ensureLegalAccepted()) {
      return;
    }
    setState(() {
      _loggingIn = true;
      _loginResult = null;
      _loginResultKind = AuthActionKind.login;
    });

    final result = await AuthConsumerLayer.instance.loginWithOtp(
      mobile: _mobileController.text,
      otpCode: _otpController.text,
      consentAccepted: _agreedToLegal,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _loginResult = result;
      _loggingIn = false;
    });
    await _completeLogin(result);
  }

  Future<void> _loginWithPassword() async {
    if (!_ensureLegalAccepted()) {
      return;
    }
    setState(() {
      _loggingIn = true;
      _loginResult = null;
      _loginResultKind = AuthActionKind.passwordLogin;
    });

    final result = await AuthConsumerLayer.instance.loginWithPassword(
      mobile: _mobileController.text,
      password: _passwordController.text,
      consentAccepted: _agreedToLegal,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _loginResult = result;
      _loggingIn = false;
    });
    await _completeLogin(result);
  }

  Future<void> _completeLogin(AuthActionResult<SessionEnvelope> result) async {
    final session = result.data;
    if (result.state != AppPageState.content || session == null) {
      return;
    }
    await AppShellScope.read(context).bootstrapAfterLogin(
      shellBootstrapState: session.shellBootstrapState ?? 'authenticated',
    );
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  void _selectMode(LoginEntryMode mode) {
    if (_mode == mode) {
      return;
    }
    setState(() {
      _mode = mode;
      _sendResult = null;
      _loginResult = null;
    });
  }

  bool _ensureLegalAccepted() {
    if (_agreedToLegal) {
      return true;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('请先勾选并同意《用户协议》《隐私政策》')));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFFFFBF4), Color(0xFFF8F4ED)],
        ),
      ),
      child: AnimatedBuilder(
        animation: _cooldownController,
        builder: (BuildContext context, Widget? child) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 118),
            children: <Widget>[
              const LoginHeroHeader(),
              Transform.translate(
                offset: const Offset(0, -30),
                child: AuthLoginCard(
                  mode: _mode,
                  onModeChanged: _selectMode,
                  agreement: LoginLegalEntryStrip(
                    agreed: _agreedToLegal,
                    onChanged: (bool value) {
                      setState(() {
                        _agreedToLegal = value;
                      });
                    },
                  ),
                  notice: LoginNotice(
                    sendResult: _sendResult,
                    loginResult: _loginResult,
                    loginResultKind: _loginResultKind,
                    lastOtpSendMobile: _lastOtpSendMobile,
                    mobileText: _mobileController.text,
                    remainingSeconds: _cooldownController.remainingSeconds,
                  ),
                  child: _mode == LoginEntryMode.otp
                      ? PhoneOtpLoginForm(
                          mobileController: _mobileController,
                          otpController: _otpController,
                          sending: _sending,
                          loggingIn: _loggingIn,
                          agreedToLegal: _agreedToLegal,
                          remainingSeconds:
                              _cooldownController.remainingSeconds,
                          coolingDown: _cooldownController.isCoolingDown,
                          onSendOtp: _sendOtp,
                          onLogin: _loginWithOtp,
                        )
                      : PasswordLoginForm(
                          mobileController: _mobileController,
                          passwordController: _passwordController,
                          loggingIn: _loggingIn,
                          sending: _sending,
                          agreedToLegal: _agreedToLegal,
                          passwordObscured: _passwordObscured,
                          onTogglePasswordVisible: () {
                            setState(() {
                              _passwordObscured = !_passwordObscured;
                            });
                          },
                          onLogin: _loginWithPassword,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_action_result_presenter.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/auth/otp_send_cooldown_controller.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final OtpSendCooldownController _cooldownController =
      OtpSendCooldownController();

  AuthActionResult<OtpSendView>? _sendResult;
  AuthActionResult<ActionAckView>? _resetResult;
  bool _sending = false;
  bool _submitting = false;
  String? _lastOtpSendMobile;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _cooldownController.dispose();
    super.dispose();
  }

  Future<void> _sendResetOtp() async {
    if (_sending || _submitting || _cooldownController.isCoolingDown) {
      return;
    }

    setState(() {
      _sending = true;
      _sendResult = null;
    });

    final result = await AuthConsumerLayer.instance.sendOtp(
      mobile: _mobileController.text,
      scene: 'password_reset',
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

  Future<void> _resetPassword() async {
    if (_sending || _submitting) {
      return;
    }

    setState(() {
      _submitting = true;
      _resetResult = null;
    });

    final result = await AuthConsumerLayer.instance.resetPassword(
      mobile: _mobileController.text,
      otpCode: _otpController.text,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _resetResult = result;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _PasswordHeroCard(
          title: '忘记密码',
          summary: '当前页面只承接手机号验证后的重置密码闭环。成功后不会自动登录，也不会创建新账号。',
        ),
        const SizedBox(height: 16),
        _PasswordSurfaceCard(
          title: 'OTP 验证后重置密码',
          child: AnimatedBuilder(
            animation: _cooldownController,
            builder: (BuildContext context, Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: '手机号',
                      hintText: '请输入当前账号手机号',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '验证码',
                      hintText: '请输入重置密码验证码',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '新密码',
                      hintText: '请输入新的登录密码',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton(
                        onPressed:
                            _sending ||
                                _submitting ||
                                _cooldownController.isCoolingDown
                            ? null
                            : _sendResetOtp,
                        child: Text(
                          authCooldownButtonLabel(
                            sending: _sending,
                            remainingSeconds:
                                _cooldownController.remainingSeconds,
                          ),
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: _sending || _submitting
                            ? null
                            : _resetPassword,
                        child: Text(_submitting ? '提交中' : '重置密码'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '忘记密码继续复用现有 OTP 发送链，但发送场景固定为 password_reset。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            },
          ),
        ),
        if (_sendResult != null) ...<Widget>[
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _cooldownController,
            builder: (BuildContext context, Widget? child) =>
                _PasswordStateCard(
                  title: _sendResult!.state == AppPageState.content
                      ? '重置验证码已发送'
                      : authActionFailureTitle(
                          _sendResult!,
                          kind: AuthActionKind.sendOtp,
                        ),
                  message: _sendResult!.state == AppPageState.content
                      ? authActionSuccessMessageForOtpSend(
                          mobile:
                              _lastOtpSendMobile ??
                              _mobileController.text.trim(),
                          remainingSeconds:
                              _cooldownController.remainingSeconds,
                          traceId: _sendResult!.data!.traceId,
                        )
                      : authActionFailureMessage(
                          _sendResult!,
                          kind: AuthActionKind.sendOtp,
                        ),
                ),
          ),
        ],
        if (_resetResult != null) ...<Widget>[
          const SizedBox(height: 16),
          _PasswordStateCard(
            title: _resetResult!.state == AppPageState.content
                ? '密码已重置'
                : authActionFailureTitle(
                    _resetResult!,
                    kind: AuthActionKind.passwordReset,
                  ),
            message: _resetResult!.state == AppPageState.content
                ? '当前密码已更新，请返回登录入口使用账号密码登录。受理编号：${_resetResult!.data!.traceId}。页面不会自动登录。'
                : authActionFailureMessage(
                    _resetResult!,
                    kind: AuthActionKind.passwordReset,
                  ),
          ),
        ],
      ],
    );
  }
}

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  AuthActionResult<ActionAckView>? _setResult;
  bool _submitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    if (_submitting || !AppSessionStore.instance.hasAnySession) {
      return;
    }

    setState(() {
      _submitting = true;
      _setResult = null;
    });

    final result = await AuthConsumerLayer.instance.setPassword(
      newPassword: _newPasswordController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _setResult = result;
      _submitting = false;
    });

    if (result.state == AppPageState.content) {
      AppSessionStore.instance.markPasswordSetupPromptDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSessionStore.instance,
      builder: (BuildContext context, Widget? child) {
        final hasSession = AppSessionStore.instance.hasAnySession;
        final isOtpLoginSession = AppSessionStore.instance.isOtpLoginSession;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: <Widget>[
            const _PasswordHeroCard(
              title: '设置登录密码',
              summary: '当前页面只服务已登录账号补齐账号密码登录能力，不作为注册入口，也不会扩成账号中心。',
            ),
            const SizedBox(height: 16),
            if (!hasSession)
              _PasswordStateCard(
                title: '当前会话暂不可用',
                message: '设置登录密码只对当前已登录账号开放。当前页不会把补齐密码伪装成注册入口。',
                footer: FilledButton.tonal(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(ProfileIdentityRoutes.login),
                  child: const Text('进入登录入口'),
                ),
              )
            else if (!isOtpLoginSession)
              const _PasswordStateCard(
                title: '当前会话不需要设置密码',
                message:
                    '设置登录密码只对当前验证码登录会话开放。当前账号若已通过账号密码登录进入，这一入口不会继续显示成可补齐状态。',
              )
            else
              _PasswordSurfaceCard(
                title: '补齐账号密码登录能力',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '新密码',
                        hintText: '请输入新的登录密码',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _submitting ? null : _setPassword,
                      child: Text(_submitting ? '提交中' : '设置密码'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '当前页只承接已登录账号的补齐密码动作，后续可回到登录页使用账号密码登录。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            if (_setResult != null) ...<Widget>[
              const SizedBox(height: 16),
              _PasswordStateCard(
                title: _setResult!.state == AppPageState.content
                    ? '密码已设置'
                    : authActionFailureTitle(
                        _setResult!,
                        kind: AuthActionKind.passwordSet,
                      ),
                message: _setResult!.state == AppPageState.content
                    ? '当前账号已补齐账号密码登录能力。受理编号：${_setResult!.data!.traceId}。页面不会把这一步展示成注册完成。'
                    : authActionFailureMessage(
                        _setResult!,
                        kind: AuthActionKind.passwordSet,
                      ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PasswordHeroCard extends StatelessWidget {
  const _PasswordHeroCard({required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordSurfaceCard extends StatelessWidget {
  const _PasswordSurfaceCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _PasswordStateCard extends StatelessWidget {
  const _PasswordStateCard({
    required this.title,
    required this.message,
    this.footer,
  });

  final String title;
  final String message;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            if (footer != null) ...<Widget>[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

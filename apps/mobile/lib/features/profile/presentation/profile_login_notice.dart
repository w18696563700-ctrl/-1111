import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/auth_contract.dart';
import 'package:mobile/core/auth/auth_action_result_presenter.dart';

class LoginNotice extends StatelessWidget {
  const LoginNotice({
    super.key,
    required this.sendResult,
    required this.loginResult,
    required this.loginResultKind,
    required this.lastOtpSendMobile,
    required this.mobileText,
    required this.remainingSeconds,
  });

  final AuthActionResult<OtpSendView>? sendResult;
  final AuthActionResult<SessionEnvelope>? loginResult;
  final AuthActionKind loginResultKind;
  final String? lastOtpSendMobile;
  final String mobileText;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final notices = <Widget>[];
    final currentSendResult = sendResult;
    if (currentSendResult != null) {
      notices.add(
        _NoticePanel(
          success: currentSendResult.state == AppPageState.content,
          title: currentSendResult.state == AppPageState.content
              ? '验证码已发送'
              : authActionFailureTitle(
                  currentSendResult,
                  kind: AuthActionKind.sendOtp,
                ),
          message: currentSendResult.state == AppPageState.content
              ? authActionSuccessMessageForOtpSend(
                  mobile: lastOtpSendMobile ?? mobileText,
                  remainingSeconds: remainingSeconds,
                  traceId: currentSendResult.data!.traceId,
                )
              : authActionFailureMessage(
                  currentSendResult,
                  kind: AuthActionKind.sendOtp,
                ),
        ),
      );
    }
    final currentLoginResult = loginResult;
    if (currentLoginResult != null) {
      notices.add(
        _NoticePanel(
          success: currentLoginResult.state == AppPageState.content,
          title: currentLoginResult.state == AppPageState.content
              ? '登录已进入壳层承接'
              : authActionFailureTitle(
                  currentLoginResult,
                  kind: loginResultKind,
                ),
          message: currentLoginResult.state == AppPageState.content
              ? authActionSuccessMessageForShell(currentLoginResult.data!)
              : authActionFailureMessage(
                  currentLoginResult,
                  kind: loginResultKind,
                ),
        ),
      );
    }
    if (notices.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        ...notices.expand(
          (Widget item) => <Widget>[item, const SizedBox(height: 8)],
        ),
      ],
    );
  }
}

class _NoticePanel extends StatelessWidget {
  const _NoticePanel({
    required this.success,
    required this.title,
    required this.message,
  });

  final bool success;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = success ? const Color(0xFF8A5B14) : const Color(0xFFB3261E);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: success ? const Color(0xFFFFF6E8) : const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              success ? Icons.check_circle_outline : Icons.info_outline,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

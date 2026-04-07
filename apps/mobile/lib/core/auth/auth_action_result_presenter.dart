import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';

enum AuthActionKind { sendOtp, login, refresh, logout }

String authActionFailureTitle<T>(
  AuthActionResult<T> result, {
  required AuthActionKind kind,
}) {
  if (_isRateLimited(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送过于频繁',
      AuthActionKind.login => '登录请求过于频繁',
      AuthActionKind.refresh => '登录刷新过于频繁',
      AuthActionKind.logout => '退出请求过于频繁',
    };
  }

  if (_isUnavailable(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送暂不可用',
      AuthActionKind.login => '登录能力暂不可用',
      AuthActionKind.refresh => '登录刷新暂不可用',
      AuthActionKind.logout => '退出能力暂不可用',
    };
  }

  if (_isUnauthorized(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送当前未授权',
      AuthActionKind.login => '登录当前未通过校验',
      AuthActionKind.refresh => '登录刷新当前未授权',
      AuthActionKind.logout => '退出当前未授权',
    };
  }

  if (_isRequestInvalid(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送信息待补全',
      AuthActionKind.login => '登录信息待补全',
      AuthActionKind.refresh => '登录刷新信息待补全',
      AuthActionKind.logout => '退出信息待补全',
    };
  }

  return switch (kind) {
    AuthActionKind.sendOtp => '验证码发送当前未完成',
    AuthActionKind.login => '登录承接当前未完成',
    AuthActionKind.refresh => '登录刷新当前未完成',
    AuthActionKind.logout => '退出承接当前未完成',
  };
}

String authActionFailureMessage<T>(
  AuthActionResult<T> result, {
  required AuthActionKind kind,
}) {
  final rawMessage = result.message?.trim();
  final base = rawMessage != null && rawMessage.isNotEmpty
      ? rawMessage
      : _fallbackFailureMessage(result.state, kind);
  final errorCode = result.errorCode?.trim();
  if (errorCode == null || errorCode.isEmpty) {
    return base;
  }
  return '$base（错误代码：$errorCode）';
}

String authActionSuccessMessageForShell(SessionEnvelope envelope) {
  return '当前 shellBootstrapState 为 ${envelope.shellBootstrapState ?? 'authenticated'}，页面将继续进入对应壳层承接。';
}

String authActionSuccessMessageForOtpSend({
  required String mobile,
  required int remainingSeconds,
  required String traceId,
}) {
  final maskedMobile = _maskMobile(mobile);
  if (remainingSeconds > 0) {
    return '已向 $maskedMobile 发起验证码发送承接。当前 $remainingSeconds 秒内不再重复发送。traceId $traceId。';
  }
  return '已向 $maskedMobile 发起验证码发送承接。当前可重新发送验证码。traceId $traceId。';
}

String authCooldownButtonLabel({
  required bool sending,
  required int remainingSeconds,
}) {
  if (sending) {
    return '发送中';
  }
  if (remainingSeconds > 0) {
    return '$remainingSeconds 秒后重发';
  }
  return '发送验证码';
}

String _fallbackFailureMessage(AppPageState state, AuthActionKind kind) {
  return switch (state) {
    AppPageState.unauthorized => '当前登录态未通过校验，请重新尝试。',
    AppPageState.forbidden => '当前账号暂不能执行该登录操作。',
    AppPageState.notFound => '当前登录路径暂未承接。',
    AppPageState.errorRetryable => switch (kind) {
      AuthActionKind.sendOtp => '当前验证码发送暂未成功，请稍后重试。',
      AuthActionKind.login => '当前登录暂未成功，请稍后重试。',
      AuthActionKind.refresh => '当前登录刷新暂未成功，请稍后重试。',
      AuthActionKind.logout => '当前退出暂未成功，请稍后重试。',
    },
    AppPageState.errorNonRetryable => '当前请求处于受控失败态，请检查输入后重试。',
    _ => '当前内容正在准备中。',
  };
}

bool _isRateLimited<T>(AuthActionResult<T> result) {
  return result.errorCode == 'AUTH_RATE_LIMITED';
}

bool _isUnavailable<T>(AuthActionResult<T> result) {
  return result.errorCode == 'AUTH_RESOURCE_UNAVAILABLE' ||
      result.state == AppPageState.notFound;
}

bool _isUnauthorized<T>(AuthActionResult<T> result) {
  return result.errorCode == 'AUTH_LOGIN_INVALID' ||
      result.errorCode == 'AUTH_SESSION_INVALID' ||
      result.errorCode == 'AUTH_PERMISSION_INSUFFICIENT' ||
      result.state == AppPageState.unauthorized ||
      result.state == AppPageState.forbidden;
}

bool _isRequestInvalid<T>(AuthActionResult<T> result) {
  return result.errorCode == 'AUTH_REQUEST_INVALID' ||
      result.state == AppPageState.errorNonRetryable;
}

String _maskMobile(String mobile) {
  final digits = mobile.replaceAll(RegExp(r'\s+'), '');
  if (digits.length < 7) {
    return digits;
  }
  final prefix = digits.substring(0, 3);
  final suffix = digits.substring(digits.length - 4);
  return '$prefix****$suffix';
}

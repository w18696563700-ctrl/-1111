import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';

enum AuthActionKind {
  sendOtp,
  login,
  passwordLogin,
  passwordReset,
  passwordSet,
  refresh,
  logout,
}

String authActionFailureTitle<T>(
  AuthActionResult<T> result, {
  required AuthActionKind kind,
}) {
  final overrideTitle = _overrideFailureTitle(result, kind);
  if (overrideTitle != null) {
    return overrideTitle;
  }

  if (_isRateLimited(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送过于频繁',
      AuthActionKind.login => '登录请求过于频繁',
      AuthActionKind.passwordLogin => '账号密码登录请求过于频繁',
      AuthActionKind.passwordReset => '重置密码请求过于频繁',
      AuthActionKind.passwordSet => '设置密码请求过于频繁',
      AuthActionKind.refresh => '登录刷新过于频繁',
      AuthActionKind.logout => '退出请求过于频繁',
    };
  }

  if (_isUnavailable(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送暂不可用',
      AuthActionKind.login => '登录能力暂不可用',
      AuthActionKind.passwordLogin => '账号密码登录暂不可用',
      AuthActionKind.passwordReset => '重置密码能力暂不可用',
      AuthActionKind.passwordSet => '设置密码能力暂不可用',
      AuthActionKind.refresh => '登录刷新暂不可用',
      AuthActionKind.logout => '退出能力暂不可用',
    };
  }

  if (_isUnauthorized(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送当前未授权',
      AuthActionKind.login => '登录当前未通过校验',
      AuthActionKind.passwordLogin => '账号密码当前未通过校验',
      AuthActionKind.passwordReset => '重置密码当前未通过校验',
      AuthActionKind.passwordSet => '设置密码当前未授权',
      AuthActionKind.refresh => '登录刷新当前未授权',
      AuthActionKind.logout => '退出当前未授权',
    };
  }

  if (_isRequestInvalid(result)) {
    return switch (kind) {
      AuthActionKind.sendOtp => '验证码发送信息待补全',
      AuthActionKind.login => '登录信息待补全',
      AuthActionKind.passwordLogin => '账号密码登录信息待补全',
      AuthActionKind.passwordReset => '重置密码信息待补全',
      AuthActionKind.passwordSet => '设置密码信息待补全',
      AuthActionKind.refresh => '登录刷新信息待补全',
      AuthActionKind.logout => '退出信息待补全',
    };
  }

  return switch (kind) {
    AuthActionKind.sendOtp => '验证码发送当前未完成',
    AuthActionKind.login => '登录承接当前未完成',
    AuthActionKind.passwordLogin => '账号密码登录当前未完成',
    AuthActionKind.passwordReset => '重置密码当前未完成',
    AuthActionKind.passwordSet => '设置密码当前未完成',
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
  if (errorCode == 'AUTH_OTP_SEND_LIMIT_REACHED') {
    return base;
  }
  final localizedCode = _localizedAuthErrorCode(errorCode);
  if (localizedCode == null || localizedCode.isEmpty) {
    return base;
  }
  return '$base（原因：$localizedCode）';
}

String authActionSuccessMessageForShell(SessionEnvelope envelope) {
  final bootstrapState = _localizedShellBootstrapState(
    envelope.shellBootstrapState,
  );
  return '登录已完成，页面将进入$bootstrapState。';
}

String authActionSuccessMessageForOtpSend({
  required String mobile,
  required int remainingSeconds,
  required String traceId,
}) {
  final maskedMobile = _maskMobile(mobile);
  final traceLabel = _shortTraceId(traceId);
  if (remainingSeconds > 0) {
    return '验证码已发送至 $maskedMobile，$remainingSeconds 秒后可重新发送。受理编号：$traceLabel。';
  }
  return '验证码已发送至 $maskedMobile，现在可以重新发送。受理编号：$traceLabel。';
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
      AuthActionKind.passwordLogin => '当前账号密码登录暂未成功，请稍后重试。',
      AuthActionKind.passwordReset => '当前重置密码暂未成功，请稍后重试。',
      AuthActionKind.passwordSet => '当前设置密码暂未成功，请稍后重试。',
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
      result.errorCode == 'AUTH_PASSWORD_LOGIN_INVALID' ||
      result.errorCode == 'AUTH_PASSWORD_RESET_OTP_INVALID' ||
      result.errorCode == 'AUTH_SESSION_INVALID' ||
      result.errorCode == 'AUTH_PERMISSION_INSUFFICIENT' ||
      result.state == AppPageState.unauthorized ||
      result.state == AppPageState.forbidden;
}

bool _isRequestInvalid<T>(AuthActionResult<T> result) {
  return result.errorCode == 'AUTH_REQUEST_INVALID' ||
      result.errorCode == 'AUTH_CONSENT_REQUIRED' ||
      result.errorCode == 'AUTH_PASSWORD_POLICY_INVALID' ||
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

String? _localizedAuthErrorCode(String errorCode) {
  return switch (errorCode) {
    'AUTH_RESOURCE_UNAVAILABLE' => '服务暂不可用',
    'AUTH_RATE_LIMITED' => '请求过于频繁',
    'AUTH_OTP_SEND_LIMIT_REACHED' => '手机号验证码次数已达上限',
    'AUTH_LOGIN_INVALID' => '验证码错误或已失效',
    'AUTH_PASSWORD_LOGIN_INVALID' => '手机号或密码错误',
    'AUTH_PASSWORD_NOT_SET' => '当前手机号尚未设置密码',
    'AUTH_PASSWORD_SET_NOT_ALLOWED' => '当前账号暂不能设置密码',
    'AUTH_PASSWORD_RESET_OTP_INVALID' => '重置验证码错误或已失效',
    'AUTH_PASSWORD_POLICY_INVALID' => '新密码不符合当前规则',
    'AUTH_SESSION_INVALID' => '登录状态已失效',
    'AUTH_PERMISSION_INSUFFICIENT' => '当前账号权限不足',
    'AUTH_CONSENT_REQUIRED' => '请先同意协议',
    'AUTH_REQUEST_INVALID' => '请求信息不完整',
    _ => null,
  };
}

String _localizedShellBootstrapState(String? value) {
  return switch (value?.trim()) {
    'no_organization' => '展览首页',
    'authenticated' || null => '首页',
    _ => '下一步承接页',
  };
}

String _shortTraceId(String traceId) {
  final normalized = traceId.trim();
  if (normalized.isEmpty) {
    return '未生成';
  }
  if (normalized.length <= 12) {
    return normalized;
  }
  return '${normalized.substring(0, 6)}...${normalized.substring(normalized.length - 4)}';
}

String? _overrideFailureTitle<T>(
  AuthActionResult<T> result,
  AuthActionKind kind,
) {
  return switch (result.errorCode) {
    'AUTH_PASSWORD_NOT_SET' when kind == AuthActionKind.passwordLogin =>
      '当前账号尚未设置密码',
    'AUTH_OTP_SEND_LIMIT_REACHED' when kind == AuthActionKind.sendOtp =>
      '当前手机号验证码次数已达上限',
    'AUTH_PASSWORD_SET_NOT_ALLOWED' when kind == AuthActionKind.passwordSet =>
      '当前账号暂不能设置密码',
    'AUTH_PASSWORD_POLICY_INVALID' when
        kind == AuthActionKind.passwordReset ||
            kind == AuthActionKind.passwordSet =>
      '新密码不符合要求',
    'AUTH_PASSWORD_RESET_OTP_INVALID' => '重置验证码未通过校验',
    _ => null,
  };
}

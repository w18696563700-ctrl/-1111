String authFallbackMessage({
  required String canonicalPath,
  required int statusCode,
}) {
  return switch (statusCode) {
    400 => switch (canonicalPath) {
      '/api/app/auth/otp/send' => '当前验证码发送请求无效，请检查后重试。',
      '/api/app/auth/otp/login' => '当前登录请求无效，请检查后重试。',
      '/api/app/auth/refresh' => '当前刷新请求无效，请检查后重试。',
      '/api/app/auth/logout' => '当前退出请求无效，请检查后重试。',
      _ => '当前请求无效，请检查后重试。',
    },
    401 => switch (canonicalPath) {
      '/api/app/auth/otp/login' => '当前验证码错误或已失效，请重试。',
      '/api/app/auth/refresh' ||
      '/api/app/auth/logout' => '当前登录态不可用，请重新登录或刷新后再试。',
      _ => '当前会话未授权。',
    },
    403 => '当前账号暂不可执行。',
    404 => '当前路径暂未承接。',
    429 => switch (canonicalPath) {
      '/api/app/auth/otp/send' => '验证码发送过于频繁，请稍后再试。',
      '/api/app/auth/otp/login' => '当前登录请求过于频繁，请稍后再试。',
      _ => '当前请求过于频繁，请稍后再试。',
    },
    503 => switch (canonicalPath) {
      '/api/app/auth/otp/send' => '当前验证码发送能力暂不可用，请稍后再试。',
      '/api/app/auth/otp/login' => '当前登录能力暂不可用，请稍后再试。',
      '/api/app/auth/refresh' => '当前登录刷新能力暂不可用，请稍后再试。',
      '/api/app/auth/logout' => '当前退出能力暂不可用，请稍后再试。',
      _ => '当前认证能力暂不可用，请稍后再试。',
    },
    final int code when code >= 500 => '当前请求暂时没有成功。',
    _ => '当前请求处于受控失败态。',
  };
}

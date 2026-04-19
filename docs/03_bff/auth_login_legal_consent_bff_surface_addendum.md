# 《auth login legal consent bff surface addendum》

## purpose
- Freeze the minimum BFF forwarding rule for login-time legal consent.

## current rule
- BFF keeps the existing `/api/app/auth/otp/login` route.
- BFF forwards `consentAccepted` to Server as part of the same request body.
- BFF does not stamp versions and does not persist consent truth.

## error mapping
- When Server returns `AUTH_CONSENT_REQUIRED`, BFF must preserve the code and normalize the app-facing message to:
  - `请先阅读并同意《用户协议》《隐私政策》。`

## no-go
- No second consent endpoint.
- No BFF-owned consent state.

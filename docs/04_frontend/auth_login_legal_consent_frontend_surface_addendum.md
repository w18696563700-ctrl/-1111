# 《auth login legal consent frontend surface addendum》

## purpose
- Freeze the minimum Flutter consumption rule for login-time legal consent.

## current rule
- Login page must expose clickable:
  - `《用户协议》`
  - `《隐私政策》`
- Login page must expose an explicit checkbox consent control.
- Before the checkbox is checked:
  - `发送验证码` stays disabled
  - `验证码登录 / 注册` stays disabled
- App-facing login request must carry `consentAccepted=true` after the checkbox is checked.

## no-go
- No default pre-checked consent.
- No hidden auto-consent.
- No widening to third-party login.

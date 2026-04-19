# 《账号登录法律同意最小闭环补充冻结单》

## 1. purpose
- Freeze the minimum truth for login-time legal consent under the current OTP-only login chain.

## 2. current round decision
- No new auth path family is introduced.
- Consent is attached to the existing `POST /api/app/auth/otp/login` path only.
- Flutter App remains checkbox-gated before auth actions unlock.
- BFF forwards the consent carrier only and does not own consent truth.
- Server stamps the active `agreement_version` and `privacy_version`, persists `agreed_at`, and appends audit together with login success.

## 3. current minimum truth
- App-facing login request must carry `consentAccepted=true`.
- Server must reject OTP login when `consentAccepted` is absent or not `true`.
- Session truth must persist:
  - `agreement_version`
  - `privacy_version`
  - `agreed_at`
- Audit must remain append-only and must include the persisted consent snapshot in the successful login audit chain.

## 4. no-go
- No second consent table in the current round.
- No passive inference that “client showed docs” equals consent truth.
- No third-party login widening.
- No BFF-owned consent state.

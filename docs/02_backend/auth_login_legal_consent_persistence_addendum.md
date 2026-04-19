# 《auth login legal consent backend truth addendum》

## purpose
- Freeze the backend persistence and audit boundary for login-time legal consent in the current OTP login round.

## persistence carrier
- Reuse `sessions`.
- Add only:
  - `agreement_version`
  - `privacy_version`
  - `agreed_at`

## write rule
- Consent truth is written only when `otp/login` succeeds.
- `agreed_at` is server-stamped time.
- `agreement_version` and `privacy_version` come from active Server runtime truth.

## audit rule
- No second audit carrier is introduced.
- Existing `audit_logs` remains the only append-only audit carrier.
- `login_success` audit must include:
  - `agreementVersion`
  - `privacyVersion`
  - `agreedAt`

## no-go
- No standalone consent history table in this round.
- No client-stamped `agreed_at`.
- No refresh-time consent rewrite.

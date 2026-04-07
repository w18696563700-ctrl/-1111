---
owner: Codex 总控
status: frozen
purpose: Freeze a dev-only minimum test channel so the current manual testing round can continue without opening the full auth or shell board and without derailing the project-publish minimum corridor mainline.
layer: L0 SSOT
alignment_basis:
  - AGENTS.md
  - docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_source_implementation_validation_signoff.md
freeze_date_local: 2026-04-02
---

# 开发态测试通道最小闭环冻结补充单

## 1. Scope

- This addendum freezes a dev-only auxiliary test channel.
- It exists only to unblock the current manual testing round.
- It is subordinate to the current mainline:
  - `项目发布最小走廊 / development-stage integration validation round`
- It does not open:
  - the full auth OTP board
  - the full shell-context board
  - the full exhibition workbench board
  - production login capability
  - release-stage readiness

## 2. Current Blocking Facts

- The current debug button on the login page is named:
  - `测试通道直接进入`
- But the current implementation is not a true direct-entry path.
- It currently still depends on:
  - `POST /api/app/auth/otp/send`
  - `POST /api/app/auth/otp/login`
- Current development runtime on `47.108.180.198` does not implement the
  required auth truth chain:
  - `Cannot POST /server/auth/otp/send`
  - `Cannot POST /server/auth/otp/login`
- Current development runtime also does not implement shell bootstrap truth:
  - `Cannot GET /server/shell/context`
- Current development runtime does not currently provide the release guard
  truth used by the project-create page:
  - `GET /api/app/exhibition/workbench` is unavailable

## 3. Total-control Ruling

- The current testing blocker must not be solved by opening the entire auth
  board.
- The current testing blocker must not be solved by pretending OTP login is
  already complete.
- The current testing blocker must not drag the project-publish mainline into:
  - auth send/login implementation
  - shell context implementation
  - organization handoff implementation
  - workbench-board implementation
- Therefore the effective control ruling is:
  - create a dev-only auxiliary test channel
  - keep the product auth family frozen and unfinished
  - keep the project-publish mainline active

## 4. Effective Priority

- For the current test-blocking issue, the active control chain is:
  - this dev-only auxiliary test-channel freeze
- For product identity and certification truth, the active control chain remains:
  - `account_login_identity_permission_minimum_freeze_addendum.md`
  - `account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md`
- This means:
  - the test channel may unblock manual testing
  - it may not be reported as product login completion

## 5. Allowed Dev-only Goal

- The only allowed dev-only goal is:
  - let the operator reach the current project-publish minimum corridor for
    manual testing
- The allowed target route family is limited to:
  - `/exhibition/projects/create`
  - create success continuation to project detail
  - upload init -> direct upload -> confirm continuation

## 6. Allowed Dev-only Mechanics

- The dev-only test channel may:
  - exist only behind `kDebugMode`
  - install the approved development base URL override for current testing
  - establish a local dev-only session carrier for the Flutter client
  - inject a local dev-only shell context snapshot for the current route handoff
  - bypass the current unavailable workbench guard only under an explicit
    dev-test-channel flag
- The dev-only test channel must not:
  - call unfinished OTP send/login routes and then claim success
  - pretend `/api/app/shell/context` has been completed
  - pretend `/api/app/exhibition/workbench` has been completed
  - create a second public auth route family
  - expose `/server/*` internal truth paths to Flutter

## 7. Mandatory Boundary Labels

- The UI copy for this channel must clearly state:
  - this is a development-stage test channel
  - this is not formal login completion
  - this is not production authentication
  - this bypass exists only because current auth, shell, and workbench truths
    are not yet closed
- It must not be described as:
  - 登录成功
  - 正式账号进入
  - 正式认证完成

## 8. Mainline Protection

- The current project-publish mainline remains:
  - backend truth
  - BFF corridor
  - frontend consumption
  - development-stage integration validation
- This dev-only test channel is only an auxiliary unblocker for manual testing.
- It must not absorb:
  - bid
  - order
  - contract
  - milestone
  - inspection
  - rating
  - dispute
- It must also not absorb:
  - full auth OTP implementation
  - shell context implementation
  - workbench implementation

## 9. Exit Condition

- This auxiliary channel remains valid only until one of the following happens:
  - formal auth minimum corridor is implemented and signed off
  - formal shell context path is implemented and signed off
  - formal workbench guard path is implemented and signed off
- After that, the auxiliary dev-only channel must be either:
  - removed
  - or explicitly downgraded to a separate engineering-only tool path

## 10. Dispatch Conclusion

- The current total-control recommendation is:
  - do not open the full auth board now
  - do not stop the current publish-corridor mainline
  - open a narrow frontend-only dev-test-channel implementation round
  - keep it debug-only and route-limited

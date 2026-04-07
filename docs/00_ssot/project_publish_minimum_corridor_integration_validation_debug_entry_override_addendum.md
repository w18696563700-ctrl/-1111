---
owner: Codex 总控
status: frozen
purpose: Freeze the temporary debug-entry override that allows the current project-publish minimum-corridor integration validation round to enter through the dev-only test channel without opening the formal auth, shell, or workbench boards.
layer: L0 SSOT
alignment_basis:
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_gate_checklist_addendum.md
  - docs/00_ssot/development_test_channel_minimum_closure_freeze_addendum.md
  - docs/00_ssot/development_test_channel_minimum_implementation_receipt.md
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊联调验证轮开发态直入覆盖单

## 1. Scope

- This addendum applies only to:
  - `项目发布最小走廊 / development-stage integration validation round`
- It authorizes only one auxiliary entry method:
  - the current Flutter debug-only dev-test-channel entry
- It does not authorize:
  - formal auth completion
  - formal shell-context completion
  - formal workbench completion
  - release-stage login readiness

## 2. Current Ruling

- The current integration-validation round may now use:
  - the debug-only test channel entry on the Flutter login page
- This is accepted only as:
  - a development-stage route-entry override
- It is not accepted as:
  - product login success evidence
  - product shell bootstrap success evidence
  - product workbench readiness evidence

## 3. Effective Boundary

- The accepted route-entry target remains only:
  - `/exhibition/projects/create`
- The accepted runtime verification object remains only:
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- Failures on the paths above must still be interpreted as:
  - runtime integration failures
  - not as entry-channel failures

## 4. Non-goals

- This addendum does not reopen:
  - `POST /api/app/auth/otp/send`
  - `POST /api/app/auth/otp/login`
  - `GET /api/app/shell/context`
  - `GET /api/app/exhibition/workbench`
- These families remain unfinished and out of scope for the current mainline.

## 5. Conclusion

- The current project-publish minimum-corridor integration-validation mainline
  remains unchanged.
- The only new allowance is:
  - use the debug-only Flutter test channel as the approved route-entry method
    for the current development-stage validation round.

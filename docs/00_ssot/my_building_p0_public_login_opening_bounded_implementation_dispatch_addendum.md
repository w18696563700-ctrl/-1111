---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded implementation dispatch for `我的楼 P0-1 public login opening`, allowing only the already-unlocked backend, BFF, Flutter, validation, and runtime-gate work packets to enter real implementation dispatch without widening into runtime acceptance, launch readiness, or unrelated packages.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_code_prerequisite_dependency_audit_checklist_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_judgment_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_minimum_closure_freeze_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_docs_only_implementation_prep_judgment_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_docs_only_implementation_prep_freeze_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_implementation_unlock_stage_gate_judgment_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_implementation_unlock_stage_gate_checklist_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_implementation_unlock_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_implementation_dispatch_judgment_addendum.md
  - docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - apps/server/src/core/runtime-config.service.ts
  - apps/server/src/modules/auth/auth.constants.ts
  - apps/server/src/modules/auth/auth-command.parser.ts
  - apps/server/src/modules/auth/auth.controller.ts
  - apps/server/src/modules/auth/auth-otp.service.ts
  - apps/server/src/modules/auth/auth-session.service.ts
  - apps/server/src/modules/auth/auth.errors.ts
  - apps/bff/src/core/auth/auth-context.service.ts
  - apps/bff/src/routes/auth/auth.controller.ts
  - apps/bff/src/routes/auth/auth.service.ts
  - apps/mobile/lib/core/auth/auth_consumer_layer.dart
  - apps/mobile/lib/core/boot/app_bootstrap_controller.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
---

# P0-1《public login opening bounded implementation dispatch》

## 1. Current Single Mainline

- 当前唯一主线只限：
  - `我的楼`
  - `P0-1 public login opening`
  - bounded implementation dispatch
- 当前唯一动作只限：
  - 把已经 bounded unlock 的 auth package 正式进入真实 implementation dispatch
- 当前仍明确禁止：
  - runtime acceptance
  - integration
  - release-prep
  - public launch approval
  - `P0-2 / P0-3 / P0-4`

## 2. Current Dispatch Basis

- 当前必须完整承接：
  - `P0-1 public login opening judgment` 已完成
  - `P0-1 public login opening minimum closure freeze` 已完成
  - `P0-1 public login opening docs-only implementation-prep judgment` 已完成
  - `P0-1 public login opening docs-only implementation-prep freeze` 已完成
  - `P0-1 public login opening implementation-unlock stage-gate judgment` 已完成
  - `P0-1 public login opening implementation-unlock stage-gate checklist` 已完成
  - `P0-1 public login opening implementation unlock` 已完成
  - `P0-1 public login opening implementation dispatch judgment` 已完成
- 当前 dispatch basis 只代表：
  - 当前 docs 链已足以 author 并冻结 bounded implementation dispatch
- 当前 dispatch basis 不代表：
  - runtime execution result 已成立
  - runtime acceptance 已成立
  - public launch ready

## 3. Current Bounded Dispatch Range

### 3.1 Backend

- backend 当前只允许承接：
  - `whitelist-only OTP send -> controlled public OTP send`
  - auth audit family materialization
  - auth risk signal materialization
  - current login/session kernel continuation
  - rollback-able runtime gate support
- backend 当前不得承接：
  - password login
  - WeChat login
  - SSO
  - personal real-name truth
  - organization scope package
  - certification package
  - messages package
  - payment / billing
  - `V2.3`
  - trade runtime

### 3.2 BFF

- BFF 当前只允许承接：
  - existing auth route family forwarding refinement
  - public-opening error normalization refinement
  - session-envelope / response-shaping refinement
  - trace / request propagation refinement
  - auth fail-closed behavior refinement
- BFF 当前不得承接：
  - second auth state machine
  - BFF-owned auth truth
  - richer account center
  - organization package expansion
  - certification package expansion
  - messages package expansion

### 3.3 Flutter

- Flutter 当前只允许承接：
  - current login entry public-facing cleanup
  - removal of debug-minded wording and 联调心智
  - `cooldown / rate-limit / unavailable / unauthorized` handling refinement
  - `shellBootstrapState` mainline continuation preservation
  - minimum public-opening UX fail-closed package
- Flutter 当前不得承接：
  - second login system
  - personal real-name pages
  - full security center
  - organization package UI expansion
  - certification package UI expansion
  - messages package expansion
  - exhibition trade runtime UI expansion

### 3.4 Validation

- validation 当前只允许承接：
  - auth transport validation
  - OTP send / login / refresh / logout validation
  - session establish validation
  - shell bootstrap validation
  - auth audit validation
  - auth risk signal validation
  - fail-closed validation
  - rollback-path validation
- validation 当前不得承接：
  - launch-level verification
  - cross-package business verification
  - runtime acceptance conclusion

### 3.5 Runtime Gate

- runtime gate 当前只允许承接：
  - controlled rollout gate support
  - rollback-able runtime gate support
  - isolated / non-production / production runtime semantics continuation
- runtime gate 当前不得承接：
  - unlimited opening
  - release plan
  - deployment plan
  - public launch approval

## 4. Allowed Directories

- 若当前进入真实 implementation dispatch，allowed directories 只允许写死为：
  - `apps/server/src/modules/auth/**`
  - `apps/server/src/core/**` 中与 runtime gate / env semantics 直接相关的最小触点
  - `apps/bff/src/routes/auth/**`
  - `apps/bff/src/core/auth/**`
  - `apps/mobile/lib/core/auth/**`
  - `apps/mobile/lib/core/boot/**`
  - `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart`
- 当前不得把 allowed directories 扩到：
  - `apps/server/src/modules/profile/**` 中与 organization / certification 主包有关的 broader families
  - `apps/server/src/modules/organization/**`
  - `apps/server/src/modules/review/**`
  - `apps/server/src/modules/project/**`
  - `apps/bff/src/routes/profile/**` 的 broader package
  - `apps/mobile/lib/features/messages/**`
  - `apps/mobile/lib/features/exhibition/**`
  - payment / billing / `V2.3` 相关目录

## 5. Ownership Split

- 当前 owner split 只允许写死为：
  - `Backend Agent` 负责 `apps/server/**` 与 `apps/bff/**` 的 bounded dispatch
  - `Frontend Agent` 负责 `apps/mobile/**` 的 bounded dispatch
  - `Codex 总控` 负责：
    - stage gate
    - scope freeze
    - validation rubric
    - result acceptance rule
- 当前不得写成：
  - backend / frontend 越包
  - dispatch 自动等于 acceptance
  - dispatch 自动等于 launch-ready

## 6. Explicit Non-goals

- 不得写成 implementation dispatch 之外的 broader auth rewrite
- 不得写成完整账号中心
- 不得写成完整安全中心
- 不得写成个人实名体系
- 不得写成 organization / certification 主包施工
- 不得写成 messages / exhibition / payment / `V2.3` 施工
- 不得写成 runtime acceptance
- 不得写成 release-prep
- 不得写成 launch-ready

## 7. Current Dispatch Meaning

- 当前 dispatch 结论只表示：
  - `P0-1 public login opening` 当前已进入 bounded implementation dispatch
  - 后续真实实现若发生，必须严格限定在本文件冻结的 package、目录与 owner split 内
- 当前 dispatch 结论不表示：
  - runtime result 已成立
  - acceptance pass 已成立
  - public launch ready
  - `P0-2 / P0-3 / P0-4` 已打开

## 8. Formal Conclusion

- 当前正式结论固定为：
  - `P0-1 public login opening bounded implementation dispatch 已完成，当前允许在冻结边界内进入真实实现派工`
- 上述结论只表示：
  - backend / BFF / Flutter / validation / runtime-gate 这五类当前已获 bounded implementation dispatch
- 上述结论不表示：
  - runtime acceptance granted
  - public launch approved
  - cross-package expansion allowed

## 9. Next Unique Action

- 下一轮唯一动作只允许写成：
  - `向 Backend Agent 与 Frontend Agent 发出 P0-1 bounded implementation execution 口令`

---
owner: Codex 总控
status: frozen
purpose: Freeze the docs-only implementation-prep package boundary for `我的楼 P0-1 public login opening`, locking only work-packet authoring scope, validation package scope, runtime-gate preparation scope, and execution ownership split without granting implementation unlock, implementation dispatch, or public launch approval.
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

# P0-1《public login opening docs-only implementation-prep freeze》

## 1. Scope

- 当前对象只限：
  - `我的楼`
  - `P0-1 public login opening`
  - `docs-only implementation-prep freeze`
- 当前唯一任务只限：
  - 冻结 work packet authoring boundary
  - 冻结 validation package boundary
  - 冻结 rollback / runtime gate boundary
  - 冻结 execution ownership split
- 当前明确不是：
  - implementation unlock
  - implementation dispatch
  - backend / BFF / frontend implementation
  - patch / diff / migration
  - runtime fix
  - release-prep
  - launch approval
  - `P0-2 organization scope closure judgment`
  - `P0-3 certification closure judgment`
  - `P0-4 messages object judgment`

## 2. Current Accepted Baseline

- 当前必须完整承接、不得重判的 baseline 固定如下：
  - `P0-1 public login opening judgment` 已完成
  - `P0-1 public login opening minimum closure freeze` 已完成
  - `P0-1 public login opening docs-only implementation-prep judgment` 已完成
  - 当前正式结论已经到：
    - `Go for docs-only implementation-prep authoring`
  - 当前正式结论明确不到：
    - implementation unlock
    - implementation ready
    - dispatch-ready
    - public launch ready
  - 当前 implementation-prep judgment 已经写死：
    - prep-authoring allowed scope
    - prep-authoring blocked scope
    - passed / failed / veto gates
    - next unique action 必须进入 implementation-prep freeze
  - 当前 public login opening 仍未真正实现
  - 当前 auth-specific audit / risk 仍未真正落地
  - 当前 Flutter 登录产品面仍未真正去联调化
- 当前 implementation-prep freeze 冻结的不是代码，而是：
  - work packet authoring boundary
  - validation package boundary
  - rollback / runtime gate boundary
  - ownership split

## 3. Prep Package Object

- 当前 prep package object 只允许被理解为：
  - `P0-1 public login opening` 的 docs-only implementation-prep package boundary
- 当前 package 唯一目的只限：
  - 为后续 `implementation-unlock stage gate` 提供单一 docs 依据
- 当前 package 即使完成，也不表示：
  - implementation unlock
  - implementation dispatch
  - code-ready
  - public launch ready
- 当前 package 最高意义只允许写成：
  - `implementation-prep package boundary frozen`
  - and nothing more

## 4. Work Packet Freezes

### 4.1 backend work packet freeze

- current purpose：
  - 把 `Server` 侧 public login opening 所需的 bounded implementation-prep authoring scope 固定成单独工作包边界
- frozen authoring scope：
  - `whitelist-only OTP send -> controlled public OTP send` 的 bounded work packet
  - auth audit family materialization work packet
  - auth risk signal materialization work packet
  - current login/session kernel continuation work packet
  - rollback-able runtime gate support packet
- frozen non-goals：
  - password login
  - WeChat login
  - SSO
  - personal real-name truth
  - organization scope package implementation
  - certification package implementation
  - messages package implementation
  - payment / billing
  - `V2.3`
  - trade runtime
- evidence expectations：
  - 必须能回钩到现有 `scene = login`、OTP cooldown、session establish、refresh / logout 现有骨架
  - 必须能证明 authoring 仍围绕当前 auth family，不另起第二登录内核

### 4.2 BFF work packet freeze

- current purpose：
  - 把 `BFF` 侧 public login opening 所需的 bounded shaping authoring scope 固定成最小工作包
- frozen authoring scope：
  - existing auth route family forwarding refinement
  - public-opening error normalization refinement
  - session-envelope / response-shaping refinement
  - trace / request propagation refinement
  - auth fail-closed behavior refinement
- frozen non-goals：
  - second auth state machine
  - BFF-owned auth truth
  - richer account center
  - broader shell / package rewrite
  - organization package expansion
  - certification package expansion
  - messages package expansion
- evidence expectations：
  - 必须继续围绕既有 `/api/app/auth/*` family
  - 必须证明 `BFF` 只做 forwarding / shaping / fail-closed，而不接管 auth truth

### 4.3 Flutter work packet freeze

- current purpose：
  - 把 Flutter 侧公众登录承接面所需的 bounded implementation-prep authoring scope 固定成最小工作包
- frozen authoring scope：
  - current login entry public-facing cleanup
  - removal of debug-minded wording and 联调心智
  - `cooldown / rate-limit / unavailable / unauthorized` handling refinement
  - `shellBootstrapState` mainline continuation preservation
  - minimum public-opening UX fail-closed package
- frozen non-goals：
  - second login system
  - personal real-name pages
  - full security center
  - organization package UI expansion
  - certification package UI expansion
  - messages package expansion
  - exhibition trade runtime UI expansion
- evidence expectations：
  - 必须继续围绕现有 login entry、OTP consumer、shell bootstrap 主走廊
  - 必须证明 authoring 是去联调化，不是另起第二登录系统

## 5. Validation Package Freeze

- current purpose：
  - 把 `P0-1` 当前 package 的验证 authoring scope 冻成单独验证包，而不是 launch 级验证
- frozen authoring scope：
  - auth transport validation
  - OTP send / login / refresh / logout validation
  - session establish validation
  - shell bootstrap validation
  - auth audit validation
  - auth risk signal validation
  - fail-closed validation
  - rollback-path validation
- frozen non-goals：
  - launch verification
  - release-prep verification
  - cross-package business verification
  - `P0-2 / P0-3 / P0-4` verification
  - payment / billing verification
  - trade runtime verification
- evidence expectations：
  - 必须以当前 auth canonical family 与 shell bootstrap 主走廊为验证对象
  - 必须证明 validation 仍停在 `P0-1` package 内，而不是跨包 acceptance

## 6. Runtime Gate Freeze

- current purpose：
  - 把 public login opening 的 runtime gate authoring scope 固定为受控开通与可回滚边界
- frozen authoring scope：
  - controlled rollout gate preparation
  - rollback-able runtime gate preparation
  - isolated / non-production / production runtime semantics clarification
  - public opening risk rollback boundary
- frozen non-goals：
  - public launch approval
  - unlimited opening
  - release plan
  - deployment plan
- evidence expectations：
  - 必须回钩当前 isolated / non-production / production 语义
  - 必须证明 runtime gate 仍是 controlled opening，而不是 unlimited opening

## 7. Ownership Split Freeze

- current purpose：
  - 把 implementation-prep authoring 的执行归属冻结清楚，防止越包与偷换 unlock
- frozen authoring scope：
  - backend agent 负责 `Server` work packet
  - backend agent 负责 `BFF` work packet
  - frontend agent 负责 Flutter work packet
  - Codex 总控负责：
    - stage gate
    - validation rubric
    - cross-packet scope freeze
    - result acceptance rule
- frozen non-goals：
  - 任何执行角色不得越包
  - 任何执行角色不得把 implementation-prep freeze 偷换成 unlock
  - 当前仍需总控后续单独发 implementation 口令，执行角色才能开工
- evidence expectations：
  - 角色归属必须与 `AGENTS.md` 当前 ownership 一致
  - 角色分工必须停在 authoring boundary，而不是 runtime execution

## 8. Explicit In-scope

- 当前 in-scope 只限：
  - backend work packet freeze
  - BFF work packet freeze
  - Flutter work packet freeze
  - validation package freeze
  - runtime gate package freeze
  - execution ownership split freeze

## 9. Explicit Out-of-scope

- 当前 out-of-scope 必须继续写死：
  - implementation unlock
  - implementation dispatch
  - code patch
  - organization scope closure package
  - certification upload/review closure package
  - messages object package
  - payment / billing
  - `V2.3`
  - trade runtime
  - public launch approval
  - password / WeChat / SSO
  - personal real-name package
  - release-prep
  - deployment / migration / runtime execution

## 10. Non-goals

- 当前 package 的 non-goals 固定为：
  - 不 author implementation unlock
  - 不 author implementation dispatch
  - 不 author runtime execution
  - 不 author `P0-2 / P0-3 / P0-4`
  - 不 author payment / billing
  - 不 author `V2.3`
  - 不 author launch / release / deployment 口径

## 11. 阶段门禁核查表

### 11.1 passed gates

- `P0-1 judgment` 已形成
- `P0-1 minimum closure freeze` 已形成
- `P0-1 docs-only implementation-prep judgment` 已形成
- current prep-authoring scope 已被 judgment 写死
- current work packet families 已可被 author 为 freeze

### 11.2 failed gates

- public opening reality 未落地
- auth audit / risk reality 未落地
- Flutter public-facing cleanup reality 未落地

### 11.3 veto gates

- 若把 freeze 写成 implementation unlock，直接 veto
- 若把 freeze 写成 implementation dispatch，直接 veto
- 若混入 `P0-2 / P0-3 / P0-4` 本体，直接 veto
- 若混入 `payment / billing / V2.3`，直接 veto
- 若触碰 `apps/**`，直接 veto

### 11.4 stage go / no-go decision

- 当前阶段最高只允许固定为：
  - `implementation-prep freeze completed`
  - `Go for implementation-unlock stage-gate authoring`
- 当前明确不得写成：
  - implementation unlock granted
  - code-ready
  - dispatch-ready
  - launch ready

## 12. Next Unique Action

- 下一轮唯一动作只允许写成：
  - `输出《我的楼 P0-1 public login opening implementation-unlock stage-gate judgment》`

---
owner: Codex 总控
status: frozen
purpose: Freeze the standalone P0-1 judgment for public login opening under `我的楼`, deciding only the real blocker, current partial capability, minimum closure scope, and next stage recommendation without granting implementation unlock or public launch approval.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_code_prerequisite_dependency_audit_checklist_addendum.md
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

# P0-1《公开登录开通 judgment》

## 1. P0-1 public login opening judgment receipt

- 当前对象：
  - `我的楼`
  - `P0-1 public login opening judgment`
- 当前唯一交付物：
  - 单独 judgment 文书
- 当前明确不是：
  - implementation unlock
  - backend / BFF / frontend implementation
  - runtime fix
  - release-prep
  - launch approval
- 当前判断层级：
  - docs-only strategic judgment
  - repo-filed L0 SSOT

## 2. current blocker

- 当前真实登录机制不是“公众开放注册/登录”。
- 当前代码层真实阻塞，不是 app-facing auth route 不存在，而是：
  - OTP send capability 被白名单机制硬性锁住
  - 非白名单手机号无法进入真实 OTP 登录闭环
  - 公开登录所需的最小风险限制与 auth-specific audit/risk closure 未完成
  - Flutter 当前仍以“联调手机号 / 受控最小闭环”心智暴露登录入口
- 当前白名单 OTP 的三层含义固定如下：
  - `代码层`：
    - `sendOtp` 先通过 `assertOtpSendEnabled` 校验手机号是否在测试白名单或 direct whitelist 内
    - direct whitelist mobile + code 还可直接绕过常规 OTP consume 校验
  - `运行态`：
    - 白名单能力受 runtime config 驱动
    - 且只允许在 `非生产` 或 `isolated runtime` 下成立
  - `产品层`：
    - 登录页文案仍是“当前只承接验证码登录最小闭环”
    - 仍保留“联调测试账号”快捷填充入口
- 当前“登录成功即自动建用户”不能被视为公众注册闭环，原因如下：
  - 它只发生在 OTP 已经成功通过之后
  - 而 OTP send 入口对公众仍被白名单卡死
  - 因此当前成立的是：
    - `受控开发态登录成功后自动建户`
  - 当前不成立的是：
    - `公众可用注册/登录`

## 3. current code truth

### 3.1 Server truth

- 当前 `Server` 已具备的最小 auth/session 代码资产：
  - `POST /server/auth/otp/send`
  - `POST /server/auth/otp/login`
  - `POST /server/auth/refresh`
  - `POST /server/auth/logout`
- 当前 OTP 代码真相如下：
  - 只允许 `scene = login`
  - OTP TTL 已存在
  - OTP cooldown 已存在
  - 非白名单手机号发送 OTP 会直接返回 unavailable
- 当前 session 代码真相如下：
  - 成功登录后可建立 access + refresh session
  - 成功登录后若不存在用户，会自动创建 `User`
  - 登录返回 `shellBootstrapState = authenticated | no_organization`
  - refresh / logout 最小链已存在
- 当前明确成立的结论：
  - `Server` 并不是完全没有登录内核
  - 当前缺的是：
    - public opening legality
    - public anti-abuse closure
    - auth-specific audit/risk materialization

### 3.2 BFF shaping

- 当前 `BFF` 已具备的最小 app-facing auth surface：
  - `POST /api/app/auth/otp/send`
  - `POST /api/app/auth/otp/login`
  - `POST /api/app/auth/refresh`
  - `POST /api/app/auth/logout`
- 当前 `BFF` 已具备：
  - transport forwarding
  - trace/request metadata propagation
  - bounded auth error normalization
  - minimum session envelope shaping
- 当前明确成立的结论：
  - `BFF` 侧不是当前 public login opening 的第一阻断点
  - 当前更像：
    - route family 已存在
    - public opening semantics 尚未闭环

### 3.3 Flutter consumption

- 当前 Flutter 已具备：
  - `sendOtp / loginWithOtp / refresh / logout` consumer
  - session store establish / clear
  - login 后按 `shellBootstrapState` 进入壳层承接
  - shell bootstrap / session refresh / unauthenticated / no_organization blocking states
- 当前 Flutter 仍处于受控产品态的证据如下：
  - 登录页提示“请输入当前联调手机号”
  - staging-like 环境下展示“填入联调测试账号”
  - 登录入口文案明确说“当前只承接验证码登录最小闭环”
- 当前明确成立的结论：
  - Flutter 侧已有最小消费走廊
  - 但当前产品暴露形态仍然是受控联调登录，不是公众正式登录面

### 3.4 Audit and risk truth gap

- 当前 contracts / backend truth 已经要求：
  - `otp_send_attempt`
  - `login_success`
  - `login_failure`
  - `session_refresh`
  - `logout`
  - `otp_rate_limit_breach`
- 但当前可见 auth 代码中，没有形成清晰的 auth-specific audit/security-event materialization 证据闭环。
- 当前正式判断：
  - `公开登录开通` 的剩余缺口，不只在 OTP whitelist
  - 还在：
    - auth audit
    - minimum risk signal
    - public abuse governance

## 4. minimum closure scope

### 4.1 app-facing transport

- 当前最小 closure 不要求新开第二套 public auth route family。
- 当前应继续沿用既有 canonical paths：
  - `/api/app/auth/otp/send`
  - `/api/app/auth/otp/login`
  - `/api/app/auth/refresh`
  - `/api/app/auth/logout`
- 当前若需要补充公开登录防滥用输入，也必须：
  - 绑定在现有 auth family 内
  - 不得新造 bare `/auth/*`
  - 不得新造第二套注册路径族

### 4.2 Server truth

- 当前最小 closure 需要补齐的 `Server` 范围只应是：
  - 从 `whitelist-only OTP send` 过渡到 `controlled public OTP send`
  - 保持 `scene = login` 的当前最小边界
  - 保持 `login success -> auto-create user -> establish session`
  - 保持 `refresh / logout` 现有 session family
  - 把 auth-specific audit / risk signal materialize 到当前真源体系
- 当前不应扩成：
  - password login
  - WeChat login
  - SSO
  - personal real-name truth family

### 4.3 BFF shaping

- 当前最小 closure 需要补齐的 `BFF` 范围只应是：
  - 继续复用现有 auth controllers and service
  - 维持 public login opening 所需的最小 error normalization
  - 明确区分：
    - invalid
    - unauthorized
    - rate limited
    - controlled unavailable
- 当前不应扩成：
  - 第二 auth state machine
  - BFF-owned identity truth
  - richer account-center logic

### 4.4 Flutter consumption

- 当前最小 closure 需要补齐的 Flutter 范围只应是：
  - 保留现有 login page + bootstrapAfterLogin 主走廊
  - 去掉“联调测试手机号”作为主产品心智
  - 对 cooldown / rate limit / unavailable / unauthorized 做稳定承接
  - 在必要时接入现有 auth family 内的受控 anti-abuse challenge
- 当前不应扩成：
  - 第二登录系统
  - 全量安全中心
  - 个人实名 UI

### 4.5 风险限制

- 当前最小 closure 需要补齐的风险限制至少包括：
  - public OTP send 不再依赖白名单，但仍需受控开通
  - OTP abuse frequency control 继续保留并提升到 public opening 语义
  - 对 mobile / device / IP 维度的最小滥用限制必须成立
  - 必须保留 rollback-able runtime gate
- 当前不得把“白名单关闭”误写成“无限制公众开放”。

### 4.6 审计留痕

- 当前最小 closure 需要补齐的 auth 审计留痕至少包括：
  - `otp_send_attempt`
  - `login_success`
  - `login_failure`
  - `session_refresh`
  - `logout`
  - `otp_rate_limit_breach`
- 当前不得仅以普通日志替代 formal audit / risk carrier。

## 5. unlocks after repair

- 若本包修复完成，当前可解开的只包括：
  - 非白名单真实用户可进入受控 OTP 登录
  - `登录 -> session establish -> shell bootstrap` 可成为真实公众入口
  - `exhibition` 与 `messages` 不再只能依赖白名单账号做最小登录承接
  - 后续 `P0-2 organization scope closure judgment` 将拥有真实登录前提，而不是测试前提
  - `messages` 与 `exhibition` 的“需先登录”阻断可转入真实公众恢复路径

## 6. non-unlocks after repair

- 即使本包修完，以下能力仍不会自动成立：
  - `organization scope closure`
  - 企业认证上传与审核闭环
  - `消息楼` 对象裁决
  - `message/index` mainline 成立
  - 展览交易链 runtime 开放
  - payment / billing runtime
  - `V2.3` 私域操作系统整理 package 结论变更
  - 公众正式上线
  - launch approval

## 7. passed gates

- `真源门禁`：
  - 当前 P0-1 judgment 仍严格基于 `docs/**` + repo code evidence
- `架构边界门禁`：
  - 当前 auth 仍保持 `Flutter -> BFF -> Server`
- `契约存在门禁`：
  - app-facing auth canonical path family 已存在
- `最小代码走廊存在`：
  - OTP send / login / refresh / logout 已存在
  - shell bootstrap handoff 已存在
  - auto-create user 已存在

## 8. failed gates

- `公众开放门禁` 未过：
  - public OTP send 仍被 whitelist-only 机制锁死
- `前端体验门禁` 未过：
  - 当前登录页仍是联调态产品表达
- `审计门禁` 未过：
  - 当前 auth-specific formal audit / risk closure 未形成清晰代码闭环证据
- `风险门禁` 未过：
  - 当前仍未形成 public opening 所需的最小 anti-abuse closure

## 9. veto gates

- 当前以下 veto 未关闭前，`P0-1 public login opening` 不得被判定为通过：
  - whitelist-only OTP send 仍然存在
  - 把 auto-create user 误当作公众注册闭环
  - 未形成 auth-specific audit / risk materialization
  - 把联调登录 UI 当作公众登录产品面
- 当前以下 veto 继续保留：
  - `No-Go for implementation unlock`
  - `No-Go for public launch approval`
  - `No-Go for jumping directly into organization / certification / messages package implementation`

## 10. stage recommendation

- 当前正式阶段建议如下：
  - `Go for docs-only P0-1 public login opening minimum-closure freeze authoring`
  - `No-Go for implementation unlock`
  - `No-Go for public launch approval`
  - `No-Go for mixing this judgment with organization/certification/messages main-package judgment`
- 当前最高允许结论只到：
  - `public login opening judgment completed`
- 当前明确不到：
  - `public login opening implementation ready`
  - `public login opening launch ready`

## 11. next unique action

- 当前建议的下一轮唯一动作是：
  - 由总控 author 一份 `P0-1 public login opening minimum closure freeze`
- 在该动作完成并被单独认可前，当前不得自行推进到：
  - `P0-2 organization scope closure judgment`
  - implementation
  - release-prep
  - launch

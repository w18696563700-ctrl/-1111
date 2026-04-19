---
owner: Codex 总控
status: frozen
purpose: Freeze the standalone P0-1 judgment for public login opening, deciding only the real blocker, current code truth, minimum closure scope, and the single next branch without granting implementation unlock or launch approval.
layer: L0 SSOT
freeze_date_local: 2026-04-08
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_code_prerequisite_dependency_audit_checklist_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - apps/server/src/core/runtime-config.service.ts
  - apps/server/src/modules/auth/auth.controller.ts
  - apps/server/src/modules/auth/auth-otp.service.ts
  - apps/server/src/modules/auth/auth-session.service.ts
  - apps/server/src/modules/auth/auth-anti-abuse.service.ts
  - apps/server/src/modules/auth/auth-event-materialization.service.ts
  - apps/bff/src/routes/auth/auth.service.ts
  - apps/mobile/lib/core/auth/auth_consumer_layer.dart
  - apps/mobile/lib/core/auth/app_session_store.dart
  - apps/mobile/lib/core/boot/app_bootstrap_controller.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
---

# P0-1《公开登录开通 judgment》

## 1. P0-1 public login opening judgment receipt

- 当前对象仅限：
  - `P0-1 public login opening judgment`
  - `公开登录开通`
  - `我的楼` 前置依赖修复主线中的登录最小闭环判断
- 当前唯一交付物：
  - 单独完整 judgment 文书
- 当前明确不是：
  - implementation unlock
  - backend / BFF / frontend implementation
  - runtime fully open
  - release-prep
  - launch approval

## 2. current blocker

- 当前真实主阻塞不是 `BFF route` 缺失，也不是 Flutter 没有登录入口。
- 当前真实主阻塞是：
  - `Server` 侧公开 OTP send 仍受 runtime gate 与 whitelist/dev OTP 语义控制
  - 当前登录链仍不能被正式认定为“公众开放注册/登录”
- 具体而言：
  - [auth-anti-abuse.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-anti-abuse.service.ts) 中，`isOtpSendEnabledForMobile()` 只在以下两类条件下返回真：
    - `AUTH_PUBLIC_OTP_SEND_ENABLED = true`
    - mobile 命中 test/direct whitelist
  - [auth-otp.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-otp.service.ts) 中仍保留：
    - direct whitelist consume bypass
    - dev OTP / whitelist OTP fallback
- 因此当前结论必须写死：
  - 现状不是“公众开放登录已经成立”
  - 现状是“公开登录链路具备代码走廊，但仍停留在受控登录开通前状态”

## 3. current code truth

### 3.1 Server truth

- 当前 `Server` 已具备：
  - [auth.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth.controller.ts)：
    - `POST /server/auth/otp/send`
    - `POST /server/auth/otp/login`
    - `POST /server/auth/refresh`
    - `POST /server/auth/logout`
  - [auth-session.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-session.service.ts)：
    - OTP 登录成功后建立 `accessToken + refreshToken`
    - 未存在用户时自动创建 `User`
    - 返回 `shellBootstrapState = authenticated | no_organization`
  - [auth-event-materialization.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-event-materialization.service.ts)：
    - `otp_send_attempt`
    - `login_success`
    - `login_failure`
    - `session_refresh`
    - `logout`
    - `otp_rate_limit_breach`
- 当前 `Server` 未完成的不是“登录内核不存在”，而是：
  - 公开 OTP send 开通语义
  - whitelist/dev OTP 退出正式主路径
  - 公开登录的受控运行态口径

### 3.2 BFF transport truth

- 当前 `BFF` 已具备 app-facing auth canonical family：
  - [auth.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/auth/auth.service.ts)
  - [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md)
  - `POST /api/app/auth/otp/send`
  - `POST /api/app/auth/otp/login`
  - `POST /api/app/auth/refresh`
  - `POST /api/app/auth/logout`
- 当前 `BFF` 已具备：
  - transport forwarding
  - auth error normalization
  - minimum session envelope shaping
- 当前 `BFF` 不是第一阻塞点。

### 3.3 Flutter consumption truth

- 当前 Flutter 已具备：
  - [auth_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/core/auth/auth_consumer_layer.dart)：
    - sendOtp / loginWithOtp / refresh / logout
  - [app_session_store.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/core/auth/app_session_store.dart)：
    - accessToken / refreshToken / deviceId session store
  - [profile_identity_access_pages.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart)：
    - 手机号 + 验证码登录入口
    - “未注册手机号首次验证成功后会自动创建账号” product copy
  - [app_bootstrap_controller.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/core/boot/app_bootstrap_controller.dart)：
    - `bootstrapAfterLogin`
    - `shell/context` reload
    - `authenticated / no_organization / unauthorized` 受控承接
- 当前 Flutter 已经是“公众样式入口”，但这不等于公众开放能力已成立。
- 当前产品层真实含义是：
  - 前端入口已按公众登录样式暴露
  - 但如果 `Server` 仍未正式开通 public OTP send，这个入口就只是“公众样式 + 受控后端”

### 3.4 当前白名单 OTP 的三层含义

- `代码层`：
  - whitelist / dev OTP 仍然是当前 auth flow 的正式分支之一
- `运行态`：
  - 是否对公众开放，取决于 `AUTH_PUBLIC_OTP_SEND_ENABLED`
  - whitelist/dev OTP 由 runtime config 明确驱动
- `产品层`：
  - 登录页已经按公众入口文案承接
  - 但它不能反向证明“公众登录已开通”

### 3.5 对“登录成功即自动建用户”的判断

- [auth-session.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/auth/auth-session.service.ts) 的确已支持：
  - `OTP 验证通过 -> 自动建用户 -> 建立 session`
- 但这不能被直接视为“公众注册闭环”。
- 原因是：
  - 自动建户只发生在 OTP 已通过之后
  - 若 OTP send 对公众仍未正式开通，则公众注册入口仍未成立

## 4. minimum closure scope

### 4.1 app-facing transport

- 当前最小闭环不需要新开第二套 auth route。
- 应继续沿用既有 canonical family：
  - `/api/app/auth/otp/send`
  - `/api/app/auth/otp/login`
  - `/api/app/auth/refresh`
  - `/api/app/auth/logout`

### 4.2 Server truth

- 当前最小闭环首先必须补齐：
  - public OTP send 的正式受控开通语义
  - whitelist/dev OTP 与正式公开登录主路径的边界切分
  - 登录后 session truth / shellBootstrapState / audit / anti-abuse 的稳定闭环
- 当前不需要新开：
  - password login
  - WeChat login
  - SSO
  - 第二套注册路径

### 4.3 BFF shaping

- 当前 `BFF` 最小闭环只应承接：
  - 既有 auth family 的受控 forwarding / normalization
  - public-open 后的 bounded error shaping
- 当前不需要先做新的 BFF transport family。

### 4.4 Flutter consumption

- 当前 Flutter 最小闭环只应承接：
  - 既有 OTP 登录入口
  - 既有 session store / refresh / shell bootstrap
  - 公开开通后对应的受控错误与恢复路径
- 当前不需要先开第二登录 UI。

### 4.5 风险限制

- 当前最小闭环必须保留并正式承接：
  - mobile/device/ip rate limit
  - OTP abuse 拦截
  - auth audit / security event materialization
  - rollback-able runtime gate

### 4.6 审计留痕

- 当前 auth 审计与 security-event materialization 代码已经存在。
- 因此本包的最小闭环重点不是“从零补审计”，而是：
  - 保证公开登录开通仍沿用这套审计/风控真相
  - 不把 whitelist/dev path 误当成公众正式登录

## 5. unlocks after repair

- 若本包修复完成，只会解开以下能力：
  - 非白名单 actor 可进入受控 OTP 登录
  - `登录 -> session establish -> shell bootstrap` 成为真实公众可用入口
  - `展览楼` 与 `消息楼` 的“需先登录”阻断可转入真实公众登录恢复路径
  - `P0-2 organization scope closure judgment` 可建立在真实公众登录前提上，而不是测试登录前提上

## 6. non-unlocks after repair

- 即使本包修完，以下也不会自动成立：
  - `organization scope closure`
  - 企业认证上传 / 提交 / 审核闭环
  - `消息楼` 单一对象真源裁决
  - `message/index` mainline 成立
  - 交易链 runtime 开放
  - release-prep
  - launch approval
  - 公众正式上线

## 7. passed gates

- `真源门禁`：通过
  - 当前 judgment 完全基于 `docs/**` 与 repo code truth
- `架构边界门禁`：通过
  - 仍是 `Flutter -> BFF -> Server`
- `契约门禁`：通过
  - auth canonical path family 已冻结且已落地在代码中
- `阶段控制门禁`：通过
  - 本轮只做单一 docs-only judgment，没有越级进入 implementation

## 8. failed gates

- `云上运行门禁`：未通过到“公众开通”层级
  - 当前登录能力仍可能停留在 runtime gate + whitelist/dev OTP 语义
- `前端体验门禁`：未通过到“公众正式可用”层级
  - 当前产品入口已呈现公众登录样式，但 Server 侧公开开通语义尚未完成闭环
- `阶段控制门禁`：未通过到“implementation unlock”层级
  - 本轮只能做到 judgment，不能直接放 implementation

## 9. veto gates

- 以下 veto 当前仍成立：
  - 公开登录仍受 whitelist/dev OTP 与 runtime gate 控制时，不得把它写成“公众开放登录已成立”
  - 在 `P0-1` 未闭环前，不得跳到 `P0-2 organization scope closure judgment`
  - 在 `P0-1` 未闭环前，不得把 exhibition/messages 的继续开发建立在测试登录前提上

## 10. stage recommendation

- 当前阶段唯一允许结论：
  - `P0-1《公开登录开通 judgment》成立`
  - `No-Go for implementation unlock in this round`
  - `No-Go for jumping to organization/certification/messages main judgments before P0-1 repair dispatch is decided`

## 11. next unique action

- 下一步唯一动作必须是：
  - 锁定 `P0-1` 的唯一 repair dispatch 分支

## 12. chosen next branch

- 选择分支：
  - `分支 A｜后端先行`

## 13. why this branch is first

- 当前主阻塞明确在 `Server truth / runtime gate / OTP-session public opening semantics`：
  - `BFF` canonical path 已存在
  - Flutter login consumption 已存在
  - docs truth 已足以支撑 repair judgment
  - 真正未闭环的是 `Server` 侧：
    - public OTP send 是否正式开通
    - whitelist/dev OTP 如何退出正式公众路径
    - session truth 与公开登录语义如何统一

## 14. why the other three branches are not first

- 不是 `分支 B｜BFF transport 先行`
  - 因为 `BFF` 已有 `/api/app/auth/otp/send|login|refresh|logout`
  - 当前不是 app-facing route 缺失问题
- 不是 `分支 C｜前端消费先行`
  - 因为 Flutter 已有 login page、session store、refresh、bootstrapAfterLogin
  - 当前不是前端消费面先天缺失问题
- 不是 `分支 D｜文书冻结补链`
  - 因为当前 judgment 所需 truth/contract/boundary 已足够
  - 当前不是 docs gap first

## 15. next unique action title

- `P0-1a《公开登录开通 backend repair dispatch judgment》`

## Formal Conclusion

- 当前真实登录机制不是“公众开放注册/登录”。
- 当前白名单 OTP 本质上仍是开发态 / 受控登录机制的一部分。
- 当前“登录成功即自动建用户”不能单独视为公众注册闭环。
- 当前 `P0-1` 只能成立为：
  - `公开登录开通 judgment`
- 当前不得被写成：
  - implementation unlock
  - launch approval
  - 公众正式上线
  - closure 已完成

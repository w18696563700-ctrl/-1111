---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum closure boundary for `我的楼 P0-1 public login opening`, fixing only the smallest closure families, non-unlocks, and dependency order after judgment completion without granting implementation unlock or public launch approval.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/my_building_code_prerequisite_dependency_audit_checklist_addendum.md
  - docs/00_ssot/my_building_p0_public_login_opening_judgment_addendum.md
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

# P0-1《public login opening minimum closure freeze》

## 1. Scope

- 当前对象只限：
  - `我的楼`
  - `P0-1 public login opening`
  - `minimum closure freeze`
- 当前唯一任务只限：
  - 冻结最小闭环范围
  - 冻结当前包内必须补齐内容
  - 冻结当前包外明确排除内容
  - 冻结修复后可解锁与不可解锁边界
  - 冻结 `P0-1 -> P0-2 -> P0-3 -> P0-4` 依赖顺序
- 当前明确不是：
  - implementation unlock
  - launch approval
  - organization scope closure judgment
  - certification upload/review closure judgment
  - messages object judgment
  - payment / billing
  - `V2.3`
  - exhibition trade runtime opening

## 2. Current Accepted Baseline

- 当前已经接受、不得重判的 baseline 固定如下：
  - 当前真实登录机制不是公众开放注册/登录
  - 当前白名单 OTP 本质上是开发态 / isolated-runtime 下的受控登录
  - 当前 app-facing canonical auth family 已存在，不是“无路可走”
  - 当前 `Server / BFF / Flutter` 已有最小登录承接走廊
  - 当前 `login success -> auto-create user -> establish session` 不能被视为公众注册闭环
  - 当前剩余缺口不只在 OTP whitelist，本轮必须同时面对：
    - public anti-abuse closure
    - auth-specific audit closure
    - auth-specific risk signal closure
    - Flutter 登录产品面去联调化
  - 当前阶段最高只到：
    - `P0-1 judgment completed`
    - `Go for docs-only minimum closure freeze authoring`
  - 当前明确不到：
    - implementation unlock
    - launch approval
    - public launch
- 当前 repo 证据继续固定如下：
  - `Server` 已存在：
    - `POST /server/auth/otp/send`
    - `POST /server/auth/otp/login`
    - `POST /server/auth/refresh`
    - `POST /server/auth/logout`
  - `BFF` 已存在：
    - `POST /api/app/auth/otp/send`
    - `POST /api/app/auth/otp/login`
    - `POST /api/app/auth/refresh`
    - `POST /api/app/auth/logout`
  - Flutter 已存在：
    - `sendOtp / loginWithOtp / refreshSession / logout`
    - `shellBootstrapState` 壳层承接
    - 当前登录页仍暴露“联调手机号 / 联调测试账号”心智

## 3. Minimum Closure Object

- 当前 minimum closure object 只允许被理解为：
  - `P0-1 public login opening` 的最小闭环冻结
  - 其目标是把“受控开发态白名单 OTP 登录”推进成“受控公众 OTP 登录前提成立”
- 当前 minimum closure 的唯一最小修复目标固定为：
  - 让非白名单真实用户进入受控 OTP 登录闭环
  - 让登录后的 `session / shell bootstrap` 成为真实公众入口
  - 不再把联调登录面伪装成公众登录面
- 当前必须明确：
  - 当前真实登录能力已经部分存在，但不等于公众开放登录成立
  - 当前白名单 OTP 只能定性为：
    - 当前开发态受控开通机制
    - 不是公众正式登录能力
  - 当前 auto-create user 只能定性为：
    - 登录成功后的建户机制
    - 不是公众注册闭环本体

## 4. Closure Families

### 4.1 app-facing transport closure

- already present：
  - 当前继续沿用既有 canonical path family：
    - `POST /api/app/auth/otp/send`
    - `POST /api/app/auth/otp/login`
    - `POST /api/app/auth/refresh`
    - `POST /api/app/auth/logout`
  - 当前 `BFF` auth family 已具备 forwarding 基础与 bounded error normalization
- must-close-now：
  - 继续只在既有 auth family 内补足 public opening transport closure
  - 若需要 anti-abuse challenge，只能挂在既有 auth family 内
  - 不得让公众登录继续依赖白名单 transport semantics
- explicitly out-of-scope：
  - 不新开第二套 bare `/auth/*`
  - 不新开“注册中心”路由族
  - 不引入 password / WeChat / SSO transport family

### 4.2 Server truth closure

- already present：
  - OTP `scene` 当前只限 `login`
  - `login success -> auto-create user -> establish session` 当前最小内核已存在
  - `refresh / logout` 当前 family 已存在
  - `shellBootstrapState = authenticated | no_organization` 已存在
- must-close-now：
  - `whitelist-only OTP send -> controlled public OTP send`
  - 保持 `scene = login` 的当前最小边界
  - formalize auth-specific audit / risk signal materialization
  - 让当前登录成功后的建户与 session 建立真正服务于公众登录前提
- explicitly out-of-scope：
  - password login
  - WeChat login
  - SSO
  - personal real-name truth
  - organization closure 本体
  - certification closure 本体

### 4.3 BFF shaping closure

- already present：
  - 当前 `BFF` 已存在：
    - forwarding
    - trace propagation
    - bounded auth error normalization
    - minimum session-envelope shaping
- must-close-now：
  - 只补最小 public login opening 所需 shaping
  - 维持：
    - forwarding
    - trace propagation
    - bounded error normalization
    - minimum session-envelope shaping
  - 对 `invalid / unauthorized / rate limited / controlled unavailable` 形成稳定 app-facing 语义
- explicitly out-of-scope：
  - own auth truth
  - own second auth state machine
  - invent richer account center

### 4.4 Flutter consumption closure

- already present：
  - 当前 Flutter 已有：
    - 现有 login page
    - `sendOtp / loginWithOtp / refresh / logout`
    - `shellBootstrapState` 后续壳层承接
    - `unauthenticated / session_refreshing / no_organization` 主线
- must-close-now：
  - 让现有 login page 成为公众可用承接，而不是联调测试承接
  - 对 `cooldown / rate limit / unavailable / unauthorized` 做稳定承接
  - 保持 `shellBootstrapState` 后续壳层承接最小主线
  - 去掉“联调测试账号”作为主产品心智
- explicitly out-of-scope：
  - 第二登录系统
  - 个人实名 UI
  - 全量安全中心

### 4.5 risk-limit closure

- already present：
  - OTP cooldown 已存在
  - 当前 whitelist / isolated runtime gate 已存在受控开通语义
- must-close-now：
  - 当前 public opening 仍必须保持受控开通，而不是无限制开放
  - 必须形成最小 anti-abuse family
  - 至少覆盖：
    - OTP 高频发送限制
    - login 高频限制
    - device / mobile / IP 维度的最小滥用拦截
    - rollback-able runtime gate
- explicitly out-of-scope：
  - 完整 risk center
  - 风控评分引擎
  - 广义账号安全中心扩包

### 4.6 audit / trace closure

- already present：
  - trace/request metadata propagation 已存在
  - contracts / backend truth 已经要求 auth audit family
- must-close-now：
  - 当前包内至少必须 formalize：
    - `otp_send_attempt`
    - `login_success`
    - `login_failure`
    - `session_refresh`
    - `logout`
    - `otp_rate_limit_breach`
  - 不得只靠普通日志代替 formal audit / risk carrier
- explicitly out-of-scope：
  - 更大范围 governance event center
  - 完整 security console
  - 跨楼统一运营审计后台

## 5. Explicit In-scope

- 当前包内明确 in-scope：
  - public login opening 的最小 transport closure
  - 受控公众 OTP send/login 前提成立
  - 当前 login scene 内的最小 `Server` truth closure
  - `BFF` 的最小 forwarding / trace / session-envelope / error normalization closure
  - Flutter 登录面去联调化与最小公众消费承接
  - auth-specific anti-abuse closure
  - auth-specific audit-and-trace closure
  - 登录后 `session establish -> shell bootstrap` 作为真实公众入口的最小闭环

## 6. Explicit Out-of-scope

- 当前包外明确排除：
  - organization scope package
  - enterprise certification package
  - messages object package
  - payment / billing
  - `V2.3`
  - trade runtime
  - launch approval
  - public launch
  - password / WeChat / SSO
  - personal real-name package
  - exhibition trade runtime rewrite

## 7. Unlocks After Closure

- 若当前 minimum closure 修完，当前只会解开：
  - 真实公众登录前提成立
  - 非白名单真实用户可进入受控 OTP 登录闭环
  - 登录后的 `session / bootstrap` 成为真实公众入口
  - `P0-2 organization scope closure` 可以建立在真实用户前提上
  - `exhibition / messages` 的“需先登录”阻断可以转入真实入口

## 8. Non-unlocks After Closure

- 当前包修完后，仍不会自动解开：
  - organization scope closure
  - certification upload/review closure
  - messages object judgment
  - `message/index` 成立
  - trade runtime opening
  - payment / billing runtime
  - `V2.3` mainline
  - public launch approval
  - implementation unlock

## 9. Dependency Order

- 当前依赖顺序固定为：
  - `P0-1 public login opening`
  - `-> P0-2 organization scope closure`
  - `-> P0-3 enterprise certification upload/review closure`
  - `-> P0-4 messages object judgment 或其后续主线`
- 当前必须继续写死：
  - `P0-1` 是 `P0-2` 的前置真实用户基础
  - `P0-1` 不是 `P0-2` 本体
  - `P0-1` 不是 `P0-3` 本体
  - `P0-1` 不是 `P0-4` 本体
  - `P0-1` 修完后，只是把后续 judgments 的前提从“测试账号前提”改成“真实公众登录前提”

## 10. Gate Result

- 当前 gate result 只允许固定为：
  - `docs-only minimum closure freeze completed`
  - `Go for docs-only implementation-prep judgment`
- 当前明确不得写成：
  - implementation unlock
  - implementation ready
  - public launch ready
  - launch approval

## 11. Next Unique Action

- 下一轮唯一动作只允许写成：
  - `输出《我的楼 P0-1 public login opening docs-only implementation-prep judgment》`

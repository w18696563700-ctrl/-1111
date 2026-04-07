---
owner: 总控文书冻结执行位
status: frozen
purpose: Freeze the follow-up truth boundary for current-session, auth-session, BFF forwarding, and Server verification after Package 1A remediation moved protected paths into fail-closed mode.
layer: L0 SSOT
decision_date_local: 2026-04-02
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md
  - docs/00_ssot/account_identity_board_closure_plan_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_dispatch_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/identity_permission_persistence_minimum_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/01_contracts/auth_contracts.yaml
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - apps/server/src/shared/request-context.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/bff/src/core/auth/auth-context.service.ts
  - apps/server/src/modules/identity/entities/session.entity.ts
  - apps/server/src/core/core.module.ts
  - apps/server/src/main.ts
---

# 展览项目发布-竞标-履约治理四文书
# Package 1 Current-session / Auth-session Follow-up Freeze Addendum

## 1. Scope

- 本文件只冻结：
  - current-session / auth-session follow-up truth boundary
  - BFF forwarding boundary
  - Server verification boundary
  - 下一轮 truth patch 前提
- 本文件明确不冻结：
  - implementation
  - BFF consumption unlock
  - migration
  - release
- 本文件是总控 follow-up truth freeze，不是实现口令，不是下游消费放行。

## 2. Current Failure-closed Meaning

- 当前 remediation 已经把误放行风险收住，但方式是 fail-closed，证据见 [exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md)。
- 这里的“安全收紧成立”具体指：
  - `any-valid-session` 误放行已被移除
  - reviewer direct trust on `x-actor-role` 已被移除
  - raw `authorization` 不再被当成认证成功
- 这里的“不是 runtime auth ready”具体指：
  - 当前 remediation 只是把 protected path 统一收回到拒绝态
  - 当前没有已冻结、可验证的 current-session truth
  - 当前没有已冻结的 token verification truth
  - 因此当前不能形成稳定 authenticated happy path
  - 当前不能进入 BFF consumption
- 本文件明确采用如下读法：
  - fail-closed 不是问题已解决
  - fail-closed 不是可用 happy path
  - fail-closed 不是 BFF unlock 前置已满足

## 3. Existing Truth Inputs

### 3.1 当前已冻结的 truth 输入

- [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md) 已冻结：
  - access token + refresh token session model
  - `Server` 是 session truth owner
  - `BFF` 可 normalize auth and session，但不是 truth owner
- [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml) 已冻结：
  - `access token plus refresh token session flow`
  - `authenticated` guard 的产品语义是“actor identity exists and current session is valid”
  - `platform_reviewer_or_super_admin` 等 guard 名称
- [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml) 已冻结：
  - authentication / shell / authorization transport rules
  - `401` 需要 session refresh 或 login recovery
- [identity_permission_persistence_minimum_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/identity_permission_persistence_minimum_addendum.md) 与 [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md) 已冻结：
  - `sessions` 是 persistence truth family
  - `refresh_token_hash` 是当前明确落库的 session secret truth
  - `BFF` 可 normalize auth and session carriers
  - `Server` 必须从 effective current session 导出 shell / profile / guard 判断
- [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md) 已冻结：
  - `BFF` 只能做 auth consolidation、trace propagation、shell/profile shaping
  - `BFF` 不拥有 session lifecycle truth

### 3.2 当前尚未冻结到位的 truth 输入

- 当前尚未冻结：
  - ordinary protected request 的可验证 current-session carrier
  - `authorization` 到 current-session truth 的 verification boundary
  - header hints 与 final auth truth 的正式角色边界
  - reviewer authorization 的 auth/session 前置 truth
- 上述缺口可从代码直接看出：
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts) 已读入 `authorization`
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts) 当前只能 fail-closed，因为当前 boundary 下“authorization carrier is not verifiable”
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts) 只做 forwarding / normalization
  - [session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts) 只明确持久化 `refresh_token_hash`，不能据此反推 raw access authorization
  - [core.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/core.module.ts) 与 [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/main.ts) 未见已冻结的全局 auth verification boundary

## 4. Current-session Carrier Freeze

- 当前 ordinary protected request 的 current-session carrier 候选，只有：
  - raw `authorization` transport carrier
- 本文件明确：
  - 这里的 `authorization` 只是 carrier candidate
  - 它已进入 [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts)
  - 但当前 frozen truth 仍不足以把它验证成“当前会话真值”
- 当前不能验证它的原因是：
  - 现有 L0/L2/L3 文书只冻结了 transport 与 refresh session baseline
  - 没有冻结 access-side token verification truth
  - 没有冻结 current authenticated request truth 的 derivation rule
  - [session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts) 只提供 `refresh_token_hash` persistence truth，不能直接证明 raw `authorization`
  - 当前文书没有冻结 JWT 结构、token payload、签名机制或 access token lookup rule
- 因此在 truth 未补齐前，Package 1A 必须 fail-closed，原因不是“实现太严格”，而是：
  - ordinary protected request 没有可验证 current-session truth
  - `Server` 不能拿 raw carrier 或 header hints 拼装出 auth truth
  - 若不 fail-closed，就会再次回到误放行风险

## 5. Auth-session Truth Freeze

- 本文件明确区分三层，不允许混写：

### 5.1 access token transport carrier

- 当前对象：
  - raw `authorization` header
- 当前角色：
  - transport
- 当前限制：
  - 它可以被 BFF 转发
  - 它可以被 Server 接收
  - 但它本身不是 verified current-session truth

### 5.2 refresh token session truth

- 当前对象：
  - `sessions` persistence family
  - 其中已明确落库的 secret truth 是 `refresh_token_hash`
  - 同时还有 `status`、`expires_at`、`revoked_at`、`device_id` 等 refresh/device session truth
- 当前角色：
  - persistence truth
- 当前限制：
  - 它服务于 refresh-token session truth
  - 它不能被反推成 raw access authorization truth
  - 它不能自动等价于 current authenticated request truth

### 5.3 current authenticated request truth

- 当前对象：
  - `Server` 针对“这个请求现在是否已认证、是谁、当前 scope 是什么、当前 authz 是否成立”的 verified conclusion
- 当前角色：
  - verification target
- 当前限制：
  - 它既不是 raw `authorization`
  - 也不是 `sessions` 某一行单独存在就算成立
  - 它必须来自 `Server` 对可验证 truth 的成功校验
- 本文件明确结论：
  - transport 不是 persistence truth
  - persistence truth 不是 current authenticated request truth
  - 这三者当前不能写成“都有，所以已成立”

## 6. Header Trust Boundary

- `authorization`
  - 当前角色：access-side raw transport carrier
  - 允许用途：forwarding candidate、受控读取、进入 verification pipeline
  - 禁止用途：直接当作 current-session verified、直接当作 final authz truth

- `x-actor-id`
  - 当前角色：forwarding hint only
  - 允许用途：受控 correlation / candidate attribution hint
  - 禁止用途：直接当作 authenticated actor truth

- `x-user-id`
  - 当前角色：legacy alias / forwarding hint only
  - 允许用途：在 BFF edge 作为 `x-actor-id` 的 alias input
  - 禁止用途：直接当作 authenticated user truth

- `x-organization-id`
  - 当前角色：requested scope hint only
  - 允许用途：表达调用方希望进入的 organization scope
  - 禁止用途：直接证明 membership、scope ownership 或 authorization

- `x-actor-role`
  - 当前角色：forwarding hint only
  - 允许用途：trace/debug hint，或在 auth truth 已成立后作为附带 attribution
  - 禁止用途：直接当作 reviewer truth、直接当作 final authorization truth

- `x-request-id`
  - 当前角色：trace / audit attribution
  - 允许用途：request correlation、append-only audit attribution
  - 禁止用途：任何 authn/authz 决策

- `x-trace-id`
  - 当前角色：trace / audit attribution
  - 允许用途：跨层追踪、审计关联
  - 禁止用途：任何 authn/authz 决策

## 7. BFF Forwarding Boundary Freeze

- 在 current-session / auth-session 这条链上，本轮只承认 BFF 当前可 forward 的决定性 carrier/hint 集合为：
  - `authorization`
  - `x-actor-id`
  - `x-organization-id`
  - `x-actor-role`
  - `x-request-id`
  - `x-trace-id`
- `x-user-id` 当前只作为 BFF edge 的 alias input 被吸收进 `x-actor-id` 处理，不能被升格成独立 final truth。
- BFF 可以做的只有：
  - 转发 raw carrier
  - 规范化 header 名称
  - 传递 request/trace attribution
  - 将 `Server` 的 `401/403` 结果映射成 app-facing controlled envelope
- BFF 不能做：
  - 自证 current session
  - 自证 reviewer role
  - 自证 authenticated actor
  - 下发 second auth truth
  - 把 header hints 改写成 current-session verified 结论

## 8. Server Verification Boundary Freeze

- `Server` 必须是 current-session verification owner。
- `Server` 必须负责：
  - 从可验证 truth 得出 actor/session/authz
  - 从已验证 truth 派生 organization scope 与 reviewer eligibility
  - 将 protected path 的 `authenticated` / `organization_scoped` / `platform_reviewer_or_super_admin` 等 guard 判定收归 Server
- `Server` 不能做：
  - 用 `authorization` 存在本身当认证成功
  - 用 `x-actor-id` / `x-user-id` 直接拼出 authenticated actor
  - 用 `x-actor-role` 直接拼出 reviewer truth
  - 用 `x-organization-id` 直接拼出 membership 或 scope truth
- 在 truth 未补齐前，Server 端 protected path 必须 fail-closed：
  - 这不是 optional behavior
  - 这是当前 boundary 下避免误放行的唯一合规行为

## 9. Explicit Non-goals

- 不猜 JWT
- 不猜 token payload
- 不猜签名结构
- 不扩大到 Package 2 / 3 / 4
- 不直接放开 BFF / Flutter / Admin
- 不直接放开 migration
- 不把 current-session follow-up freeze 偷换成 implementation unlock

## 10. Next Required Truth Patch Set

- 需要后续 patch [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml)
  - 原因：它当前冻结的是 authentication / authorization transport rules，但还没冻结 raw `authorization` 只是 transport carrier、不能直接等于 current-session verified 的 boundary。

- 需要后续 patch [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - 原因：它当前冻结了 `authenticated = actor identity exists and current session is valid`，但没有冻结“current session valid”应如何从 verifiable truth 得出，也没有冻结 header trust boundary。

- 需要后续 patch [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
  - 原因：它已写明 `Server` 必须从 effective current session 派生 shell/profile/guard，但还没冻结 current-session verification owner、reviewer auth/session 前置 truth、以及 forwarding hints 的 non-truth 地位。

- 需要新增一个专门的 backend auth/session truth addendum
  - 原因：现有 backend truth 文书主要覆盖 account/certification 主链与 refresh-token persistence baseline，还没有单独冻结：
    - access transport carrier 与 refresh session truth 的关系
    - current authenticated request truth 的 verification target
    - Server verification boundary
    - header hint non-truth boundary
    - fail-closed before verification-ready 的正式规则
  - 本文件明确建议：下一轮 truth patch bundle 应以该专门 addendum 为核心，而不是继续把这组边界散落写进实现代码。

## 11. Stage Decision

`Go` for docs-only auth/session truth patch bundle authoring

原因如下：

- [exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md) 已明确给出：
  - remediation 结论是 `PASS WITH RISK`
  - 下一步只能进入 current-session / auth-session truth follow-up freeze
- 当前缺的不是更多实现，而是：
  - current-session carrier truth
  - auth-session verification truth
  - BFF forwarding boundary
  - Server verification boundary
- 这组缺口属于 docs-only truth patch 问题，符合先文书、后实现的门禁顺序。

## 12. Next Unique Action

- 下一条允许发出。
- 但只能发给：`总控文书冻结`
- 且只能是 docs-only auth/session truth patch prompt
- 原因：
  - 下一轮需要改的是 `docs/01_contracts/**` 与 `docs/02_backend/**` 真源边界
  - `docs/**` 由 Codex 总控主导
  - 当前仍不能发给 Backend implementation、BFF consumption、Flutter、Admin
  - 在 auth/session truth patch bundle 完成前，任何下游消费或继续实现都会继续踩在未冻结 verification boundary 上


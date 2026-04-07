---
owner: 独立复核
status: completed
purpose: Independently review whether the Package 1 current-session and auth-session truth patch bundle freezes the required auth/session boundaries clearly enough for the next bounded Server verification gate-authoring step without implying implementation unlock or BFF consumption unlock.
layer: L0 SSOT
decision_date_local: 2026-04-02
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md
  - docs/01_contracts/auth_contracts.yaml
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/identity_permission_persistence_minimum_addendum.md
  - docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - apps/server/src/shared/request-context.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/bff/src/core/auth/auth-context.service.ts
  - apps/server/src/modules/identity/entities/session.entity.ts
---

# 展览项目发布-竞标-履约治理四文书
# Package 1 Current-session Auth-session Truth Patch Independent Review Addendum

## 1. Review Scope

- 本轮是 docs-only 独立复核，只核对 auth/session truth patch bundle 是否把 Package 1 当前最关键的 auth/session 真值边界冻结清楚。
- 本轮只判断：
  - transport / persistence / verification / forwarding / Server-boundary 五条边界是否拆清
  - fail-closed 是否仍被明确写成非 runtime-ready、非 BFF-consumable
  - header hints、raw `authorization`、refresh-session truth 是否仍被严格分层
  - 是否足以支撑下一条“总控文书冻结 backend current-session verification implementation-dispatch gate”起草
- 本轮不做：
  - 实现
  - migration
  - BFF / Flutter / Admin consumption unlock
  - release-prep 或 release execution

## 2. Review Basis

- 复核主文书：
  - [exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md)
  - [exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md)
  - [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
  - [identity_permission_persistence_minimum_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/identity_permission_persistence_minimum_addendum.md)
  - [package1_current_session_and_auth_session_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md)
  - [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md)
- 复核代码证据：
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts)
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts)
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts)
  - [session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts)
- 本轮执行方式是只读核查；未对 `apps/**`、`docs/01_contracts/**`、`docs/02_backend/**`、migration 做任何改动。

## 3. Verified Boundary Findings

- `transport / persistence / verification` 已被清晰拆开：
  - raw `authorization` 被稳定写成 access transport carrier only
  - `sessions.refresh_token_hash` 被稳定写成 refresh-session persistence truth only
  - `verified current-session context` 被稳定写成 protected request verification target，并由 `Server` 拥有
- 上述三层在文书中没有被重新混写成“都有所以认证成立”：
  - [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml) 明确把 raw `authorization` 归为 transport only
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml) 明确把 protected request target 写成 `verified_current_session_context`
  - [package1_current_session_and_auth_session_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md) 明确写出 transport 与 persistence truth 不能折叠成 verification target
- header trust boundary 已冻结清楚：
  - forwarding hints only: `x-actor-id`、`x-user-id`、`x-organization-id`、`x-actor-role`
  - trace / audit attribution only: `x-request-id`、`x-trace-id`
  - 没有任何一个 header 被文书升格成 final auth truth
- BFF / Server 边界已被清晰拆开：
  - `BFF` 只允许 forward raw carrier、bounded hints、request/trace attribution
  - `BFF` 不允许 verify current session、不允许 certify reviewer role、不允许 synthesize second auth truth
  - `Server` 被明确冻结为 current-session verification owner，并在 truth 不足时 fail-closed
- backend truth patch 已把 reviewer authorization 写回 Server-side verified / DB-backed 语义：
  - verified actor identity
  - active membership truth
  - role key in `platform_reviewer | platform_super_admin`
  - platform organization truth
- 当前 remediation 代码与上述读法一致：
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts) 只读 raw carrier、forwarding hints、trace attribution，不形成 auth truth
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts) 明确拒绝“同用户任意 valid session 即放行”，并在 current-session truth 不足时 fail-closed
  - 同文件中的 reviewer 判定来自 DB-backed active membership + reviewer role + platform organization，不再信任 raw `x-actor-role`

## 4. Risk Findings

- 当前 patch bundle 的正确 operational reading 仍然只能是：
  - safe but fail-closed
  - not runtime-ready
  - not BFF-consumable yet
- 当前文书足以冻结边界，但还不足以形成 authenticated happy path：
  - 还没有实现级 current-session verification
  - 还没有 Server-side verification success path
  - 还没有 runtime schema / migration blocker closure
- [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts#L54) 仍保留一处 legacy wording：
  - `authorization` 与 `x-actor-id/x-user-id` 被并列称作 “valid session carrier”
  - 这与新冻结 truth 的精确读法相比，措辞偏宽
  - 当前应把它视为 BFF forwarding entry wording，而不是 current-session verification truth
- `x-actor-id` 与 `x-user-id` 在代码里仍会被读取并前传：
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts#L26)
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts#L42)
  - 这本身不构成越界，但要求下一条 implementation-dispatch gate 明确“可 forward 不等于可认证”
- 本轮没有发现文书把 raw `authorization`、header hints、refresh-session truth 混写成 current-session truth；风险主要是现存代码措辞仍可能被误读，不是 truth patch 本身重新漂移。

## 5. Unsupported Or Overstated Claims

- 不支持把本轮 docs patch 说成 implementation unlock。
- 不支持把 fail-closed 说成 authenticated happy path 已恢复。
- 不支持把本轮结论说成 runtime-ready。
- 不支持把本轮结论说成可以给 BFF 发 consumption prompt。
- 不支持把 raw `authorization`、`x-actor-id`、`x-user-id`、`x-actor-role` 任一项说成 final auth truth。
- 不支持把 refresh-session persistence truth 偷换成 current authenticated request truth。

## 6. Consistency Check Across Contracts Backend Truth And Code

- 合同层一致性：
  - [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml) 与 [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml) 已把 `authorization`、forwarding headers、`verified_current_session_context` 三者拆清。
- backend truth 一致性：
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md) 已把 eligibility 前提提升为 verified current-session context，并明确禁止“same-user any valid session”替代当前请求的 verified current-session context。
  - [package1_current_session_and_auth_session_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md) 已把 reviewer authorization 收回到 Server-verified、DB-backed truth。
- 代码边界一致性：
  - [session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts) 只给出 `sessions.refresh_token_hash` 与 refresh-session persistence fields，没有把 raw access authorization 升格为 persistence truth。
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts#L181) 当前显式 fail-closed，符合“truth 不足时 Server 拒绝放行”的冻结读法。
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts) 行为上仍是 forwarding layer，不见 BFF 自证 current session 或 reviewer role；但其 401 文案仍保留 legacy phrasing，应视为残留措辞风险，不应覆盖 truth patch 的正式边界。

## 7. Stage Decision

- 复核结论：`PASS WITH RISK`
- Stage decision：`Go` for 总控文书冻结 backend current-session verification implementation-dispatch gate authoring only
- 原因：
  - transport / persistence / verification / forwarding / Server-boundary 五条边界已经冻结到足以支撑下一条 bounded gate authoring
  - 文书仍严格维持 `fail-closed != runtime-ready != BFF-consumable`
  - 当前没有把 raw `authorization`、header hints、refresh-session truth 混写成 current-session truth
  - 该 `Go` 只支持总控继续起草下一条 backend verification gate，不支持实现放行，不支持 BFF consumption

## 8. Next Unique Action

- 建议下一条发给：`总控文书冻结`
- 唯一合理下一步是起草并冻结 `backend current-session verification implementation-dispatch gate`，把以下非目标继续锁死：
  - 不是 BFF consumption unlock
  - 不是 runtime-ready signoff
  - 不是 migration unlock
  - 不是 token internals 猜测授权
  - 不是把 forwarding hints 重新升格为 auth truth

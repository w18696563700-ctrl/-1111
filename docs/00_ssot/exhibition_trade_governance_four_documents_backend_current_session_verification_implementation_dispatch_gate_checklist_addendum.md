---
owner: 总控文书冻结执行位
status: frozen
purpose: Record the dispatch gate decision for whether the next bounded Backend Agent implementation prompt may enter apps/server for current-session verification only.
layer: L0 SSOT
decision_date_local: 2026-04-02
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md
  - docs/01_contracts/auth_contracts.yaml
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - apps/server/src/shared/request-context.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/bff/src/core/auth/auth-context.service.ts
  - apps/server/src/modules/identity/entities/session.entity.ts
  - apps/server/src/core/core.module.ts
  - apps/server/src/main.ts
---

# 展览项目发布-竞标-履约治理四文书
# Backend Current-session Verification Implementation Dispatch Gate Checklist Addendum

## 1. Scope

- 本文件只裁定两件事：
  - 现在是否允许发出下一条真正进入 `apps/server` 的 Backend Agent implementation prompt
  - 若允许，该 prompt 是否只能针对 `current-session verification`
- 本文件明确不裁定：
  - `apps/bff` unlock
  - Package 1 其他能力
  - Package 2 / 3 / 4
  - migration
  - release-prep
  - release execution
- 本文件是 implementation-dispatch gate checklist，不是实现口令，不是 BFF unlock 文书，不是 release 文书。

## 2. Gate Basis

### 2.1 实际依据的门禁与总控文书

- [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
- [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
- [exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md)
- [exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md)
- [exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md)

### 2.2 实际依据的 contracts / backend truth / BFF boundary

- [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml)
- [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
- [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
- [package1_current_session_and_auth_session_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md)
- [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md)

### 2.3 实际依据的代码证据

- [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts)
- [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts)
- [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts)
- [session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts)
- [core.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/core.module.ts)
- [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/main.ts)

## 3. Current Inputs Summary

- `follow-up freeze` 已固定五条边界：
  - transport
  - persistence
  - verification
  - forwarding
  - server-boundary
  证据见 [exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_followup_freeze_addendum.md)。
- `truth patch bundle` 已进一步固定：
  - raw `authorization` 只是 transport carrier
  - `sessions.refresh_token_hash` 只是 refresh-session persistence truth
  - `verified current-session context` 是 protected request verification target
  - header hints 不是 final auth truth
  - reviewer authorization 必须来自 verified actor identity + DB-backed platform membership truth
  证据见 [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml)、[identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)、[account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)、[package1_current_session_and_auth_session_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md)。
- `independent review` 已确认：
  - 五条边界拆清
  - fail-closed 仍被保留为 non-runtime-ready、non-BFF-consumable
  - 当前只足以进入“backend current-session verification implementation-dispatch gate”起草
  证据见 [exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md)。
- 当前系统仍缺：
  - 实现级 current-session verification success path
  - runtime-ready signoff
  - migration closure
  - BFF consumption readiness
- 当前必须显式承认：
  - remediation 只证明“安全 fail-closed 成立”，不证明 runtime auth ready
  - raw `authorization` 不是 verified current-session truth
  - `Server` 才是 current-session verification owner
  - `auth-context.service.ts` 仍有 legacy wording 风险，但这不是本门禁要放开的修复包

## 4. Passed Gates

- 真源门禁已满足：current-session / auth-session 五条边界已经冻结清楚，且没有引入 second truth。
- 契约门禁已满足：`docs/01_contracts/**` 已把 transport carrier、refresh-session persistence truth、verified current-session context、header trust boundary 分层写清，足以支撑最小实现 authoring。
- backend truth 门禁已满足：eligibility 前提已经从宽松的 `Session.status = valid` 收紧到 `verified current-session context under a trusted Server-side verification boundary`。
- BFF / Server 边界门禁已满足：BFF 只 forward raw carrier 与 bounded hints，Server 才是 verification owner，这一分工已冻结完成。
- 独立复核已通过当前阶段 authoring 判断：`PASS WITH RISK`，且只支持进入“backend current-session verification implementation-dispatch gate authoring”。

## 5. Failed Gates

### 5.1 当前未通过、但不直接阻断本轮最小实现 gate 的门

- BFF consumption unlock 仍未通过。
- Flutter / Admin unlock 仍未通过。
- Package 2 / 3 / 4 implementation unlock 仍未通过。
- migration unlock 仍未通过。
- runtime-ready signoff 仍未通过。
- full auth family unlock 仍未通过。
- [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts) 仍有 legacy wording 风险，但该问题当前只被记录，不构成本轮 Server-side current-session verification gate 的直接阻断。

### 5.2 当前未通过、且会直接阻断本轮最小实现 gate 的门

- 在严格限定为：
  - `apps/server` only
  - current-session verification only
  - no migration
  - no BFF / Flutter / Admin
  - no full auth family
  的前提下，本轮未发现剩余的直接阻断门。
- 但若下一条 prompt 触及以下任一行为，本门禁立即失效并回退为 `No-Go`：
  - 把范围扩大成 full auth implementation
  - 顺手放开 BFF consumption
  - 顺手放开 Flutter / Admin
  - 顺手 author migration
  - 把 reviewer 以外其他 authz 扩修混入同一包

## 6. Veto Gates

以下任一项触发即一票否决：

- second truth：发明第二套 identity / session / auth truth。
- 把 raw `authorization` 当 verified session。
- 把 header hints 当 final auth truth。
- 放大成 full auth implementation。
- 越权放开 BFF / Flutter / Admin。
- 越权放开 migration。
- 把 fail-closed 偷换成 runtime-ready。
- 猜 JWT / token payload / signature 结构。

## 7. Stage Go / No-Go

`Go` for bounded Backend Agent current-session verification implementation prompt only

原因如下：

- 当前五条边界已经冻结清楚，且 docs-only truth patch bundle 已通过独立复核，足以支撑“current-session verification 最小实现”这一条明确目标。
- 当前最小下一步不是 full auth family，也不是 BFF unlock，而只是把 `Server` 侧 current-session verification 从 fail-closed-only 状态推进到有受控验证路径的最小实现。
- 当前 review 结论只允许起草这一条最小 Server-side verification gate；并未给 BFF gate、migration gate、runtime-ready gate 放行。
- 该 `Go` 只是为解除“永远 fail-closed”的下一小步，不是 BFF unlock，不是 Package 1 全量重做，更不是 release-ready。

## 8. If Go, Allowed Range

### 8.1 允许触碰的目录

- 只限 `apps/server`
- 最小允许目录范围只能是：
  - `apps/server/src/shared/**`
  - `apps/server/src/core/**`
  - `apps/server/src/main.ts`
  - `apps/server/src/app.module.ts`
  - `apps/server/src/modules/identity/**`
  - `apps/server/src/modules/organization/**`
- 如为接入同一最小 verifier 所必需，可允许对现有 protected path consumer 做 compile-required mechanical touch：
  - `apps/server/src/modules/shell/**`
  - `apps/server/src/modules/profile/**`
  - `apps/server/src/modules/review/**`
  但只限接入 shared current-session verification 结果，不得扩成新的业务语义。

### 8.2 允许完成的工作类型

- 只限 current-session verification 最小补丁。
- 允许：
  - request-context refinement
  - 局部 guard / verifier / verification service
  - current-session verification owner 的最小 wiring
  - 让既有 protected path 从“永远 fail-closed”进入“只有 verified current-session context 才放行”的受控实现
- 允许 reviewer 相关逻辑只做一件事：
  - 复用同一 verified current-session context
  - 不允许把 reviewer authorization 扩成单独 authz 改造包

### 8.3 明确禁止的事项

- 仍然禁止 full auth family。
- 仍然禁止 migration。
- 仍然禁止 BFF consumption。
- 仍然禁止 Flutter / Admin。
- 仍然禁止 Package 2 / 3 / 4。
- 仍然禁止 reviewer 以外其他 authz 扩修。
- 仍然禁止猜 JWT / token payload / signature 结构。
- 仍然禁止把 raw `authorization`、`x-actor-id`、`x-user-id`、`x-organization-id`、`x-actor-role` 升格为 final auth truth。

### 8.4 为什么 migration 仍不能动

- 当前门禁只放行 current-session verification 最小补丁，不放行 runtime schema closure。
- migration blocker 仍是 open blocker，但它阻断的是 runtime-ready 与 BFF unlock，不是本轮最小 verification code patch authoring。
- 因此本轮保持：
  - `Go` for bounded current-session verification implementation
  - `No-Go` for migration authoring / execution

## 9. If No-Go, Required Prerequisites

- 本轮结论为 `Go`，因此不存在“发 current-session verification 最小实现 prompt 前还必须新增哪份文书”的额外 prerequisite。
- 但若后续想扩大范围，则必须重新补 gate，而不能沿用本文件：
  - 若要 author migration，必须先补 migration scope gate
  - 若要进入 BFF consumption，必须先补 BFF dispatch gate
  - 若要进入 full auth family，必须先补 auth-family implementation gate

## 10. Next Unique Action

- 下一条允许发给 Backend Agent。
- 但只允许发一个 bounded current-session verification implementation prompt。
- 该下一条 prompt 必须同时写死以下边界：
  - 只限 `apps/server`
  - 只限 current-session verification 最小补丁
  - 不得新增或修改 migration
  - 不得推进 BFF consumption
  - 不得触碰 Flutter / Admin
  - 不得触碰 Package 2 / 3 / 4
  - 不得扩成 full auth family
  - 不得把 fail-closed 误写成 runtime-ready
- 若下一条 prompt 不能满足上述条件，则应退回总控重新出 gate，而不是带条件直接开工。


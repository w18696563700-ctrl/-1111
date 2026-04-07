---
owner: 独立复核
status: completed
purpose: Independent review of the bounded backend current-session verification implementation to confirm whether the verification boundary is centralized, fail-closed, scope-disciplined, and still non-runtime-ready.
layer: L0 SSOT
decision_date_local: 2026-04-02
inputs_canonical:
  - AGENTS.md
  - apps/server/AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_current_session_verification_implementation_dispatch_gate_checklist_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md
  - docs/01_contracts/auth_contracts.yaml
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md
  - apps/server/src/shared/current-session-verification.ts
  - apps/server/src/shared/request-context.ts
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/shell/shell-query.service.ts
  - apps/server/src/modules/profile/profile-query.service.ts
  - apps/server/src/modules/profile/profile-certification-write.service.ts
  - apps/server/src/modules/review/organization-review-query.service.ts
  - apps/server/src/modules/review/organization-review-write.service.ts
  - apps/server/src/modules/identity/entities/session.entity.ts
  - apps/bff/src/core/auth/auth-context.service.ts
  - apps/server/src/core/migrations/migrations.ts
---

# 展览项目发布-竞标-履约治理四文书
# Backend Current-session Verification Implementation Independent Review Addendum

## 1. Review Scope

- 本轮只做独立复核，不做新实现，不做 migration，不做 BFF / Flutter / Admin 消费，不做 release。
- 本轮只核验：
  - 是否已建立单一、显式、可复用的 current-session verification boundary
  - `shell / profile / review` 受保护路径是否统一依赖该 boundary
  - `CurrentActorEligibilityService` 是否只消费 verified current-session context
  - 是否没有回退到 any-valid-session surrogate 或 raw header direct trust
  - 是否没有越界到 BFF / migration / full auth family / Package 2+
  - 当前读法是否仍然只是 safe + centralized + fail-closed，而不是 runtime-ready 或 BFF-consumable

## 2. Review Basis

- 门禁与阶段文书：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [exhibition_trade_governance_four_documents_backend_current_session_verification_implementation_dispatch_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_current_session_verification_implementation_dispatch_gate_checklist_addendum.md)
  - [exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_package1_current_session_auth_session_truth_patch_independent_review_addendum.md)
  - [exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_independent_review_addendum.md)
- contracts 与 backend truth：
  - [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
  - [package1_current_session_and_auth_session_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/package1_current_session_and_auth_session_truth_addendum.md)
- 当前代码证据：
  - [current-session-verification.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/current-session-verification.ts)
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts)
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts)
  - [shell-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell/shell-query.service.ts)
  - [profile-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-query.service.ts)
  - [profile-certification-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts)
  - [organization-review-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-query.service.ts)
  - [organization-review-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts)
  - [session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts)
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts)
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)

## 3. Verified Wiring Findings

- 当前已新增唯一 shared verification boundary：
  - [current-session-verification.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/current-session-verification.ts)
  - 该文件统一定义了：
    - raw request input：`RequestContext`
    - verified output：`VerifiedCurrentSessionContext`
    - verification failure：`CurrentSessionVerificationResult` with `failed` outcome
- `CurrentActorEligibilityService` 已不再接收 raw `RequestContext`。
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts) 只消费 `VerifiedCurrentSessionContext`
  - 该 service 中未见：
    - any-valid-session by user surrogate
    - raw header role shortcut
    - raw actor/user fallback 作为 current-session truth
- `shell / profile / review` 当前 Package 1 受保护路径已统一接到同一个 verifier：
  - [shell-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell/shell-query.service.ts) 先调 `requireVerifiedCurrentSessionContext(context)`
  - [profile-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-query.service.ts) 三个读路径都先调同一 verifier
  - [profile-certification-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts) `submit / resubmit` 先调同一 verifier
  - [organization-review-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-query.service.ts) `list / detail` 先调同一 verifier
  - [organization-review-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts) `approve / reject` 先调同一 verifier
- 本轮静态扫描未见 `shell / profile / review / organization` 模块继续各自解释 raw `authorization`、`x-actor-id`、`x-user-id`、`x-actor-role`。
  - raw header 读取仍只集中在 [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts)
  - verification 判断仍只集中在 [current-session-verification.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/current-session-verification.ts)

## 4. Security-boundary Findings

- current-session verification boundary 已 centralized，但仍然 fail-closed。
  - [current-session-verification.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/current-session-verification.ts) 只承认 raw `authorization` 是 carrier candidate
  - 在 current truth 仍不足时，它统一返回：
    - `missing_current_session_carrier`
    - `authorization_carrier_not_verifiable`
- 当前没有把 raw `authorization` 升格成 verified truth。
  - verifier 在有 carrier 时也不会给出 `verified` 结果
  - `VerifiedCurrentSessionContext` 并未被 raw header 直接拼装生成
- 当前没有回退到 any-valid-session surrogate。
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts) 不再注入或查询 `SessionEntity`
  - [session.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts) 仍只代表 refresh-session persistence truth
- reviewer authorization 仍然只来自：
  - verified actor identity
  - active DB-backed membership
  - `platform_reviewer | platform_super_admin`
  - platform organization truth
- 当前没有看到 protected path 漏接同一 verifier 的情况。
- 当前正确读法仍然是：
  - safe
  - centralized
  - fail-closed
  - not runtime-ready
  - not BFF-consumable

## 5. Remaining Runtime Blockers

- current-session verification 仍没有 verified success path。
  - 当前 centralized verifier 只把失败语义收口，尚未形成 authenticated happy path
- runtime schema blocker 仍未解决。
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 仍未覆盖 `users / sessions / organizations / organization_members / organization_certifications / audit_logs`
- BFF wording 风险仍保留且本轮未被顺手修复。
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts) 仍把 `authorization` 与 `x-actor-id/x-user-id` 并列描述为 “valid session carrier”
  - 这不影响本轮 centralized verifier 结论，但也证明本轮没有越界到 BFF 修包
- `file_assets` vs `file_asset` naming drift 仍未解决。
- 因此本轮结果不能被读成 runtime-ready，也不能被读成 BFF consumption unlock。

## 6. Unsupported Or Overstated Claims

- 不支持把“current-session verification centralized”说成 authenticated happy path 已恢复。
- 不支持把 `tsc` / `nest build` 通过说成 runtime auth ready。
- 不支持把本轮结论说成 BFF-consumable。
- 不支持把本轮结论说成 full auth family 已放行。
- 不支持把 raw `authorization`、`x-actor-id`、`x-user-id`、`x-actor-role` 任一项说成 verified current-session truth。

## 7. Verification Commands And Results

| Command | Result |
| --- | --- |
| `rg -n "requireVerifiedCurrentSessionContext|verifyCurrentSessionContext" apps/server/src` | 命中 shared verifier 与 `shell / profile / review` consumer，确认存在单一 shared verification boundary。 |
| `rg -n "RequestContext" apps/server/src/modules/{shell,profile,review,organization}` | 命中 controller 与 consumer service；`organization` 模块不再把 `RequestContext` 传入 eligibility service。 |
| `rg -n "same user has any valid session|valid session" apps/server/src/modules/organization apps/server/src/shared` | 无命中，未见 any-valid-session surrogate 回退。 |
| `rg -n "x-actor-role|context\\.actorRole|context\\.userId|context\\.actorId|context\\.organizationId|context\\.authorization" apps/server/src/modules/{shell,profile,review,organization}` | 无命中，未见受保护业务模块继续直接消费 raw header context 字段。 |
| `./node_modules/.bin/tsc --noEmit` in [apps/server](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server) | 退出码 `0`。 |
| `./node_modules/.bin/nest build` in temporary mirror of [apps/server](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server) | 退出码 `0`；为避免写入 repo 下 `apps/server/dist/**`，本命令在临时副本 `/tmp/server-review.t5UiA4` 执行。 |

## 8. Stage Decision

- 复核结论：`PASS WITH RISK`
- Stage decision：`Go` for 总控文书冻结 next auth/session implementation-prep gate only
- 原因：
  - 本轮实现已经做到“正确 centralized + 仍然 fail-closed + 无越界”
  - `shell / profile / review` 已统一依赖同一个 shared verification boundary
  - `CurrentActorEligibilityService` 已只消费 verified current-session context
  - 但当前仍没有 verified success path，仍不是 runtime-ready，也仍不能给 BFF 发 consumption prompt

## 9. Next Unique Action

- 建议下一条发给：`总控文书冻结`
- 下一条应只起草并冻结 next auth/session implementation-prep gate，明确后续最小实现前提，而不是直接继续放开：
  - BFF consumption
  - migration
  - full auth family
  - runtime-ready signoff

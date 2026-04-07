---
owner: 结果校验 Agent
status: active
purpose: Independent read-only verification of Backend Package 1A remediation for current-session and reviewer authorization boundary tightening.
layer: L0 SSOT
review_date_local: 2026-04-02
---

# 展览项目发布-竞标-履约治理四文书
# Backend Package 1A Remediation Independent Review Addendum

## 1. Review Scope

- 本轮只做独立复核，不做新实现，不做 migration，不做 BFF / Flutter / Admin 消费，不做 release。
- 本轮只读核验以下目标：
  - 是否已消除“同用户任意 valid session 即放行”的误放行语义
  - 是否已移除对 `x-actor-role` / header role 的 reviewer direct trust
  - 在 current-session truth 尚未冻结可验证前，是否已经转为 fail-closed
  - remediation 是否越界到 migration / BFF / Flutter / Admin / Package 2+
  - 当前是否足以进入下一步“总控文书冻结 current-session / auth-session truth”跟进
  - 当前仍然不能给 BFF 发 consumption prompt
- 本轮实际代码核验范围：
  - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts)
  - [current-actor-eligibility.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts)
  - [profile-certification-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts)
  - [organization-review-write.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts)
  - [core.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/core.module.ts)
  - [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/main.ts)
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)
  - [auth-context.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts)

## 2. Review Basis

- 门禁与 remediation dispatch 依据：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [apps/server/AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [exhibition_trade_governance_four_documents_backend_package1a_remediation_dispatch_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1a_remediation_dispatch_gate_checklist_addendum.md)
  - [exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_independent_review_addendum.md)
- frozen truth / contracts 依据：
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [auth_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/auth_contracts.yaml)

## 3. Remediation Verification Findings

### 3.1 current-session semantics

- `requireAuthenticatedActor()` 已移除“按 `userId` 查任意 valid session 即放行”的旧语义。
  - 当前 [current-actor-eligibility.service.ts#L52](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts#L52) 不再注入 `SessionEntity` repository，也不再做 `findOne({ where: { userId, status: 'valid' ... }})` 查询。
- 当前实现已经变成显式 fail-closed。
  - [request-context.ts#L26](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts#L26) 仅把 `authorization` 当作 carrier 读入上下文。
  - [current-actor-eligibility.service.ts#L181](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts#L181) 的 `assertTrustedCurrentSessionBoundary()` 在两种情况下都返回 `AUTH_SESSION_INVALID`：
    - 没有 `authorization`
    - 有 raw `authorization`，但当前 Package 1A boundary 无法验证它
- 因此当前实现满足：
  - 没有可信 current-session carrier 就 fail-closed
  - 有 raw `authorization` 但当前 boundary 无法验证时，仍 fail-closed
  - raw `authorization` 的存在本身不会被当成认证成功
- 该修复是安全收紧，不是 runtime auth ready。

### 3.2 reviewer authorization boundary

- `requireReviewer()` 已完全移除 header role direct trust。
  - 旧问题中的 `if (actorRole && REVIEWER_ROLE_KEYS.has(actorRole)) direct pass` 已不存在。
  - 当前 [current-actor-eligibility.service.ts#L106](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts#L106) 只从 DB truth 取 reviewer membership：
    - `user` 先经 `requireAuthenticatedActor()`
    - `organization_members.member_status = active`
    - `roleKey in platform_reviewer | platform_super_admin`
    - `organizations.organization_type = platform`
- `organization-review-write.service.ts` 的 reviewer attribution 已切到 DB reviewer truth。
  - `reviewedBy` 现在写 [review-write#L67](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L67) 和 [review-write#L125](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L125) 的 `reviewer.user.id`
  - audit context 也使用 [review-write#L41](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L41) / [review-write#L104](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L104) 的 DB reviewer `userId` 与 `actorRole`

### 3.3 Protected path tightening

- Package 1A 受保护读写路径当前都统一经过 `CurrentActorEligibilityService`，因此 fail-closed 不是局部补丁：
  - [shell-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell/shell-query.service.ts)
  - [profile-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-query.service.ts)
  - [profile-certification-write.service.ts#L45](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts#L45)
  - [organization-review-query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-query.service.ts)
  - [organization-review-write.service.ts#L38](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L38)
- 当前结果是：这些 Package 1A 受保护路径不再会因为“同用户任意 valid session”而误放行。

## 4. Security-boundary Findings

### 4.1 Pass findings

- any-valid-session 误放行风险已被收住。
- reviewer 权限不再直接信任 header role。
- reviewer attribution 已切回 DB truth，而不是 header 派生值。
- remediation 没有把 raw `authorization` 误判为认证成功。
- `file_asset` / `file_assets` drift 本轮未被借机扩修。

### 4.2 Risk findings

1. 当前实现是“永远 fail-closed”。
   - 这对安全是收紧。
   - 但这也意味着当前 Package 1A 受保护路径在现有 truth / forwarding boundary 下无法形成正常 authenticated happy path。

2. 当前 current-session truth 仍未冻结到可验证载体。
   - [request-context.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts) 只拿到 raw `authorization` 字符串。
   - [auth-context.service.ts#L54](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts#L54) 仍只是转发 `authorization` 或 `x-actor-id`，没有 current-session 可验证 truth carrier。
   - 因此当前 remediation 成功地把风险收住了，但没有解决 current-session truth 本身。

3. `x-actor-role` 仍会被 `RequestContext` 和 BFF forward header 读入。
   - [request-context.ts#L32](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts#L32)
   - [auth-context.service.ts#L28](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/core/auth/auth-context.service.ts#L28)
   - 但在本轮核验范围内，它已不再作为 reviewer 直接放行条件。

4. 本轮 scope 校验受限于 workspace 无 git metadata。
   - 根目录、`apps/server`、`apps/bff` 均不是 git repo。
   - 因此“未越界”判断只能基于当前文件系统与静态扫描证据，而不是 VCS diff。

## 5. Remaining Runtime Blockers

1. current-session / auth-session truth 仍未冻结到可验证边界。
   - 这是当前 remediation 后仍然必须保留的 blocker。

2. runtime schema blocker 仍未解决。
   - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 仍只覆盖 `enterpriseHubMigrations` 与 `projectPublishCorridorMigrations`。
   - 当前仍未看到 `users / sessions / organizations / organization_members / organization_certifications / audit_logs` 的建表语句。

3. naming drift 仍未解决。
   - frozen truth 写 `file_assets`
   - 当前实体 / migration 仍是 [file-asset.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts) 与 [migrations.ts#L223](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts#L223) 的 `file_asset`

4. 因此当前阶段仍不能给 BFF 发 consumption prompt。
   - 本轮只支持进入“总控文书冻结 current-session / auth-session truth”跟进，不支持下游消费解锁。

## 6. Unsupported Or Overstated Claims

- 当前不能宣称 runtime auth ready。
- 当前不能宣称 Package 1A 已恢复 authenticated happy path。
- 当前不能宣称已形成可消费的 BFF forwarding contract。
- 当前不能宣称 runtime schema blocker 已关闭。
- 当前不能宣称 `file_assets` naming drift 已关闭。
- 当前只能宣称：
  - remediation 已把 two high-risk bypasses 收住
  - 系统在当前 boundary 下转为 fail-closed
  - 下一步只允许进入总控文书冻结 current-session / auth-session truth 跟进

## 7. Verification Commands And Results

| Command | Result |
| --- | --- |
| `sed -n` / `rg -n` over required docs and remediation target files | 完成 required 文书与代码只读核验。 |
| `rg -n "requireAuthenticatedActor\\(|requireOrganizationAdmin\\(|requireReviewer\\(" apps/server/src/modules/{shell,profile,review,organization}` | 确认 Package 1A 受保护读写路径统一经过 `CurrentActorEligibilityService`。 |
| `rg -n "authorization carrier is not verifiable|missing a verifiable current-session carrier" apps/server/src` | 确认 `assertTrustedCurrentSessionBoundary` 为 fail-closed 语义。 |
| `rg -n "exhibition_report_cases|governance_penalties|...|eligibility_snapshots"` over `apps/server/src apps/bff/src apps/mobile/lib apps/admin/src` | 未见 remediation 借机引入 Package 2+ truth carrier；未见 `file_assets` naming 修复进入代码。 |
| `./node_modules/.bin/tsc --noEmit` in [apps/server](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server) | 退出码 `0`。 |
| `./node_modules/.bin/nest build` in [apps/server](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server) | 退出码 `0`。 |
| `find apps/server/dist -type f -mmin -10` | 观测到 `nest build` 刷新了 `apps/server/dist/**` 编译产物。 |
| `git rev-parse --show-toplevel` in root / `apps/server` / `apps/bff` | 均失败；workspace 无 git metadata，可做静态核验，不能做 VCS diff。 |

## 8. Stage Decision

- 复核结论：`PASS WITH RISK`
- Stage decision：`Go` for 总控文书冻结 current-session/auth-session truth follow-up prompt only

原因：
- remediation 已经把 `any-valid-session` 误放行和 `x-actor-role` direct trust 两个高风险缺口收住。
- 当前实现已经明确转为 fail-closed，不会把 raw carrier 当作认证成功。
- 但 current-session truth、runtime schema blocker、naming drift 仍未关闭，因此这不是 runtime-ready，更不是 BFF consumption-ready。

## 9. Next Unique Action

- 下一唯一动作应发给：`总控文书冻结`
- 原因：
  - 当前最缺的不是代码实现，而是 current-session / auth-session truth 的正式冻结与边界定义。
  - remediation 已安全地把风险收紧到 fail-closed，现阶段最合理的下一步是让总控冻结：
    - trusted current-session carrier
    - BFF forwarding boundary
    - Server verification boundary
    - current-session truth 与 existing auth contracts 的关系
  - 在这一步完成前，不能发 BFF consumption prompt。

---
owner: 结果校验 Agent
status: active
purpose: Independent read-only verification of apps/server Package 1A bounded implementation for exhibition trade governance four documents.
layer: L0 SSOT
review_date_local: 2026-04-02
---

# 展览项目发布-竞标-履约治理四文书
# Backend Package 1 Implementation Independent Review Addendum

## 1. Review Scope

- 本轮只做独立校验，不做新实现，不做 migration，不做 BFF / Flutter / Admin 消费，不做 release。
- 本轮只读核验以下目标：
  - 是否严格落在已放行的 Package 1 边界内
  - 是否没有越权触碰 migration / BFF / Flutter / Admin / Package 2+
  - `Server` 是否真实挂出要求的 10 条 internal/admin truth path
  - truth binding、derived eligibility、certification transition、activation coupling、audit、file-evidence linkage 是否与 frozen truth 一致
  - 当前是否足以作为下一条发给 BFF 的前置输入
  - 当前是否只是 compile-level ready，而不是 runtime-ready
- 本轮实际核验代码范围：
  - [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)
  - [apps/server/src/modules/identity](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity)
  - [apps/server/src/modules/organization](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization)
  - [apps/server/src/modules/audit](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit)
  - [apps/server/src/modules/shell](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell)
  - [apps/server/src/modules/profile](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile)
  - [apps/server/src/modules/review](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review)
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts)
  - [file-asset.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts)

## 2. Review Basis

- 门禁与派工边界：
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [apps/server/AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [exhibition_trade_governance_four_documents_backend_package1_implementation_dispatch_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_package1_implementation_dispatch_gate_checklist_addendum.md)
  - [exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_backend_d1_truth_gap_planning_addendum.md)
- frozen truth / BFF surface / closure basis：
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
  - [account_and_enterprise_certification_rules_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md)
  - [account_identity_board_closure_plan_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_identity_board_closure_plan_addendum.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 3. Verified Paths And Wiring

### 3.1 Required path verification

| Required path | Controller evidence | Wiring result |
| --- | --- | --- |
| `GET /server/shell/context` | [shell.controller.ts#L6](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell/shell.controller.ts#L6) | Pass |
| `GET /server/profile/index` | [profile.controller.ts#L7](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L7) | Pass |
| `GET /server/profile/organization/mine` | [profile.controller.ts#L19](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L19) | Pass |
| `POST /server/profile/certification/submit` | [profile.controller.ts#L29](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L29) | Pass |
| `GET /server/profile/certification/current` | [profile.controller.ts#L24](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L24) | Pass |
| `POST /server/profile/certification/resubmit` | [profile.controller.ts#L34](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L34) | Pass |
| `GET /server/admin/reviews/organizations` | [organization-review.controller.ts#L7](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review.controller.ts#L7) | Pass |
| `GET /server/admin/reviews/organizations/{organizationId}` | [organization-review.controller.ts#L19](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review.controller.ts#L19) | Pass |
| `POST /server/admin/reviews/organizations/{organizationId}/approve` | [organization-review.controller.ts#L24](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review.controller.ts#L24) | Pass |
| `POST /server/admin/reviews/organizations/{organizationId}/reject` | [organization-review.controller.ts#L33](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review.controller.ts#L33) | Pass |

### 3.2 Module wiring verification

- `AppModule` 真实导入了：
  - [ShellModule](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts#L30)
  - [ProfileModule](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts#L31)
  - [ReviewModule](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts#L32)
- `ShellModule` 通过 [shell.module.ts#L8](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell/shell.module.ts#L8) 导入 `OrganizationModule`。
- `ProfileModule` 通过 [profile.module.ts#L14](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.module.ts#L14) 导入 `OrganizationModule`、`IdentityAuditModule` 与所需实体。
- `ReviewModule` 通过 [review.module.ts#L14](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/review.module.ts#L14) 导入 `OrganizationModule`、`IdentityAuditModule` 与所需实体。
- `OrganizationModule` 再经 [organization.module.ts#L9](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/organization.module.ts#L9) 导入 `IdentityModule`。

### 3.3 Internal path / app-facing path boundary

- 本轮核验到的 controller 装饰器全部是 `server/*` internal/admin path：
  - [shell.controller.ts#L6](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell/shell.controller.ts#L6)
  - [profile.controller.ts#L7](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L7)
  - [organization-review.controller.ts#L7](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review.controller.ts#L7)
- 在 `apps/server/src` 当前核验范围内未发现把这些 path 错挂成 `/api/app/*` 的 controller 证据。
- `openapi.yaml` 中的 `/api/app/*` 仍停留在 app-facing contracts 层，不应与当前 `Server` internal/admin path 混用。

## 4. Truth-boundary Findings

### 4.1 Boundary-conformant findings

- 当前新接线确实落在 Package 1A 允许 carrier 内，没有新 dedicated identity / certification table 发明：
  - [users](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/user.entity.ts)
  - [sessions](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/identity/entities/session.entity.ts)
  - [organizations](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/entities/organization.entity.ts)
  - [organization_members](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/entities/organization-member.entity.ts)
  - [organization_certifications](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/entities/organization-certification.entity.ts)
  - [audit_logs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/identity-audit-log.entity.ts)
  - [file_asset](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts)
- 在本轮新增接触面中未发现 Package 2 / 3 / 4 controller 或 new truth carrier；`report / governance / contract / milestone / inspection` 相关 controller family 未被接入 `AppModule`。
- 未发现把 `enterprise_hub` 快照对象误当认证真值的证据；Package 1A 模块本身没有直接依赖 `enterprise_hub` runtime object。
- `submit / resubmit` 只会写成 `pending_review`，证据见：
  - [profile-certification-write.service.ts#L68](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts#L68)
  - [profile-certification-write.service.ts#L149](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts#L149)
- `approve / reject` 仅出现在 admin review 写入口，证据见：
  - [organization-review-write.service.ts#L33](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L33)
  - [organization-review-write.service.ts#L93](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L93)
- `organizations.status` 与 `organization_certifications.certification_status` 仍然分离；`approve` 仅在 `organization.status === 'draft'` 时升到 `active`，未自动恢复 `suspended / closed`，`reject` 也未把组织置 `closed`，证据见 [organization-review-write.service.ts#L63](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L63)。
- 认证文件仍以 `licenseFileId -> file asset` 绑定，不以 raw URL 或 `objectKey` 升格为 truth；review 读写也以 `licenseFileId` 为准，证据见：
  - [profile-certification-write.service.ts#L46](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts#L46)
  - [organization-review-write.service.ts#L55](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L55)

### 4.2 Fail findings

1. `derived eligibility` 的 `session valid` 语义与 frozen truth 不一致。
   - [RequestContext](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts#L5) 不携带任何 current-session id / token 语义。
   - [requireAuthenticatedActor](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts#L49) 只按 `context.userId` 查“该用户任意一个 `status = valid` 且未撤销的 session”，而不是校验“当前请求绑定的那个 session”。
   - 结果是：若某用户有另一个仍有效的 session，当前已失效或被撤销的请求上下文仍可能被误放行。
   - 这属于你要求重点核对的 current-session 语义偏差，按本轮判定直接记为高优先级失败。

2. `admin review` 权限当前对 `x-actor-role` 存在直接信任放行。
   - [resolveRequestContext](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/shared/request-context.ts#L25) 直接从 header 读取 `x-actor-role`。
   - [requireReviewer](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/organization/current-actor-eligibility.service.ts#L114) 只要 header 中的 `actorRole` 属于 reviewer 集合，就直接放行，不再核对平台组织 membership。
   - [CoreModule](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/core.module.ts) 与 [main.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/main.ts) 未见全局 guard / middleware / auth filter 兜底证据。
   - 对 `Server` Admin truth path 来说，这不是可接受的 runtime-ready 权限边界。

3. `file_assets` frozen wording 与当前代码 / schema naming 存在 drift。
   - frozen truth 使用 `file_assets` 作为 canonical family 名称。
   - 当前实体与 migration 仍绑定 [file_asset.entity.ts#L3](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/upload/entities/file-asset.entity.ts#L3) 和 [migrations.ts#L223](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts#L223) 的单数 `file_asset`。
   - 本轮只记录 drift，不自行修复。

## 5. Runtime-risk Findings

1. 当前实现只能判为 compile-level ready，不能判为 runtime-ready。
   - [AppModule](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts#L25) 开启 `autoLoadEntities: true`，同时 [AppModule](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts#L26) 关闭 `synchronize`。
   - 这意味着 runtime 依赖现有 migration 已真实提供表结构。

2. Package 1A 新依赖的 canonical tables 不在当前 `serverMigrations` 内，构成 runtime blocker。
   - 在 [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 中只见：
     - `enterpriseHubMigrations`
     - `projectPublishCorridorMigrations`
   - 现有建表语句只覆盖 `enterprise_hub`、`project`、`upload_session`、`file_asset`、`project_publish_audit_log`。
   - 本轮未找到 `CREATE TABLE IF NOT EXISTS users / sessions / organizations / organization_members / organization_certifications / audit_logs`。
   - 因此在 fresh schema 或只跑当前 repo migrations 的环境里，Package 1A 相关查询和写入无法被保证真实可运行。

3. 认证与 review 的审计最小字段基本具备，但 evidence pointer 仍是非结构化字符串。
   - [identity-audit.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/identity-audit.service.ts) 记录了 actor、action、object、before/after、requestId、traceId。
   - 认证文件指针以 `licenseFileId=...` 的形式写入 `reason` 字段，见：
     - [profile-certification-write.service.ts#L109](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile-certification-write.service.ts#L109)
     - [organization-review-write.service.ts#L83](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review-write.service.ts#L83)
   - 这可视为“同等可追踪信息”，但仍是非结构化证据承载，稳定性弱于专门字段。

4. `Server` 当前没有可见的全局 auth / session guard 证据。
   - 当前 controller 统一通过 `@Headers()` + `resolveRequestContext()` 直接读 header，证据见：
     - [shell.controller.ts#L10](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/shell/shell.controller.ts#L10)
     - [profile.controller.ts#L14](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/profile/profile.controller.ts#L14)
     - [organization-review.controller.ts#L14](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/review/organization-review.controller.ts#L14)
   - 对 compile-level 来说可以通过；对 runtime 安全性来说仍是 blocker。

## 6. Unsupported Or Overstated Claims

- 当前不能宣称“runtime-ready”。
- 当前不能宣称“已足以作为下一条发给 BFF 的安全前置输入”。
- 当前不能宣称“`session valid` 已按 current-session 语义落地”。
- 当前不能宣称“admin review 权限已完成可信 reviewer attribution 绑定”。
- 当前不能宣称“canonical table family 已被现有 migration 真实覆盖”。
- 当前不能宣称“`file_assets` frozen wording 与当前 schema naming 完全一致”。
- 当前只能宣称：
  - required 10 paths 已在 `Server` controller / module 上 compile-level 接线完成
  - bounded scope 基本仍在 Package 1A 内
  - 但 runtime blocker 与权限语义 blocker 仍未关闭

## 7. Verification Commands And Results

| Command | Result |
| --- | --- |
| `rg -n "/server/shell/context|/server/profile/index|/server/profile/organization/mine|/server/profile/certification/submit|/server/profile/certification/current|/server/profile/certification/resubmit|/server/admin/reviews/organizations" docs/01_contracts/openapi.yaml apps/server/src` | 找到 10 条 required path 的 contract 与 controller 装饰器证据。 |
| `rg -n "@Module\\(|imports:|controllers:|providers:" apps/server/src/app.module.ts apps/server/src/modules/{identity,organization,shell,profile,review}/**/*.ts apps/server/src/modules/audit/identity-audit*.ts` | 确认 `AppModule`、`ShellModule`、`ProfileModule`、`ReviewModule` 与其依赖链真实导入。 |
| `rg -n "@Controller\\(|@Entity\\(|...|/api/app/" apps/server/src/modules apps/server/src/app.module.ts` | 未发现 Package 1A controller 错挂 `/api/app/*`；未发现 new dedicated Package 2+ table/controller。 |
| `./node_modules/.bin/tsc --noEmit` in [apps/server](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server) | 退出码 `0`。 |
| `./node_modules/.bin/nest build` in [apps/server](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server) | 退出码 `0`。 |
| `find apps/server/dist -type f -mmin -10` | 无输出；本轮未观察到新的 `dist` 写入痕迹。 |
| `git status --short` | 当前工作目录不是 git repo，无法用 VCS diff 做增量比对；本轮结论基于当前文件系统只读扫描与编译验证。 |

## 8. Stage Decision

- 复核结论：`FAIL`
- Stage decision：`No-Go` for bounded BFF Package 1 consumption prompt only

原因：
- 当前 `derived eligibility` 的 `session valid` 实现不是 current-session 语义，而是“同 user 任意 valid session”语义，属于高优先级失败。
- `admin review` 权限当前直接信任 `x-actor-role` header，未见上游全局 guard / middleware 兜底证据，不能作为可信 `Server Admin` truth path 放给下一步消费。
- 虽然 `tsc --noEmit` 与 `nest build` 都通过，但当前 migration 不覆盖 Package 1A 所依赖的 canonical tables，只能判为 compile-level ready，不能判为 runtime-ready。

## 9. Next Unique Action

- 下一唯一动作应发给：`总控文书冻结`
- 原因：
  - 当前不是 BFF consumption unlock，而是 `Server Package 1A` 的 bounded remediation / gate reset 问题。
  - 必须先由总控冻结一条新的 bounded remediation 指令，只处理：
    - current-session 语义纠偏
    - reviewer authorization 边界纠偏
    - runtime schema / migration 缺口裁定
    - `file_assets` vs `file_asset` naming drift 裁定
  - 在这组 blocker 关闭前，不应发出下一条 BFF Package 1 consumption prompt。

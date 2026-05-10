---
owner: Codex 总控
status: draft
layer: L0 SSOT
scope: Admin Day 4 Audit 聚合与追责字段方案
created_at: 2026-05-11
---

# Admin Day 4 Audit 聚合与追责字段方案

## 1. 总裁决

Day 4 目标是关闭 `P0-4 / P0-5` 的设计缺口。

当前裁决：`PASS WITH OPEN IMPLEMENTATION`。

本地代码事实：

- Admin `/audit` 当前只读查询 `identity` 与 `project_publish` 两类 audit。
- 内容安全、forum report、exhibition report-case、governance penalty、governance appeal、governance rescan 已通过 `ContentSafetyAuditService` 写入 `content_safety_audit_logs`。
- `content_safety_audit_logs` 未被 `AuditLogQueryService` 聚合进 `/server/admin/audit/logs`。

本轮方案只做只读聚合，不修改历史 audit，不做 backfill，不做 export，不做 replay，不做 audit mutation。

## 2. 当前证据

| 证据 | 路径 | 结论 |
| --- | --- | --- |
| Admin audit query | `apps/server/src/modules/audit/audit-log-query.service.ts` | 只查询 `IdentityAuditLogEntity` 与 `ProjectPublishAuditLogEntity` |
| Admin audit module | `apps/server/src/modules/audit/audit-admin.module.ts` | TypeOrm 只注册 identity / project_publish 两类 audit entity |
| Audit source family | `apps/server/src/modules/audit/audit-log.types.ts` | 当前 `AUDIT_SOURCE_FAMILIES = ['identity', 'project_publish']` |
| Audit presenter | `apps/server/src/modules/audit/audit-log.presenter.ts` | `parseAuditLogId()` 只接受 identity / project_publish |
| Content safety audit writer | `apps/server/src/modules/content_safety/content-safety-audit.service.ts` | 写 `ContentSafetyAuditLogEntity` |
| Content safety audit entity | `apps/server/src/modules/content_safety/entities/content-safety-audit-log.entity.ts` | 字段已包含 subjectType / subjectId / actorId / actorRole / action / decision / reason / requestId / traceId / createdAt |
| Current audit test | `apps/server/test/audit-admin-read.test.cjs` | 测试只覆盖 identity / project_publish 聚合 |

## 3. 最小聚合范围

新增 audit sourceFamily：

```ts
content_safety
```

`content_safety` family 覆盖以下 subject/action：

| subjectType | 来源模块 | 代表 action |
| --- | --- | --- |
| `forum_report_ticket` | Forum report | `forum_report_submitted`；后续 `forum_report_decide` / `forum_report_hide_target` / `forum_report_restore_target` |
| `exhibition_report_case` | Exhibition report cases | `exhibition_report_case_submit` / `request_explanation` / `decide` / `escalate` |
| `governance_penalty` | Governance penalty | `governance_penalty_apply` |
| `governance_appeal` | Governance appeal | `governance_appeal_decide` |
| `governance_rescan_job` | Governance rescan | `governance_rescan_job_create` |
| `profile_safety_submission` | Profile safety | profile safety manual review actions |

## 4. 统一字段映射

`ContentSafetyAuditLogEntity` 映射到 `NormalizedAuditLog` 的最小规则：

| NormalizedAuditLog 字段 | content_safety 映射 |
| --- | --- |
| `auditLogId` | `content_safety:${id}` |
| `sourceFamily` | `content_safety` |
| `objectType` | `subjectType` |
| `objectId` | `subjectId` |
| `objectNo` | `null` |
| `action` | `action` |
| `actorId` | `actorId` |
| `actorRole` | `actorRole` |
| `requestId` | `requestId` |
| `traceId` | `traceId` |
| `occurredAt` | `createdAt.toISOString()` |
| `beforeState` | `null` |
| `afterState` | `decision` |
| `reason` | `reason` |
| `payload` | `{ reasonCode, matchedRuleIds, metadata, engineType, userId }` |

## 5. 最小 Server 修改范围

若进入实现，Server 只允许以下最小改动：

1. `apps/server/src/modules/audit/audit-log.types.ts`
   - 将 `content_safety` 加入 `AUDIT_SOURCE_FAMILIES`。
2. `apps/server/src/modules/audit/audit-admin.module.ts`
   - 注册 `ContentSafetyAuditLogEntity` repository。
3. `apps/server/src/modules/audit/audit-log-query.service.ts`
   - 注入 content safety audit repository。
   - 按 `sourceFamily` 过滤读取。
   - 合并排序和分页仍保持现有逻辑。
4. `apps/server/src/modules/audit/audit-log.presenter.ts`
   - 增加 `fromContentSafety()`。
   - `parseAuditLogId()` 接受 `content_safety:<id>`。
5. `apps/server/test/audit-admin-read.test.cjs`
   - 增加 list/filter/detail 覆盖。

禁止事项：

- 不改已有 audit 表结构。
- 不做 migration。
- 不修改历史 audit row。
- 不添加 audit export。
- 不添加 audit delete / edit / replay / backfill。

## 6. 最小 Admin 修改范围

Admin 侧只允许做只读呈现：

1. `/audit` 列表显示 `sourceFamily = content_safety`。
2. detail 显示 `afterState = decision`、`reason`、`payload`。
3. 不增加任何 audit 写按钮。
4. 不把 audit 页面变成治理操作台。

建议字段顺序：

| 列 | 字段 |
| --- | --- |
| 时间 | `occurredAt` |
| 来源 | `sourceFamily` |
| 对象 | `objectType / objectId` |
| 动作 | `action` |
| 操作人 | `actorId / actorRole` |
| 链路 | `requestId / traceId` |

## 7. Contracts 影响

需要更新：

- `docs/01_contracts/openapi.yaml`
  - `/server/admin/audit/logs` response 的 `sourceFamily` enum 增加 `content_safety`。
  - detail payload 允许 content-safety audit 字段。

可能需要更新：

- `packages/contracts/openapi/openapi.bundle.json`
- `packages/contracts/src/generated/**`

但必须通过 approved contracts generation，不允许手写 generated 作为正式闭环。

## 8. Day 4 准入下一天裁决

Day 4 准入 Day 5 条件：

- Audit 聚合范围固定为只读 `content_safety` sourceFamily。
- 追责字段 actor / reason / occurredAt / target / action 已有映射。
- 不做 migration、不做 backfill、不做 audit mutation。
- Contracts 影响已识别，交给 Day 5 clean-window。

当前裁决：`PASS`。

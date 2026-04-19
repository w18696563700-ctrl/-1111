---
owner: Codex 总控
status: frozen
purpose: Freeze the stage3 package C admin-audit contract family for the bounded read-only queue/list/detail workbench without opening mutation or export semantics.
layer: L2 Contracts
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_c_controller_review_conclusion_addendum.md
  - docs/05_admin/admin_governance_surface_matrix.md
  - docs/02_backend/audit_log_spec.md
  - docs/01_contracts/openapi.yaml
  - apps/admin/src/app/audit/page.tsx
  - apps/admin/src/modules/audit/audit-shell.tsx
  - apps/server/src/modules/audit/identity-audit-log.entity.ts
  - apps/server/src/modules/audit/project-publish-audit-log.entity.ts
---

# 《阶段3 package C audit contracts addendum》

## 1. contract family 目标

- 本轮只冻结 `package C` 的最小 read-only admin path family。
- 本轮只允许：
  - queue/list
  - filter
  - detail
- 本轮不允许：
  - mutation
  - export
  - bulk replay
  - audit-row rewrite

## 2. canonical path family

- `GET /server/admin/audit/logs`
- `GET /server/admin/audit/logs/{auditLogId}`

当前 package-C 不冻结：
- `POST /server/admin/audit/*`
- `PATCH /server/admin/audit/*`
- `DELETE /server/admin/audit/*`
- `GET /server/admin/audit/export*`

## 3. list query params

`GET /server/admin/audit/logs` 允许的最小 query family 固定为：

- `sourceFamily`
  - allowed:
    - `identity`
    - `project_publish`
- `objectType`
- `objectId`
- `objectNo`
- `actorId`
- `requestId`
- `traceId`
- `action`
- `occurredFrom`
- `occurredTo`
- `page`
- `pageSize`

当前 package-C 不冻结：
- full-text query
- arbitrary sort field
- export token
- saved search

## 4. list response shape

`GET /server/admin/audit/logs` 的最小 response shape 固定为：

- `items[]`
  - `auditLogId`
  - `sourceFamily`
  - `objectType`
  - `objectId`
  - `objectNo`
  - `action`
  - `actorId`
  - `actorRole`
  - `requestId`
  - `traceId`
  - `occurredAt`
- `pagination`
  - `page`
  - `pageSize`
  - `total`

规则：
- `items[]` 必须是 read-only projection。
- 不得把 projection 写回为第二真源。

## 5. detail response shape

`GET /server/admin/audit/logs/{auditLogId}` 的最小 response shape 固定为：

- `auditLogId`
- `sourceFamily`
- `objectType`
- `objectId`
- `objectNo`
- `action`
- `actorId`
- `actorRole`
- `requestId`
- `traceId`
- `occurredAt`
- `beforeState`
- `afterState`
- `reason`
- `payload`

规则：
- `beforeState / afterState / reason / payload` 为 detail 层字段。
- 如底层 carrier 本身不持有某字段，该字段返回：
  - `null`
  - 或空对象
  - 但不得伪造值。

## 6. source-family normalization rule

- `identity` family 对齐：
  - `audit_logs`
- `project_publish` family 对齐：
  - `project_publish_audit_log`

最小 normalization 规则固定为：
- `objectType`
  - from `object_type` or `aggregate_type`
- `objectId`
  - from `object_id` or `aggregate_id`
- `action`
  - from `action` or `event_type`
- `occurredAt`
  - from `occurred_at` or `created_at`

当前 package-C 不冻结更多 family。

## 7. auth and transport boundary

- `Admin` 继续直连 `Server Admin API`
- 不经 `BFF`
- 继续受当前 `server_session_carrier_only` 管理员会话载体保护

## 8. explicit non-goals

- 不冻结 Admin export path
- 不冻结 audit mutation path
- 不冻结 generic observability path
- 不冻结 ticket correlation path
- 不冻结 app-facing path

## 9. Formal Conclusion

- `stage3 package C` 的最小 contracts family 已冻结为：
  - `GET /server/admin/audit/logs`
  - `GET /server/admin/audit/logs/{auditLogId}`
- 当前 package-C contract 只允许 read-only queue/list/detail。
- 在后续 execution-dispatch author 之前，不得自行扩展 mutation/export family。

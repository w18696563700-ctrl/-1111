---
owner: Codex 总控
status: frozen
purpose: Freeze the stage3 package C backend truth boundary for the admin audit read-only workbench, including carrier ownership, normalized read-model rules, and the prohibition on second audit truth.
layer: L3 Backend
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/stage3_admin_package_c_controller_review_conclusion_addendum.md
  - docs/01_contracts/stage3_admin_package_c_audit_contracts_addendum.md
  - docs/02_backend/audit_log_spec.md
  - apps/server/src/modules/audit/identity-audit-log.entity.ts
  - apps/server/src/modules/audit/identity-audit.service.ts
  - apps/server/src/modules/audit/project-publish-audit-log.entity.ts
  - apps/server/src/modules/audit/project-publish-audit.service.ts
---

# 《阶段3 package C audit backend truth addendum》

## 1. package-C backend truth 目标

- 本轮只冻结 `package C` 的 read-only query truth。
- 本轮只允许：
  - read-model aggregation
  - normalized projection
  - append-only verification
- 本轮不允许：
  - second audit persistence
  - retroactive audit rewrite
  - audit mutation through Admin

## 2. canonical truth ownership

- `Server` 继续是唯一 audit truth owner。
- `Admin` 只能消费受控 `Server Admin API` 的 read-only projection。
- `BFF` 不介入本包。

## 3. approved carrier families

当前 package-C 第一 bounded package 只允许重用以下现有 truth carriers：

- `audit_logs`
  - current entity:
    - [identity-audit-log.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/identity-audit-log.entity.ts)
- `project_publish_audit_log`
  - current entity:
    - [project-publish-audit-log.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/audit/project-publish-audit-log.entity.ts)

当前 package-C 明确不允许：
- 新建第二审计真源表，只为给 Admin 查询方便
- 把 Admin 查询 projection 回写到数据库当作新 truth

## 4. read-model truth rule

- package-C 允许在 `Server Admin` controller/query 层构造统一 read-model。
- 该 read-model 的性质只能是：
  - transient projection
  - query-time normalization
- 它不是：
  - new persistence truth
  - new audit store
  - new state machine

## 5. normalized list/detail anchor

package-C 第一 bounded package 的最小检索锚点固定为：

- `sourceFamily`
- `auditLogId`
- `objectType`
- `objectId`
- `objectNo`
- `action`
- `actorId`
- `actorRole`
- `requestId`
- `traceId`
- `occurredAt`

detail 层补充字段固定为：
- `beforeState`
- `afterState`
- `reason`
- `payload`

规则：
- 若底层 carrier 不提供某 detail 字段，则 projection 只能返回空值。
- 不得在 query 层猜测或补造业务语义。

## 6. normalization mapping

### 6.1 identity family

- `sourceFamily = identity`
- maps from:
  - `object_type -> objectType`
  - `object_id -> objectId`
  - `object_no -> objectNo`
  - `action -> action`
  - `actor_id -> actorId`
  - `actor_role -> actorRole`
  - `request_id -> requestId`
  - `trace_id -> traceId`
  - `occurred_at -> occurredAt`
  - `before_state -> beforeState`
  - `after_state -> afterState`
  - `reason -> reason`
- `payload = {} | null`

### 6.2 project_publish family

- `sourceFamily = project_publish`
- maps from:
  - `aggregate_type -> objectType`
  - `aggregate_id -> objectId`
  - `event_type -> action`
  - `actor_id -> actorId`
  - `request_id -> requestId`
  - `trace_id -> traceId`
  - `created_at -> occurredAt`
  - `payload -> payload`
- `objectNo = '' | null`
- `actorRole = '' | null`
- `beforeState = null`
- `afterState = null`
- `reason = null`

## 7. filter boundary

当前 package-C 只允许支持：
- `sourceFamily`
- `objectType`
- `objectId`
- `objectNo`
- `actorId`
- `requestId`
- `traceId`
- `action`
- `occurredFrom`
- `occurredTo`

当前 package-C 不允许支持：
- generic full-text search
- fuzzy payload search
- mutable saved views
- write-back bookmarks

## 8. audit rule inheritance

- `docs/02_backend/audit_log_spec.md` 继续拥有：
  - append-only rule
  - must-audit action set
  - required fields baseline
- 本文只冻结：
  - package-C read-only query boundary
  - normalized projection boundary
- 当前 package-C 不改写：
  - must-audit action ownership
  - append-only semantics

## 9. explicit non-goals

- 不新增导出持久化对象
- 不新增审计修正命令
- 不新增统一跨域 observability index
- 不把治理工单和审计投影混成一个对象家族

## 10. Formal Conclusion

- `stage3 package C` 的 backend truth 已冻结为：
  - 复用 `audit_logs` 与 `project_publish_audit_log`
  - 通过 `Server Admin` query-time normalized read-model 形成最小 queue/list/detail
- 当前 package-C 明确禁止：
  - 第二审计真源
  - 审计写入或修正
  - 任何通过 Admin 触发的业务状态变更

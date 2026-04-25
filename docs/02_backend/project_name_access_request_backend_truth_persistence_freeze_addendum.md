---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L3 Server truth and persistence boundary for
  `ProjectNameAccessRequest`, including request state, organization-scoped
  visibility grant, public masked-title read logic, and the derived review
  interaction/thread projections.
layer: L3 Backend
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/audit_log_spec.md
---

# 《项目名称申请查看 backend truth freeze》

## 1. Scope

- 本冻结单只覆盖 Server truth：
  - `ProjectNameAccessRequest`
  - 公域项目名称遮罩读规则
  - 基于申请真值派生的 interaction / review-thread projection
- 本冻结单不授权：
  - implementation unlock
  - release-prep
  - generic message persistence

## 2. Truth Owner

- 项目真实名称真值 owner 继续固定为：
  - `Project`
- 项目名称查看申请的唯一真值 owner 当前固定为：
  - `ProjectNameAccessRequest`
- 以下对象当前只允许是 read projection：
  - `MessagesInteractionListItem` for name-access
  - `ProjectNameAccessReviewThreadDetail`

## 3. `ProjectNameAccessRequest` State Machine

- canonical anchor 固定为：
  - `projectId + requesterOrganizationId`
- 最小状态集合固定为：
  - `pending`
  - `approved`
  - `rejected`
- 最小状态迁移固定为：
  - `pending -> approved`
  - `pending -> rejected`
- 当前明确禁止：
  - `cancelled`
  - `expired`
  - `archived`
  - second approval chain in BFF / Flutter

## 4. Persistence Boundary

### 4.1 New Carrier

- 当前允许新增一个 bounded persistence carrier：
  - `project_name_access_request`

### 4.2 Minimum Column Set

| field | meaning |
|---|---|
| `id` | request id |
| `project_id` | target project |
| `requester_organization_id` | requester org scope |
| `requested_by_user_id` | request initiator |
| `state` | `pending / approved / rejected` |
| `reviewed_by_user_id` | reviewer, nullable until reviewed |
| `reviewed_at` | decision time, nullable until reviewed |
| `created_at` | create time |
| `updated_at` | last update time |

### 4.3 Unique Constraint

- 当前正式写死：
  - 同一 `project_id + requester_organization_id` 只允许一条 active `pending`
- 当前正式禁止：
  - BFF 幂等缓存冒充唯一约束
  - Flutter 本地去重冒充唯一约束

## 5. Public Read Masking Rule

- Server 在构造公域 `project/list` 与 `project/detail` 时必须先判定：
  - current actor 是否 owner
  - current actor organization 是否已获批
- 未授权 non-owner 的公域 read 必须：
  - 返回遮罩 `displayTitle`
  - 返回 `nameAccess.status`
  - 不返回真实 `title / exhibitionName / brandName`
- owner / 已获批组织必须：
  - 返回真实展示标题
  - `nameAccess.status = visible`

## 6. Review Projection Rule

- `message/interactions` 中的 name-access 条目只允许从以下真值派生：
  - `ProjectNameAccessRequest`
  - `Project` 最小摘要
  - requester organization summary
- `project/name-access/thread/detail` 只允许是 read-time derived projection：
  - not generic thread truth
  - not second message table
  - no independent lifecycle
- thread detail item 只允许由以下事实派生：
  - request created
  - request approved
  - request rejected

## 7. Permission Truth

### 7.1 Request

- 申请命令最小准入固定为：
  - current session valid
  - current organization scope valid
  - current actor 不是 owner-side actor
  - 当前组织尚未获批可见

### 7.2 Review

- approve / reject 最小准入固定为：
  - current session valid
  - current actor 在 owner-side organization scope
  - current actor 拥有受控 review 权限

## 8. Audit Boundary

- 以下动作必须审计：
  - request created
  - request approved
  - request rejected
- audit 最小字段必须包括：
  - `projectId`
  - `requestId`
  - `requesterOrganizationId`
  - `actorUserId`
  - `decision`
  - `occurredAt`

## 9. No Second Chat State Machine

- 当前正式写死：
  - 不新增 generic chat table
  - 不新增 name-access message table
  - 不新增 name-access unread / typing / online lifecycle
  - 不把 interaction projection 写成 authoritative truth

## 10. Stage Conclusion

- `项目名称申请查看` 的 L3 backend truth boundary 现正式冻结。
- 下一步只允许：
  - `Go for L4 BFF surface freeze authoring`
  - `Go for L5 frontend consumption freeze authoring`
- 当前仍：
  - `No-Go for implementation`


---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L4 BFF app-facing surface for `项目名称申请查看`, defining
  the route family, the public masked-title shaping rule, and the bounded
  messages handoff shaping while keeping BFF free of business truth and second
  state machines.
layer: L4 BFF
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
  - docs/02_backend/project_name_access_request_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
---

# 《项目名称申请查看 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖 BFF app-facing surface：
  - 公域项目 list/detail 名称遮罩整形
  - 申请 / 审批路由透传
  - 互动中心条目整形
  - review thread detail 整形
- BFF 当前只允许承担：
  - transport
  - auth carrier forwarding
  - bounded DTO shaping
  - visibility trimming
  - controlled error mapping

## 2. App-facing Path Family

- `GET /api/app/project/list`
- `GET /api/app/project/detail`
- `POST /api/app/project/name-access/request`
- `GET /api/app/project/name-access/thread/detail`
- `GET /api/app/my/projects/{projectId}/name-access/pending`
- `POST /api/app/my/projects/{projectId}/name-access/{requestId}/approve`
- `POST /api/app/my/projects/{projectId}/name-access/{requestId}/reject`
- `GET /api/app/message/interactions`

## 3. Server Mapping Boundary

- BFF 必须转发到对应 Server read/write family。
- BFF 必须继续保留：
  - auth carrier
  - organization scope carrier
  - request id / trace headers where available
- BFF 当前不得：
  - own `ProjectNameAccessRequest`
  - persist interaction truth
  - persist review-thread truth

## 4. Public Title Shaping Rule

- 当上游返回 `nameAccess.status != visible` 时，BFF 只允许向 Flutter 输出：
  - `displayTitle`
  - `nameAccess`
- BFF 当前不得：
  - 继续把真实 `title / exhibitionName / brandName` 透给未授权 public viewer
  - 在本地拼假标题冒充真实项目名

## 5. Home Card Support

- BFF 对首页红框改版不新增新 route。
- 继续允许首页消费既有字段：
  - `cityName`
  - `areaSqm`
  - `plannedStartAt`
- BFF 当前不得：
  - 为首页红框新造 summary 字段家族

## 6. Interaction Shaping

- `GET /api/app/message/interactions` 当前允许新增的 bounded shaping 只有：
  - `interactionType = project_name_access_thread`
  - `requestId`
  - `routeTarget.actionKey = project_name_access_thread.open`
  - `seedSummary.seedType` 的 3 个新增枚举
- BFF 当前明确禁止：
  - 把 `message/index` 沉默升级成同一 active object
  - 为 name-access flow 新造 interaction lifecycle

## 7. Review Thread Shaping

- `GET /api/app/project/name-access/thread/detail` 的 BFF 角色只允许：
  - app-facing DTO 命名归一
  - actionKey handoff 归一
  - controlled unavailable / forbidden mapping
- BFF 当前不得：
  - own message item truth
  - own decision truth
  - own primary review action enablement truth

## 8. Error Mapping

- 当前最小 app-facing error family 固定为：
  - `PROJECT_NAME_ACCESS_UNAVAILABLE`
  - `PROJECT_NAME_ACCESS_FORBIDDEN`
  - `PROJECT_NAME_ACCESS_CONFLICT`
  - `PROJECT_NAME_ACCESS_INVALID_STATE`
  - `AUTH_SESSION_INVALID`
- BFF 必须正式写死：
  - upstream missing / transport gap 不得伪装成成功空列表
  - unknown upstream failure 不得伪装成成功 detail

## 9. BFF No-Go

- 不得在 BFF 落第二状态机
- 不得在 BFF 决定最终“谁能看到项目真实名称”
- 不得新造 `message_interactions` truth family
- 不得把 review thread 扩成 generic chat

## 10. Stage Conclusion

- `项目名称申请查看` 的 L4 BFF surface boundary 现正式冻结。
- 下一步只允许：
  - `Go for L5 frontend consumption freeze authoring`
- 当前仍：
  - `No-Go for implementation`

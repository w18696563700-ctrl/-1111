---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L2 app-facing contract family for `项目名称申请查看`,
  including public list/detail masked-title semantics, request and review
  routes, and the bounded messages handoff contract needed for the controlled
  review-thread posture.
layer: L2 Contracts
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/00_ssot/project_name_access_request_field_table_addendum.md
  - docs/00_ssot/project_name_access_request_route_table_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目名称申请查看 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
  - `POST /api/app/project/name-access/request`
  - `GET /api/app/project/name-access/thread/detail`
  - `GET /api/app/my/projects/{projectId}/name-access/pending`
  - `POST /api/app/my/projects/{projectId}/name-access/{requestId}/approve`
  - `POST /api/app/my/projects/{projectId}/name-access/{requestId}/reject`
  - `GET /api/app/message/interactions` 的受控扩面
- 本冻结单不覆盖：
  - generic thread write contract
  - `message/index`
  - bid thread write family

## 2. Public Project Read Supplement

### 2.1 `GET /api/app/project/list`

- 当前在既有项目读模型上新增以下 app-facing 字段：
  - `displayTitle`
  - `nameAccess`
- `nameAccess` 最小字段固定为：
  - `status`
  - `canRequest`
- `status` enum 当前只允许：
  - `visible`
  - `requestable`
  - `pending`
  - `rejected`
- 现有字段继续保持可读并允许首页红框消费：
  - `cityName`
  - `areaSqm`
  - `plannedStartAt`

### 2.2 `GET /api/app/project/detail`

- 当前在既有 detail read model 上新增以下 app-facing 字段：
  - `displayTitle`
  - `nameAccess`
- `nameAccess` 最小字段固定为：
  - `status`
  - `canRequest`
  - `requestId`
- `requestId` 允许为：
  - 当前组织已有申请时返回其 id
  - 其余返回 `null`

## 3. Request Command Contract

### 3.1 `POST /api/app/project/name-access/request`

- request body 最小字段固定为：
  - `projectId`
- success response 最小字段固定为：
  - `requestId`
  - `projectId`
  - `status`
  - `threadId`
- `status` 在成功创建时只允许返回：
  - `pending`

## 4. Review Thread Detail Contract

### 4.1 `GET /api/app/project/name-access/thread/detail`

- query 最小字段只允许：
  - `threadId`
- response 最小字段固定为：
  - `threadId`
  - `threadType`
  - `projectId`
  - `requestId`
  - `requestStatus`
  - `displayTitle`
  - `items`
  - `primaryReviewAction`
- `threadType` 当前只允许：
  - `project_name_access_review`
- `requestStatus` 当前只允许：
  - `pending`
  - `approved`
  - `rejected`

### 4.2 Thread Item Boundary

- `items[]` 最小字段固定为：
  - `itemId`
  - `itemKind`
  - `title`
  - `summary`
  - `createdAt`
  - `action`
- `itemKind` 当前只允许：
  - `system_seed`
  - `system_notice`
- `action.actionKey` 当前只允许：
  - `project_name_access.review`
  - `project_name_access.refresh`

## 5. Owner Review Commands

### 5.1 `GET /api/app/my/projects/{projectId}/name-access/pending`

- response 最小字段固定为：
  - `projectId`
  - `items`
- `items[]` 最小字段固定为：
  - `requestId`
  - `requesterOrganization`
  - `requestedAt`
  - `status`
  - `threadId`

### 5.2 `POST /api/app/my/projects/{projectId}/name-access/{requestId}/approve`

- success response 最小字段固定为：
  - `requestId`
  - `projectId`
  - `status`
- `status` 只允许：
  - `approved`

### 5.3 `POST /api/app/my/projects/{projectId}/name-access/{requestId}/reject`

- success response 最小字段固定为：
  - `requestId`
  - `projectId`
  - `status`
- `status` 只允许：
  - `rejected`

## 6. `message/interactions` Bounded Extension

- 当前 contract 在既有 interaction item 上新增受控扩面：
  - `interactionType` 允许新增：
    - `project_name_access_thread`
  - `requestId`
- `bidId` 当前正式允许：
  - `bid_thread` 时非空
  - `project_name_access_thread` 时为 `null`
- `routeTarget.actionKey` 当前允许新增：
  - `project_name_access_thread.open`
- `seedSummary.seedType` 当前允许新增：
  - `project_name_access_requested`
  - `project_name_access_approved`
  - `project_name_access_rejected`

## 7. Hard Boundary

- 不得把真实项目名继续塞进未授权公域 `title / exhibitionName / brandName`
- 不得复用 `message/index`
- 不得引入：
  - unreadCount
  - typingState
  - onlineState
  - generic message write action
- 不得把 review thread contract 扩成 generic DM contract

## 8. Error Boundary

- 当前最小错误族固定为：
  - `PROJECT_NAME_ACCESS_UNAVAILABLE`
  - `PROJECT_NAME_ACCESS_FORBIDDEN`
  - `PROJECT_NAME_ACCESS_CONFLICT`
  - `PROJECT_NAME_ACCESS_INVALID_STATE`
  - `AUTH_SESSION_INVALID`

## 9. Stage Conclusion

- 当前 contract freeze 正式完成。
- 下一步只允许：
  - `Go for backend truth freeze authoring`
  - `Go for BFF surface freeze authoring`
  - `Go for frontend consumption freeze authoring`
- 当前仍：
  - `No-Go for implementation`

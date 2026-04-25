---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L2 app-facing contract family for `对方主体会话容器`,
  defining the list/detail contracts, routeTarget/actionKey, old-carrier
  downgrade handoff, and the title-click permission-sheet contract.
layer: L2 Contracts
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_field_table_addendum.md
  - docs/00_ssot/counterpart_conversation_route_table_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
---

# 《对方主体会话容器 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `GET /api/app/message/interactions`
  - `GET /api/app/message/counterpart-conversation/detail`
  - `GET /api/app/project/detail` 的标题点击权限 sheet supplement
  - 旧 `project_name_access_thread / bid_thread` 的 handoff contract
- 本冻结单不覆盖：
  - generic send-message contract
  - 新审批命令 contract
  - `message/index`

## 2. List Contract

### 2.1 `GET /api/app/message/interactions`

- query 最小字段只允许：
  - `lane`
- `lane` enum 当前只允许：
  - `project_communication`
- response 最小字段固定为：
  - `lane`
  - `items`

### 2.2 `CounterpartConversationListItem`

- 最小字段固定为：
  - `interactionId`
  - `interactionType`
  - `conversationId`
  - `projectId`
  - `counterpart`
  - `summary`
  - `updatedAt`
  - `routeTarget`
- `interactionType` 当前只允许：
  - `counterpart_conversation`
- `routeTarget.actionKey` 当前只允许：
  - `counterpart_conversation.open`

## 3. Detail Contract

### 3.1 `GET /api/app/message/counterpart-conversation/detail`

- query 最小字段只允许：
  - `conversationId`
  - `projectId`
- response 最小字段固定为：
  - `conversationId`
  - `counterpart`
  - `summary`
  - `focusProjectId`
  - `latestActivityAt`
  - `projectGroups`

### 3.2 `CounterpartConversationProjectGroup`

- 最小字段固定为：
  - `projectId`
  - `projectDisplayTitle`
  - `titleVisibility`
  - `projectState`
  - `latestActivityAt`
  - `cards`

### 3.3 `CounterpartConversationBusinessCard`

- 最小字段固定为：
  - `cardId`
  - `cardType`
  - `title`
  - `summary`
  - `status`
  - `updatedAt`
  - `truthAnchor`
  - `detailRouteTarget`
  - `decisionAvailability`

## 4. Truth Anchor Boundary

- `truthAnchor.truthType` 当前只允许：
  - `project_name_access_request`
  - `bid_thread`
  - `project_clarification`
  - `project_notice_event`
- 任一 truthAnchor 都必须带：
  - `projectId`
- `project_name_access_request` 时最小字段允许：
  - `projectId`
  - `requestId`
  - `threadId`
- `bid_thread` 时最小字段允许：
  - `projectId`
  - `bidId`
  - `threadId`
- `project_clarification` 时最小字段允许：
  - `projectId`
  - `clarificationId`

## 5. RouteTarget / ActionKey Contract

- `routeTarget` 最小字段固定为：
  - `objectType`
  - `actionKey`
  - `canonicalPath`
  - `params`
- 当前 `actionKey` 只允许：
  - `counterpart_conversation.open`
  - `project_name_access_thread.open`
  - `bid_thread.open`
  - `project_clarification.open`
  - `project_name_access.permission_sheet.open`
  - `project_name_access.request.submit`
- 当前正式写死：
  - 除 `counterpart_conversation.open` 外，所有原业务动作都必须带 `params.projectId`

## 6. Title Permission Sheet Contract

- `GET /api/app/project/detail` 当前允许新增：
  - `projectTitleAccess`
- `projectTitleAccess` 最小字段固定为：
  - `status`
  - `canOpenPermissionSheet`
  - `permissionSheetRouteTarget`
- `permissionSheetRouteTarget.actionKey` 当前只允许：
  - `project_name_access.permission_sheet.open`
- `permission sheet` 最小 DTO 固定为：
  - `projectId`
  - `displayTitle`
  - `reasonCode`
  - `canRequest`
  - `requestAction`

## 7. Old Carrier Downgrade Contract Rule

- `GET /api/app/project/name-access/thread/detail` 继续是：
  - `ProjectNameAccess` 详情 carrier
- `GET /api/app/bid/thread/detail` 继续是：
  - `Bid` 详情 carrier
- 它们当前不得：
  - 承担 counterpart container 主入口 list
  - 反向定义 counterpart container state

## 8. Hard Boundary

- 不得引入：
  - `conversationStatus`
  - `mergedProjectStatus`
  - `unreadCount`
  - `typingState`
  - `onlineState`
- 不得省略 `projectId`
- 不得复用 `message/index`

## 9. Error Boundary

- 当前最小错误族固定为：
  - `COUNTERPART_CONVERSATION_UNAVAILABLE`
  - `COUNTERPART_CONVERSATION_FORBIDDEN`
  - `COUNTERPART_CONVERSATION_INVALID`
  - `AUTH_SESSION_INVALID`

## 10. Stage Conclusion

- 当前 contract freeze 正式完成。
- 下一步只允许：
  - `Go for backend truth freeze authoring`
  - `Go for BFF surface freeze authoring`
  - `Go for frontend consumption freeze authoring`
- 当前仍：
  - `No-Go for implementation`

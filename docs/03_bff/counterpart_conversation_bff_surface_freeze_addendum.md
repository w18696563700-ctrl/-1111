---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L4 BFF app-facing surface for `对方主体会话容器`, defining
  the app-facing list/detail routes, DTO shaping, routeTarget/actionKey, old-
  carrier downgrade handoff, and title-click permission-sheet shaping.
layer: L4 BFF
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/counterpart_conversation_contract_freeze_addendum.md
  - docs/02_backend/counterpart_conversation_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
  - docs/03_bff/project_name_access_request_bff_surface_freeze_addendum.md
---

# 《对方主体会话容器 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖 BFF app-facing surface：
  - `counterpart conversation` list/detail
  - 标题点击权限 sheet DTO 整形
  - 旧 carrier handoff 整形
- BFF 当前只允许承担：
  - transport
  - auth carrier forwarding
  - bounded DTO shaping
  - visibility trimming
  - controlled error mapping

## 2. App-facing Path Family

- `GET /api/app/message/interactions`
- `GET /api/app/message/counterpart-conversation/detail`
- `GET /api/app/project/detail`
- `GET /api/app/project/name-access/thread/detail`
- `GET /api/app/bid/thread/detail`
- `GET /api/app/project/clarification/list`

## 3. Server Mapping Boundary

- BFF 必须转发到以下 Server family：
  - `GET /server/message/interactions`
  - `GET /server/message/counterpart-conversation/detail`
  - `GET /server/projects/{projectId}`
  - `GET /server/project/name-access/thread/detail`
  - `GET /server/trading-im/bid/thread/detail`
  - `GET /server/project/clarification/list`
  - BFF 必须继续保留：
  - auth carrier
  - organization scope carrier
  - request id / trace headers where available

## 4. Container Shaping

- `GET /api/app/message/interactions` 当前只允许输出冻结字段：
  - `interactionId`
  - `interactionType`
  - `conversationId`
  - `projectId`
  - `counterpart`
  - `summary`
  - `updatedAt`
  - `routeTarget`
- `routeTarget.actionKey` 当前只允许：
  - `counterpart_conversation.open`

## 5. Detail Shaping

- `GET /api/app/message/counterpart-conversation/detail` 当前只允许输出冻结字段：
  - `conversationId`
  - `counterpart`
  - `summary`
  - `focusProjectId`
  - `latestActivityAt`
  - `projectGroups`
- `projectGroups[]` 当前必须保留：
  - `projectId`
  - `projectDisplayTitle`
  - `titleVisibility`
  - `projectState`
  - `latestActivityAt`
  - `cards`
- `cards[]` 当前必须保留：
  - `cardId`
  - `cardType`
  - `title`
  - `summary`
  - `status`
  - `updatedAt`
  - `truthAnchor`
  - `detailRouteTarget`
  - `decisionAvailability`
- BFF 当前不得：
  - 在 project group 层做 merged status
  - 隐去 `projectId`

## 6. Old Carrier Downgrade Shaping

- BFF 当前必须正式写死：
  - `project_name_access_thread` 是旧 detail carrier
  - `bid_thread` 是旧 detail carrier
- 它们在容器输出中只允许以：
  - `CarrierRef`
  - `RouteTarget`
  的形式出现
- BFF 当前不得把旧 thread 列表反包成容器主列表。

## 7. Title Permission Sheet Shaping

- `GET /api/app/project/detail` 当前允许新增受控输出：
  - `projectTitleAccess`
- `projectTitleAccess` 当前只允许：
  - `status`
  - `canOpenPermissionSheet`
  - `permissionSheetRouteTarget`
- `permissionSheetRouteTarget.actionKey` 当前只允许：
  - `project_name_access.permission_sheet.open`
- BFF 当前不得：
  - 让标题点击直接跳旧 thread
  - 在 BFF 本地决定审批结果

## 8. Error Mapping

- 当前最小 app-facing error family 固定为：
  - `COUNTERPART_CONVERSATION_UNAVAILABLE`
  - `COUNTERPART_CONVERSATION_FORBIDDEN`
  - `COUNTERPART_CONVERSATION_INVALID`
  - `AUTH_SESSION_INVALID`
- BFF 必须正式写死：
  - upstream missing / transport gap 不得伪装成成功空容器
  - unknown upstream failure 不得伪装成成功 detail

## 9. BFF No-Go

- 不得在 BFF 落第二状态机
- 不得在 BFF 决定最终业务真值
- 不得把旧 carrier 升回主入口
- 不得丢失 `projectId`

## 10. Stage Conclusion

- `对方主体会话容器` 的 L4 BFF surface boundary 现正式冻结。
- 下一步只允许：
  - `Go for L5 frontend consumption freeze authoring`
- 当前仍：
  - `No-Go for implementation`

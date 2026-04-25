---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 field table for `对方主体会话容器`, listing the exact
  container, slice, carrier-ref, route-target, and title-permission-sheet
  fields admitted by the next stages.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/01_contracts/counterpart_conversation_contract_freeze_addendum.md
---

# 《对方主体会话容器字段表》

## 1. List Item Fields

| surface | field | status | meaning |
|---|---|---|---|
| `message/interactions items[]` | `interactionId` | new | 当前统一容器列表项 id |
| same | `interactionType` | new | 固定为 `counterpart_conversation` |
| same | `conversationId` | new | counterpart 容器 id |
| same | `projectId` | new | 当前列表项 focus project |
| same | `counterpart.organizationId` | new | 对方主体组织 id |
| same | `counterpart.displayName` | new | 对方主体展示名 |
| same | `counterpart.avatarUrl` | new | 对方主体头像 |
| same | `counterpart.role` | new | 固定为 `counterpart` |
| same | `summary.focusProjectId` | new | 当前最值得处理的项目 |
| same | `summary.title` | new | 容器摘要标题 |
| same | `summary.text` | new | 容器摘要文案 |
| same | `summary.projectCount` | new | 当前容器 admitted 项目数 |
| same | `summary.latestCardType` | new | 最近业务卡类型 |
| same | `updatedAt` | new | 当前容器最近更新时间 |
| same | `routeTarget` | new | 容器打开 handoff |

## 2. Detail Root Fields

| surface | field | status | meaning |
|---|---|---|---|
| `message/counterpart-conversation/detail` | `conversationId` | new | counterpart 容器 id |
| same | `counterpart` | new | 对方主体信息 |
| same | `summary` | new | 容器摘要 |
| same | `focusProjectId` | new | 当前 detail focus project |
| same | `latestActivityAt` | new | 最近活动时间 |
| same | `projectGroups[]` | new | 按项目分组后的业务卡容器 |

## 3. Project Group Fields

| surface | field | status | meaning |
|---|---|---|---|
| `projectGroups[]` | `projectId` | new | 当前分组所属项目 |
| same | `projectDisplayTitle` | new | 当前项目展示标题，可为遮罩标题 |
| same | `titleVisibility` | new | `masked / visible` |
| same | `projectState` | new | 当前项目状态 |
| same | `latestActivityAt` | new | 当前分组最近活动时间 |
| same | `cards[]` | new | 当前项目分组下的业务卡列表 |

## 4. Business Card Fields

| surface | field | status | meaning |
|---|---|---|---|
| `cards[]` | `cardId` | new | 当前业务卡 id |
| same | `cardType` | new | `project_name_access_request / bid_thread / project_clarification / system_notice` |
| same | `title` | new | 卡片标题 |
| same | `summary` | new | 卡片摘要 |
| same | `status` | new | 当前卡片状态 |
| same | `updatedAt` | new | 当前卡片更新时间 |
| same | `truthAnchor` | new | 原业务真值锚点 |
| same | `detailRouteTarget` | new | 原业务详情 handoff |
| same | `decisionAvailability` | new | owner 审批能力摘要 |

## 5. Truth Anchor Fields

| surface | field | status | meaning |
|---|---|---|---|
| `truthAnchor` | `truthType` | new | `project_name_access_request / bid_thread / project_clarification / project_notice_event` |
| same | `projectId` | new | 强制绑定项目 id |
| same | `requestId` | new | name-access 时允许返回 |
| same | `bidId` | new | bid 时允许返回 |
| same | `threadId` | new | 旧 carrier detail 打开时允许返回 |
| same | `clarificationId` | new | clarification 时允许返回 |
| same | `noticeId` | new | notice 时允许返回 |

## 6. RouteTarget Fields

| surface | field | status | meaning |
|---|---|---|---|
| `routeTarget / detailRouteTarget` | `objectType` | new | 当前 handoff 对象类型 |
| same | `actionKey` | new | 当前 handoff 动作键 |
| same | `canonicalPath` | new | 当前标准路径 |
| same | `params.projectId` | new | 原业务动作强制携带项目锚点 |
| same | `params.conversationId` | new | 容器 detail 打开时的容器锚点 |
| same | `params.requestId` | new | name-access 时允许返回 |
| same | `params.bidId` | new | bid 时允许返回 |
| same | `params.threadId` | new | 旧 carrier detail 打开时允许返回 |

## 7. Title Permission Sheet Fields

| surface | field | status | meaning |
|---|---|---|---|
| `project/detail title click` | `projectTitleAccess.status` | new | `visible / requestable / pending / rejected` |
| same | `projectTitleAccess.canOpenPermissionSheet` | new | 标题是否允许点击打开 sheet |
| same | `projectTitleAccess.permissionSheetRouteTarget` | new | 权限 sheet handoff |
| `permission sheet` | `projectId` | new | 被遮罩项目 |
| same | `displayTitle` | new | 标题展示值 |
| same | `reasonCode` | new | 遮罩原因 |
| same | `canRequest` | new | 是否允许发起名称查看申请 |
| same | `requestAction.actionKey` | new | `project_name_access.request.submit` |

## 8. Explicit Non-fields

- 不新增：
  - `conversationStatus`
  - `unreadCount`
  - `typingState`
  - `onlineState`
  - cross-project `mergedStatus`
  - business-truth `objectKey`

---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 field table for `项目名称申请查看`, listing the exact public
  read, request, review, and messages-extension fields that the next
  implementation stages may consume.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/project_name_access_request_truth_freeze_addendum.md
  - docs/01_contracts/project_name_access_request_contract_freeze_addendum.md
---

# 《项目名称申请查看字段表》

## 1. Public Project Read Fields

| surface | field | status | meaning |
|---|---|---|---|
| `project/list` | `displayTitle` | new | 公域标题占位或真实标题 |
| `project/list` | `nameAccess.status` | new | `visible / requestable / pending / rejected` |
| `project/list` | `nameAccess.canRequest` | new | 当前 viewer 是否允许发起申请 |
| `project/list` | `cityName` | existing | 首页红框搭建地 |
| `project/list` | `areaSqm` | existing | 首页红框项目面积 |
| `project/list` | `plannedStartAt` | existing | 首页红框进场时间 |
| `project/detail` | `displayTitle` | new | 详情主标题展示位 |
| `project/detail` | `nameAccess.status` | new | 当前申请状态 |
| `project/detail` | `nameAccess.canRequest` | new | 是否允许发起申请 |
| `project/detail` | `nameAccess.requestId` | new | 当前组织已有申请时返回 |

## 2. Request / Review Fields

| route | field | status | meaning |
|---|---|---|---|
| `POST /api/app/project/name-access/request` | `projectId` | new | 被申请项目 |
| same response | `requestId` | new | 申请 id |
| same response | `status` | new | 创建后固定为 `pending` |
| same response | `threadId` | new | review thread handoff id |
| `GET /api/app/my/projects/{projectId}/name-access/pending` | `requestId` | new | owner review list item id |
| same | `requesterOrganization` | new | 申请方组织摘要 |
| same | `requestedAt` | new | 申请时间 |
| same | `status` | new | 请求状态 |
| same | `threadId` | new | review thread handoff id |

## 3. Review Thread Fields

| surface | field | status | meaning |
|---|---|---|---|
| `project/name-access/thread/detail` | `threadId` | new | 受控 review thread id |
| same | `threadType` | new | 固定为 `project_name_access_review` |
| same | `projectId` | new | 对应项目 |
| same | `requestId` | new | 对应申请 |
| same | `requestStatus` | new | `pending / approved / rejected` |
| same | `displayTitle` | new | 当前线程标题展示位 |
| same | `items[]` | new | 线程内系统项列表 |
| `items[]` | `itemKind` | new | `system_seed / system_notice` |
| `items[]` | `title` | new | 卡片标题 |
| `items[]` | `summary` | new | 卡片摘要 |
| `items[]` | `createdAt` | new | 发生时间 |
| `items[]` | `action.actionKey` | new | `project_name_access.review / refresh` |

## 4. Interaction Extension Fields

| surface | field | status | meaning |
|---|---|---|---|
| `message/interactions` | `interactionType` | extend | 新增 `project_name_access_thread` |
| same | `requestId` | new | 对应名称查看申请 |
| same | `bidId` | extend | name-access item 时允许 `null` |
| same | `routeTarget.actionKey` | extend | 新增 `project_name_access_thread.open` |
| same | `seedSummary.seedType` | extend | 新增 request/approved/rejected 3 个枚举 |

## 5. Explicit Non-fields

- 不新增：
  - `visibility`
  - `displayStatus`
  - `unreadCount`
  - `typingState`
  - `onlineState`
  - generic `messageText`
  - local-only `maskedByClient`

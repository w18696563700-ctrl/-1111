---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 route table for `对方主体会话容器`, listing the canonical
  app-facing route family, old-carrier handoff routes, and the title-click
  permission-sheet routeTarget/actionKey mapping.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/01_contracts/counterpart_conversation_contract_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_bff_surface_freeze_addendum.md
---

# 《对方主体会话容器路由表》

## 1. Canonical App-facing Route Table

| method | path | role | note |
|---|---|---|---|
| `GET` | `/api/app/message/interactions` | list read | 统一消息入口，当前只返回 `counterpart_conversation` |
| `GET` | `/api/app/message/counterpart-conversation/detail` | detail read | 单一对方主体容器详情，按 `projectId` 分 group |
| `GET` | `/api/app/project/detail` | public/shared read | 标题点击权限 sheet 的来源页 |
| `GET` | `/api/app/project/name-access/thread/detail` | old carrier detail | 旧 `project_name_access_thread` 降级后的真值详情 |
| `GET` | `/api/app/bid/thread/detail` | old carrier detail | 旧 `bid_thread` 降级后的真值详情 |
| `GET` | `/api/app/project/clarification/list` | carrier detail | clarification 详情承接页 |

## 2. RouteTarget / ActionKey Table

| objectType | actionKey | canonicalPath | meaning |
|---|---|---|---|
| `counterpart_conversation` | `counterpart_conversation.open` | `/api/app/message/counterpart-conversation/detail` | 打开对方主体容器 |
| `project_name_access_thread` | `project_name_access_thread.open` | `/api/app/project/name-access/thread/detail` | 打开名称申请旧 carrier 详情 |
| `bid_thread` | `bid_thread.open` | `/api/app/bid/thread/detail` | 打开竞标旧 carrier 详情 |
| `project_clarification` | `project_clarification.open` | `/api/app/project/clarification/list` | 打开项目澄清详情 |
| `project_name_access_permission_sheet` | `project_name_access.permission_sheet.open` | `sheet://project-name-access-permission` | 项目标题点击权限 sheet |
| `project_name_access_request` | `project_name_access.request.submit` | `command://project-name-access-request` | 在 sheet 内发起申请 |

## 3. Required Param Rule

| actionKey | required params |
|---|---|
| `counterpart_conversation.open` | `conversationId + projectId` |
| `project_name_access_thread.open` | `projectId + requestId + threadId` |
| `bid_thread.open` | `projectId + bidId + threadId` |
| `project_clarification.open` | `projectId` |
| `project_name_access.permission_sheet.open` | `projectId` |
| `project_name_access.request.submit` | `projectId` |

## 4. Explicit No-Go Paths

- 当前明确不使用：
  - `/api/app/message/index`
- 当前明确不新造：
  - generic `/api/app/messages/*`
  - generic `/api/app/conversations/*/messages/send`
  - direct-to-Server mobile path

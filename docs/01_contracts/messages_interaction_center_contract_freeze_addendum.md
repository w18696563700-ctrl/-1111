---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L2 app-facing contract for `消息楼互动中心`, introducing a
  bounded trading interaction-list surface that hands off directly into the
  existing bid-thread object without reusing reminder projection semantics as
  active conversation truth.
layer: L2 Contracts
freeze_date_local: 2026-04-23
inputs_canonical:
  - docs/00_ssot/messages_interaction_center_truth_freeze_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_stage_gate_checklist_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《消息楼互动中心 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `消息楼互动中心` 的 app-facing contract family
- 本冻结单不覆盖：
  - thread detail/write contracts
  - participant-card contracts
  - forum inbox contracts

## 2. Canonical Path Family

当前唯一建议新开 app-facing path：

- `GET /api/app/message/interactions`

该 path 的正式语义固定为：

- trading interaction list only
- not reminder placeholder
- not forum inbox
- not generic station message center

## 3. Minimum Query

- 当前最小 query 只允许：
  - `lane`
- `lane` enum:
  - `project_communication`
  - `forum_interaction`

首发当前只要求：

- `project_communication`

## 4. Minimum Response

### 4.1 InteractionListResponse

- `lane`
- `items`

### 4.2 InteractionListItem

最小字段固定为：

- `interactionId`
- `interactionType`
- `threadId`
- `projectId`
- `bidId`
- `counterpart`
- `seedSummary`
- `lastMessageSummary`
- `updatedAt`
- `routeTarget`

### 4.3 CounterpartSummary

- `organizationId`
- `displayName`
- `avatarUrl`
- `role`

### 4.4 RouteTarget

- `objectType`
- `actionKey`
- `canonicalPath`
- `params`

当前 `routeTarget` 只允许跳到：

- `bid_thread.open`

## 5. Seed Summary Boundary

`seedSummary` 当前最小语义固定为：

- `seedType`
- `title`
- `summary`
- `ctaLabel`

当前 `seedType` 只允许：

- `bid_submitted`

## 6. Hard Boundary

当前 contract 明确禁止混入：

- unreadCount
- readState
- typingState
- onlineState
- push preferences
- group members
- stranger relation
- forum comment detail truth

## 7. Error Boundary

当前最小错误族固定为：

- `MESSAGE_INTERACTION_UNAVAILABLE`
- `MESSAGE_INTERACTION_FORBIDDEN`
- `AUTH_SESSION_INVALID`

## 8. Relation to Existing `message/index`

当前必须正式写死：

- `GET /api/app/message/interactions`
  - is the new interaction-center list carrier
- `GET /api/app/message/index`
  - must not be silently reused as the same active object in this contract

## 9. Existing `bid/thread/detail` Continuity Supplement

当前必须正式写死：

- `GET /api/app/bid/thread/detail`
  - remains the canonical thread-detail carrier
  - is the only admitted route target for interaction-list handoff

在当前 package 下，`bid/thread/detail` 只允许被补充以下 bounded read semantics：

- message item may admit:
  - `messageKind`
- `messageKind` enum 当前只允许：
  - `actor_message`
  - `system_seed`
- when `messageKind = system_seed`，当前只允许附带：
  - `systemSeedType`
  - `systemSeedAction`
- `systemSeedType` 当前只允许：
  - `bid_submitted`
- `systemSeedAction.actionKey` 当前只允许：
  - `bid_submission_snapshot.open`

当前明确禁止：

- 将 `system_seed` 扩成新 thread 类型
- 将 `system_seed` 解释成 read-receipt / delivery / station notice
- 将 thread detail contract 改写成 generic message center contract

## 10. Stage Conclusion

- 当前 contract freeze 正式完成。
- 下一步只允许：
  - `Go for backend truth freeze authoring`
- 当前仍：
  - `No-Go for implementation`

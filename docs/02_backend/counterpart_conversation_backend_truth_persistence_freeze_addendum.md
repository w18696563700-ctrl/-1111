---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L3 Server truth and persistence boundary for `对方主体会话容器`,
  defining it as a read-only aggregation projection over original project-
  scoped truths, with strict `projectId` anchors, old-carrier downgrade, and
  no second unified state machine.
layer: L3 Backend
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/01_contracts/counterpart_conversation_contract_freeze_addendum.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/project_name_access_request_backend_truth_persistence_freeze_addendum.md
---

# 《对方主体会话容器 backend truth freeze》

## 1. Scope

- 本冻结单只覆盖 Server-owned truth boundary：
  - `CounterpartConversationContainer` 的读投影边界
  - 原业务真值到容器的聚合规则
  - 旧 carrier 降级后的详情承接关系
  - 标题点击权限 sheet 所需真值派生
- 本冻结单不授权：
  - implementation unlock
  - 新 persistence carrier 建表
  - 新统一状态机

## 2. Truth Owner

- `CounterpartConversationContainer` 当前不是新的业务真值 owner。
- 当前原业务真值继续固定在：
  - `ProjectNameAccessRequest`
  - `Bid`
  - `BidPrivateThread`
  - `BidThreadMessage`
  - admitted project-scoped notice / clarification truth only after separate freeze
- 当前容器只允许是：
  - bounded read projection
  - bounded query output
  - aggregation container

## 3. Canonical Anchor Rule

- 当前容器 canonical anchor 固定为：
  - `viewerOrganizationId + counterpartOrganizationId`
- 当前容器内每个 project slice 的 canonical anchor 固定为：
  - `projectId + viewerOrganizationId + counterpartOrganizationId`
- 当前任何进入原业务动作的聚合条目都必须保留：
  - `projectId`
- 当前明确禁止：
  - 只依赖 `threadId` 还原项目边界
  - 只依赖容器 id 推导审批或竞标真值

## 4. Aggregation Rule

- Server 当前只允许从既有原业务真值派生：
  - counterpart summary
  - project slices
  - entry summaries
  - old carrier refs
  - permission sheet inputs
- Server 当前必须先按 `counterpartOrganizationId` 聚合，再按 `projectId` 切片。
- 容器层不得合并：
  - 不同项目的申请状态
  - 不同项目的竞标状态
  - 不同项目的澄清状态
  - 不同项目的通知状态

## 5. Old Carrier Downgrade Truth Rule

- `project_name_access_thread` 继续是：
  - `ProjectNameAccessRequest` 的 detail carrier
- `bid_thread` 继续是：
  - `Bid` relation 的 detail carrier
- 当前容器只保留它们的：
  - `CarrierRef`
  - `RouteTarget`
- Server 当前明确禁止：
  - 把旧 carrier read model 直接升格成容器 truth
  - 为旧 carrier 衍生统一跨项目 lifecycle

## 6. Title Permission Sheet Truth Rule

- `project/detail` 标题点击所需 `permission sheet` 输入，当前只允许从既有真值派生：
  - `projectId`
  - `displayTitle`
  - `ProjectNameAccessRequest` 当前组织态
  - viewer permission rule
- 当前标题点击只触发：
  - 读权限解释
  - 可选原申请命令入口
- 不得在标题点击链路新造：
  - 临时 thread truth
  - second review truth

## 7. Persistence Boundary

- 当前明确禁止：
  - new `counterpart_conversations` truth table
  - new `counterpart_conversation_entries` truth table
  - new unified approval state table
  - new cross-project status table
- 当前允许的未来优化仅限：
  - read-optimized projection carrier
- 但若未来引入 projection carrier，必须满足：
  - not authoritative
  - no command writes
  - no independent lifecycle
  - no second business state machine

## 8. Server Read Family

- 当前为后续实现预冻结的 Server read family 只有：
  - `GET /server/message/interactions`
  - `GET /server/message/counterpart-conversation/detail`
- 当前继续复用的 detail carrier read family：
  - `GET /server/project/name-access/thread/detail`
  - `GET /server/trading-im/bid/thread/detail`
  - `GET /server/project/clarification/list`
  - `GET /server/projects/{projectId}` for title-permission inputs

## 9. Hard Boundary

- 不新造统一业务状态机
- 不把容器写成统一业务真值 owner
- 不允许任何动作丢失 `projectId`
- 不让标题点击绕过原 `ProjectNameAccessRequest`
- 不让旧 carrier 回升为主入口

## 10. Formal Conclusion

- `对方主体会话容器` 的 L3 backend truth boundary 现正式冻结。
- 日验收正式写死：
  - `CounterpartConversationContainer` 只是聚合读模型
  - 项目边界按 `projectId` 强制保留
  - 旧 `project_name_access_thread / bid_thread` 只做 detail carrier
  - 标题点击先走 permission sheet
- 下一步只允许：
  - `Go for L4 BFF surface freeze authoring`
  - `Go for L5 frontend consumption freeze authoring`
- 当前仍：
  - `No-Go for implementation`

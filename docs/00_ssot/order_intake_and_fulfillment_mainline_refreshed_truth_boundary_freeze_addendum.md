---
owner: Codex 总控
status: active
purpose: >
  Refresh the truth boundary for `订单承接与履约承接主链` after the reentry
  asset-inventory refresh, so the next contract round proceeds on the current
  post-cleanup meanings for included mainline assets, adjacent-but-excluded
  shell/handoff runtime, summary/private-carry reuse, and explicitly blocked
  dead families.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_fresh_asset_inventory_refresh_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_reentry_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_successor_reentry_ruling_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/order_intake_and_fulfillment_mainline_frontend_consumption_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/bff/src/routes/trading_shell_handoff/app-trading-shell-handoff.controller.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/my_project/my-project.private-progress.ts
---

# 《订单承接与履约承接主链 refreshed truth boundary freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象纳入项
  - 当前对象排除项
  - 当前 repo 里已经存在但仍属邻接对象的 shell / handoff runtime
  - `workbench / my-project / S2 read corridor`
    与当前对象之间的真义边界
  - `Flutter / BFF / Server`
    在当前对象中的 truth responsibility 边界
- 本冻结单不进入：
  - refreshed contract 最终字段清单
  - persistence / migration
  - backend / BFF / Flutter 实现
  - integration
  - `release-prep`
  - `production release`

## 2. Refreshed Truth Freeze Conclusion

- 当前对象正式刷新为一条：
  - `订单承接 -> 履约承接`
    的 bounded continuation mainline
- 当前对象的 included mainline 只纳入：
  1. `发布项目工作台` 中：
     - `order_chain`
     - `fulfillment_chain`
     的 continuation carrier 与 handoff 关系
  2. 4 条已存在的 read-corridor 主 carrier：
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `inspection/detail`
  3. 当前对象内唯一允许继续 author 的两个 submit handoff：
     - `milestone/submit`
     - `inspection/submit`
- 当前对象正式不纳入：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/open`
  - `dispute/withdraw`
- 当前必须明确：
  - `dispute/open` 虽然已在 repo 中具备相邻 shell / handoff runtime，
    但它仍属邻接边界对象，不回流进当前主链 scope

## 3. Current Mainline Definition

### 3.1 当前主链起点

- 当前主链起点正式冻结为：
  - `activeOrderId`
  - `activeMilestoneId`
    已存在时的 continuation mainline
- 当前对象不是：
  - `bid -> order/create`
    的上游转换对象
- 当前对象是：
  - 订单实例已存在后的继续承接
  - 履约节点已存在后的继续承接

### 3.2 当前主链最小组成

- 当前对象的最小主链正式刷新为：

```text
workbench.order_chain
  -> order/detail
  -> contract/detail

workbench.fulfillment_chain
  -> milestone/list
  -> milestone/submit
  -> inspection/detail
  -> inspection/submit
```

- 这里的正式含义是：
  - `order/detail / contract/detail / milestone/list / inspection/detail`
    是当前已存在的主 read carrier
  - `milestone/submit / inspection/submit`
    是当前对象内唯一允许继续 author 的 submit handoff 目标

### 3.3 邻接但未纳入的 runtime

- 当前 repo 中已存在、但仍未纳入当前对象的邻接 runtime 只有：
  - `dispute/open`
- 当前正式意义固定为：
  - 它是 current repo 中的相邻 shell / handoff runtime
  - 它可以被 workbench / order carrier 邻接引用
  - 但它不是当前 `订单承接与履约承接主链`
    的 included mainline member

## 4. workbench / my-project / 当前对象 的真义边界

### 4.1 workbench 边界

- `发布项目工作台`
  当前在这条主线里的正式真义仍然是：
  - 摘要页
  - handoff 页
  - continuation carrier page
- 但与旧版 boundary freeze 相比，当前必须补充写死：
  - `order_chain / fulfillment_chain`
    已具备真实 continuation carrier
  - 这只代表 handoff anchor 已存在
  - 不代表 workbench 成了详情 truth owner
  - 不代表交易写主链已经打开

### 4.2 my-project 边界

- `my/projects` 与 `my/projects/{projectId}`
  当前在这条主线里的正式真义仅为：
  - 项目级私域进度摘要复用
- 与旧版 boundary freeze 相比，当前必须刷新为：
  - 它只继续复用
    - `orderStatus`
    - `contractStatus`
    - `fulfillmentStatus`
    的 in-scope 语义
  - 不再把 `ratings / disputes`
    作为当前对象 truth 输入
- 当前正式禁止把 `my_project` 写成：
  - 订单详情 carrier
  - 合同详情 carrier
  - 履约详情 carrier
  - 验收详情 carrier
  - 当前主链的 truth owner

### 4.3 S2 read corridor 边界

- 当前对象正式继续复用 `S2` 的只读走廊资产。
- 当前正式写死：
  - `S2 read corridor = 当前对象的已存在资产`
  - `S2 read corridor != 当前对象已经全链闭环`
  - `S2 read corridor != 当前对象的实现放行依据`

## 5. Flutter / BFF / Server 真义边界

### 5.1 Flutter

- Flutter 当前在本对象里只允许：
  - 承载 `order/detail`
  - 承载 `contract/detail`
  - 承载 `milestone/list`
  - 承载 `inspection/detail`
  - 承载 `milestone/submit`
  - 承载 `inspection/submit`
  - 承载受控 empty / blocker / unavailable
  - 承载 continuation route handoff
- Flutter 当前正式禁止：
  - 发明第二套订单状态机
  - 发明第二套履约状态机
  - 本地推导合同确认、改单、复检、评价、争议治理结论
  - 把 page shell / route shell / placeholder
    写成主链 runtime 已通
- 当前额外必须明确：
  - `dispute/open` 虽然有 mobile route / page / command 路径，
    但它仍然是邻接边界 runtime，
    不是当前对象纳入项

### 5.2 BFF

- BFF 当前在本对象里只允许：
  - 聚合 `order/detail`
  - 聚合 `contract/detail`
  - 聚合 `milestone/list`
  - 聚合 `inspection/detail`
  - 承接当前对象范围内的：
    - `milestone/submit`
    - `inspection/submit`
      app-facing shell / handoff transport
- BFF 当前正式禁止：
  - 拥有订单真相
  - 拥有履约真相
  - 推导 archive-ready
  - 推导 contract confirmed
  - 推导 inspection passed / rechecked 终态
  - 把 `dispute/open`
    借当前 refresh 顺带纳入本对象 contract family

### 5.3 Server

- Server 当前在本对象里仍然是唯一 truth owner。
- 当前对象内，
  `Server` 正式拥有的 truth family 只冻结到：
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
- 当前对象正式不把以下对象默认视为“当前 included runtime truth family”：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating`
  - `dispute`
- 当前额外必须明确：
  - `trading_shell_handoff.dispute/open`
    已作为 repo 现存邻接 runtime 存在
  - 但这不改变当前对象只纳入
    `Milestone / Inspection submit handoff`
    的 truth boundary

## 6. Included / Adjacent / Excluded Matrix

| 对象 | 当前真义 | 当前状态 |
|---|---|---|
| `order_chain` | workbench continuation carrier | 纳入 |
| `fulfillment_chain` | workbench continuation carrier | 纳入 |
| `order/detail` | 订单只读主 carrier | 纳入 |
| `contract/detail` | 合同只读主 carrier | 纳入 |
| `milestone/list` | 履约节点只读主 carrier | 纳入 |
| `milestone/submit` | 当前对象最小 submit handoff | 纳入 |
| `inspection/detail` | 验收只读主 carrier | 纳入 |
| `inspection/submit` | 当前对象最小 submit handoff | 纳入 |
| `dispute/open` | 邻接 shell / handoff runtime | 邻接但排除 |
| `order/create` | 上游 bid->order 转换 | 排除 |
| `contract/confirm` | 合同确认次级主链 | 排除 |
| `contract/amend` | 合同改单次级主链 | 排除 |
| `inspection/recheck` | 验收复检边界对象 | 排除 |
| `rating/*` | 下游评价边界对象 | 排除 |
| `dispute/withdraw` | 下游争议撤回边界对象 | 排除 |

## 7. 当前对象正式禁止的误导口径

- 不得写：
  - `订单承接与履约承接主链 = 整个交易主链`
- 不得写：
  - `workbench order_chain / fulfillment_chain 已有 carrier = 下游 runtime 已闭环`
- 不得写：
  - `repo 中已有 dispute/open = 当前对象已经自动扩到 dispute`
- 不得写：
  - `OpenAPI 有 path = included runtime 已实现`
- 不得写：
  - `Flutter 页已存在 = BFF/Server 命令主链已通`
- 不得写：
  - `S2 read corridor PASS WITH RISK = 当前对象 implementation PASS`
- 不得写：
  - `my-project 仍以 ratings / disputes 驱动当前对象私域进度`

## 8. Explicit Non-goals

- 不扩到：
  - `my_project` 结构重构
  - workbench 新容器
  - 支付、结算、发票、税务
  - 合同历史、验收历史、治理台席
  - 评价与争议治理闭环
  - `dispute/open` 由邻接边界升级为当前对象纳入项
- 不在本轮 author：
  - migration
  - implementation prompt
  - integration prompt

## 9. Stage Conclusion

- 当前结论：
  - `Go for 订单承接与履约承接主链 refreshed contract freeze authoring`
  - `No-Go for Phase 0 implementation exception unlock`
  - `No-Go for implementation dispatch send`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 10. Next Unique Action

- 下一轮唯一动作：
  - 输出《订单承接与履约承接主链 refreshed contract freeze》

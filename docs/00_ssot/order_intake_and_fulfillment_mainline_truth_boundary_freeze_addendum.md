---
owner: Codex 总控
status: frozen
purpose: Freeze the truth boundary for the order-intake and fulfillment mainline object, so the next contract round proceeds on a single meaning for what belongs to the current bounded chain, what is only summary reuse, what is only S2 read-corridor reuse, and what remains explicitly outside scope.
layer: L0 SSOT
based_on:
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/04_frontend/flutter_screen_map.md
freeze_date_local: 2026-04-11
---

# 《订单承接与履约承接主链 truth boundary freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象纳入项
  - 当前对象排除项
  - `workbench / my-project / S2 read corridor`
    与当前对象之间的真义边界
  - `Flutter / BFF / Server`
    在当前对象中的 truth responsibility 边界
- 本冻结单不进入：
  - contract 最终字段清单
  - persistence / migration
  - backend / BFF / Flutter 实现
  - integration
  - `release-prep`
  - `production release`

## 2. Truth Freeze Conclusion

- 当前对象正式冻结为一条
  - `订单承接 -> 履约承接`
    的 bounded continuation mainline
- 这条 mainline 当前只纳入：
  1. `发布项目工作台` 中：
     - `order_chain`
     - `fulfillment_chain`
     的摘要 carrier 与 handoff 关系
  2. 4 条已存在的 `S2` 只读主 carrier：
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `inspection/detail`
  3. 当前 workbench 已暴露、且确实属于本链继续动作的两个提交入口：
     - `milestone/submit`
     - `inspection/submit`
- 当前对象正式不纳入：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/entry`
  - `rating/submit`
  - `dispute/open`
  - `dispute/withdraw`

## 3. 当前对象的主链定义

### 3.1 当前主链起点

- 当前主链起点正式冻结为：
  - `activeOrderId`
  - `activeMilestoneId`
    已经存在时的 continuation mainline
- 也就是说，
  当前对象不是：
  - `bid -> order/create`
    的上游转换对象
- 当前对象是：
  - 订单实例已存在后的继续承接
  - 履约节点已存在后的继续承接

### 3.2 当前主链最小组成

- 当前对象的最小主链正式冻结为：

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
    是当前对象内唯一允许继续 author 的命令 handoff 目标

### 3.3 当前主链不跨越的边界

- 当前对象正式不跨越：
  - `bid -> order/create`
  - `contract/detail -> contract/confirm`
  - `contract/detail -> contract/amend`
  - `inspection/detail -> inspection/recheck`
  - `inspection/detail -> rating`
  - `order/detail -> dispute`

原因固定为：

- 这些对象虽然在 OpenAPI、前端壳页或历史冻结中存在，
  但它们不属于这次用户指定的
  `订单承接与履约承接主链`
  的当前 bounded scope。

## 4. workbench / my-project / 当前对象 的真义边界

### 4.1 workbench 边界

- `发布项目工作台`
  当前在这条主线里的正式真义仍然是：
  - 摘要页
  - handoff 页
  - continuation carrier page
- 当前正式禁止把 workbench 解释成：
  - 订单真值 owner
  - 履约真值 owner
  - 订单/履约控制台
  - 交易写主链已经打开的证明

### 4.2 my-project 边界

- `my/projects` 与 `my/projects/{projectId}`
  当前在这条主线里的正式真义仅为：
  - 项目级私域进度摘要复用
- 它们允许继续复用：
  - `orderStatus`
  - `contractStatus`
  - `fulfillmentStatus`
  - 项目级最小 `afterSalesOrDisputeStatus`
- 但当前正式禁止把 `my_project` 写成：
  - 订单详情 carrier
  - 合同详情 carrier
  - 履约详情 carrier
  - 验收详情 carrier
  - 当前主链的真源 owner

### 4.3 S2 read corridor 边界

- 当前对象正式复用 `S2` 的只读走廊资产，
  但复用不等于改写其历史结论。
- 当前正式写死：
  - `S2 read corridor = 当前对象的已存在资产`
  - `S2 read corridor != 当前对象已经全链闭环`

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
  - 把 page shell / demo fallback 写成主链已通

### 5.2 BFF

- BFF 当前在本对象里只允许：
  - 聚合 `order/detail`
  - 聚合 `contract/detail`
  - 聚合 `milestone/list`
  - 聚合 `inspection/detail`
  - 未来在当前对象范围内承接：
    - `milestone/submit`
    - `inspection/submit`
      的 app-facing transport
- BFF 当前正式禁止：
  - 拥有订单真相
  - 拥有履约真相
  - 推导 archive-ready
  - 推导 contract confirmed
  - 推导 inspection passed / rechecked 终态
  - 越界承接 `rating/dispute` 成为当前对象一部分

### 5.3 Server

- Server 当前在本对象里仍然是唯一 truth owner。
- 当前对象内，
  `Server` 正式拥有的 truth family 只冻结到：
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
- 当前对象正式不把以下命令真相默认视为“已存在 active runtime”：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating`
  - `dispute`

## 6. 当前对象的 included / excluded matrix

| 对象 | 当前真义 | 是否纳入当前对象 |
|---|---|---|
| `order_chain` | workbench 摘要 carrier | 纳入 |
| `fulfillment_chain` | workbench 摘要 carrier | 纳入 |
| `order/detail` | 订单只读主 carrier | 纳入 |
| `contract/detail` | 合同只读主 carrier | 纳入 |
| `milestone/list` | 履约节点只读主 carrier | 纳入 |
| `milestone/submit` | 履约节点最小提交 handoff | 纳入 |
| `inspection/detail` | 验收只读主 carrier | 纳入 |
| `inspection/submit` | 验收最小提交 handoff | 纳入 |
| `order/create` | 上游 bid->order 转换 | 排除 |
| `contract/confirm` | 合同确认次级主链 | 排除 |
| `contract/amend` | 合同改单次级主链 | 排除 |
| `inspection/recheck` | 验收复检边界对象 | 排除 |
| `rating/entry` | 下游评价边界对象 | 排除 |
| `rating/submit` | 下游评价写链 | 排除 |
| `dispute/open` | 下游争议边界对象 | 排除 |
| `dispute/withdraw` | 下游争议撤回边界对象 | 排除 |

## 7. 当前对象正式禁止的误导口径

- 不得写：
  - `订单承接与履约承接主链 = 整个交易主链`
- 不得写：
  - `workbench order_chain / fulfillment_chain 已有数据壳 = 下游 runtime 已完成`
- 不得写：
  - `OpenAPI 有 path = active source 已实现`
- 不得写：
  - `Flutter 页已存在 = BFF/Server 命令主链已通`
- 不得写：
  - `S2 read corridor PASS WITH RISK = 当前对象 implementation PASS`

## 8. Explicit Non-goals

- 不扩到：
  - `my_project` 结构重构
  - workbench 新容器
  - 支付、结算、发票、税务
  - 合同历史、验收历史、治理台席
  - 评价与争议治理闭环
- 不在本轮 author：
  - migration
  - implementation prompt
  - integration prompt

## 9. Stage Conclusion

- 当前结论：
  - `Go for 订单承接与履约承接主链 contract freeze authoring`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 10. Next Unique Action

- 下一轮唯一动作：
  - 输出《订单承接与履约承接主链 contract freeze》

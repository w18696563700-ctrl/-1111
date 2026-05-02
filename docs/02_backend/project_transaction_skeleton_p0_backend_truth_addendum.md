---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend truth ownership, persistence carriers, canonical-vs-derived
  split, and prohibited truth mixing rules for `项目交易骨架 P0`.
layer: L3 Backend
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_transaction_skeleton_p0_gate_checklist.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/01_contracts/project_transaction_skeleton_p0_contracts_addendum.md
  - docs/02_backend/db_schema.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md
---

# 项目交易骨架 P0 Backend Truth Addendum

## 1. Scope

本文件只冻结 `项目交易骨架 P0` 的 backend truth。

本文件不做：

- 支付 / 账单 / 押金 / 保证金 / 交易保障 / 佣金 backend truth
- 项目 review state machine
- 项目 visibility/displayStatus truth
- `apps/server/**` 实现

## 2. 唯一 truth owner

当前 `P0` 交易骨架的唯一 truth owner 是：

- `Server`

更具体地说：

- `App` 不是 truth owner
- `BFF` 不是 truth owner
- `my/projects` 不是 truth owner
- `exhibition/workbench` 不是 truth owner
- `profile/*` bounded posture family 不是 truth owner

## 3. Truth Ownership Table

| 对象 | canonical carrier | server-owned truth | audit ownership | snapshot ownership | prohibited second truth |
|---|---|---|---|---|---|
| `Bid` | `bids` | `bid submit` 的命令真值与状态归 `Server` | `audit_logs` | 无独立 app snapshot | `workbench summary`、`viewerProjectRelation`、Flutter local cache |
| `Order` | `orders` | `order create/detail` 的唯一业务真值归 `Server` | `audit_logs` | `my/projects privateProgress` 只能读时摘要 | `privateProgress.orderStatus`、`summary.stateLabel` |
| `Contract` | `contracts` | `contract confirm/detail` 的唯一业务真值归 `Server` | `audit_logs` | `my/projects privateProgress` 只能读时摘要 | BFF state、frontend local state、`contract/amend` 伪快照 |
| `Milestone` | `milestones` | `milestone submit/list` 的唯一业务真值归 `Server` | `audit_logs` | `privateProgress.fulfillmentStatus` 只能读时摘要 | workbench container、UI stepper |
| `Inspection` | `inspections` | `inspection submit/detail` 的唯一业务真值归 `Server` | `audit_logs` | `privateProgress.acceptanceStatus` 只能读时摘要 | BFF pass guess、frontend local pass flag |
| 证据链 | `evidences` + `file_assets` | 绑定到对应业务对象的证据真值归 `Server` | `audit_logs` | 无独立前端真值 | raw URL、`objectKey`、本地文件缓存 |

## 4. Persistence Carrier Table

| 对象族 | P0 当前 canonical persistence carriers | 当前不批准 |
|---|---|---|
| `Bid` | `bids` | 任意 `bid_summary_cache`、前端本地投影表 |
| `Order` | `orders` | 第二订单状态机、`order_runtime_snapshot` |
| `Contract` | `contracts`, `contract_clauses`, `evidences`, `file_assets` | `contract_versions`, `contract_confirmations` |
| `Milestone` | `milestones`, `evidences`, `file_assets` | `milestone_projection_cache`, `daily_progress_logs` |
| `Inspection` | `inspections`, `evidences`, `file_assets` | `inspection_console_state`, `rectification_items` |
| 审计 | `audit_logs` | BFF 侧 audit、Flutter 侧 pseudo-audit |

## 5. Derived-vs-Canonical Split

| 字段或对象 | 当前分类 | 说明 |
|---|---|---|
| `orders / contracts / milestones / inspections` 表记录 | canonical | 这些对象的业务真值只能由 `Server` 持有 |
| `project.state` | canonical but not trade truth | 只负责项目生命周期，不负责交易骨架真值 |
| `publishedAt` | canonical but not trade truth | 只负责公域准入 |
| `viewerProjectRelation` | derived projection | 只做 `owner/non_owner` handoff |
| `privateProgress.*Status` | derived projection | 只能从交易对象真值读时派生 |
| `workbench summary containers` | derived projection | 只做 continuation posture，不得写回交易真值 |
| `summary.stateLabel` | UI wording | 任何时候都不是真值 |

## 6. P0 Read Corridor Only Objects

以下对象在 `P0` 中只能作为 read corridor，不得被当成写命令真源：

1. `order/detail`
2. `contract/detail`
3. `milestone/list`
4. `inspection/detail`

含义：

- 它们可以消费 `Server` canonical truth。
- 它们不得反向成为：
  - 写命令来源
  - 第二状态机
  - 最终放行判断

## 7. P0 Write Corridor Only Objects

以下对象是 `P0` 当前唯一批准进入 write corridor 的业务命令族：

1. `bid/submit`
2. `order/create`
3. `contract/confirm`
4. `milestone/submit`
5. `inspection/submit`

明确排除：

1. `contract/amend`
2. `inspection/recheck`
3. `rating`
4. `dispute`

## 8. Audit Ownership Rule

当前 `P0` 必须坚持：

- 每个被批准进入 write corridor 的对象，都由 `Server` 持有 audit ownership。
- `BFF` 不得补记第二份业务审计。
- Flutter 不得把本地交互日志冒充业务审计。

当前最小必须留痕对象为：

1. `BidSubmitted`
2. `OrderCreated`
3. `ContractConfirmed`
4. `MilestoneSubmitted`
5. `InspectionSubmitted`

## 9. Snapshot Ownership Rule

当前允许存在的 snapshot / projection 只有：

- `my/projects privateSummary/privateProgress`
- `exhibition/workbench summary containers`

这些 projection 的边界写死为：

- 只能读时派生
- 不能作为写命令 carrier
- 不能作为第二状态机
- 不能替代 canonical table family

## 10. Prohibited Truth Mixing List

当前明确禁止以下 truth mixing：

1. 把 `profile/payment-and-billing-status/*` 当作 payment execution truth
2. 把 `profile/credit-and-constraints/*` 当作交易 runtime gate truth
3. 把 `membership summary` 当作项目主链资格真源
4. 把 `workbench summary` 当作交易实例真源
5. 把 `my-project privateProgress` 当作 `order/contract/fulfillment` 原始真源
6. 把 `viewerProjectRelation` 当作 owner 权限总真源
7. 把 `summary.stateLabel` 当作状态真值
8. 把 `project.state` 回写成 order/contract/inspection 真值
9. 把 `payment/billing/deposit/credit/posture` 接进当前项目交易 runtime

## 11. Funds/Risk Exclusion Rule

当前必须明确：

- `payment`
- `billing`
- `deposit`
- `guarantee`
- `credit`
- `membership`

都不属于当前 `P0 backend truth` 包。

当前也不得把：

- `profile bounded posture/status`

接进项目交易 runtime。

## 12. Formal Conclusion

`项目交易骨架 P0` 的 backend truth 正式冻结为：

- `Server` 是唯一 truth owner
- canonical persistence carriers 只承认：
  - `bids`
  - `orders`
  - `contracts`
  - `contract_clauses`
  - `milestones`
  - `inspections`
  - `evidences`
  - `file_assets`
  - `audit_logs`
- `order/detail / contract/detail / milestone/list / inspection/detail` 只读，不得被当成写命令真源
- `payment / billing / deposit / guarantee / credit / membership` 全部不属于当前包

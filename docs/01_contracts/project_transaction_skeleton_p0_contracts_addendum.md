---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 contracts boundary for `项目交易骨架 P0`, deciding the only
  admitted app-facing path families, the P0 write stop-line, the read-only
  families, and the explicit non-P0 prohibition list.
layer: L2 Contracts
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_transaction_skeleton_p0_gate_checklist.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_business_closure_strategy_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 项目交易骨架 P0 Contracts Addendum

## 1. Scope

本文件只冻结 `项目交易骨架 P0` 的 app-facing contracts 边界。

本文件不做：

- 支付 / 账单 / 押金 / 交易保障 / 佣金 contract
- 项目可见性治理 contract
- 项目审核状态机 contract
- `apps/**` 实现

## 2. P0 唯一对象 stop-line

`P0` 的唯一交易骨架 stop-line 冻结为：

- `bid/submit`
- `order/create`
- `contract/confirm`
- `milestone/submit`
- `inspection/submit`

同时只承认以下 read baseline：

- `order/detail`
- `contract/detail`
- `milestone/list`
- `inspection/detail`

当前不把以下对象纳入 `P0`：

- `contract/amend`
- `inspection/recheck`
- `rating/*`
- `dispute/*`

## 3. Path Matrix

| path family | P0 定位 | 当前裁决 | 说明 |
|---|---|---|---|
| `POST /api/app/bid/submit` | write corridor | 批准进入 P0 | 这是 P0 唯一上游真实 app-facing write corridor 起点；但不等于完整交易闭环已成立 |
| `GET /api/app/order/detail` | read corridor only | 保留 | 只作为 continuation read baseline |
| `POST /api/app/order/create` | write corridor | 批准进入 P0 | 当前 order 的唯一 P0 write carrier |
| `GET /api/app/contract/detail` | read corridor only | 保留 | 只作为 contract continuation read baseline |
| `POST /api/app/contract/confirm` | write corridor | 批准进入 P0 | 当前 contract 的唯一 P0 write carrier |
| `POST /api/app/contract/amend` | 非 P0 | 不批准 | 保留为后续扩展，不进入当前骨架 |
| `GET /api/app/milestone/list` | read corridor only | 保留 | 只作为 fulfillment read baseline |
| `POST /api/app/milestone/submit` | write corridor | 批准进入 P0 | 当前 milestone 的唯一 P0 write carrier |
| `GET /api/app/inspection/detail` | read corridor only | 保留 | 只作为 acceptance read baseline |
| `POST /api/app/inspection/submit` | write corridor | 批准进入 P0 | 当前 inspection 的唯一 P0 write carrier |
| `POST /api/app/inspection/recheck` | 非 P0 | 不批准 | 继续保留为 extension-only 候选 |
| `GET /api/app/rating/entry` | 战略预留 | 不批准 | 不属于当前 P0 |
| `POST /api/app/rating/submit` | 战略预留 | 不批准 | 不属于当前 P0 |
| `POST /api/app/dispute/open` | 战略预留 | 不批准 | 不属于当前 P0 |
| `POST /api/app/dispute/withdraw` | 战略预留 | 不批准 | 不属于当前 P0 |

## 4. Object Family Matrix

| 对象族 | P0 分类 | 当前允许 | 当前不允许 |
|---|---|---|---|
| `Bid` | P0 write 起点 | `submit` | shortlist、比价台、win/loss console |
| `Order` | P0 write + read | `create` + `detail` | 第二订单状态机、order complete 命令 |
| `Contract` | P0 write + read | `confirm` + `detail` | `amend`、history、clause editor、legal review |
| `Milestone` | P0 write + read | `submit` + `list` | 第二 workflow、approval console |
| `Inspection` | P0 write + read | `submit` + `detail` | `recheck`、history、governance console |
| `Rating` | 后置预留 | 无 | `entry`、`submit` 全部不进 P0 |
| `Dispute` | 后置预留 | 无 | `open`、`withdraw` 全部不进 P0 |

## 5. `bid/submit` 当前裁决

`bid/submit` 在 P0 的正式定位是：

- `真实 write corridor`

同时必须写死：

- 它不等于完整交易闭环。
- 它不自动证明：
  - `bid -> order` 已稳定转化
  - `order/contract/milestone/inspection` 已全部成立

## 6. `order / contract / milestone / inspection` 当前定位

### 6.1 Order

- `GET /api/app/order/detail`
  - `read corridor only`
- `POST /api/app/order/create`
  - `纳入 write corridor`

### 6.2 Contract

- `GET /api/app/contract/detail`
  - `read corridor only`
- `POST /api/app/contract/confirm`
  - `纳入 write corridor`
- `POST /api/app/contract/amend`
  - `当前不批准为 P0 交易骨架实现对象`

### 6.3 Milestone

- `GET /api/app/milestone/list`
  - `read corridor only`
- `POST /api/app/milestone/submit`
  - `纳入 write corridor`

### 6.4 Inspection

- `GET /api/app/inspection/detail`
  - `read corridor only`
- `POST /api/app/inspection/submit`
  - `纳入 write corridor`
- `POST /api/app/inspection/recheck`
  - `当前不批准为 P0 交易骨架实现对象`

## 7. `rating / dispute` 当前裁决

- `rating`
  - 继续保留为战略预留
- `dispute`
  - 继续保留为战略预留

当前不得把它们写成：

- `P0` 交易骨架对象
- 当前主链完成度证明
- 当前 write corridor 一部分

## 8. 明确“不属于 P0”的禁止清单

以下 path family 当前明确不属于 `P0`：

1. `/api/app/contract/amend`
2. `/api/app/inspection/recheck`
3. `/api/app/rating/entry`
4. `/api/app/rating/submit`
5. `/api/app/dispute/open`
6. `/api/app/dispute/withdraw`
7. `/api/app/profile/payment-and-billing-status/*`
8. `/api/app/profile/credit-and-constraints/*`
9. `/api/app/profile/membership/*`

## 9. P0 外的对象禁止升格规则

以下对象即使在 `openapi.yaml` 或既有 bounded package 中存在，也不得升格为 `P0`：

1. `payment`
2. `billing`
3. `deposit`
4. `guarantee`
5. `credit`
6. `membership`
7. `project visibility/displayStatus`
8. `project review state machine`

## 10. Formal Conclusion

当前 `项目交易骨架 P0` 的 contracts freeze 正式写死为：

- write corridor 只到：
  - `bid/submit -> order/create -> contract/confirm -> milestone/submit -> inspection/submit`
- read corridor baseline 只到：
  - `order/detail -> contract/detail -> milestone/list -> inspection/detail`
- `contract/amend`、`inspection/recheck`、`rating/*`、`dispute/*` 当前都不批准为 P0 对象
- `payment / billing / deposit / guarantee / credit / membership` 当前都不属于 P0

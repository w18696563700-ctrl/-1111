---
owner: Codex 总控
status: frozen
purpose: >
  Consolidate the current project-mainline stop-line, transaction-skeleton
  priority, funds/risk admission rules, and P0/P1/P2 roadmap into one strategy
  entry document for future scheduling and implementation governance.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/historical_projects_semantics_ruling_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_closure_conclusion_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/stage2_transport_admin_support_closure_conclusion_addendum.md
  - docs/00_ssot/s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_bff_order_contract_fulfillment_read_corridor_aggregation_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_mobile_order_contract_fulfillment_read_corridor_consumption_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_bounded_implementation_review_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目业务闭环战略冻结总单》

## 1. 总诊断结论

### 1.1 当前项目主线是否已经构成真实交易闭环

- 结论：**不是**

### 1.2 当前闭环止于哪一段

- 当前正式止于：
  - `发布 -> 展示 -> owner/non-owner 分流 -> 私域承接`

### 1.3 当前最重要的战略结论

- 下一阶段必须**先做交易骨架**。
- 当前不得直接开资金链。
- 当前不得把 profile 里的 membership / payment / billing / credit / deposit posture 家族误判成项目主链已接入。
- 当前若要推进资金/风控，必须先明确交易骨架的唯一 gate 位置与唯一 state map。

## 2. 功能状态总表

| 功能族 | 当前状态 | 当前正式意义 | 当前下一步 |
|---|---|---|---|
| `project/create` | 已成立 | 发布最小走廊成立 | 只做维护，不再夸大为交易闭环 |
| `project/list` / `project/detail` | 已成立 | 公域展示主线成立 | 保持 shared public read，不混私域语义 |
| `viewerProjectRelation` | 已成立 | owner/non-owner 最小分流成立 | 继续保持 relation-only 语义 |
| `my/projects*` | 已成立 | 私域项目资产与私域承接成立 | 继续保持私域资产面 |
| `exhibition/workbench` | 已成立 | 私域 continuation summary 成立 | 继续保持 summary/entry posture |
| 认证 | 已成立并入主链 | 发布/竞标硬 gate | 继续作为唯一当前资格硬 gate |
| 会员 | 已 bounded implementation 成立 | commercial read package，不是项目 gate | 旁路保留，不前插主链 |
| `bid/submit` | 受控可用 | 最小 continuation 边界，不是交易闭环 | 只能作为交易骨架上游前置 |
| `order/detail` / `contract/detail` / `milestone/list` / `inspection/detail` | 已成立只读边界 | `S2` read corridor PASS WITH RISK | 作为后续 write skeleton 的 read baseline |
| `order/create` / `contract/confirm` / `milestone/submit` / `inspection/submit` | 未作为当前闭环收口 | canonical path 已存在，但未被当前总包接受为已闭环 | 进入 P0 交易骨架 |
| `rating` / `dispute` | 战略预留 | 只保留边缘 entry/planning 语义 | 后置，不作为当前主链依据 |
| 支付 / 账单 | 已 bounded implementation 成立 | profile status/reference/handoff package，不是资金执行链 | 后置到 P2 |
| 信用 / 保证金 / 交易保障 | 已 bounded implementation 成立 | profile posture/status/handoff package，不是项目 gate | 后置到 P1，先接交易骨架 |
| 项目 visibility/displayStatus | 未成立 | 当前没有独立 truth carrier | 如需要展示治理，先补 truth |
| 项目 review state machine | 未成立 | 当前不存在 review-before-display | 禁止凭空接入 |

## 3. 当前最关键的 10 个 blocker

1. 当前没有被正式接受的“真实交易闭环”止点总单，容易把项目资产闭环误说成交易闭环。
2. `bid` 当前只到 minimum continuation，尚未被正式接受为 `bid -> order` 的稳定转换闭环。
3. `order / contract / milestone / inspection` 当前收口的是 read corridor，不是 write skeleton。
4. 当前没有独立项目级 `visibility / displayStatus` truth；任何隐藏/下架/展示冻结语义都会失真。
5. 当前没有项目审核状态机；任何 review-before-display 语义都会是伪真值。
6. 认证以外，没有第二个已接入主链的资格/风控硬 gate。
7. `credit / deposit / guarantee` 当前只有 posture/status/handoff，尚未冻结其接入 `bid -> order -> contract` 的唯一位置。
8. `payment / billing` 当前只有 status/reference/handoff，尚未冻结真实资金执行、账单、结算与 finance-admin truth。
9. 会员当前是商业 read package，若不明确阻断，后续很容易被误写成交易资格或资金 gate。
10. `rating / dispute` 当前只是边缘对象，若不明确后置，后续会被错误拿来充当“项目后链已闭环”的证明。

## 4. P0 / P1 / P2 实施建议

### 4.1 P0

P0 唯一优先级：

- **先做交易骨架，不做资金链**

P0 必做项：

1. 冻结并验证 `bid -> order/create -> contract/confirm -> milestone/submit -> inspection/submit` 的最小 write skeleton。
2. 明确 `project.state` 与 downstream `order/contract/fulfillment` state 的彻底分层。
3. 冻结 `credit / deposit / guarantee` 将来接在：
   - `bid -> order`
   - 还是 `order -> contract`
   的唯一 gate 位点。
4. 明确 `S2` read corridor 只作为 read baseline，不得冒充 write closure。
5. 在进入任何资金动作前，先确认是否需要独立 `visibility/displayStatus` carrier。

### 4.2 P1

P1 只在 P0 完成后允许启动：

1. 把 `credit / deposit / guarantee` 从 profile posture 家族接入交易骨架。
2. 把它们固定成：
   - 硬 gate
   - 还是 advisory/soft gate
   的唯一语义。
3. 明确它们是否影响：
   - `bid -> order`
   - `order -> contract`
   - `contract -> fulfillment`
4. 继续保持：
   - membership 不等于 trade gate
   - payment/billing 不提前进入执行链

### 4.3 P2

P2 只在 P0 + P1 完成后允许启动：

1. 冻结 payment execution truth。
2. 冻结 billing/reference 与实际 obligation 的关系。
3. 冻结 settlement / clearing / finance-admin 是否存在以及如何分层。
4. 冻结 invoice/tax 是否入当前主链还是继续旁路。
5. 在那之前，不得开：
   - 真实支付
   - 押金实缴
   - 佣金 / 服务费
   - 结算

## 5. 必须立即拍板的战略决策清单

1. 当前项目主线是否为真实交易闭环：
   - 已拍板：不是。
2. 当前闭环止点：
   - 已拍板：止于 `发布 -> 展示 -> owner/non-owner 分流 -> 私域承接`。
3. 下一阶段先做什么：
   - 已拍板：先做交易骨架，不先做资金链。
4. 认证是否继续是当前唯一项目资格硬 gate：
   - 已拍板：是。
5. 会员是否允许升格为项目 gate：
   - 已拍板：不允许。
6. `credit / deposit / guarantee` 是否允许现在直接入主链：
   - 已拍板：不允许，先停留旁路 posture/handoff。
7. `payment / billing` 是否允许现在直接入主链：
   - 已拍板：不允许，先停留旁路 status/reference/handoff。
8. 是否允许用 `project.state` 或 `publishedAt` 顶替未来 visibility/funds gate：
   - 已拍板：不允许。
9. 是否允许引入项目审核状态机来承接后续资金/治理需求：
   - 已拍板：当前不允许。
10. `rating / dispute` 是否可作为当前主线完成度依据：
   - 已拍板：不允许，继续后置。

## 6. 开启支付 / 押金 / 佣金实现前的 veto blocker

以下问题不解决，不得开启支付 / 押金 / 佣金实现：

1. 没有正式收口的交易 write skeleton。
2. 没有冻结 `credit / deposit / guarantee` 的唯一接线位点。
3. 没有冻结 payment execution 与 billing/settlement 的唯一分层。
4. 还在混用 `project.state`、`publishedAt`、`viewerProjectRelation`、`privateProgress`、`workbench summary`。
5. 还试图把 membership 升格为交易资格 gate。
6. 还试图把 profile posture/status 页当成已接线主链。
7. 如果需要展示冻结/下架/成交后可见性切换，却还没有独立 `visibility/displayStatus` truth。

## 7. 当前四个决策问题的正式答案

### 7.1 当前项目主线是否已经构成真实交易闭环

- 正式答案：**不是**
- 当前止于：
  - `发布 -> 展示 -> owner/non-owner 分流 -> 私域承接`

### 7.2 当前支付 / 账单 / 押金 / 信用约束 / 会员中，哪些允许进入下一阶段实现

- 认证：
  - 已在主链，继续保留
- 会员：
  - 仍必须停留在旁路，不进入项目 gate
- 支付 / 账单：
  - 仍必须停留在旁路，不进入当前下一阶段
- 信用约束 / 保证金 / 交易保障：
  - 当前仍必须停留在旁路；只能在 P1、且以交易骨架为前置时接线

### 7.3 下一阶段到底先做什么

- 正式答案：
  - **先做交易骨架**

### 7.4 哪些问题不解决，就不得开启支付 / 押金 / 佣金实现

- 正式答案：
  - 上述第 6 节 veto blockers 全部属于先决条件

## 8. Formal Conclusion

本单正式作为后续实现排期的唯一战略入口。

后续所有实现、排期、人力分配、阶段门禁，必须服从以下顺序：

1. 先承认当前项目主线并非真实交易闭环。
2. 先把交易骨架做成真正的 write skeleton。
3. 再把信用 / 保证金 / 交易保障接到骨架的唯一 gate 位点。
4. 最后才允许讨论 payment / billing / settlement 等资金执行链。

在这之前：

- 不得并行开启资金链
- 不得把旁路 status/posture package 冒充主链
- 不得再用模糊口径描述“项目闭环已完成”

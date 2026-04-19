---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum L3 backend truth ownership, persistence carriers, derived-read boundary, timeout discipline, audit boundary, and migration scope for exhibition bidding midstream platformization so later BFF authoring proceeds on a single Server meaning for seat, bid package completeness, buyer compare, and loser feedback.
layer: L3 Backend
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/exhibition_bidding_midstream_platformization_minimum_closure_freeze.md
  - docs/01_contracts/exhibition_bidding_midstream_platformization_contract_freeze.md
  - docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《展览竞标平台化中段 backend truth / persistence freeze》

## 1. 目标

- 本轮只冻结：
  - `展览竞标平台化中段` 的最小 backend truth / persistence
- 本轮只承接：
  - `seat`
  - `bid package completeness`
  - `buyer compare` 最小稳定消费面
  - `loser feedback` 最小稳定消费面
- 本轮不是：
  - 完整竞标平台 backend
  - 支付 / 保证金 backend
  - 复杂评分引擎 backend
  - 完整 compare console backend
  - 合同 / 履约中段 backend
  - 信用飞轮 backend
  - 平台治理台 backend
  - BFF / Flutter / implementation

## 2. 当前真相

- 当前已经成立并继续沿用的上游 truth 包括：
  - `project publish`
  - `project detail/public board`
  - 最小 `bid submit`
  - 最小 `bid award`
  - 最小 `order/contract seed bridge`
- 当前必须明确：
  - `Server` 是本轮唯一 truth owner
  - `BFF` 不是 truth owner
  - Flutter 不是 truth owner
- 当前尚未成立的对象包括：
  - `seat lock runtime`
  - 结构化 `bid package completeness` carrier
  - buyer 侧稳定 compare projection
  - 稳定的 loser feedback consumption projection
- 当前不得把上游 `BidAward bridge` 文书写成：
  - `seat` 已经成立
  - `compare` 已经有完整 console
  - `loser feedback` 已经有完整独立系统

## 3. Persistence 方案裁决

### 3.1 唯一 truth owner

- `Server` 是以下对象的唯一 truth owner：
  - `seat`
  - `bid package completeness`
  - `buyer compare`
  - `loser feedback`

### 3.2 Canonical persistence / derived carrier family

- 本轮最小 canonical backend family 固定为：
  - `projects`
  - `bids`
  - `bid_awards`
  - `bid_seats`
  - `audit_logs`
- 本轮正式裁决如下：
  - `seat`
    - 使用独立 persistence carrier：
      - `bid_seats`
  - `bid package completeness`
    - 不新开独立 workspace table
    - 以 `bids` 现有 canonical fields 为 source truth
    - 由 `Server` 派生 completeness projection
  - `buyer compare`
    - 不是独立 persistence table
    - 是基于 `projects + bids + bid_seats + bid_awards` 的 buyer-only derived read-model
  - `loser feedback`
    - 不是独立 persistence table
    - 继续由 `bid_awards` 与既有 `bids` loser disposition truth 派生

### 3.3 `bid_seats` carrier 冻结

- `bid_seats` 是本轮唯一 seat canonical carrier。
- 最小字段固定为：
  - `seatId`
  - `projectId`
  - `bidId`
  - `state`
  - `lockedAt`
  - `expiresAt`
  - `releasedAt`
  - `updatedAt`
- `bid_seats` 的唯一性固定为：
  - 一个 `(projectId, bidId)` 只允许一条 canonical seat row

### 3.4 明确排除的 persistence family

- 本轮明确排除：
  - `bid_deposits`
  - `bid_payments`
  - `compare_snapshots`
  - `compare_scores`
  - `loser_feedback_threads`
  - `loser_feedback_console_state`
  - `contract_versions`
  - `change_orders`
  - `fulfillment_plans`
  - `rating_profiles`
  - 任意治理台 workspace table

## 4. Truth 流程裁决

### 4.1 `seat lock`

- `seat lock` 是 command。
- truth owner：
  - `Server`
- canonical write target：
  - `bid_seats`
- 最小 truth 流程固定为：
  1. 校验 `projectId / bidId` 属于当前 in-scope bid
  2. 读取当前 `(projectId, bidId)` 的 canonical seat row
  3. 若不存在 row，则创建：
     - `state = locked`
     - `lockedAt = now`
     - `expiresAt = now + seatTTL`
  4. 若存在 row 且 `state in (released, timed_out)`，允许重锁：
     - `state = locked`
     - 刷新 `lockedAt`
     - 刷新 `expiresAt`
     - 清空 `releasedAt`
  5. 若当前处于有效 `locked`，则 fail-close
- 本轮明确：
  - `seat lock` 不创建 `BidAward`
  - `seat lock` 不创建 `Order`
  - `seat lock` 不触发 payment / deposit

### 4.2 `seat release`

- `seat release` 是 command。
- truth owner：
  - `Server`
- canonical write target：
  - `bid_seats`
- 最小 truth 流程固定为：
  1. 定位 canonical seat row
  2. 若当前是有效 `locked`
     - 更新为 `state = released`
     - 写入 `releasedAt = now`
     - 清空有效占位语义
  3. 若当前已 `released` 或 `timed_out`
     - 直接返回 controlled fail-close

### 4.3 `seat timeout`

- `seat timeout` 不是 app-facing command。
- `seat timeout` 是 `Server` owned transition。
- 最小 truth 流程固定为：
  1. 任一 `seat status / seat lock / seat release / buyer compare` 读取 seat 前
  2. 若发现 `state = locked` 且 `expiresAt < now`
  3. 立即把该 row 改写为：
     - `state = timed_out`
     - `releasedAt = now`
  4. 再继续后续 read / write 判定
- 当前不引入：
  - 独立 timeout queue
  - payment / deposit 相关回收语义

### 4.4 `bid package completeness`

- `bid package completeness` 在本轮不是 command。
- `bid package completeness` 是 server-derived projection。
- truth owner：
  - `Server`
- source truth 固定为：
  - `bids.quoteAmount`
  - `bids.proposalSummary`
  - `bids.submittedAt`
- 最小 completeness 流程固定为：
  1. 定位 `projectId + bidId`
  2. 校验 bid 属于当前 project 且已进入 submitted scope
  3. 计算：
     - `quoteAmountReady`
     - `proposalSummaryReady`
  4. 生成：
     - `state`
     - `missingItems[]`
- 本轮正式裁决：
  - completeness 是 read-time derived truth
  - 不是独立 workspace
  - 不是独立 snapshot-bearing table

### 4.5 `buyer compare` read-model

- `buyer compare` 不是 command。
- `buyer compare` 是 buyer-only derived read-model。
- truth owner：
  - `Server`
- projection source 固定为：
  - `projects`
  - in-scope `bids`
  - `bid_seats`
  - `bid package completeness` derived result
  - 如已存在，则读取 `bid_awards` 以排除已决项目上的错误 compare 表达
- 当前正式裁决：
  - compare 不保存独立 snapshot
  - compare 不保存独立评分
  - compare 只承接最小稳定投影视图

### 4.6 `loser feedback` read-model

- `loser feedback` 不是 command。
- `loser feedback` 是 supplier-private derived read-model。
- truth owner：
  - `Server`
- projection source 固定为：
  - `bid_awards`
  - 既有 `bids` loser disposition truth
- 当前正式裁决：
  - loser feedback 不新增独立 persistence
  - loser feedback 不新增第二状态机
  - loser feedback 继续从上游 `BidAward bridge` 派生

## 5. 状态机 / timeout 裁决

### 5.1 `seat` 最小状态集合

- `seat` 最小状态集合固定为：
  - `available`
  - `locked`
  - `released`
  - `timed_out`

### 5.2 `available` 的 backend 表达

- `available` 在 backend 层固定为：
  - 当前 `(projectId, bidId)` 不存在 canonical `bid_seats` row
  - 或存在 row 但在 timeout / release 处理后已不再形成有效占位
- 当前不要求单独持久化一条 `available` row。

### 5.3 timeout 回收

- timeout 后：
  - `seat` 必须进入 `timed_out`
  - 当前占位失效
  - 后续可再次 `lock`
- timeout 不允许触发：
  - payment 回收
  - deposit 回收
  - award rollback
  - order rollback

### 5.4 release 回收

- release 后：
  - `seat` 必须进入 `released`
  - 当前占位立即失效
  - 后续可再次 `lock`

### 5.5 与 `award / order seed` 的边界

- `seat` 只控制中段占位与比较节奏。
- `seat` 不直接决定：
  - `BidAward`
  - `Order`
  - `Contract seed`
- 当前与 `award / order seed` 的边界固定为：
  - seat 只是前置 truth
  - award 继续由上游 `BidAward bridge` 单独治理

## 6. Completeness Truth Freeze

### 6.1 最小 completeness 维度

- Round 本轮最小 completeness 维度固定为：
  - `quoteAmountReady`
  - `proposalSummaryReady`
- `missingItems[]` 在本轮只允许：
  - `quote_amount`
  - `proposal_summary`

### 6.2 最低可比较 / 可定标 / 可留痕要求

- `可比较` 最低要求：
  - `quoteAmount` 已存在且大于 `0`
  - `proposalSummary` trim 后非空
- `可定标` 最低要求：
  - completeness `state = complete`
  - bid 已处于 submitted scope
- `可留痕` 最低要求：
  - completeness 结果必须可由 `Server` 复算
  - completeness 评估必须进入最小 audit 事件

### 6.3 正式裁决

- completeness 是 read-time projection
- completeness 不进入独立编辑工作台
- completeness 不进入复杂方案编排系统
- completeness 不引入单独持久化 snapshot 表

## 7. Compare Truth Freeze

### 7.1 最小 compare 投影视图

- `buyer compare` 最小字段固定为：
  - `projectId`
  - `bidId`
  - `supplierOrganizationId`
  - `supplierDisplayName`
  - `quoteAmount`
  - `proposalSummaryPreview`
  - `packageCompletenessState`
  - `seatState`
  - `submittedAt`

### 7.2 compare 访问边界

- compare 只对 buyer-side 开放。
- compare 不是 public read-model。
- compare 不是 supplier-side workspace。

### 7.3 snapshot 裁决

- compare 在本轮不保存独立 snapshot。
- compare 在本轮只保留 derived projection。
- 如后续需要治理留痕或评分 snapshot，必须新开单独冻结，不得在本轮偷带。

## 8. Loser Feedback Truth Freeze

### 8.1 最小来源

- loser feedback 的最小来源固定为：
  - `bid_awards`
  - `bids` 上既有 loser disposition truth

### 8.2 最小显示字段

- 最小显示字段固定为：
  - `bidId`
  - `projectId`
  - `state`
  - `result`
  - `reasonCode`
  - `reasonText`
  - `decidedAt`

### 8.3 正式裁决

- loser feedback 是由 award 结果派生的 supplier-private read-model
- loser feedback 不新增独立 persistence
- loser feedback 不扩成完整投标后反馈系统

## 9. Audit Freeze

### 9.1 Must-audit 集合

- 本轮必须进入 audit 的事件固定为：
  - `seat_locked`
  - `seat_released`
  - `seat_timeout_released`
  - `bid_completeness_evaluated`

### 9.2 本轮不进入 must-audit 的事件

- 本轮不把以下事件纳入 must-audit：
  - `buyer_compare_viewed`
  - `loser_feedback_revealed`
- 理由：
  - 当前 compare 与 loser feedback 只冻结最小稳定消费面
  - 当前不把它们提升为治理台 / 证据台 / 评分台

### 9.3 最小 audit 字段

- 每条 must-audit 至少记录：
  - `eventType`
  - `projectId`
  - `bidId`
  - `actorUserId`
  - `actorOrgId`
  - `traceId`
  - `occurredAt`
  - `result`

## 10. Migration Freeze

### 10.1 Round 本轮需要的 migration

- Round 本轮只新增：
  - `bid_seats` carrier migration

### 10.2 明确不新增的 migration

- 当前明确不新增：
  - `compare_snapshots`
  - `loser_feedback_threads`
  - `bid_package_workspaces`
  - `payment` / `deposit` 相关表
  - `esign` 相关表

### 10.3 对既有 carrier 的裁决

- `bids`
  - 继续复用现有 canonical fields：
    - `quoteAmount`
    - `proposalSummary`
    - `submittedAt`
    - 既有 loser disposition truth
  - 本轮不扩新列
- `bid_awards`
  - 本轮不扩新列
- `orders / contracts`
  - 本轮不新增字段
- `audit_logs`
  - 继续复用既有 audit carrier，只新增事件语义

## 11. 合规与发布门禁

- 当前文书只允许进入：
  - `BFF surface freeze authoring`
- 当前文书不允许进入：
  - direct implementation
  - integration
  - `release-prep`
  - production release
- 当前正式硬门禁写死：
  - backend truth 完成前，`BFF` 不得自行发明 compare / feedback truth
  - backend truth 完成前，frontend 不得把 placeholder 页面写成 runtime 已通
  - `docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md`
    是本轮并行硬门禁输入，不得跳过

## 12. No-Go 边界

- 不得把本轮写成完整竞标平台
- 不得把 `seat` 写成收费 / 支付 / 保证金
- 不得把 compare 写成完整评分控制台
- 不得把 loser feedback 写成完整反馈系统
- 不得顺手带入合同 / 履约 / 争议 / 支付
- 不得把 completeness 写成完整方案工作台
- 不得把 compare / loser feedback 偷扩成独立 persistence family

## 13. 下一步唯一动作

- 下一步唯一动作：
  - `输出《展览竞标平台化中段 BFF surface freeze》`

## 14. 裁决

- `《展览竞标平台化中段 backend truth / persistence freeze》是否可入库：是`

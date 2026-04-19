---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum L1 contract family for exhibition bidding midstream platformization so later backend truth and persistence authoring can proceed on a single meaning for seat, bid package completeness, minimum buyer compare consumption, and minimum loser feedback consumption without reopening payment, governance, or full compare-console scope.
layer: L1 Contracts
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/exhibition_bidding_midstream_platformization_minimum_closure_freeze.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/01_contracts/bid_award_bridge_contract_freeze_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《展览竞标平台化中段 contract freeze》

## 1. 目标

- 本轮只冻结：
  - `展览竞标平台化中段` 的最小 contract family
- 本轮只承接：
  - `seat`
  - `bid package completeness`
  - `buyer compare` 最小稳定消费面
  - `loser feedback` 最小稳定消费面
- 本轮不是：
  - 完整竞标平台 contract
  - 支付 / 保证金 contract
  - 复杂评分引擎 contract
  - 完整 compare console contract
  - 完整治理台 contract
  - 合同 / 履约中段 contract
  - 信用飞轮 contract

## 2. 当前真相

- 当前已经成立并继续沿用的 contract 真相包括：
  - `project publish`
  - `project detail/public board`
  - 最小 `bid submit`
  - 最小 `bid award`
  - 最小 `order/contract seed bridge`
- 当前尚未成立的运行态对象包括：
  - `seat lock runtime`
  - `bid package completeness workspace`
  - `buyer compare console / board`
  - 稳定的 `loser feedback` 消费面
- 当前必须明确：
  - 本轮 contract freeze 是对这些缺口做最小 contract 下钻
  - 不是证明这些对象已经 runtime 成立

## 3. Canonical Paths Freeze

### 3.1 Canonical app-facing path family

- 本轮进入 contract freeze 的唯一 app-facing path family 固定为：
  - `POST /api/app/bid/seat/lock`
  - `POST /api/app/bid/seat/release`
  - `GET /api/app/bid/seat/status?projectId={projectId}&bidId={bidId}`
  - `GET /api/app/bid/package-completeness?projectId={projectId}&bidId={bidId}`
  - `GET /api/app/bid/compare?projectId={projectId}`
  - `GET /api/app/bid/result?projectId={projectId}`

### 3.2 App-facing path meaning

- `seat`：
  - `POST /api/app/bid/seat/lock`
  - `POST /api/app/bid/seat/release`
  - `GET /api/app/bid/seat/status`
- `bid package completeness`：
  - `GET /api/app/bid/package-completeness`
- `buyer compare` 最小稳定消费面：
  - `GET /api/app/bid/compare`
- `loser feedback` 最小稳定消费面：
  - 继续复用已冻结的
    `GET /api/app/bid/result?projectId={projectId}`
  - 本轮不新开第二条 `/api/app/bid/loser-feedback` family

### 3.3 明确禁止进入本轮的 path

- 当前明确禁止进入本轮：
  - `POST /api/app/order/create`
  - `POST /api/app/bid/award`
    - 继续留在已冻结的 `BidAward bridge` contract family，不在本轮重写
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/board`
  - `GET /api/app/bid/compare/score`
  - `GET /api/app/bid/losers`
  - `POST /api/app/bid/deposit/*`
  - `POST /api/app/payment/*`
  - `POST /api/app/esign/*`
  - 任意 buyer governance console path

## 4. Server-facing Path Family

- 与上述 app-facing 对应的唯一合法 server-facing path family 固定为：
  - `POST /server/bid/seat/lock`
  - `POST /server/bid/seat/release`
  - `GET /server/bid/seat/status?projectId={projectId}&bidId={bidId}`
  - `GET /server/bid/package-completeness?projectId={projectId}&bidId={bidId}`
  - `GET /server/bid/compare?projectId={projectId}`
  - `GET /server/bid/result?projectId={projectId}`

- 正式边界写死：
  - `BFF` 只做 aggregation / normalize / error mapping
  - `BFF` 不拥有 `seat` truth
  - `BFF` 不拥有 completeness truth
  - `BFF` 不拥有 compare truth
  - `BFF` 不拥有 loser feedback truth
- 不得新开第二套并行 path family。

## 5. Request / Response Freeze

### 5.1 `POST /api/app/bid/seat/lock`

- 路径类型：
  - write path
- 最小 request 固定为：
  - `projectId`
  - `bidId`
- 最小 accepted response 固定为：
  - `seatId`
  - `projectId`
  - `bidId`
  - `state`
  - `expiresAt`
- 正式边界：
  - `seat lock` 只表达当前候选 bid 的中段占位
  - 不表达收费、支付、保证金、签约

### 5.2 `POST /api/app/bid/seat/release`

- 路径类型：
  - write path
- 最小 request 固定为：
  - `projectId`
  - `bidId`
- 最小 accepted response 固定为：
  - `seatId`
  - `projectId`
  - `bidId`
  - `state`
  - `releasedAt`

### 5.3 `seat timeout`

- 当前没有单独 app-facing write path。
- `seat timeout` 在本轮只通过：
  - `GET /api/app/bid/seat/status`
  的 read-model 被消费。
- 正式判断：
  - `seat timeout` 是 server-owned transition
  - 不是 app-facing command

### 5.4 `GET /api/app/bid/seat/status`

- 路径类型：
  - read path
- 最小 query 固定为：
  - `projectId`
  - `bidId`
- 最小 response 固定为：
  - `seatId`
  - `projectId`
  - `bidId`
  - `state`
  - `expiresAt`
  - `releasedAt`
- 其中当前 drift 修补固定为：
  - `seatId` 在 `available` 态允许为 `nullable`
  - `lock / release` accepted response 中的 `seatId` 继续保持 `string`

### 5.5 `GET /api/app/bid/package-completeness`

- 路径类型：
  - read path
- 最小 query 固定为：
  - `projectId`
  - `bidId`
- 最小 response 固定为：
  - `bidId`
  - `projectId`
  - `state`
  - `missingItems[]`
  - `quoteAmountReady`
  - `proposalSummaryReady`
- 正式边界：
  - 只冻结最小结构化完整性字段
  - 不冻结复杂方案工作台

### 5.6 `GET /api/app/bid/compare`

- 路径类型：
  - read path
- 最小 query 固定为：
  - `projectId`
- 最小 response 固定为：
  - `projectId`
  - `comparableBids[]`
- 每个 `comparableBid` 最小字段固定为：
  - `bidId`
  - `supplierOrganizationId`
  - `supplierDisplayName`
  - `quoteAmount`
  - `proposalSummaryPreview`
  - `packageCompletenessState`
  - `seatState`
  - `submittedAt`
- 正式边界：
  - 只承接 buyer compare 的最小稳定消费面
  - 不承接 scoring、排序引擎、治理台

### 5.7 `GET /api/app/bid/result`

- 路径类型：
  - read path
- 本轮继续沿用已有最小 loser feedback outlet：
  - `bidId`
  - `projectId`
  - `state`
  - `result`
  - `reasonCode`
  - `reasonText`
  - `decidedAt`
- 正式边界：
  - 这是最小稳定 loser feedback 消费面
  - 不是完整反馈系统

### 5.8 当前仍然 No-Go 的 path 类型

- 本轮仍然 `No-Go`：
  - compare write path
  - winner decision write path
    - 已存在的 `POST /api/app/bid/award` 继续由上游 bridge contract 单独治理
  - loser feedback edit / withdraw / appeal path
  - deposit / payment / esign path

## 6. State / Error Freeze

### 6.1 Seat 最小状态语义

- `seat` 最小状态固定为：
  - `available`
  - `locked`
  - `released`
  - `timed_out`

### 6.2 Completeness 最小状态语义

- `bid package completeness` 最小状态固定为：
  - `complete`
  - `incomplete`

### 6.3 Controlled error family

- `seat` 最小错误族固定为：
  - `BID_SEAT_INVALID`
  - `BID_SEAT_INVALID_STATE`
  - `BID_SEAT_CONFLICT`
  - `BID_SEAT_TIMEOUT`
- `bid package completeness` 最小错误族固定为：
  - `BID_PACKAGE_COMPLETENESS_INVALID`
  - `BID_PACKAGE_COMPLETENESS_UNAVAILABLE`
- `buyer compare` 最小错误族固定为：
  - `BID_COMPARE_INVALID`
  - `BID_COMPARE_UNAVAILABLE`
- `loser feedback` 最小错误族固定为：
  - `BID_RESULT_INVALID`
  - `BID_RESULT_UNAVAILABLE`

### 6.4 Hard boundary

- 当前不得把完整平台治理错误码族带进来。
- 当前不得把 payment / dispute / review-console 错误族并入本轮。

## 7. BFF Boundary

- `BFF` 在本轮只允许：
  - app-facing -> server-facing transport
  - request normalization
  - response shaping
  - controlled error mapping
- `BFF` 不允许：
  - 持有 `seat` 真值
  - 持有 completeness 真值
  - 持有 compare 真值
  - 持有 loser feedback 真值
  - 打开第二套并行 path family
  - 把 `GET /api/app/bid/result` 重写成第二条 loser path

## 8. No-Go 边界

- `seat` 不等于收费 / 支付 / 保证金
- `bid package completeness` 不等于复杂方案工作台
- `buyer compare` 不等于完整评分控制台
- `loser feedback` 不等于完整反馈系统
- 不得打开支付结算 path
- 不得打开电子签 path
- 不得把当前 contract freeze 写成完整竞标平台 contract 已完成

## 9. 合规与发布门禁

- 当前文书只允许进入：
  - `backend truth / persistence freeze authoring`
- 当前文书不允许进入：
  - direct implementation
  - integration
  - `release-prep`
  - production release
- 当前文书不等于：
  - runtime 已通
  - compare console 已完成
  - loser feedback 已形成完整系统

## 10. 下一步唯一动作

- 下一步唯一动作：
  - `输出《展览竞标平台化中段 backend truth / persistence freeze》`

## 11. 裁决

- `《展览竞标平台化中段 contract freeze》是否可入库：是`

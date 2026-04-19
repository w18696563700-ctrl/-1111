---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the current L2 contract family for `BidAward bridge`, limited to the
  bounded bridge object after `project publish` and `bid submit` already
  exist, so later backend truth and persistence authoring proceeds on a single
  meaning for award command, loser-result read outlet, order conversion, and
  synchronous contract seed without reopening `/api/app/order/create` or any
  heavier bid-governance family.
layer: L2 Contracts
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/00_ssot/bid_award_bridge_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/bid_award_bridge_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/bid_award_bridge_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/bid_award_bridge_package_level_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/bid_award_bridge_phase0_implementation_exception_independent_review_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/exhibition_showcase_bid_flow_v11_upgrade_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《BidAward bridge contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `BidAward bridge`
- 本冻结单只服务于：
  - 当前对象 app-facing / server-facing contract family
  - 当前对象 command / read outlet 最小字段边界
  - 当前对象错误语义与 unavailable 语义
  - `order conversion + synchronous contract seed` 的最小 continuation carrier
- 本冻结单不进入：
  - persistence / migration
  - backend / BFF / frontend 实现
  - integration
  - `release-prep`
  - production release

## 2. Contract Freeze Conclusion

- 本轮 contract freeze 不是 `no-op`。
- 本轮正式冻结当前 bridge 对象的最小 contract 变化。
- 当前必须明确：
  - `BidAward` 是唯一合法桥接对象
  - `/api/app/*` 是唯一 authoritative external path family
  - `/server/*` 只允许作为 backend 内部实现 / smoke / focused transport 对应位
- 当前不允许把以下对象一并写进 contract 作用域：
  - `POST /api/app/order/create`
  - `seat`
  - `bid package completeness`
  - payment / split-billing / electronic signature
  - full compare console
  - supplier `my bids workspace`

## 3. Canonical Path Family Freeze

### 3.1 App-facing Path Family

- 当前 contract family 只冻结以下 app-facing path：
  - `POST /api/app/bid/award`
  - `GET /api/app/bid/result?projectId={projectId}`

### 3.2 Server-facing Minimal Corresponding Family

- 当前允许冻结的最小 server-facing 对应 family 为：
  - `POST /server/bid/award`
  - `GET /server/bid/result?projectId={projectId}`
- 这里的正式含义是：
  - 若后续进入 backend truth / persistence freeze，
    只能围绕上述最小对应 family author
  - 不得把 `/server/*` 回写成第二套 app-facing 真源

### 3.3 Explicitly Excluded Path Family

- 当前必须明确禁止把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/board`
  - `GET /api/app/bid/compare`
  - `GET /api/app/bid/losers`

## 4. `POST /api/app/bid/award` Contract Freeze

- `POST /api/app/bid/award` 当前正式冻结为：
  - buyer 侧唯一合法 award command

### 4.1 Minimum Request

- 最小 request 至少包括：
  - `projectId`
  - `winningBidId`
  - `reasonCode`
  - `reasonText`

### 4.2 Minimum Accepted Response

- 最小 accepted response 至少包括：
  - `bidAwardId`
  - `projectId`
  - `winningBidId`
  - `orderId`
  - `contractId`
  - `state`

### 4.3 Hard Boundary

- 当前 command 不得扩到：
  - compare scoring matrix
  - seat lock
  - loser list editing console
  - payment / deposit fields
  - negotiation artifacts
- 当前必须明确：
  - `orderId` 与 `contractId` 在 accepted response 中只承担 continuation anchor
  - 不等于“合同已确认完成”
  - 不等于“完整交易已正式生效”

## 5. `GET /api/app/bid/result` Contract Freeze

- `GET /api/app/bid/result?projectId={projectId}` 当前正式冻结为：
  - supplier 当前 actor 私域读取的最小 result outlet

### 5.1 Minimum Query

- 最小 query 只包括：
  - `projectId`

### 5.2 Minimum Response Semantics

- 最小响应语义至少包括：
  - `bidId`
  - `projectId`
  - `state`
  - `result`
  - `reasonCode`
  - `reasonText`
  - `decidedAt`

### 5.3 Hard Boundary

- 当前最小 result outlet 不是：
  - buyer compare board
  - public project surface
  - full `my bids workspace`
  - supplier bid history

## 6. Order Conversion / Contract Seed Continuation Boundary

- 当前 contract 只冻结最小 continuation carrier：
  - `orderId`
  - `contractId`
  - `state`
- 当前正式冻结：
  - `Order.state = active`
    只允许解释为：
    - bridge compatibility state
  - `Contract.state = pending_confirm`
    才是后半链正式确认前态

### 6.1 Hard Boundary

- 当前不得把 `order.active` 写成：
  - 合同已确认完成
  - 完整交易已正式生效
  - 完整履约已正式启动
- 当前不得把 `contract seed` 延后为异步补种第二协议

## 7. Error / Unavailable Boundary

### 7.1 Controlled Error Family

- 当前对象允许并只允许冻结以下最小错误族：
  - `BID_AWARD_INVALID`
  - `BID_AWARD_INVALID_STATE`
  - `BID_AWARD_DUPLICATE`
  - `BID_AWARD_CONCURRENT_CONFLICT`
  - `BID_RESULT_INVALID`
  - `BID_RESULT_UNAVAILABLE`
  - `ORDER_CONVERSION_FAILED`
  - `CONTRACT_SEED_FAILED`

### 7.2 Controlled Meaning

- 当前错误必须保持：
  - fail-close
  - no partial success
  - no silent fallback to `/api/app/order/create`
- 当前 unavailable 只允许表达：
  - 当前 actor 不可见
  - 当前 project 不可 award
  - 当前 bid result 不可读
- 不允许把 unknown state / unknown error code 伪装成 success

## 8. Non-goals

- 当前 non-goals 明确如下：
  - `/api/app/order/create`
  - `seat`
  - `bid package completeness`
  - payment / split-billing / settlement
  - electronic signature
  - complex scoring / heavy risk control
  - full compare console
  - supplier `my bids workspace`
  - buyer-side loser management console

## 9. Stage Conclusion

- 当前阶段结论只允许写：
  - `Go for backend truth / persistence freeze authoring`
  - `No-Go for direct implementation`
  - `No-Go for backend real dispatch issuance`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum L4 BFF app-facing surface for exhibition bidding midstream platformization so later frontend authoring proceeds on a single BFF meaning for seat transport, completeness projection, buyer compare projection, and loser feedback projection without introducing a second state machine or any BFF-owned trade truth.
layer: L4 BFF
freeze_date_local: 2026-04-13
inputs_canonical:
  - docs/00_ssot/exhibition_bidding_midstream_platformization_minimum_closure_freeze.md
  - docs/01_contracts/exhibition_bidding_midstream_platformization_contract_freeze.md
  - docs/02_backend/exhibition_bidding_midstream_platformization_backend_truth_persistence_freeze.md
  - docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《展览竞标平台化中段 BFF surface freeze》

## 1. 目标

- 本轮只冻结：
  - `展览竞标平台化中段` 的最小 BFF app-facing surface
- 本轮只承接：
  - `seat`
  - `bid package completeness`
  - `buyer compare` 最小稳定消费面
  - `loser feedback` 最小稳定消费面
- 本轮不是：
  - frontend freeze
  - implementation
  - runtime ready
  - release ready

## 2. 当前真相

- 当前 `Server` 已被冻结为以下对象的唯一 truth owner：
  - `seat`
  - `bid package completeness`
  - `buyer compare`
  - `loser feedback`
- 当前 `BFF` 必须继续保持：
  - app-facing aggregation
  - normalize
  - visibility trim
  - response shaping
  - light idempotency
- 当前 `BFF` 不得被误写成：
  - `seat` truth owner
  - completeness truth owner
  - compare truth owner
  - loser feedback truth owner
- 当前必须明确：
  - completeness 在 backend 端是 derived projection，不是 BFF 发明的状态
  - compare 与 loser feedback 都是 `Server` 派生 read-model，不是 BFF 自建真相

## 3. BFF Boundary

- `BFF` 在本轮的唯一职责固定为：
  - app-facing -> server-facing transport
  - request normalization
  - response shaping
  - visibility trim
  - controlled error mapping
  - light idempotency
- `BFF` 明确不得：
  - 持有 `seat` truth
  - 持有 `bid package completeness` truth
  - 持有 `buyer compare` truth
  - 持有 `loser feedback` truth
  - 新开第二套业务状态机
  - 把 derived read-model 误写成 BFF own truth
  - 生成第二套 compare / feedback response family

## 4. Path Mapping Freeze

### 4.1 本轮进入的唯一合法 path mapping

- `POST /api/app/bid/seat/lock`
  - `POST /server/bid/seat/lock`
- `POST /api/app/bid/seat/release`
  - `POST /server/bid/seat/release`
- `GET /api/app/bid/seat/status?projectId={projectId}&bidId={bidId}`
  - `GET /server/bid/seat/status?projectId={projectId}&bidId={bidId}`
- `GET /api/app/bid/package-completeness?projectId={projectId}&bidId={bidId}`
  - `GET /server/bid/package-completeness?projectId={projectId}&bidId={bidId}`
- `GET /api/app/bid/compare?projectId={projectId}`
  - `GET /server/bid/compare?projectId={projectId}`
- `GET /api/app/bid/result?projectId={projectId}`
  - `GET /server/bid/result?projectId={projectId}`

### 4.2 本轮明确 No-Go 的 path

- 当前明确 `No-Go`：
  - `POST /api/app/bid/package-completeness`
  - `PATCH /api/app/bid/package-completeness`
  - `POST /api/app/bid/compare/*`
  - `POST /api/app/bid/loser-feedback/*`
  - `GET /api/app/bid/losers`
  - `GET /api/app/bid/compare/score`
  - `POST /api/app/bid/deposit/*`
  - `POST /api/app/payment/*`
  - `POST /api/app/esign/*`
- 本轮不新增第二套并行 path family。

## 5. Request Surface Freeze

## 5.1 `seat lock`

- 类型：
  - write path
- 客户端原样透传字段只允许：
  - `projectId`
  - `bidId`
- `BFF` 规范化补入字段只允许：
  - 标准 request trace / idempotency envelope
  - 不补业务字段
- 由 auth / session / context 注入的字段只允许：
  - current actor identity
  - current organization scope
- `BFF` 不允许补入：
  - payment / deposit 信息
  - compare score
  - buyer decision truth

## 5.2 `seat release`

- 类型：
  - write path
- 客户端原样透传字段只允许：
  - `projectId`
  - `bidId`
- `BFF` 规范化补入字段只允许：
  - 标准 request trace / idempotency envelope
- 由 auth / session / context 注入的字段只允许：
  - current actor identity
  - current organization scope

## 5.3 `bid package completeness submit / update`

- 当前正式裁决：
  - `No-Go`
- 本轮没有 app-facing submit / update surface。
- `BFF` 不得发明：
  - completeness submit command
  - completeness update command
  - completeness workspace mutation

## 5.4 `buyer compare read`

- 类型：
  - read path
- 客户端原样透传字段只允许：
  - `projectId`
- `BFF` 规范化补入字段只允许：
  - query normalization
  - stable pagination absence normalization
- 由 auth / session / context 注入的字段只允许：
  - buyer-side current actor
  - buyer-side organization scope

## 5.5 `loser feedback read`

- 类型：
  - read path
- 客户端原样透传字段只允许：
  - `projectId`
- `BFF` 规范化补入字段只允许：
  - query normalization
- 由 auth / session / context 注入的字段只允许：
  - supplier-side current actor
  - actor-visible bid scope

## 6. Response Shaping Freeze

## 6.1 `seat` 最小状态投影

- `BFF` 对外只允许稳定返回：
  - `seatId`
  - `projectId`
  - `bidId`
  - `state`
  - `expiresAt`
  - `releasedAt`
- 允许 trim：
  - 内部 lock metadata
  - server-internal audit / locking detail
- 必须保真：
  - `state`
  - `expiresAt`
  - `releasedAt`

## 6.2 `bid package completeness` 最小 projection

- `BFF` 对外只允许稳定返回：
  - `bidId`
  - `projectId`
  - `state`
  - `missingItems[]`
  - `quoteAmountReady`
  - `proposalSummaryReady`
- 允许 trim：
  - server 内部复算细节
  - 原始字段诊断信息
- 必须保真：
  - `state`
  - `missingItems[]`
  - readiness booleans

## 6.3 `buyer compare` 最小 projection

- `BFF` 对外只允许稳定返回：
  - `projectId`
  - `comparableBids[]`
- 每个 `comparableBid` 只允许：
  - `bidId`
  - `supplierOrganizationId`
  - `supplierDisplayName`
  - `quoteAmount`
  - `proposalSummaryPreview`
  - `packageCompletenessState`
  - `seatState`
  - `submittedAt`
- 允许 trim：
  - compare 诊断字段
  - server 内部派生原因细节
- 必须保真：
  - `quoteAmount`
  - `proposalSummaryPreview`
  - `packageCompletenessState`
  - `seatState`

## 6.4 `loser feedback` 最小 projection

- `BFF` 对外只允许稳定返回：
  - `bidId`
  - `projectId`
  - `state`
  - `result`
  - `reasonCode`
  - `reasonText`
  - `decidedAt`
- 允许 trim：
  - server 内部解释路径
  - award transaction 细节
- 必须保真：
  - `result`
  - `reasonCode`
  - `reasonText`
  - `decidedAt`

## 7. Visibility Trimming Freeze

- `buyer compare` 只对 buyer 侧开放。
- `loser feedback` 的可见性固定为：
  - winning bidder：
    - 不是本轮 loser feedback 消费对象
  - losing bidder：
    - 允许读取自己的最小结果与理由
  - public：
    - 不可见
- `seat` 与 completeness 的对外可见性固定为：
  - 只在 in-scope private bidding flow 内消费
  - 不进入 public board / public project detail
- `BFF` 可以做 visibility trim，但不得：
  - 改写 server truth
  - 本地判断谁是最终 winner / loser
  - 放大 compare 或 loser feedback 可见性

## 8. Error Mapping Freeze

### 8.1 `seat` 相关最小 app-facing 错误语义

- `BFF` 只允许对外稳定归一：
  - `BID_SEAT_INVALID`
  - `BID_SEAT_INVALID_STATE`
  - `BID_SEAT_CONFLICT`
  - `BID_SEAT_TIMEOUT`

### 8.2 completeness 相关最小错误语义

- `BFF` 只允许对外稳定归一：
  - `BID_PACKAGE_COMPLETENESS_INVALID`
  - `BID_PACKAGE_COMPLETENESS_UNAVAILABLE`

### 8.3 compare / feedback 最小错误语义

- `BFF` 只允许对外稳定归一：
  - `BID_COMPARE_INVALID`
  - `BID_COMPARE_UNAVAILABLE`
  - `BID_RESULT_INVALID`
  - `BID_RESULT_UNAVAILABLE`

### 8.4 错误归一边界

- 当前不得把平台治理错误族带进来。
- 当前不得暴露多余 truth 细节。
- 当前不得把：
  - unauthorized
  - invisible
  - unavailable
  伪装成 empty success。

## 9. Normalization Freeze

- `id` 规范化：
  - `projectId`
  - `bidId`
  - `seatId`
  只做最小 string normalization，不改业务含义
- `list` 规范化：
  - `comparableBids[]` 只保留 backend 已给定的最小稳定序
  - BFF 不自建 compare ranking
- `paging` 规则：
  - 本轮 compare / feedback 不新增 paging surface
- `sort` 规则：
  - 本轮 compare 不开放 sort query
  - BFF 不自建排序语义
- 枚举字段对外收口：
  - `seat.state` 只收口为：
    - `available`
    - `locked`
    - `released`
    - `timed_out`
  - completeness `state` 只收口为：
    - `complete`
    - `incomplete`
- timeout / stale seat / released seat 的 surface 表达：
  - stale locked seat 在 BFF 对外必须表现为 `timed_out`
  - 已释放 seat 必须表现为 `released`
  - 不得继续透出失效 locked 假象
- `BFF` 不得偷偷补业务真值。

## 10. Runtime Hard-gate Input

- `docs/00_ssot/runtime_release_stabilization_execution_checklist_dispatch_freeze.md`
  是本轮后续实现与联调的并行硬门禁输入。
- 这不是建议项。
- 后续 BFF 实现、smoke、联调、release-prep 都不得跳过该 checklist。

## 11. 合规与发布门禁

- 当前文书只允许进入：
  - `frontend consumption freeze authoring`
- 当前文书不允许进入：
  - direct implementation
  - integration
  - `release-prep`
  - production release
- 当前必须继续保持：
  - backend truth 未落地前，BFF 不得自行发明 compare / feedback truth
  - frontend 不得把 placeholder 页面写成 runtime 已通

## 12. No-Go 边界

- 不得让 `BFF` 持有 `seat` truth
- 不得让 `BFF` 持有 completeness truth
- 不得让 `BFF` 自己生成 compare truth
- 不得让 `BFF` 自己生成 loser feedback truth
- 不得顺手带入支付 / 保证金 / 评分引擎 / 治理台
- 不得把 compare 写成完整评分控制台
- 不得把 loser feedback 写成完整反馈系统
- 不得新增第二套 compare / feedback app-facing family

## 13. 下一步唯一动作

- 下一步唯一动作：
  - `输出《展览竞标平台化中段 frontend consumption freeze》`

## 14. 裁决

- `《展览竞标平台化中段 BFF surface freeze》是否可入库：是`

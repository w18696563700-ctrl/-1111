---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L3 backend truth ownership, canonical persistence carriers,
  write-set boundary, transaction and locking plan, state transitions, and
  fail-close rules for `BidAward bridge`, so later BFF/frontend freeze and any
  future dispatch authoring proceed on a single backend meaning for
  BidAward, loser disposition, order conversion, and synchronous contract seed.
layer: L3 Backend
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/00_ssot/bid_award_bridge_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/bid_award_bridge_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/bid_award_bridge_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/bid_award_bridge_package_level_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/bid_award_bridge_phase0_implementation_exception_independent_review_addendum.md
  - docs/01_contracts/bid_award_bridge_contract_freeze_addendum.md
  - docs/02_backend/db_schema.md
  - docs/02_backend/audit_log_spec.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
---

# 《BidAward bridge backend truth / persistence freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `BidAward bridge`
- 本冻结单只服务于：
  - `BidAward truth`
  - `loser disposition truth`
  - `BidAward -> Order conversion`
  - `synchronous contract seed`
  - `Project.state = awarded / converted_to_order`
  - 当前对象最小 backend write-set、transaction、locking、rollback 规则
- 本冻结单不进入：
  - `apps/server/**` 实现
  - BFF / frontend 文书
  - integration
  - release-prep
  - production release

## 2. Backend Freeze Conclusion

- 本轮 backend freeze 不是 `no-op`。
- 当前正式冻结：
  - `Server` 是 `BidAward bridge` 唯一 truth owner
  - `BidAward` 是唯一合法桥接真相对象
  - `loser disposition` 在首轮不引入独立 workspace family
  - `Order` 与 `Contract seed` 只承担 bridge downstream continuation
- 当前不得把以下对象混写成 bridge truth：
  - `Workbench`
  - `My Project`
  - `Showcase`
  - `Order`
  - `Contract`
- 当前不得借 backend 文书把以下范围偷偷并入：
  - `seat`
  - `bid package completeness`
  - `/api/app/order/create`
  - payment / split-billing / electronic signature
  - complex scoring / heavy risk control

## 3. Unique Truth Owner Freeze

- `Server` 是当前对象唯一 truth owner。
- `BFF` 不是 truth owner。
- Flutter 不是 truth owner。
- `Workbench` 不是 truth owner。
- `My Project` 不是 truth owner。
- `Order` 不是 award 真相 owner。
- `Contract` 不是 award 真相 owner。

### 3.1 Derived Projection Boundary

- `Workbench` 与 `My Project` 只允许承载：
  - summary
  - handoff
  - continuation projection
- 它们不得承载：
  - `BidAward` canonical truth
  - `loser disposition` canonical truth
  - `winner decision` canonical truth

## 4. Canonical Persistence Carrier Freeze

- 当前对象只允许冻结以下最小 canonical persistence family：
  - `projects`
  - `bids`
  - `bid_awards`
  - `orders`
  - `contracts`
  - `audit_logs`

### 4.1 Canonical Meaning

- `bid_awards`
  - 是 bridge 唯一 canonical truth carrier
  - 承载：
    - `bidAwardId`
    - `projectId`
    - `winningBidId`
    - `decisionOwnerOrgId`
    - `decisionActorUserId`
    - `reasonCode`
    - `reasonText`
    - `state`
    - `orderId`
    - `contractId`
    - `decidedAt`
- `bids`
  - 继续承载 bid canonical truth
  - 首轮允许最小扩充 loser disposition truth 字段，不单开新 persistence family
  - 当前 loser-side 最小 canonical truth 只允许包括：
    - `result`
    - `reasonCode`
    - `reasonText`
    - `decidedAt`
    - `bidAwardId`
- `orders`
  - 只承载 downstream continuation truth
  - `Order.state = active` 只允许解释为 bridge compatibility state
- `contracts`
  - 只承载 synchronous seed truth
  - `Contract.state = pending_confirm`

### 4.2 Explicitly Excluded Persistence Family

- 当前不得发明或带入：
  - `bid_seats`
  - `bid_packages`
  - `winner_decision_snapshots`
  - `loser_disposition_console_state`
  - `order_conversion_cache`
  - `contract_seed_queue`
  - `contract_versions`
  - `contract_confirmations`
  - `change_orders`
  - `ratings`
  - `disputes`
  - 任何 BFF / Flutter local snapshot table

## 5. First-round Minimum Write Set Freeze

### 5.1 Must-touch

- 首轮必改只允许包括：
  - `apps/server/src/modules/bid_award/**`
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/bid/**`

### 5.2 Conditional-touch

- 只有在 bridge fallout 无法自然承接时，才允许条件触达：
  - `apps/server/src/app.module.ts`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/audit/**`

### 5.3 Prohibited-touch

- 本轮明确禁止触达：
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/trading_shell_handoff/**`
  - `apps/server/src/modules/rating/**`
  - `apps/server/src/modules/dispute/**`
  - `apps/server/src/modules/inspection/**`
  - `apps/server/src/modules/organization/current-actor-eligibility.service.ts`
  - 任何 `/order/create` 旧入口实现族

## 6. Backend Internal Execution Order Freeze

- backend 内部唯一施工顺序正式写死如下：
  1. authorize current actor against `project.organizationId`
  2. lock target `project` row and in-scope submitted `bids`
  3. verify no effective `BidAward` already exists for the same `projectId`
  4. create `BidAward` row with `state = awarded`
  5. write loser disposition truth onto non-winning `bids`
  6. create downstream `Order`
  7. create synchronous `Contract seed`
  8. update `BidAward.state = converted_to_order`
  9. update `Project.state = converted_to_order`
  10. commit transaction
  11. derive `My Project` / `Workbench` fallout only after canonical truth commit

## 7. Transaction / Locking / Idempotency Freeze

### 7.1 Single-winner Rule

- 一个 `projectId` 最多只允许一个 effective `BidAward`。
- 一个 `BidAward` 最多只允许生成一个 `Order`。
- 一个 `Order` 最多只允许生成一个 synchronous `Contract seed`。

### 7.2 Concurrency Rule

- 同一 `projectId` 的 award command 必须在 `Server` truth transaction 内裁决。
- 当前正式冻结：
  - 并发 award 不允许双赢
  - first committer wins
  - later conflicting request fail-close 为：
    - `BID_AWARD_CONCURRENT_CONFLICT`

### 7.3 Duplicate Rule

- 同一 `projectId` 一旦已有 effective `BidAward`，
  重复 award 必须 fail-close 为：
  - `BID_AWARD_DUPLICATE`

### 7.4 Atomicity Rule

- `BidAward -> loser disposition -> Order -> Contract seed -> Project.state`
  必须同事务完成。
- 当前不得拆成：
  - 先 award 再异步 create order
  - 先 create order 再补种 contract
  - 先 project converted 再补 award result

### 7.5 Partial Failure Rule

- 任一步失败，整体业务 mutation 必须回滚。
- 当前只允许保留：
  - append-only failure audit attempt
- 当前不允许留下：
  - 已存在 `Order` 但无 `Contract seed`
  - 已存在 `BidAward` 但 loser disposition 未落库
  - `Project.state = converted_to_order` 但无 downstream carrier

## 8. State Transition Freeze

### 8.1 Project State

- 当前桥接对象只允许：
  - `published -> awarded -> converted_to_order`
- 当前必须明确：
  - `awarded` 是 bridge canonical intermediate state
  - 首轮不要求投影层把 `awarded` 做成稳定消费面
  - `converted_to_order` 才是首轮 downstream continuation 稳定状态

### 8.2 BidAward State

- 当前只允许：
  - `awarded -> converted_to_order`

### 8.3 Bid Result State

- 当前只允许最小结果语义：
  - winning bid => `awarded`
  - losing bid => `lost`
- 当前 loser disposition 不是 compare workspace。
- 当前不得再引入：
  - `shortlisted`
  - `negotiating`
  - `countered`

### 8.4 Downstream Continuation State

- `Order.state = active`
  - 只允许解释为 bridge compatibility state
  - 不得被下游解释为：
    - 合同已确认完成
    - 完整履约已正式启动
- `Contract.state = pending_confirm`
  - 是后半链正式确认前态

## 9. Permission Boundary Freeze

- award 发起权限只允许：
  - `project.organizationId` 内 buyer-side authorized actor
- 当前不得把 award 权限回写进：
  - `current-actor-eligibility.service.ts` 的发布资格体系
- 当前 bridge 权限必须作为 package-local truth rule author，
  不得污染 project publish eligibility。

## 10. Error Family / Fail-close Freeze

- backend 只允许冻结以下对象级错误族：
  - `BID_AWARD_INVALID`
  - `BID_AWARD_INVALID_STATE`
  - `BID_AWARD_DUPLICATE`
  - `BID_AWARD_CONCURRENT_CONFLICT`
  - `BID_RESULT_INVALID`
  - `BID_RESULT_UNAVAILABLE`
  - `ORDER_CONVERSION_FAILED`
  - `CONTRACT_SEED_FAILED`

### 10.1 Controlled Meaning

- `BID_AWARD_INVALID`
  - request/body/anchor invalid
- `BID_AWARD_INVALID_STATE`
  - project/bid 当前状态不允许 award
- `BID_AWARD_DUPLICATE`
  - same project already awarded or converted
- `BID_AWARD_CONCURRENT_CONFLICT`
  - concurrent loser request
- `ORDER_CONVERSION_FAILED`
  - award 已进入事务，但 order create step fail-close
- `CONTRACT_SEED_FAILED`
  - order create succeeded in-transaction but contract seed step fail-close, overall rolled back

### 10.2 Hard Boundary

- 当前不得：
  - silent fallback to `/api/app/order/create`
  - partial success
  - UI wording 冒充 truth success

## 11. Minimum Test Plan Freeze

### 11.1 P0 Must-pass Bridge Mainline

- `BidAward` success mainline
- loser disposition 同事务落库
- `GET /server/bid/result` 中标/落选最小可读
- duplicate award fail-close
- concurrent award single-winner
- `Order + Contract seed + Project.state` 原子闭合
- failure rollback without dirty downstream carriers

### 11.2 P1 Non-regression Smoke

- `project publish/showcase` 不回退
- `bid submit` 不回退
- `My Project` buyer-side fallout refresh 不回退
- `Workbench` buyer-side fallout refresh 不回退
- `E1-E5` 已通过 continuation surfaces 不回退

## 12. Stage Completion Marker

- 当前 backend truth / persistence freeze 完成标志只包括：
  - canonical persistence family single-sourced
  - must-touch / conditional-touch / prohibited-touch 收死
  - backend internal execution order 收死
  - concurrency / duplicate / atomic rollback 收死
  - `Project.state`、`BidAward.state`、`Order.state`、`Contract.state` 语义边界收死
  - `P0 / P1` 测试层级收死

## 13. Non-goals

- 当前明确不做：
  - BFF dispatch
  - frontend dispatch
  - `seat`
  - `bid package completeness`
  - payment / split-billing / settlement
  - electronic signature
  - complex scoring / heavy risk control
  - supplier `my bids workspace`
  - buyer compare console
  - full loser management console

## 14. Stage Conclusion

- 当前阶段结论只允许写：
  - `Go for BFF surface freeze authoring`
  - `No-Go for backend real dispatch issuance`
  - `No-Go for implementation unlock`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`

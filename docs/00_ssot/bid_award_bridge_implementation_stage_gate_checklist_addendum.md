---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the implementation-stage gate for `BidAward bridge`, deciding only
  whether bounded implementation-dispatch bundle authoring may begin while
  direct implementation, implementation unlock, real dispatch issuance,
  integration, release-prep, and production release remain blocked until the
  bridge's concurrency/idempotency/atomicity rules, `Order.state = active`
  semantic boundary, loser-disposition read outlet, and freeze-status
  consistency are all hardened.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/domain_model.md
  - docs/00_ssot/lifecycle_state_machine.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/exhibition_showcase_bid_flow_v11_upgrade_addendum.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
---

# 《BidAward bridge implementation stage gate checklist》

## 1. Scope

- 本门禁核查表只服务于：
  - `BidAward bridge`
  - bounded implementation-dispatch bundle authoring
- 本门禁核查表只回答：
  - 哪些门禁已通过
  - 哪些门禁未通过
  - 哪些是一票否决
  - 当前是否允许进入下一阶段
- 本门禁核查表不等于：
  - direct implementation
  - implementation unlock
  - real implementation dispatch issuance
  - integration pass
  - `release-prep` pass
  - production release pass

## 2. Passed Gates

- 真源连续性门禁：
  - 通过
  - `BidAward` 业务桥接蓝图已经冻结，当前桥接对象、桥接边界、`bid -> order -> contract seed` 主判断已有正式上游真源。
- 桥接对象唯一命名门禁：
  - 通过
  - 当前唯一合法桥接对象已经固定为：
    - `BidAward`
  - 不再允许在实现阶段把：
    - `Award`
    - `WinnerDecision`
    - `Order`
    混写成同一 truth carrier。
- 投影层不冒充真相层门禁：
  - 通过
  - `Workbench / My Project / Showcase` 继续只作为投影与入口层，不允许升格成 `BidAward`、`Order conversion` 或 loser disposition 的真相 owner。
- publish 前门禁 / 公域前门禁保留挂点门禁：
  - 通过
  - 当前已明确保留：
    - `ProjectPublishPrecheckHook`
    - `ProjectPublicVisibilityGate`
  - 桥接层实现不得反向焊死这两个上游治理挂点。
- 文书冻结口径一致性门禁：
  - 通过
  - 当前 `freeze addendum` 已统一为：
    - `status: frozen`
  - 当前不得继续把 freeze 文书写成 `active`。
- 阶段控制门禁：
  - 通过
  - 当前阶段仍然只允许进入：
    - bounded implementation-dispatch bundle authoring
  - 不允许越级进入真实实现或 runtime 操作。

## 3. Failed Gates

- direct implementation gate：
  - 未通过
  - root `AGENTS.md` 仍明确：
    - `No trading flow implementation`
- implementation unlock gate：
  - 未通过
  - 当前还没有该桥接对象的 formal implementation unlock / legality grant。
- real implementation dispatch issuance gate：
  - 未通过
  - 当前还没有《BidAward bridge bounded implementation dispatch bundle》。
- integration gate：
  - 未通过
  - 当前没有 bridge runtime 集成结论。
- `release-prep` gate：
  - 未通过
- production release gate：
  - 未通过

## 4. Veto Gates

- 若在实现阶段把 `BidAward` 再塞回 `Order`，直接 veto。
- 若把 `Order.state = active` 解释成：
  - 合同已确认完成
  - 完整交易已正式生效
  - 完整履约已正式启动
  直接 veto。
- 若 `BidAward -> Order -> Contract seed` 不能保证单项目唯一、并发单胜、部分失败不留脏数据，直接 veto。
- 若 loser disposition 只留在 truth 层、没有最小消费出口，直接 veto。
- 若实现阶段顺手扩到以下任一对象，直接 veto：
  - `seat`
  - `bid package completeness`
  - payment / deposit / billing / settlement
  - electronic signature
  - complex scoring
  - heavy risk control
  - full bid workspace
  - full compare console
- 若在《BidAward bridge bounded implementation dispatch bundle》冻结前就向 agent 发真实实现口令，直接 veto。

## 5. Hard Supplements Frozen By This Checklist

### 5.1 `Order.state = active` 的阶段性语义边界

- 当前桥接蓝图里：
  - `Order.state = active`
    只允许解释为：
    - post-award bridge compatibility state
    - 让既有 `contract/detail -> contract seed -> contract confirm/amend -> milestone/inspection` continuation 不被打断
- 当前明确不得解释为：
  - 合同已经确认完成
  - 交易双方已完成正式签约
  - 完整履约已经正式启动
- 当前正式交易确认起点仍然是：
  - `contract.state = active`
- 因此实现阶段必须写死：
  - 下游所有 consumer / presenter / page-state / copy
    都不得把 `order.active` 渲染成“已签约完成”或“已履约启动”。

### 5.2 `BidAward -> Order -> Contract seed` 并发 / 幂等 / 原子性规则

- 单项目唯一规则：
  - 一个 `Project` 最多只允许一个有效 `BidAward`。
  - 一个有效 `BidAward` 最多只允许生成一个 `Order`。
- 重复定标规则：
  - 若同一 `Project` 已经存在有效 `BidAward`，
    再次 award 不得生成第二个 `BidAward`。
  - 若重试请求与已成功请求完全同义，
    只允许返回已存在结果或稳定 conflict / invalid-state 业务错误，
    不得重复落单。
- 并发定标规则：
  - 同一 `Project` 上的并发 award 必须由 `Server` 侧串行化裁决。
  - 最终只能有一个请求成功提交；
    其余请求必须稳定失败，
    不得出现“双中标 / 双订单 / 双合同种子”。
- 原子提交规则：
  - 以下动作必须处于同一真值事务内：
    1. create `BidAward`
    2. persist loser disposition
    3. create `Order`
    4. create `Contract seed`
    5. update `BidAward.state = converted_to_order`
    6. update `Project.state = converted_to_order`
- 部分失败处理规则：
  - 如果上面任一步失败，
    整个桥接事务必须 fail-close 并整体回滚。
  - 不允许留下：
    - 已创建 `Order` 但没有 `Contract seed`
    - 已写 `BidAward` 但没有 loser disposition
    - `Project.state = converted_to_order`
      但 `Order` 不存在
  - 唯一允许保留的是 append-only 审计 attempt；
    不允许保留半完成业务真值。

### 5.3 loser disposition 的最小消费出口

- 当前必须明确：
  - loser disposition 不能只存在于 `BidAward` truth 内部。
  - 当前阶段必须固定一个最小 app-facing 读出口。
- 当前唯一冻结的最小消费出口是：
  - `GET /api/app/bid/result?projectId={projectId}`
- 该出口的正式语义是：
  - supplier 当前 actor 私域读取
  - 只返回“当前 actor 针对该项目的最小 bid 结果”
  - 不是 buyer compare board
  - 不是 full `my bids workspace`
  - 不是 public project surface
- 当前最小返回责任只允许承接：
  - `bidId`
  - `projectId`
  - `state`
  - `result = submitted | won | lost`
  - `reasonCode`
  - `reasonText`
  - `decidedAt`
- 当前最小消费目标只允许是：
  - 让未中标方有稳定读取“为什么没中”的出口
  - 让已中标方有稳定读取“已中标”结果的最小出口
- 当前明确暂不开：
  - `GET /api/app/my/bids`
  - bid compare board
  - bid history workspace
  - buyer-side loser management console

### 5.4 文书状态与冻结口径一致性

- 只要文书标题与 purpose 已明确属于：
  - `freeze`
  - `freeze addendum`
  - `stage gate checklist`
  当前 status 默认必须写：
  - `frozen`
- 当前不接受：
  - freeze 文书继续标 `active`
  - gate checklist 继续标 `draft`
    但正文已经开始承担正式门禁裁决
- 当前这一条已经通过收正：
  - `docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md`

## 6. Dispatch Boundary

- 若下一步进入《BidAward bridge bounded implementation dispatch bundle》authoring，
  当前只允许围绕：
  - `BidAward` truth
  - loser disposition truth
  - `GET /api/app/bid/result`
    最小结果出口
  - `BidAward -> Order conversion`
  - synchronous `contract seed`
  - `Project.state = awarded / converted_to_order`
    的最小真值迁移
  - `my-project / workbench`
    的最小 fallout refresh
- 当前 bounded bundle authoring 可触及目录只允许写死为：
  - `docs/01_contracts/openapi.yaml`
  - `packages/contracts/src/generated/app-api.types.ts`
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/bid/**`
  - `apps/server/src/modules/order/**`
  - `apps/server/src/modules/contract/**`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/bff/src/routes/bid/**`
  - `apps/bff/src/routes/order/**`
  - `apps/bff/src/routes/contract/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/data/**`
    中与上述 bridge fallout 直接相关的最小 consumer touch
- 当前不得放开：
  - `seat lock`
  - `bid package completeness workspace`
  - payment / settlement / split-billing
  - electronic signature
  - complex score / review system
  - full buyer compare console
  - full supplier bid workspace
  - `enterprise_hub`
  - `workbench` 重设计

## 7. Stage Go / No-Go

- 当前阶段结论：
  - `Go` for bounded implementation-dispatch bundle authoring
  - `No-Go` for direct implementation
  - `No-Go` for implementation unlock
  - `No-Go` for real implementation dispatch issuance
  - `No-Go` for integration
  - `No-Go` for `release-prep`
  - `No-Go` for production release

## 8. Current Meaning

- 当前允许含义：
  - 总控现在可以 author：
    - 《BidAward bridge bounded implementation dispatch bundle》
  - 并把 backend-first、BFF-second、frontend-last 的 bounded 口令对象写清楚
- 当前不允许含义：
  - 不允许直接开工
  - 不允许直接下 backend / BFF / frontend 实施口令
  - 不允许把 `BidAward bridge blueprint` 误写成已实现
  - 不允许把 `order.active` 误写成“合同已确认完成”
  - 不允许把 loser disposition 误写成“以后再想怎么读”

## 9. Final Stage Ruling

- 当前桥接对象 implementation-stage gate 结论为：
  - `通过`
- 当前通过的唯一含义：
  - `Go for BidAward bridge bounded implementation-dispatch bundle authoring`
- 当前必须继续保留：
  - `No-Go for direct implementation`
  - `No-Go for implementation unlock`
  - `No-Go for real implementation dispatch issuance`
  - `No-Go for integration / release-prep / production release`

## 10. Next Unique Action

- 下一步唯一动作固定为：
  - 输出《BidAward bridge bounded implementation dispatch bundle》
  - 只围绕：
    - `BidAward`
    - loser disposition
    - `GET /api/app/bid/result`
    - `order conversion`
    - synchronous `contract seed`
  - 不得顺手扩到：
    - `seat`
    - `bid package completeness`
    - 支付 / 分账 / 电子签
    - 复杂评分 / 复杂风控

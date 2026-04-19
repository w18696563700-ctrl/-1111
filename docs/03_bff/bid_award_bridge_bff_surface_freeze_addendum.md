---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L4 BFF app-facing surface for `BidAward bridge`, including the
  unique external path family, minimum request/response shaping, actor-scope
  trimming, loser-result read outlet, fallout refresh projection boundary, and
  fail-close error normalization, while explicitly forbidding BFF from owning
  award truth, duplicate state derivation, or any second trade-state machine.
layer: L4 BFF
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
  - docs/02_backend/bid_award_bridge_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/bff_ssot.md
  - docs/03_bff/bff_routes.md
---

# 《BidAward bridge BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `BidAward bridge`
- 本冻结单只服务于：
  - 当前对象 app-facing transport / shaping
  - 当前对象 command / read outlet 的最小 BFF 暴露边界
  - 当前对象 auth consolidation / actor-scope trimming
  - 当前对象 loser result outlet 的最小消费出口
  - 当前对象 fallout refresh 的最小投影承接边界
  - 当前对象 controlled invalid / unavailable / conflict 的统一错误归一
- 本冻结单不进入：
  - frontend 文书
  - `apps/bff/**` 实现
  - integration
  - release-prep
  - production release

## 2. BFF Freeze Conclusion

- 本轮 BFF freeze 不是 `no-op`。
- 当前正式冻结：
  - `/api/app/*` 是唯一对外 authoritative path family
  - `BFF` 只做 app-facing 表层，不拥有 `BidAward` 真相
  - `BFF` 不得把 `Order` / `Contract` continuation 重新包装成 award 真相
  - `GET /api/app/bid/result?projectId={projectId}` 是当前 loser disposition 的最小消费出口
- 当前必须明确：
  - repo 中 `apps/bff/src/**` 还没有 `BidAward bridge` 现成 source 命中
  - 本轮冻结只定义下游 authoring 边界
  - 不得被误读为当前 runtime 已闭环

## 3. BFF 角色总边界

`BFF` 在当前对象中的唯一职责是：

- app-facing path 暴露
- command / query 透传
- actor / session / organization scope 承接
- 最小响应整形
- 统一 envelope
- controlled error normalization
- fallout refresh surface 透传

`BFF` 当前明确不得：

- 自建 `BidAward` 第二真相
- 自建第二交易状态机
- 自建 “是否可定标 / 是否已转单 / 是否已种合同” 本地判断
- 把 `My Project` 或 `Workbench` 投影层写回成 award 真相
- 把 `/server/*` 暴露成第二套对外协议

## 4. 对外唯一路径族冻结

### 4.1 唯一对外路径

- 当前只允许冻结以下 app-facing path：
  - `POST /api/app/bid/award`
  - `GET /api/app/bid/result?projectId={projectId}`

### 4.2 内部对应路径

- 当前只允许最小对应的 server-facing family：
  - `POST /server/bid/award`
  - `GET /server/bid/result?projectId={projectId}`

### 4.3 硬边界

- `/server/*` 只允许作为：
  - `BFF -> Server` 内部 transport 对应位
- `/server/*` 不得被回写成：
  - 第二套 app-facing 真源
  - 第二套公开接口文档

### 4.4 明确排除

- 当前不得把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/board`
  - `GET /api/app/bid/compare`
  - `GET /api/app/bid/losers`

## 5. `POST /api/app/bid/award` BFF 表层冻结

- 当前 `POST /api/app/bid/award` 只承担：
  - buyer 私域 command surface

### 5.1 最小请求整形

- `BFF` 只允许透传和校验最小字段：
  - `projectId`
  - `winningBidId`
  - `reasonCode`
  - `reasonText`

### 5.2 最小成功响应整形

- `BFF` 只允许稳定回传：
  - `bidAwardId`
  - `projectId`
  - `winningBidId`
  - `orderId`
  - `contractId`
  - `state`

### 5.3 硬边界

- `BFF` 不得：
  - 补本地 compare 结果
  - 补本地 loser list
  - 本地生成 `orderId`
  - 本地决定是否应创建 `Order`
  - 本地决定是否应种 `Contract seed`
  - fallback 到 `/api/app/order/create`

## 6. `GET /api/app/bid/result` BFF 表层冻结

- 当前 `GET /api/app/bid/result?projectId={projectId}` 只承担：
  - supplier 私域最小 result outlet

### 6.1 最小 query

- `BFF` 只允许 query：
  - `projectId`

### 6.2 最小响应整形

- `BFF` 只允许稳定整形以下字段：
  - `bidId`
  - `projectId`
  - `state`
  - `result`
  - `reasonCode`
  - `reasonText`
  - `decidedAt`

### 6.3 可见性边界

- `BFF` 只允许读取：
  - 当前 actor 自己的 bid result
- 当前不得把 result outlet 扩成：
  - buyer compare board
  - public surface
  - full supplier `my bids workspace`

## 7. 身份与可见性裁剪冻结

### 7.1 Award command

- `POST /api/app/bid/award` 当前只允许：
  - buyer-side private auth
  - `project.organizationId` 内合法 actor

### 7.2 Result read

- `GET /api/app/bid/result` 当前只允许：
  - supplier-side private auth
  - 当前 actor 自己可见的 result

### 7.3 硬边界

- `BFF` 不得：
  - 代替 `Server` 完成最终权限裁决
  - 本地猜测“谁是 winner / loser”
  - 将 unauthorized 偷转换成 success

## 8. Fallout Refresh 表层边界

- award 成功后的 fallout refresh 当前只允许承接：
  - buyer 侧 `My Project`
  - buyer 侧 `Workbench`

### 8.1 最小表层职责

- `BFF` 只允许做：
  - continuation anchor 透传
  - downstream projection refresh 所需最小字段整形

### 8.2 硬边界

- `BFF` 不得把以下投影升级成真相：
  - `privateProgress.orderStatus`
  - `privateProgress.contractStatus`
  - `workbench.project_chain`
  - `workbench.order_chain`

## 9. 错误归一冻结

- 当前对象只允许冻结以下最小错误族：
  - `BID_AWARD_INVALID`
  - `BID_AWARD_INVALID_STATE`
  - `BID_AWARD_DUPLICATE`
  - `BID_AWARD_CONCURRENT_CONFLICT`
  - `BID_RESULT_INVALID`
  - `BID_RESULT_UNAVAILABLE`
  - `ORDER_CONVERSION_FAILED`
  - `CONTRACT_SEED_FAILED`

### 9.1 允许的归一动作

- `BFF` 只允许：
  - 剥离上游技术细节
  - 保持稳定的：
    - `code`
    - `message`
    - `source`

### 9.2 禁止动作

- `BFF` 不得：
  - 自造新的业务错误码
  - 把上游并发冲突改写成模糊失败
  - 把 unavailable 伪装成 empty success
  - 把 invalid-state 伪装成前端可重试成功

## 10. 最小 authoring 触达范围冻结

### 10.1 必改 authoring 目标

- 首轮 BFF authoring 只允许围绕：
  - `apps/bff/src/routes/bid_award/**`
  - `apps/bff/src/routes/routes.module.ts`

### 10.2 条件触达

- 只有在 fallout refresh 无法自然承接时，才允许条件触达：
  - `apps/bff/src/routes/my_project/**`
  - `apps/bff/src/routes/exhibition_workbench/**`

### 10.3 禁止触达

- 当前明确禁止触达：
  - `apps/bff/src/routes/trading_read_corridor/**`
  - `apps/bff/src/routes/trading_shell_handoff/**`
  - `apps/bff/src/routes/rating/**`
  - `apps/bff/src/routes/dispute/**`
  - `apps/bff/src/routes/inspection/**`
  - 任何 `/order/create` 旧入口族

## 11. 非目标

- 当前明确不做：
  - BFF real dispatch
  - frontend dispatch
  - `seat`
  - `bid package completeness`
  - compare console
  - supplier `my bids workspace`
  - payment / split-billing / electronic signature
  - complex scoring / heavy risk control

## 12. 阶段结论

- 当前阶段结论只允许写：
  - `Go for frontend consumption freeze authoring`
  - `No-Go for BFF real dispatch issuance`
  - `No-Go for implementation unlock`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`

---
owner: Codex 总控
status: frozen
purpose: >
  Conclude the package-scoped result verification for the cloud
  backend-first bounded implementation of `BidAward bridge`, decide whether
  the backend package itself is accepted, and decide whether the next stage
  may move into `BFF bounded implementation`.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - docs/00_ssot/bid_award_bridge_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/bid_award_bridge_backend_package_scoped_validation_baseline_ruling_addendum.md
  - docs/00_ssot/bid_award_bridge_bff_surface_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - cloud workspace `/srv/workspaces/exhibition-infra-monorepo/apps/server`
---

# 《BidAward bridge backend implementation result verification conclusion》

## 1. 结论摘要

- 当前对象：
  - `BidAward bridge`
- 当前阶段：
  - `backend implementation result verification`
- 本轮结论：
  - `backend-first bounded implementation` 在包级验收基线下基本完成
  - `backend package acceptance = 有条件通过`
  - `Go for backend implementation result verification = 已完成`
  - `No-Go for direct BFF bounded implementation = 维持`

## 2. 本轮核查范围

- 只核后端已放开范围：
  - `BidAward truth`
  - loser disposition truth
  - `POST /server/bid/award`
  - `GET /server/bid/result?projectId={projectId}`
  - `BidAward -> Order conversion`
  - synchronous `contract seed`
  - `Project.state = awarded / converted_to_order`
- 不核：
  - `BFF implementation`
  - `frontend implementation`
  - integration / release-prep / production release

## 3. 五个重点核查点

### 3.1 `Order.totalAmount` 两位小数改动是否构成兼容性风险

- 结论：
  - `不构成当前包级 veto blocker`
- 理由：
  1. `Order.totalAmount` 已从整数提升为 `numeric(12,2)`，避免桥接时把 `winningBid.quoteAmount` 截断成整数。
  2. 现有读走廊本来就按 `number | string | null` 承接金额，不要求整数语义。
  3. 迁移里已补 `ALTER TABLE orders ... USING total_amount::numeric(12,2)`，旧整数数据会被安全上抬为两位小数。
- 保留风险：
  - 历史非目标模块若私下假定整数金额，后续仍可能有仓内老代码漂移；但这不属于当前写集，不构成本包 veto。

### 3.2 `app.module.ts / migrations.ts` 是否属于本轮最小必要触达

- 结论：
  - `属于本轮最小必要触达`
- 理由：
  1. 不触达 `app.module.ts`，`BidAwardModule` 不会注册，`/server/bid/award` 与 `/server/bid/result` 无法成立。
  2. 不触达 `migrations.ts`，`bid_awards`、`orders`、`contracts` 以及 bid loser disposition 列无法保证在云端真值层存在。
  3. 这两处虽然触达跨模块入口，但仍然只服务本包最小 truth 落位，不属于越界扩面。

### 3.3 `my-project / workbench` fallout 是否有真实消费证据，而不只是测试名成立

- 结论：
  - `有真实消费证据`
- 证据：
  1. `my_project` 真实消费链存在：
     - `MyProjectQueryService.loadPrivateProgressByProjectId()` 会查询最新 `orders / contracts / milestones / disputes / ratings` 并派生 `privateProgress`
     - 这意味着 `BidAward -> Order -> Contract seed` 会真实进入 buyer 侧私域投影
  2. `workbench` 真实消费链存在：
     - `ExhibitionWorkbenchQueryService.getSummary()` 会查询 `activeOrder`、最新合同、里程碑、验收、争议、评价
     - `ExhibitionWorkbenchPresenter` 已把这些真值投影到 `order_chain / extension_boundary`
  3. 本轮 `P0` 测试只是证明这些真实查询链在 bridge 落地后能对齐，不是凭测试名“伪造消费”。

### 3.4 `/server/*` 当前实现与未来 `/api/app/*` 冻结口径之间是否新增 drift

- 结论：
  - `存在新增 drift`
  - `这是当前阻断 BFF 放行的首要 blocker`
- 证据：
  1. 本轮已落的是：
     - `POST /server/bid/award`
     - `GET /server/bid/result?projectId={projectId}`
  2. 当前对外冻结口径仍是：
     - `POST /api/app/bid/award`
     - `GET /api/app/bid/result?projectId={projectId}`
  3. 当前 `docs/01_contracts/openapi.yaml` 中还没有这两条 app-facing path。
- 影响：
  - 后端内部桥接真值已经成形
  - 但 app-facing contract 尚未闭合
  - 所以当前不能放行 `BFF bounded implementation`

### 3.5 package-scoped validation baseline 是否已足够支撑本包独立验收

- 结论：
  - `足够支撑 backend 包级独立验收`
- 理由：
  1. 当前全仓 `apps/server npm run build` 的失败主要来自 forum、content_safety、旧 order/project 服务等历史红项。
  2. 这些红项不在本包写集内，也不属于本包目标路径。
  3. 本轮已通过：
     - 本包目标写集类型检查
     - `P0 bridge mainline`
     - `P1 non-regression smoke`
  4. 所以对当前阶段而言，package-scoped baseline 已足够支撑“后端包内验收”，但不足以直接放行下一层 app-facing 开发。

## 4. 实施结果判断

### 4.1 实现结果

- `BidAward truth`：已落位
- loser disposition truth：已落位
- `POST /server/bid/award`：已落位
- `GET /server/bid/result`：已落位
- `BidAward -> Order -> Contract seed -> Project.state` 同事务：已落位
- duplicate fail-close / concurrent single-winner / rollback：已落位
- buyer 侧 `my-project / workbench` 最小 fallout refresh：已落位

### 4.2 包级验收结果

- `backend package acceptance = 有条件通过`
- 条件通过的含义：
  - 后端窄口实现已达到本轮包级基线
  - 但当前不能把它误读为：
    - `BFF` 已可开工
    - `/api/app/*` 已闭合
    - integration / release 已可推进

## 5. 阻断项与非阻断风险

### 5.1 当前 blocker

1. `app-facing contract drift`
   - `openapi.yaml` 尚未收进：
     - `POST /api/app/bid/award`
     - `GET /api/app/bid/result?projectId={projectId}`
2. `server 路径与 app 路径尚未完成桥接闭合`
   - 当前只有 `server/*` 实现
   - 尚未形成 `BFF` 可消费的正式 app-facing contract 基线

### 5.2 当前非阻断风险

1. `Order.totalAmount` 精度提升会让历史整数语义进一步退出舞台
   - 这是正确方向
   - 但仓内老服务若仍偷假定整数，后续可能暴露历史漂移
2. `apps/server` 全仓 build 仍然不绿
   - 这不阻断本包
   - 但会继续影响任何试图把全仓 build 当唯一准入条件的后续阶段

## 6. 最终裁决

- `implementation_result`：
  - `backend-first bounded implementation = 基本完成`
- `acceptance_result`：
  - `backend package acceptance = 有条件通过`
- `go_or_no_go_for_bff_bounded_implementation`：
  - `No-Go`
- 原因：
  - 当前真正没过的不是后端真值实现
  - 而是 `server/* -> /api/app/*` 的 contract 闭合还没完成

## 7. 下一步唯一动作

- 进入：
  - `BidAward bridge app-facing contract closure`
- 目标只允许是：
  - 收口 `POST /api/app/bid/award`
  - 收口 `GET /api/app/bid/result?projectId={projectId}`
  - 消除 `server/*` 与 `/api/app/*` 的 authoritative drift
- 在这个动作完成前：
  - `No-Go for BFF bounded implementation`


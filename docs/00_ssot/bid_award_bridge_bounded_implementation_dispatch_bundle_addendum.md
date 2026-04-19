---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded implementation-dispatch bundle for `BidAward bridge` so
  later execution authoring stays inside the already-frozen bridge blueprint
  and stage-gate ruling, with a single backend-first sequence, first-round
  minimal write set, minimal regression checklist, object-pollution red lines,
  and explicit stage completion markers, while direct implementation,
  implementation unlock, real dispatch issuance, integration, release-prep,
  and production release remain blocked.
layer: L0 SSOT
freeze_date_local: 2026-04-12
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/domain_model.md
  - docs/00_ssot/lifecycle_state_machine.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/bid_award_order_conversion_contract_seed_bridge_blueprint_freeze_addendum.md
  - docs/00_ssot/bid_award_bridge_implementation_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/exhibition_showcase_bid_flow_v11_upgrade_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《BidAward bridge bounded implementation dispatch bundle》

## 1. Scope

- 本派工包只适用于：
  - `BidAward bridge`
- 本派工包只冻结：
  - 当前实现轮唯一目标
  - 当前执行顺序
  - 当前首轮最小写集
  - 当前首轮最小回归清单
  - 当前对象污染红线
  - 当前阶段完成标志
- 本派工包不代表：
  - implementation execution 已开始
  - implementation unlock 已通过
  - backend / BFF / frontend 真实 dispatch prompt 已发出
  - integration 通过
  - `release-prep` 通过
  - production release

## 2. Round Unique Goal

- 当前实现轮唯一目标是：
  - 把 `BidAward -> loser disposition -> Order conversion -> synchronous contract seed`
    收成最小可治理桥接链
- 当前轮唯一必须可见的最小 surface 是：
  - buyer 侧：
    - `POST /api/app/bid/award`
  - supplier 侧：
    - `GET /api/app/bid/result?projectId={projectId}`
- 当前轮唯一必须成立的最小真值变化是：
  - `BidAward` 创建
  - loser disposition 留痕
  - `Order` 由 `BidAward` 唯一生成
  - `Contract seed` 在同事务内生成
  - `Project.state: published -> awarded -> converted_to_order`
- 当前轮不允许：
  - 回退到 `POST /api/app/order/create`
  - 把 `Order` 写成 award truth
  - 把 loser reason 挂进 `Order`
  - 顺手打开 `seat`
  - 顺手打开 `bid package completeness`
  - 顺手打开 payment / split-billing / electronic signature
  - 顺手打开 full compare console / full supplier bid workspace

## 3. Frozen Command and Read Surfaces

### 3.1 Command surface

- 当前轮唯一冻结的 award command 是：
  - `POST /api/app/bid/award`
- 当前 command body 最小责任只允许承接：
  - `projectId`
  - `winningBidId`
  - `reasonCode`
  - `reasonText`
- 当前 command 不允许承接：
  - compare scoring matrix
  - multi-round negotiation artifacts
  - payment / deposit fields
  - full loser list editing console payload

### 3.2 Read surface

- 当前轮唯一冻结的 loser/winner 最小读出口是：
  - `GET /api/app/bid/result?projectId={projectId}`
- 当前最小读取语义固定为：
  - supplier 当前 actor 私域读取
  - 只读当前 actor 在该 `Project` 下的最小 bid 结果
  - 不是 public 面
  - 不是 buyer compare 面
  - 不是 `my bids workspace`

### 3.3 Explicit non-surface

- 当前轮明确不得重开：
  - `POST /api/app/order/create`
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/board`
  - `GET /api/app/bid/compare`
  - `GET /api/app/bid/losers`

## 4. Execution Order

1. `Backend Agent`
   - 先补齐 `BidAward` truth、loser disposition、`Order conversion`、`Contract seed`、`Project` 状态迁移、buyer/supplier 最小读投影
2. `BFF Agent`
   - 再补齐 `POST /api/app/bid/award`、`GET /api/app/bid/result` 的 app-facing surface、错误归一、payload shaping、投影 refresh fallout
3. `Frontend Agent`
   - 最后补齐 buyer 侧最小 award handoff、supplier 侧最小 result 读取、以及 `my-project / workbench / project detail` 的最小刷新承接
4. `结果校验 Agent`
   - 独立复核 bridge success chain、duplicate/concurrent guard、loser read outlet、以及 downstream continuation seed

- 当前唯一允许顺序就是：
  - `backend-first -> BFF-second -> frontend-last -> verification`
- 当前不得并行猜字段、猜状态、猜错误语义。

## 5. First-Round Minimal Write Set

### 5.1 Backend minimal write set

- 只允许实现：
  - `BidAward` truth carrier
  - loser disposition truth
  - `POST /server/bid/award`
  - `GET /server/bid/result`
  - `BidAward -> Order` 唯一 conversion
  - synchronous `Contract seed`
  - `Project.state = awarded / converted_to_order`
  - buyer 侧 `my-project` 最小 fallout refresh
  - buyer 侧 `workbench.project_chain / order_chain` 最小 fallout refresh
- 若需要新模块，当前只允许新增：
  - `apps/server/src/modules/bid_award/**`
- 当前最小 backend 触达目录只允许：
  - `apps/server/src/modules/bid/**`
  - `apps/server/src/modules/bid_award/**`
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/order/**`
  - `apps/server/src/modules/contract/**`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/organization/current-actor-eligibility.service.ts`
  - `apps/server/src/modules/audit/**`

### 5.2 BFF minimal write set

- 只允许实现：
  - `POST /api/app/bid/award`
  - `GET /api/app/bid/result`
  - `bid` family 下的 app-facing error normalization
  - buyer 侧 `my-project / workbench` refresh fallout 透传
- 当前最小 BFF 触达目录只允许：
  - `apps/bff/src/routes/bid/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/bff/src/routes/exhibition_workbench/**`

### 5.3 Frontend minimal write set

- 只允许实现：
  - buyer 侧最小 award handoff
  - supplier 侧最小 bid result 读取
  - `project detail / bid submit / my-project detail / workbench`
    的最小刷新承接
- 当前最小 frontend 触达目录只允许：
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart`
  - `apps/mobile/lib/features/exhibition/data/**`
    中与 bid award / bid result 直接相关的最小 consumer touch
- 如必须新增最小结果页，当前只允许新增：
  - `apps/mobile/lib/features/exhibition/presentation/pages/bid_result_page.dart`

## 6. First-Round Minimal Regression Checklist

- `project create / save / submit / publish` 不回退
- `project showcase list / detail` 不回退
- `bid submit` 仍保持最小 submit 闭环，不被改写成 compare console
- `contract confirm / amend` 已通过链路不回退
- `inspection recheck` 已通过链路不回退
- `dispute withdraw` 已通过链路不回退
- `rating entry / submit` 不因 bridge 实现被顺手重开或误改
- `Workbench` 继续只是摘要投影，不变成 `BidAward` 或 `Order` 真相 owner
- `My Project` 继续只是私域投影，不变成 `BidAward` 真相 owner
- 现有 `order/detail / contract/detail / milestone/list / inspection/detail` continuation 不回退
- app-facing 不出现新的 `/api/app/order/create`
- `Order.state = active` 不被任何页面文案解释成“合同已确认完成”

## 7. Object Pollution Red Lines

- 不得把 `BidAward` 混写进 `Order` truth
- 不得把 loser disposition 混写进 `Order`
- 不得把 `Bid submit` 扩成 award / compare / shortlist 第二状态机
- 不得把 `Workbench` 写成 buyer award console
- 不得把 `My Project` 写成 supplier bid workspace
- 不得把 `Project Detail` 写成 full compare board
- 不得把 `Order.state = active` 写成合同已确认完成态
- 不得把 `contract seed` 延后到异步补种
- 不得把 partial failure 留成脏数据
- 不得借 bridge 实现顺手打开：
  - `seat`
  - `bid package completeness`
  - payment / billing / settlement
  - electronic signature
  - complex scoring / complex risk

## 8. Backend Mandatory Rules For The First Dispatch

- award 必须是 must-audit action
- duplicate award 必须稳定 fail-close
- concurrent award 必须单胜
- `BidAward -> Order -> Contract seed -> Project.state`
  必须同事务提交
- loser disposition 必须与 `BidAward` 同事务提交
- 任一步失败必须整体回滚
- `Order.state = active` 只允许作为 bridge compatibility state

## 9. Stage Completion Markers

- 当前 bounded implementation stage 只有在以下条件同时成立时，才可记为完成：
  - backend 实施回执完成
  - BFF 实施回执完成
  - frontend 实施回执完成
  - focused tests 全部通过
  - 独立结果校验拿到：
    - award success 样本
    - loser result 样本
    - duplicate / concurrent guard 样本
    - `Order + Contract seed` 原子闭合证据
  - buyer 侧：
    - `my-project`
    - `workbench`
    刷新成立
  - supplier 侧：
    - `GET /api/app/bid/result`
      稳定可读
- 当前阶段完成不代表：
  - integration 通过
  - release-prep 通过
  - production release 通过

## 10. Final Dispatch Ruling

- 当前 dispatch bundle authoring 结论：
  - `通过`
- 当前通过的唯一含义：
  - `Go for BidAward bridge bounded implementation-dispatch authoring`
- 当前继续保留：
  - `No-Go` for direct implementation
  - `No-Go` for implementation unlock
  - `No-Go` for real dispatch issuance
  - `No-Go` for integration / release-prep / production release

## 11. Next Unique Action

- 下一步唯一动作固定为：
  - 输出 `BidAward bridge backend implementation dispatch addendum`
  - 只围绕：
    - `BidAward`
    - loser disposition
    - `POST /api/app/bid/award`
    - `GET /api/app/bid/result`
    - `order conversion`
    - synchronous `contract seed`
  - 不得顺手扩到：
    - `seat`
    - `bid package completeness`
    - 支付 / 分账 / 电子签
    - 复杂评分 / 复杂风控

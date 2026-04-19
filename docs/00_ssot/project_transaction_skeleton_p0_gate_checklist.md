---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the stage gate checklist for `项目交易骨架 P0`, decide whether the
  project may enter bounded P0 implementation, and write the unique allowed
  scope, vetoes, and stop-line in one place.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/historical_projects_semantics_ruling_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
  - docs/00_ssot/project_business_closure_strategy_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
---

# 项目交易骨架 P0 阶段门禁核查表

## 1. Stage Name

- 阶段名称：
  - `项目交易骨架 P0`

## 2. Gate Verdict

- `status`: `frozen`
- 是否允许进入下一阶段：
  - `yes`
- 下一阶段唯一名称：
  - `项目交易骨架 P0 bounded implementation`
- 当前唯一合法大方向：
  - `先做交易骨架，不先做资金链`

## 3. Evidence Baseline

### 3.1 已冻结 SSOT 证据

- `project/create` 的资格真源已统一到 `Server eligibility/policy`，且
  `workbench.canCreateProject` 只是 app-facing projection，不是最终真源。
- `historicalProjects` 已冻结为：
  - `privateSummary.formalCompletionStatus = formally_completed` bucket
- `project/list / project/detail` 已冻结为公域。
- `my/projects / exhibition/workbench` 已冻结为私域承接面。
- `viewerProjectRelation` 已冻结为 `owner | non_owner` 最小 handoff，不得再默认补成 owner。
- `payment / billing / credit / deposit / guarantee / membership` 已冻结为
  `profile` 旁路 bounded family，不得冒充项目交易 runtime。

### 3.2 本地 contracts / code 证据

- `openapi.yaml` 当前已注册：
  - `POST /api/app/bid/submit`
  - `GET /api/app/order/detail`
  - `POST /api/app/order/create`
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`
- 本地 `Server + BFF` 已真实存在的当前交易骨架 baseline 代码面是：
  - `project/create` 真资格校验入口
  - `workbench.canCreateProject` 投影入口
  - `order/detail / contract/detail / milestone/list / inspection/detail` 的
    `trading_read_corridor`
- 本地 Flutter 已注册全部 canonical path，但这不等于对应 runtime 已实现。

### 3.3 云上 active runtime 证据

- 通过 `127.0.0.1:8080 -> nginx :80` 核验到当前 active runtime：
  - `GET /health/bff/live` -> `200 OK`
  - `GET /health/server/live` -> `200 OK`
  - `GET /api/app/project/list` -> `200 OK`
  - `GET /api/app/exhibition/workbench` 无登录态 -> `401 AUTH_SESSION_INVALID`
- 上述结果说明：
  - 当前公域 list 已真实在线
  - 当前私域 workbench 已真实是私域入口
  - 当前验证使用的是云上 active ingress，而非本地假 runtime

## 4. Passed Gates

1. 主线定位 gate：已通过。
   - 当前唯一合法下一大步已被上位 SSOT 冻结为 `先做交易骨架`。
2. 公域/私域边界 gate：已通过。
   - `project/list / detail` 与 `my/projects / workbench` 的职责边界已冻结。
3. 资格真源 gate：已通过。
   - `project/create` 最终资格真源归 `Server eligibility/policy`。
4. 交易 stop-line gate：已通过。
   - 当前闭环止于 `发布 -> 展示 -> owner/non-owner 分流 -> 私域承接`；
     交易骨架是下一阶段，不再与当前已完成闭环混写。
5. 资金旁路阻断 gate：已通过。
   - `payment / billing / deposit / guarantee / credit / membership` 均已被
     冻结为当前不得入主链。
6. 最小 read baseline gate：已通过。
   - `order/detail / contract/detail / milestone/list / inspection/detail`
     已有 contracts 与 local corridor baseline，可作为 P0 write skeleton 的 read baseline。

## 5. Failed Gates

1. 当前 repo/runtime 尚未形成完整 P0 write corridor。
   - 这说明 `P0 implementation` 还未完成。
   - 这不是阻断进入实现阶段的 veto，而正是下一阶段的实施对象。
2. 当前 active runtime 还未提供本轮所需的 authenticated write-chain smoke。
   - 这阻断 `result verification / release`。
   - 这不阻断 `bounded implementation` 开始。

## 6. Veto Gates

- 当前 veto gate 结论：
  - `none for entering bounded P0 implementation`

但以下事项继续作为后续阶段 veto，当前不得越过：

1. 没有独立 `project visibility/displayStatus` truth 时，不得实现展示冻结/下架 runtime。
2. 没有独立项目 review state machine 时，不得实现 `review-before-display` runtime。
3. 没有新的 funds/risk freeze 前，不得实现：
   - 支付
   - 账单
   - 押金实缴
   - 保证金执行
   - 交易保障执行
   - 佣金 / 服务费 / 结算

## 7. 当前是否允许进入“项目交易骨架 P0”实现阶段

- 正式答案：
  - `允许`

原因：

- 当前上游战略、边界、stop-line、资格真源、公私域职责、profile 旁路阻断都已冻结。
- 当前缺的不是“方向判断”，而是 `P0 skeleton` 的 bounded implementation 本身。
- 当前没有 `visibility truth`、没有 `project review state machine`，并不阻断本轮把交易骨架推进到最小 write skeleton；
  但会阻断任何展示治理或审核治理 runtime 扩写。

## 8. 当前是否仍存在 veto gate 阻断

- 对 `进入 P0 bounded implementation`：
  - `否`
- 对 `支付 / 押金 / 佣金 / 资金执行`：
  - `是`

## 9. 当前是否允许直接开启支付 / 押金 / 佣金实现

- 正式答案：
  - `不允许`

阻断原因：

- 交易骨架尚未先行完成。
- `payment / billing / deposit / guarantee / credit` 当前只在 `profile/*`
  bounded family 内成立。
- 当前未冻结它们接入 `bid -> order` 或 `order -> contract` 的唯一 gate 位点。

## 10. 当前唯一允许范围

当前只允许进入以下 bounded P0 实现对象：

1. `bid/submit` 进入真实 app-facing write corridor。
2. `order/create` 进入真实 app-facing write corridor。
3. `contract/confirm` 进入真实 app-facing write corridor。
4. `milestone/submit` 进入真实 app-facing write corridor。
5. `inspection/submit` 进入真实 app-facing write corridor。
6. 同时配套消费并校验以下 read corridor baseline：
   - `order/detail`
   - `contract/detail`
   - `milestone/list`
   - `inspection/detail`

## 11. 明确禁止范围

当前明确禁止纳入 `P0` 的对象与主题：

1. `contract/amend`
2. `inspection/recheck`
3. `rating/entry`
4. `rating/submit`
5. `dispute/open`
6. `dispute/withdraw`
7. `payment execution`
8. `billing execution`
9. `deposit paid truth`
10. `transaction guarantee execution`
11. `credit runtime gate`
12. `membership as project gate`
13. `project visibility/displayStatus runtime`
14. `project review state machine runtime`

## 12. 阻断原因与必须先补什么

由于本阶段结论为 `yes`，当前没有进入实现阶段的阻断项。

但要进入下一后续阶段，必须先补：

1. 本轮 6 份 P0 文书链全部冻结并登记到 `source_of_truth_map.md`。
2. 后端、BFF、前端分别完成 bounded implementation 与 receipt。
3. 结果校验给出 authenticated smoke 与 object-by-object verification。

## 13. Formal Conclusion

- 当前允许进入：
  - `项目交易骨架 P0 bounded implementation`
- 当前唯一合法下一步仍然是：
  - `先做交易骨架`
- 当前不允许直接进入：
  - `支付 / 押金 / 佣金 / 账单 / 结算 / 交易保障执行`
- 当前不得把本结论改写成：
  - `真实交易闭环已成立`
  - `资金链可并行开启`
  - `项目 visibility 或 review runtime 已合法解锁`

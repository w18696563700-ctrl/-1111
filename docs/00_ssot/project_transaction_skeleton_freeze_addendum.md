---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the current strategic stop-line of the project mainline and classify
  `bid / order / contract / milestone / inspection / rating / dispute` by what
  is already a real mainline, what is only controlled continuation, what is
  read-only transport, and what remains strategic reserve.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/historical_projects_semantics_ruling_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_showcase_detail_bid_board_closure_conclusion_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_signoff.md
  - docs/00_ssot/my_building_round1_viewer_project_relation_runtime_alignment_review_conclusion_addendum.md
  - docs/00_ssot/stage2_transport_admin_support_closure_conclusion_addendum.md
  - docs/00_ssot/s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_bff_order_contract_fulfillment_read_corridor_aggregation_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_mobile_order_contract_fulfillment_read_corridor_consumption_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/exhibition_showcase_bid_flow_v11_upgrade_addendum.md
  - docs/00_ssot/contract_phase3_decision_addendum.md
  - docs/00_ssot/inspection_phase3_decision_addendum.md
  - docs/00_ssot/rating_object_decision_addendum.md
  - docs/00_ssot/dispute_object_decision_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/my_project/my-project.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/server/test/project-publish-eligibility.test.cjs
  - apps/server/test/historical-projects-semantics.test.cjs
  - apps/bff/test/my-project-viewer-relation.test.cjs
---

# 《项目交易骨架冻结单》

## 1. Scope

本冻结单只回答一件事：

- 当前项目主线真实闭环到底已经到哪一段。

本冻结单覆盖：

- `project/create`
- `project/list`
- `project/detail`
- `my/projects`
- `my/projects/{projectId}`
- `exhibition/workbench`
- `bid / order / contract / milestone / inspection / rating / dispute`

本冻结单不做：

- 支付 / 账单 / 保证金 / 信用约束接线
- 资金执行策略设计
- 任何 `apps/**` 代码修改
- 任何新 implementation unlock

## 2. 当前总结论

当前项目主线**不是**“真实交易闭环已成立”。

当前真实闭环止于：

- `发布 -> 展示 -> owner / non-owner 分流 -> 私域承接`

并且当前只额外成立两层受控延伸：

- `bid/submit` 作为最小继续竞标 continuation，属于**受控可用边界**
- `order/detail -> contract/detail -> milestone/list -> inspection/detail`
  作为 `S2` 的 read corridor，属于**只读边界**

当前不得改写成：

- `发布 -> 展示 -> bid -> order/contract` 已完整成立
- `真实交易闭环已成立`
- `履约闭环已成立`
- `售后/评价/争议闭环已成立`

## 3. 交易骨架分层表

| 层 | 对象 | 当前 carrier | 当前定性 | 说明 |
|---|---|---|---|---|
| L0 项目资产闭环 | `project/create` | `POST /api/app/project/create` | 已成立真实主链 | 已有 create/detail/upload development-stage 联调签收与封板结论，但不等于 release |
| L0 公域发现闭环 | `project/list` / `project/detail` | `GET /api/app/project/list` / `GET /api/app/project/detail` | 已成立真实主链 | 已回到公域展示主线；`detail` 承接最小共享详情 |
| L0 owner 分流闭环 | `viewerProjectRelation` | `project/detail` / `my/projects/{id}` | 已成立真实主链 | 只承接 owner/non-owner handoff，不是动作矩阵 |
| L0 私域承接闭环 | `my/projects*` / `exhibition/workbench` | 私域项目资产与私域摘要 | 已成立真实主链 | `my/projects` 是私域项目资产面，`workbench` 是私域 continuation summary |
| L1 竞标 continuation 边界 | `bid/submit` | `POST /api/app/bid/submit` | 受控可用 | 当前板块以“最小继续竞标 + controlled failure/guard”封板，不得上升为 order conversion 已闭环 |
| L2 交易读走廊 | `order/detail` / `contract/detail` / `milestone/list` / `inspection/detail` | `S2` backend+BFF+mobile read corridor | 只读边界 | `stage2 closure = PASS WITH RISK`，但保持 `stage2 implementation = No-Go` |
| L3 交易写骨架 | `order/create` / `contract/confirm` / `contract/amend` / `milestone/submit` / `inspection/submit` / `inspection/recheck` | canonical paths 已存在，但未被本轮收口为项目主线完成基线 | 战略预留 | 这些对象可作为下一阶段交易骨架对象，但当前不得冒充已闭环 |
| L4 售后/治理边缘对象 | `rating` / `dispute` | entry/minimal action planning or historical edge routes | 战略预留 | 当前不得作为项目主线完成度证明 |

## 4. 当前已成立 / 当前未成立 / 战略预留表

| 对象 | 当前分类 | 当前结论 | 主要依据 |
|---|---|---|---|
| `project/create` | 已成立真实主链 | create accepted + detail continuation + upload 子链签收成立 | `project_publish_minimum_corridor_integration_validation_signoff.md` |
| `project/list` | 已成立真实主链 | 公域展示 list 已封板 | `project_showcase_detail_bid_board_closure_conclusion_addendum.md` |
| `project/detail` | 已成立真实主链 | 公域 detail + owner-aware handoff 已封板 | 同上 + `viewerProjectRelation` 复签 |
| `my/projects` | 已成立真实主链 | 私域 ongoing/historical 项目资产面成立 | `historical_projects_semantics_ruling_addendum.md` + runtime tests |
| `my/projects/{projectId}` | 已成立真实主链 | `publicProject + privateProgress` 私域承接成立 | `project_visibility_boundary_freeze_addendum.md` |
| `exhibition/workbench` | 已成立真实主链 | 私域摘要与 continuation handoff 成立 | `workbench_private_board_closure_conclusion_addendum.md` |
| `bid` | 受控可用 | 最小继续竞标 continuation 已成立，但仅到 bid 边界 | `project_showcase_detail_bid_board_closure_conclusion_addendum.md` |
| `order` | 只读边界 | 当前已收口的是 `order/detail` read corridor，不是 order write chain | `S2` conclusions + `openapi.yaml` |
| `contract` | 只读边界 | 当前已收口的是 `contract/detail` read corridor，不是 contract workflow closure | `S2` conclusions + `contract_phase3_decision_addendum.md` |
| `milestone` | 只读边界 | 当前已收口的是 `milestone/list` read corridor，不是 submit/approval 闭环 | `S2` conclusions |
| `inspection` | 只读边界 | 当前已收口的是 `inspection/detail` read corridor，不是 submit/recheck/decision 闭环 | `S2` conclusions + `inspection_phase3_decision_addendum.md` |
| `rating` | 战略预留 | 当前只保留 entry/minimal-action planning，不能算项目主线完成 | `rating_object_decision_addendum.md` |
| `dispute` | 战略预留 | 当前只保留 order-level minimal open semantics，不能算项目主线完成 | `dispute_object_decision_addendum.md` |

## 5. 当前未成立表

| 当前未成立对象 | 为什么未成立 | 当前禁止口径 |
|---|---|---|
| `bid -> order` 真正转换闭环 | 当前 bid 封板只接受最小 continuation 与 controlled failure，未把 order conversion 收口成验收基线 | 不得说“bid 成功后交易闭环已成立” |
| `order -> contract -> milestone -> inspection` 写链 | `S2` 收口的是 read corridor，不是 write skeleton | 不得说“履约闭环已成立” |
| `rating` 完整提交闭环 | 当前 first-release acceptance 允许停在 controlled unavailable 或最小 action planning | 不得说“评价闭环已成立” |
| `dispute` 完整治理闭环 | 当前只有 minimal open historical boundary，不含 negotiation/review/resolution | 不得说“争议处理闭环已成立” |
| 支付 / 账单 / 保证金 / 信用 | 当前仍在 profile bounded read/status/posture 家族 | 不得说“项目主线已接入资金链/风控链” |

## 6. 当前闭环止点结论

当前项目主线的正式止点冻结为：

1. `project/create` 完成发布进入公域。
2. `project/list / project/detail` 完成公域展示与共享详情。
3. `viewerProjectRelation` 在公域 detail 完成 owner / non-owner 最小分流。
4. `my/projects` 与 `exhibition/workbench` 完成私域承接。

当前只能把 `bid` 视为：

- 项目主线边缘的最小 continuation
- 而不能视为“项目交易闭环已经越过 bid 进入 order/contract”

当前只能把 `order / contract / milestone / inspection` 视为：

- 下游交易读走廊 transport closure
- 而不能视为“当前项目主线已经进入真实交易写闭环”

## 7. Formal Conclusion

本单正式写死：

- 当前项目主线**不是**真实交易闭环。
- 当前项目主线真实闭环止于：
  - `发布 -> 展示 -> owner/non-owner 分流 -> 私域承接`
- `bid` 当前属于：
  - `受控可用`
- `order / contract / milestone / inspection` 当前属于：
  - `只读边界`
- `rating / dispute` 当前属于：
  - `战略预留`
- 后续 release、排期、实现、资源评估不得再把当前项目主线夸大成“真实交易闭环已成立”。

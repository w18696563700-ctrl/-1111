---
owner: Codex 总控
status: active
purpose: >
  Freeze the next highest-priority same-object mainline after the authority
  refresh of the current `发布项目工作台及延伸功能全链` object cluster, so the
  repo proceeds into the L2-L5 consistency-refresh chain instead of drifting
  back to subordinate subchains, single-action side loops, or implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-13
based_on:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/01_contracts/openapi.yaml
  - docs/03_bff/bff_routes.md
  - docs/04_frontend/ui_state_contract.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/00_ssot/inspection_phase3_detail_submit_contract_closure_addendum.md
  - docs/00_ssot/inspection_phase3_trigger_recheck_contract_addendum.md
  - docs/00_ssot/rating_entry_minimal_action_contract_permission_addendum.md
  - docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
---

# 《项目发布对象簇 L2-L5 一致性刷新主线裁决单》

## 1. Scope

- 本裁决单只回答四件事：
  - authority refresh 之后，当前最高优先级应该开的主线是什么
  - 为什么它必须是同对象 `L2-L5 consistency refresh`，而不是别的候选线
  - 这条主线固定覆盖哪些 authoring 范围
  - 这条主线的固定顺序与下一步唯一动作是什么
- 本裁决单不代表：
  - implementation dispatch
  - implementation unlock
  - integration
  - `release-prep`
  - production release

## 2. Current Situation

- 当前已正式成立的前置事实只有三条：
  1. `发布项目工作台及延伸功能全链`
     的当前对象簇 authority 已由
     `project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
     锁定
  2. 当前 repo 中可直接沿用的对象资产已识别完成，
     包括：
     - `project create / list / detail / my-project`
     - `post-publish materials corridor`
     - `order/detail / contract/detail / milestone/list / inspection/detail`
     - `milestone submit / inspection submit / inspection recheck`
     - `rating entry / submit`
     - `dispute open / withdraw`
  3. 旧 `order_intake_and_fulfillment_mainline_*`
     与旧 `project_publish_workbench_full_extension_mainline_*`
     已被正式降级
- 当前真正还未收口的不是：
  - 对象边界
  - 资产识别
- 当前真正还未收口的是：
  - 下层 `L2 / L3 / L4 / L5` 冻结口径与当前 repo 事实不一致
- 当前 repo 的实际冲突固定为：
  - 旧 `L2-L5` 文书仍把
    `contract confirm/amend`
    `inspection recheck`
    `rating entry/submit`
    `dispute withdraw`
    继续写成排除项或边界外项
  - 当前 `openapi / BFF / Server / mobile / test`
    已把这组动作纳入当前对象簇事实

## 3. Current Highest-priority Mainline

- 当前最高优先级主线正式裁定为：
  - `项目发布对象簇 L2-L5 一致性刷新主线`
- 其唯一正式语义固定为：
  - 在已经锁死的同一个 `项目发布对象簇` 内，
    依次刷新 `L2 contract`、`L3 backend truth`、`L4 BFF surface`、`L5 frontend consumption`
    的过时或冲突冻结口径
  - 让下层冻结链重新与当前 repo 的 object authority、
    current contracts、current code、current tests 对齐
- 这条主线明确是：
  - same-object refresh mainline
  - docs-only authoring mainline
- 这条主线明确不是：
  - 新的业务对象切换
  - `order_intake` 子链重开
  - `rating` 单对象重开
  - `dispute` 单对象重开
  - implementation mainline

## 4. Why It Must Be This Mainline

- 当前 authority refresh 已经解决了“总边界是谁说了算”的问题。
- 但如果下一步不先刷新 `L2-L5`，当前 repo 会继续保持：
  - `L0 authority` 口径正确
  - `L2-L5 freeze` 口径落后
  - `openapi / code / test` 口径领先
  的三层错位状态。
- 在这种状态下直接开别的线，会产生三个后果：
  - stale docs 继续与当前 repo 争夺 authority
  - 后续 authoring 继续引用过时 `excluded` 条款
  - implementation 或局部修订会失去当前唯一优先级顺序
- 因此当前最短闭环不是再做一次大扫描，
  也不是去开单动作对象，
  而是先把当前对象簇的 `L2-L5` 冻结链刷新到与 repo 一致。

## 5. Covered Authoring Scope

- 当前主线固定覆盖以下 authoring 范围：
  1. `L2 contract refresh`
     - 刷新当前对象簇的 app-facing contract included set
     - 刷新动作家族：
       - `contract confirm / amend`
       - `milestone submit`
       - `inspection submit / recheck`
       - `rating entry / submit`
       - `dispute open / withdraw`
     - 刷新与当前对象簇直接相关的 request anchor / response / error boundary
  2. `L3 backend truth refresh`
     - 刷新 `Server truth / query / command / persistence / status flow`
       的当前 authority 描述
     - 刷新从属子链与同对象 extension boundary 的真实归属
  3. `L4 BFF surface refresh`
     - 刷新当前对象簇 app-facing mapping / payload shaping / error normalization
       的当前 authority 描述
  4. `L5 frontend consumption refresh`
     - 刷新当前 route/page/consumer/view-model 的 current carrier authority
     - 收掉与 `flutter_screen_map.md` 这类旧 route 独立承载口径的冲突
- 当前主线必须直接沿用但不得改写对象边界的资产包括：
  - `project_showcase_filter_and_project_create_form_refactor_*`
  - `project_publish_workbench_post_publish_materials_corridor_v1_*`
  - `inspection_phase3_*`
  - `rating_entry_minimal_*`
  - `dispute_entry_minimal_*`
- 当前主线明确不覆盖：
  - `bid`
  - `order/create`
  - `payment / billing`
  - `forum`
  - Admin 独立对象
  - release-prep
  - production release

## 6. Why Not Other Candidates

| 候选主线 | 为什么不是当前优先级第一 |
| --- | --- |
| `订单承接与履约承接主链` | 该家族已被 authority refresh 降级为从属 continuation subchain，当前不能重新冒充整个对象簇主线。 |
| `rating` 或 `dispute` 单对象线 | 这两组动作已经是当前对象簇的一部分；单独再拆主线只会破坏刚刚锁定的总 authority。 |
| `implementation` 主线 | 当前 stale `L2-L5` 还未刷新，先做 implementation 会让下层 authoring 与代码 authority 继续错位。 |
| 再做一轮全对象大扫描 | 当前缺口已经不是边界和资产识别，而是 lower-layer freeze mismatch；继续大扫描不会缩短闭环。 |

## 7. Fixed Sequence

- 当前主线顺序固定为：
  1. `L2 contract refresh`
  2. `L3 backend truth refresh`
  3. `L4 BFF surface refresh`
  4. `L5 frontend consumption refresh`
- 当前不允许改成：
  - `L5 -> L4 -> L3 -> L2`
  - 单独抽一个动作家族抢跑
  - 先 implementation、后补冻结
- 当前 `L0 authority refresh`
  的地位固定为：
  - 上位总 authority
  - 不是被本主线改写的对象
  - 而是本主线的唯一上游依据

## 8. Formal Conclusion

- 当前最高优先级正式主线：
  - `项目发布对象簇 L2-L5 一致性刷新主线`
- 当前正式意义：
  - 这是同对象的 docs-only refresh mainline
  - 不是新的业务对象切换
  - 不是从属子链重开
  - 不是 implementation 重开
- 当前必须先解决：
  - current `L2-L5` freeze 与 repo 事实的错位
- 当前仍然：
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 9. Next Unique Action

- 下一步唯一动作：
  - 提交《项目发布对象簇 L2-L5 一致性刷新主线 阶段门禁核查表》

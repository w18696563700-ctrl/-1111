---
owner: Codex 总控
status: frozen
purpose: >
  Submit the stage gate checklist for the same-object `项目发布对象簇 L2-L5
  一致性刷新主线`, so the repo may proceed only into the docs-only lower-layer
  freeze refresh and may not drift into implementation, dispatch, or scope
  expansion.
layer: L0 SSOT
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md
  - docs/00_ssot/project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/routes.module.ts
  - apps/server/src/app.module.ts
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/mobile/test/shell_app_test.dart
---

# 《项目发布对象簇 L2-L5 一致性刷新主线 阶段门禁核查表》

## 1. Scope

- 当前对象只限：
  - `发布项目工作台及延伸功能全链` 的同一 `project publish object cluster`
- 本门禁只回答：
  - 当前是否允许进入同对象 `docs-only L2-L5 freeze authoring`
- 本门禁不代表：
  - implementation unlock
  - implementation dispatch send
  - direct implementation
  - integration
  - `release-prep`
  - production release

## 2. Passed Gates

- true-source gate：
  - passed
  - 当前上位 authority 已固定为：
    - `project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
    - `project_publish_object_cluster_l2_l5_consistency_refresh_mainline_ruling_addendum.md`
    - `source_of_truth_map.md`
  - 当前 authoring 仍然只落在 `docs/**`
- same-object gate：
  - passed
  - 当前只刷新同一个 `project publish object cluster`
  - 没有切换成新对象，也没有把 `rating`、`dispute`、`order_intake` 拆成新主线
- architecture gate：
  - passed
  - 当前 repo 仍然是：
    - `Flutter App -> BFF -> Server`
  - `BFF` 仍不是 truth owner
  - `Server` 仍是唯一 business truth owner
- canonical-path evidence gate：
  - passed
  - `openapi.yaml` 已存在当前 canonical path family
  - 当前 repo 的 `BFF / Server / mobile / tests` 已直接对应这些 canonical paths
- workbench posture gate：
  - passed
  - `GET /api/app/exhibition/workbench`
    仍然是 summary / handoff / boundary-state posture
  - 现行 workbench view-model 没有把它写成 active command desk
- direct-current-repo evidence gate：
  - passed
  - 当前 repo 已直接纳入：
    - `contract confirm / amend`
    - `milestone submit`
    - `inspection submit / recheck`
    - `rating entry / submit`
    - `dispute open / withdraw`
  - 且现行 tests 已覆盖这些 carrier 与 boundary-state
- docs-only scope gate：
  - passed
  - 当前动作只需刷新 lower-layer freeze
  - 不需要改实现代码，不需要跑 runtime，不需要发 dispatch

## 3. Failed Gates

- lower-layer contract consistency gate：
  - failed
  - 旧 `L2` 文书仍保留把部分当前已纳入动作写成 excluded family 的过时口径
- lower-layer backend consistency gate：
  - failed
  - 旧 `L3` 文书仍把 `contract confirm/amend`、`inspection recheck`、`rating submit`、
    `dispute withdraw` 的当前 `Server` 归属写成对象外、边界外、或仅历史 planning
- lower-layer BFF consistency gate：
  - failed
  - 旧 `L4` 文书仍把当前已存在的 app-facing mapping / payload shaping /
    error normalization 家族写成 next-stage 或 excluded
- lower-layer frontend consistency gate：
  - failed
  - 旧 `L5` 文书仍混用历史 route authority 与现行 route registry
  - `flutter_screen_map.md` 中的若干独立 route authority 已落后于当前 repo
- source-of-truth registration gate：
  - failed
  - `source_of_truth_map.md`
    还没有登记本轮 `stage gate + L2 + L3 + L4 + L5` 的新优先级
- direct implementation gate：
  - failed
- integration gate：
  - failed
- `release-prep` gate：
  - failed
- production release gate：
  - failed

## 4. Veto Gates

- no-new-object veto：
  - passed
  - 当前没有扩到：
    - `bid`
    - `order/create`
    - `payment / billing`
    - `forum`
    - `Admin`
- no-implementation veto：
  - passed
  - 当前只做 docs-only freeze
  - 没有 implementation、dispatch、runtime 操作
- no-second-state-machine veto：
  - passed
  - 当前 evidence 仍表明：
    - `BFF` 只做 mapping / shaping / normalization
    - Flutter 只做消费与 controlled state
- workbench-command-desk veto：
  - passed
  - 当前 repo 的 `openapi + workbench presenter + workbench view-model`
    都没有把 workbench 写成 active command desk
- contract-anchor-drift veto：
  - passed
  - 当前 canonical request anchor 以 `openapi + current repo` 为准
  - 没有继续沿用 `dispute withdraw -> disputeId request anchor`
- prompt-before-gate veto：
  - passed
  - 当前先出门禁，再进入 lower-layer freeze

## 5. Stage Go / No-Go Decision

- 结论：
  - `Go for docs-only freeze authoring`
- 当前允许进入：
  - `L2 contract`
  - `L3 backend truth`
  - `L4 BFF surface`
  - `L5 frontend consumption`
  - `source_of_truth_map` 归属与优先级登记更新
- 当前仍然：
  - `No-Go for implementation unlock`
  - `No-Go for implementation dispatch send`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 6. Current Gate Meaning

- 当前允许的含义：
  - 可以只在同一个 `project publish object cluster` 内，
    把 `L2-L5` 过时 freeze 一次性刷新到与当前 repo 一致
  - 可以正式收掉旧 `full_extension_mainline`
    与旧 `order_intake_and_fulfillment_mainline`
    在下层文书里的过时排除口径
- 当前不允许的含义：
  - 不能重开 implementation 主线
  - 不能把 workbench 改写成 active command desk
  - 不能把 `bid / order/create / payment / forum / Admin`
    扩进当前对象

## 7. Next Unique Action

- 下一步唯一动作：
  - 按固定顺序一次性输出：
    - `L2 contract consistency refresh`
    - `L3 backend truth consistency refresh`
    - `L4 BFF surface consistency refresh`
    - `L5 frontend consumption consistency refresh`
    - `source_of_truth_map` 登记更新

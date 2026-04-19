---
owner: Codex 总控
status: active
purpose: >
  Refresh the formal authority for the current `发布项目工作台及延伸功能全链`
  object cluster against the live repository, locking the current object-cluster
  boundary, marking directly reusable assets, formally downgrading stale or
  conflicting freeze documents, and resetting the `source_of_truth_map`
  ownership and priority order for this cluster.
layer: L0 SSOT
freeze_date_local: 2026-04-13
based_on:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/project_publish_workbench_post_publish_materials_corridor_v1_truth_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
  - docs/00_ssot/inspection_phase3_detail_submit_contract_closure_addendum.md
  - docs/00_ssot/inspection_phase3_trigger_recheck_contract_addendum.md
  - docs/00_ssot/rating_entry_minimal_action_contract_permission_addendum.md
  - docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/03_bff/bff_routes.md
  - docs/04_frontend/ui_state_contract.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/server/src/app.module.ts
---

# 《发布项目工作台及延伸功能全链 authority refresh 补充单》

## 1. Scope

- 本补充单只做四件事：
  - 锁定当前 `项目发布对象簇` authority
  - 标记当前 repo 中可直接沿用的资产
  - 正式降级已过时或互相冲突的旧文书
  - 更新 `source_of_truth_map.md` 的归属和优先级
- 本补充单不做：
  - implementation dispatch
  - implementation unlock
  - integration
  - `release-prep`
  - production release

## 2. Current Authority

### 2.1 唯一当前 authority

- 自本补充单起，`发布项目工作台及延伸功能全链` 的当前对象簇 authority
  固定为：
  - `docs/00_ssot/project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
- 本 authority 的判断依据只允许锚定：
  - 当前 repo 已存在文书
  - 当前 repo 已存在 contracts
  - 当前 repo 已存在 code / test / runtime 资产
- 任何更早文书，如与当前 repo 事实冲突，只保留历史或局部语义，不再拥有本对象簇的当前总 authority。

### 2.2 当前对象簇边界

- 当前对象簇正式锁定为以下六块直接相关范围：
  1. `发布项目工作台`
     - `project_chain`
     - `order_chain`
     - `fulfillment_chain`
     - `extension_boundary`
  2. `项目发布主链`
     - `workbench -> project create`
     - `create / edit / save / submit / publish`
     - `创建后的回跳 / 回显 / 状态刷新`
  3. `项目展示主链`
     - `workbench -> project list / project pool / 项目展示`
     - `project list / detail / 筛选 / 分页 / 过期裁剪`
  4. `订单与履约承接`
     - `workbench -> order/detail -> contract/detail`
     - `workbench -> milestone/list -> inspection/detail`
  5. `边界动作`
     - `contract confirm / amend`
     - `milestone submit`
     - `inspection submit / recheck`
     - `rating entry / submit`
     - `dispute open / withdraw`
  6. `直接相关技术层`
     - `mobile route / page / consumer / transport / view-model`
     - `BFF app-facing contract / payload shaping / error normalization`
     - `Server truth / query / command / persistence / status flow`
     - `相关 tests / runtime / active release / health / tunnel`
- 下列对象不在本补充单 authority 范围：
  - `bid`
  - `order/create`
  - `payment / billing`
  - `forum`
  - `Admin` 独立运营台
  - 与本对象簇无直接 handoff 的其他 building

### 2.3 当前 authority 语义

- 当前对象簇不再允许被解释成：
  - 只有 `订单承接与履约承接主链`
  - 或只有 `project publish minimum corridor`
- 当前对象簇也不再允许被解释成：
  - 2026-04-11 时点的 frozen exclusion snapshot
- 当前对象簇必须按当前 repo 实际存在的：
  - `project + my-project + workbench + trading_read_corridor + trading_shell_handoff + rating + dispute + post-publish attachments`
  一起理解。

## 3. Directly Reusable Assets

### 3.1 当前可直接沿用的主资产

- `project_showcase_filter_and_project_create_form_refactor_*`
  冻结链，继续作为 `project create / list / detail / filter / pagination / expiry trimming`
  的直接沿用资产。
- `project_publish_workbench_post_publish_materials_corridor_v1_*`
  冻结链，继续作为 `已发布项目资料补充走廊`
  的直接沿用资产。
- `inspection_phase3_detail_submit_contract_closure_addendum.md`
  与
  `inspection_phase3_trigger_recheck_contract_addendum.md`
  继续作为 `inspection/detail / submit / recheck`
  的直接沿用资产。
- `rating_entry_minimal_action_contract_permission_addendum.md`
  继续作为 `rating/entry + rating/submit`
  的直接沿用资产。
- `dispute_entry_minimal_governance_action_addendum.md`
  继续作为 `dispute/open + dispute/withdraw`
  的动作语义、权限边界、审计边界沿用资产，
  但不再拥有 withdraw 请求锚点的最终 authority。
- `docs/01_contracts/openapi.yaml`
  继续作为当前对象簇 `app-facing contract` 的直接合同快照资产。
- `docs/03_bff/bff_routes.md`
  继续作为当前对象簇 `BFF route ownership / mapping` 的直接沿用资产。
- `docs/04_frontend/ui_state_contract.md`
  继续作为当前对象簇 `frontend state / boundary-state` 的直接沿用资产。

### 3.2 当前可直接沿用的代码与验证资产

- 当前 mobile 直接沿用资产固定为：
  - `apps/mobile/lib/features/exhibition/navigation/**`
  - `apps/mobile/lib/features/exhibition/data/**`
  - `apps/mobile/lib/features/exhibition/presentation/**`
  - `apps/mobile/test/project_*`
  - `apps/mobile/test/inspection_*`
  - `apps/mobile/test/rating_*`
  - `apps/mobile/test/dispute_*`
- 当前 BFF 直接沿用资产固定为：
  - `apps/bff/src/routes/project/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/bff/src/routes/trading_read_corridor/**`
  - `apps/bff/src/routes/trading_shell_handoff/**`
  - `apps/bff/src/routes/rating/**`
  - 对应 `apps/bff/test/**`
- 当前 Server 直接沿用资产固定为：
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/trading_shell_handoff/**`
  - `apps/server/src/modules/rating/**`
  - 对应 `apps/server/test/**`
- 当前 runtime 直接沿用资产固定为：
  - `infra/docker-compose.yml`
  - `infra/nginx/**`
  - `infra/scripts/smoke.sh`
  - 当前 development-stage tunnel / health / smoke evidence

### 3.3 当前沿用优先级

- 本对象簇当前沿用优先级固定为：
  1. 本补充单
  2. 当前 repo 仍与实现、合同、测试一致的同对象文书与合同资产
  3. 当前 repo 中同对象的 code / test / runtime 资产
  4. 从属子链文书
  5. 历史 freeze / sidecar 文书

## 4. Formal Downgrade

### 4.1 降级为从属子链资产

- 以下文书家族当前正式降级为：
  - `发布项目对象簇下的从属 continuation subchain`
  - 不再拥有整个对象簇的总 authority
- 降级对象包括：
  - `docs/00_ssot/order_intake_and_fulfillment_mainline_*`
  - `docs/01_contracts/order_intake_and_fulfillment_mainline_*`
  - `docs/02_backend/order_intake_and_fulfillment_mainline_*`
  - `docs/03_bff/order_intake_and_fulfillment_mainline_*`
  - `docs/04_frontend/order_intake_and_fulfillment_mainline_*`
- 上述家族仍可沿用的 only-if-not-conflicting 范围是：
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `inspection/detail`
  - `milestone/submit`
  - `inspection/submit`
- 上述家族不再允许继续定义：
  - 当前总对象边界
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/entry`
  - `rating/submit`
  - `dispute/open`
  - `dispute/withdraw`
  的 included / excluded authority

### 4.2 降级为历史 freeze 基线

- 以下文书家族当前正式降级为：
  - `2026-04-11 historical freeze baseline`
  - 不再拥有当前对象簇的总 authority
- 降级对象包括：
  - `docs/00_ssot/project_publish_workbench_full_extension_mainline_*`
  - `docs/01_contracts/project_publish_workbench_full_extension_mainline_*`
  - `docs/02_backend/project_publish_workbench_full_extension_mainline_*`
  - `docs/03_bff/project_publish_workbench_full_extension_mainline_*`
  - `docs/04_frontend/project_publish_workbench_full_extension_mainline_*`
- 上述家族仍可保留的价值 only-if-not-conflicting 是：
  - 四容器对象命名
  - `project_chain / order_chain / fulfillment_chain / extension_boundary`
    的总形态
  - 2026-04-11 时点的 freeze landing / package evidence
- 上述家族不再允许继续定义：
  - 当前对象簇的 included / excluded boundary
  - 当前对象簇的动作闭包优先级
  - 当前对象簇的 `maintenance-only` 结论

### 4.3 局部冲突条款降级

- `docs/04_frontend/flutter_screen_map.md`
  中关于：
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/ratings/submit`
  的独立 route authority，
  当前正式降级为：
  - historical sidecar only
- 当前这组 route 的 authority 以：
  - 本补充单
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `docs/01_contracts/openapi.yaml`
  为准。
- `docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md`
  中关于：
  - `POST /api/app/dispute/withdraw` 缺少 `disputeId`
    即 `DISPUTE_WITHDRAW_INVALID`
  的请求锚点条款，
  当前正式降级为：
  - 历史规划条款
- 当前 withdraw 请求锚点 authority 以：
  - `docs/01_contracts/openapi.yaml`
  - 当前 BFF / Server / test 资产
  为准，
  当前 canonical request anchor 是：
  - `orderId`

## 5. Source Of Truth Map Update

- `docs/00_ssot/source_of_truth_map.md`
  必须登记以下当前归属与优先级：
  1. `project_publish_workbench_full_extension_mainline_authority_refresh_addendum.md`
     是本对象簇唯一当前 L0 authority refresh 文书
  2. `project_showcase_filter_and_project_create_form_refactor_*`
     与
     `project_publish_workbench_post_publish_materials_corridor_v1_*`
     是当前对象簇的直接沿用主资产
  3. `inspection_phase3_*`
     `rating_entry_minimal_*`
     `dispute_entry_minimal_*`
     是当前对象簇的局部动作 authority，
     但局部冲突条款以本补充单和 `openapi.yaml` 为准
  4. `order_intake_and_fulfillment_mainline_*`
     家族当前只归属于从属 continuation subchain
  5. `project_publish_workbench_full_extension_mainline_*`
     家族当前只归属于历史 freeze baseline
- 若 `source_of_truth_map.md` 中旧登记与本补充单冲突，
  当前一律按本补充单优先。

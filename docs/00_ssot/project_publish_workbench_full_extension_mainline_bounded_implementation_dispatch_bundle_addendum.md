---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded implementation dispatch bundle for
  `发布项目工作台及延伸功能全链` so execution authoring stays inside
  the already-frozen mainline ruling, truth, contract, backend, BFF,
  and frontend chain without issuing any real implementation prompt yet.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_asset_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
---

# 《发布项目工作台及延伸功能全链 bounded implementation dispatch bundle》

## 1. Scope

- 本派工包只适用于：
  - `发布项目工作台及延伸功能全链`
- 本派工包只冻结：
  - 当前实现轮的唯一目标
  - 当前允许的增量范围
  - 当前执行角色与顺序
  - 当前 retained veto 与非目标
- 本派工包不代表：
  - implementation execution 已开始
  - implementation unlock 已通过
  - backend / BFF / frontend 真实 dispatch prompt 已发出
  - integration 通过
  - `release-prep` 通过
  - production release

## 2. Round Unique Goal

- 当前实现轮唯一目标是：
  - 只把 corrected full-object 的 `project_chain + subordinate read-corridor + shell / handoff + boundary-only`
    做成有界实现 authoring 包
- 当前主链仅包括：
  - `project_chain` 已有 verified development-stage runtime 资产的对齐与保持
  - `workbench` 四容器 summary / handoff 承接
  - `my-project` 私域 carry 复用
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `inspection/detail`
  - `milestone/submit` 的 shell / handoff position
  - `inspection/submit` 的 shell / handoff position
  - `dispute/open` 的 shell / handoff position
  - `ratingEntryState`
  - `disputeWithdrawState`
  - upload 三段式与 `evidence / file_asset` 最小复用
- 当前轮不允许：
  - 把 `订单承接与履约承接主链` 重新抬成真实主线
  - 把 `order / fulfillment / extension` 写成 runtime 已闭环
  - 把 shell / handoff 节点升级成 active command family
  - 扩到 `order/create`
  - 扩到 `contract/confirm`
  - 扩到 `contract/amend`
  - 扩到 `inspection/recheck`
  - 扩到 `rating/submit`
  - 扩到 `dispute/withdraw`
  - 扩到 payment / billing / settlement / tax
  - 扩到 governance / reporting / moderation console

## 3. Included Scope

### 3.1 Backend Included Scope

- `apps/server` 当前只允许实现 authoring：
  - `exhibition_workbench` 对四容器 summary / handoff 的最小 continuation projection
  - `project` 对以下已冻资产的最小 truth continuation：
    - `project/create`
    - `project/detail`
    - `project/list`
  - `my_project` 对以下已冻资产的最小 private carry continuation：
    - `my/projects`
    - `my/projects/{projectId}`
  - `trading_read_corridor` 对以下最小 read-corridor truth 的闭合：
    - `order/detail`
    - `contract/detail`
    - `milestone/list`
    - `inspection/detail`
  - `milestone/submit`
  - `inspection/submit`
  - `dispute/open`
    只允许按 shell / handoff truth position authoring，不得升格成 active command truth family
  - `upload` 对 `evidence / file_asset` 的三段式复用，不改变 `objectKey` 非真值原则
- `apps/server` 当前不允许实现：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/submit`
  - `dispute/withdraw`
  - 第二状态机
  - 新 path family
  - 把 shell / handoff 节点写成 runtime write chain 已闭环

### 3.2 BFF Included Scope

- `apps/bff` 当前只允许实现 authoring：
  - `exhibition_workbench` 的 summary / handoff shaping
  - `project` 的最小 app-facing shaping：
    - `project/create`
    - `project/detail`
    - `project/list`
  - `my_project` 的最小 private carry shaping：
    - `my/projects`
    - `my/projects/{projectId}`
  - `trading_read_corridor` 的最小 app-facing shaping：
    - `order/detail`
    - `contract/detail`
    - `milestone/list`
    - `inspection/detail`
  - `milestone/submit`
  - `inspection/submit`
  - `dispute/open`
    只允许按 shell / handoff surface position authoring，不得升格成 active command surface family
  - `file` route family 对 upload 三段式的既有复用承接
- `apps/bff` 当前不允许实现：
  - 第二套业务真义
  - 第二套状态机
  - 新 app-facing path
  - 本地 `pass / complete / closed / withdrawable / rateable` 推导
  - 把 `workbench / my-project` 写成 truth owner

### 3.3 Frontend Included Scope

- `apps/mobile` 当前只允许实现 authoring：
  - `/exhibition/workbench` 的四容器 summary / handoff 承接
  - `/exhibition/projects/create`
  - `/exhibition/projects/detail`
  - `/exhibition/projects`
  - `/exhibition/my/projects`
  - `/exhibition/my/projects/detail`
    的既有成熟消费闭合
  - `/exhibition/orders/detail`
  - `/exhibition/contracts/detail`
  - `/exhibition/milestones`
  - `/exhibition/inspections/detail`
    的 read-corridor 消费闭合
  - `/exhibition/milestones/submit`
  - `/exhibition/inspections/submit`
  - `/exhibition/disputes/open`
    只允许按 shell / handoff page position authoring，不得升格成 active command consumption family
- `apps/mobile` 当前不允许实现：
  - `contract_confirm_page`
  - `contract_amend_page`
  - `inspection_recheck_page`
  - `rating_submit_page`
  - `dispute_withdraw_page`
  - 全站 UI 重做
  - 直连 `Server`
  - 把 page shell / placeholder / route presence 写成 runtime 已通

## 4. Execution Environment Boundary

- 前端只在本地执行：
  - `apps/mobile`
- `BFF` 只在云端执行：
  - `apps/bff`
- backend 只在云端执行：
  - `apps/server`
- 当前 bundle 只冻结 dispatch authoring 边界：
  - 不冻结 runtime 通过
  - 不冻结联调通过
  - 不冻结发布通过

## 5. Allowed Directories

- backend dispatch 后续只允许触达：
  - `apps/server/src/modules/exhibition_workbench/**`
  - `apps/server/src/modules/project/**`
  - `apps/server/src/modules/my_project/**`
  - `apps/server/src/modules/trading_read_corridor/**`
  - `apps/server/src/modules/upload/**`
- BFF dispatch 后续只允许触达：
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/bff/src/routes/project/**`
  - `apps/bff/src/routes/my_project/**`
  - `apps/bff/src/routes/trading_read_corridor/**`
  - `apps/bff/src/routes/file/**`
- frontend dispatch 后续只允许触达：
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_text.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/project_create_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/milestone_submit_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/inspection_submit_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/dispute_open_command.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_workbench_contract_validation.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_workbench_contract_mapper.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
  - `apps/mobile/lib/features/exhibition/data/services/my_project_contract_validation.dart`
  - `apps/mobile/lib/features/exhibition/data/services/my_project_contract_mapper.dart`
  - `apps/mobile/lib/features/exhibition/**` 中与上述页面、命令、consumer、mapper 直接相关的最小 supporting touch
- 当前不得放开：
  - `apps/server/src/modules/audit/**` 的新扩面
  - `apps/bff/src/routes/profile/**`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_confirm_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/contract_amend_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/inspection_recheck_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/rating_submit_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/dispute_withdraw_page.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/order_create_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/contract_confirm_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/contract_amend_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/inspection_recheck_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/rating_submit_command.dart`
  - `apps/mobile/lib/features/exhibition/data/commands/dispute_withdraw_command.dart`

## 6. Execution Order

1. `后端 Agent`
   - 先补齐 full-object 的四容器 summary / handoff projection、project_chain 既有成熟资产对齐、read-corridor continuation truth、以及 shell / handoff 节点的最小 truth position
2. `BFF Agent`
   - 再补齐 full-object 的 app-facing shaping、summary / handoff 承接、controlled failure normalization、以及 shell / handoff surface position
3. `前端 Agent`
   - 再补齐 full-object 的 workbench / project / my-project / read-corridor 页面消费闭合，以及 shell / handoff 页面的受控承接
4. `结果校验 Agent`
   - 独立复核：
     - `workbench`
     - `project/create`
     - `project/detail`
     - `project/list`
     - `my/projects`
     - `my/projects/{projectId}`
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `inspection/detail`
     - shell / handoff 节点是否仍未被误写成 active command family
5. `联调发布 Agent`
   - 仅在前四步都通过后，重新给出当前对象的 integration judgment

## 7. Mandatory Receipt Rule

- 当前实现轮继续强制遵守：
  - backend / BFF / frontend 三份回执缺任一项，不启动结果校验
- 含义保持不变：
  - 后端 / BFF 回执允许先落云端
  - 前端回执先落本仓库 `docs/**`
- 当前仍不允许：
  - 用 workbench summary 替代真实回执
  - 用 page shell / placeholder 替代真实回执
  - 用 route presence 替代真实回执
  - 用 docs authoring 替代真实 dispatch send

## 8. Explicit Non-goals

- 不做 `order/create`
- 不做 `contract/confirm`
- 不做 `contract/amend`
- 不做 `inspection/recheck`
- 不做 `rating/submit`
- 不做 `dispute/withdraw`
- 不做 payment / billing / settlement / tax
- 不做 governance / reporting / moderation console
- 不做 history / list / reporting 扩面
- 不做 `bid / award / order conversion` 扩面
- 不做第二状态机
- 不做 `objectKey` 真值化
- 不做 shell / handoff 节点 active-command 化
- 不做 `workbench / my-project` truth-owner 化

## 9. Formal Conclusion

- 当前正式结论如下：
  - `发布项目工作台及延伸功能全链 = 当前可进入 backend implementation dispatch authoring`
  - `implementation unlock / direct implementation / real implementation dispatch issuance / integration / release-prep / production release = 仍然 No-Go`

## 10. Next Unique Action

- 下一步唯一动作：
  - 先向 `后端 Agent` 发出《发布项目工作台及延伸功能全链 backend implementation dispatch》口令

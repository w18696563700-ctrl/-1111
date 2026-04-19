---
owner: Codex 总控
status: active
purpose: >
  Refresh the same-object asset inventory for
  `订单承接与履约承接主链` after reentry stage-gate approval, so the next round
  uses the current repo truth instead of the earlier pre-cleanup inventory,
  while granting neither truth-boundary changes, implementation unlock,
  dispatch send, implementation, integration, nor release permission.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_successor_reentry_ruling_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_reentry_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/order_intake_and_fulfillment_mainline_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_bounded_implementation_dispatch_bundle_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_backend_implementation_dispatch_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_package_level_implementation_unlock_assessment_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_phase0_implementation_exception_assessment_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_phase0_implementation_exception_independent_review_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_phase0_implementation_exception_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/bff/src/routes/trading_shell_handoff/app-trading-shell-handoff.controller.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/my_project/my-project.private-progress.ts
---

# 《订单承接与履约承接主链 fresh asset inventory refresh》

## 1. Scope

- 本文书只回答：
  - 在 reentry stage gate 已通过后，`订单承接与履约承接主链`
    当前 repo 里的现有资产是否发生变化
  - 哪些旧资产继续沿用
  - 哪些旧盘点结论已经失效
  - 下一轮 truth-boundary authoring 应以什么现状为准
- 本文书不是：
  - refreshed truth boundary freeze
  - implementation unlock
  - implementation dispatch send
  - direct implementation
  - integration
  - `release-prep`
  - production release

## 2. Refresh Basis

- 当前 refresh 的直接依据是：
  - `订单承接与履约承接主链 / reentry stage gate checklist = 通过`
- 当前 refresh 同时吸收了前一轮真实代码变化：
  - `发布项目工作台 / Package 2`
    已补上 `order_chain / fulfillment_chain`
    的真实 carrier projection
  - `发布项目工作台 / Package 3`
    已把 `milestone/submit / inspection/submit / dispute/open`
    收正为 shell / handoff runtime
  - `发布项目工作台 / Package 4`
    已清掉 mobile dead-family residue，
    并把 `my-project` 越界 truth 读取收回到 in-scope trade truth
- 当前必须明确：
  - 这不是 root guardrail 已解除
  - 这不是 exception unlock 已通过
  - 这不是 authored dispatch 已可发送

## 3. Refresh Summary

- 与旧版
  [order_intake_and_fulfillment_mainline_asset_inventory_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md)
  相比，当前最重要的 refresh 结论有 4 条：
  1. 旧盘点单中列出的
     `contract_confirm / contract_amend / inspection_recheck / rating / dispute_withdraw / order_create`
     这批 mobile dead-family 资产，
     现在已经不能再被当成 current active assets。
  2. `milestone/submit / inspection/submit / dispute/open`
     不再是“只有 Flutter 页壳，BFF/Server 没有同级 route family”，
     现在已具备 `BFF + Server` shell / handoff runtime。
  3. `workbench.order_chain / fulfillment_chain`
     不再只是空壳 summary，
     现在已有 `activeOrderId / activeMilestoneId`
     及相关 continuation carrier。
  4. `my-project`
     不再读取 `ratings / disputes` 作为私域进度真值输入。

## 4. Carried-forward Assets

### 4.1 继续沿用的 read-corridor runtime

- 当前继续沿用以下 `GET` 读走廊资产：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
- 这 4 条资产继续同时存在于：
  - `mobile canonical path + route helper`
  - `BFF trading_read_corridor`
  - `Server trading_read_corridor`

### 4.2 继续沿用的 shell / handoff runtime

- 当前继续沿用以下 shell / handoff 资产：
  - `POST /api/app/milestone/submit`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/dispute/open`
- 但当前必须继续写死：
  - 它们是 accepted shell / handoff runtime
  - 不是 active trade command family 全闭环

### 4.3 继续沿用的 workbench / my-project reuse boundary

- 当前继续沿用：
  - `workbench` 只负责 summary + handoff
  - `my-project` 只负责 project-level private carry
  - `Flutter App -> BFF -> Server`
    单主通道不变
  - `Server` 仍是唯一 truth owner

## 5. Current Mobile Asset Refresh

### 5.1 当前仍存在的 active mobile 页面与命令

- 当前 active mobile 页面只应按以下集合盘点：
  - [order_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart)
  - [contract_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart)
  - [milestone_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart)
  - [milestone_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart)
  - [inspection_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart)
  - [inspection_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart)
  - [dispute_open_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart)
  - [milestone_submit_command.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/commands/milestone_submit_command.dart)
  - [inspection_submit_command.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/commands/inspection_submit_command.dart)

### 5.2 当前 mobile canonical path 家族

- 当前与本对象直接相关、仍然 active 的 canonical path 为：
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `milestone/submit`
  - `inspection/detail`
  - `inspection/submit`
  - `dispute/open`
- 当前同样必须明确：
  - `bid/submit` 仍是项目展示旁支，不属于当前主链闭环

### 5.3 已失效的旧 mobile 盘点结论

- 旧盘点单中以下 mobile 资产，当前已失效，不得再写成 current active assets：
  - `contract_confirm_page`
  - `contract_amend_page`
  - `inspection_recheck_page`
  - `rating_entry_page`
  - `rating_submit_page`
  - `dispute_withdraw_page`
  - `order_create_command`
  - `contract_confirm_command`
  - `contract_amend_command`
  - `inspection_recheck_command`
  - `rating_submit_command`
  - `dispute_withdraw_command`

## 6. Current BFF Asset Refresh

- 当前 `apps/bff` 与本对象直接相关的 active route family 只有两组：
  1. `trading_read_corridor`
  2. `trading_shell_handoff`
- 因此当前 BFF 真实资产应刷新为：
  - read-corridor 4 条 `GET`
  - shell / handoff 3 条 `POST`
- 当前不得再沿用旧盘点单里的结论：
  - “BFF/Server 并没有对应成体系的 command route family”
- 但同时也不得升级成：
  - “BFF 已具备订单与履约 active command family 全闭环”

## 7. Current Server Asset Refresh

### 7.1 当前 Server runtime 资产

- 当前 `apps/server` 与本对象直接相关的 active module family 也只有两组：
  1. `trading_read_corridor`
  2. `trading_shell_handoff`
- 当前真实 runtime 资产应刷新为：
  - read-corridor 4 条 `GET`
  - shell / handoff 3 条 `POST 202`

### 7.2 当前 workbench carrier 资产

- 当前 `exhibition_workbench.presenter`
  已不再是 order / fulfillment 全空壳。
- 当前已存在的 summary carrier 包括：
  - `order_chain.activeOrderId`
  - `order_chain.activeOrderNo`
  - `order_chain.activeOrderState`
  - `order_chain.canOpenOrderDetail`
  - `order_chain.canOpenContractDetail`
  - `order_chain.canOpenDisputeOpen`
  - `fulfillment_chain.activeMilestoneId`
  - `fulfillment_chain.activeMilestoneTitle`
  - `fulfillment_chain.inspectionState`
  - `fulfillment_chain.canOpenMilestoneList`
  - `fulfillment_chain.canOpenMilestoneSubmit`
  - `fulfillment_chain.canOpenInspectionDetail`
  - `fulfillment_chain.canOpenInspectionSubmit`
- 这意味着：
  - 当前工作台已能提供 continuation carrier
  - 但仍不等于 workbench 成了 detail truth owner

### 7.3 当前 my-project 资产

- 当前 `my-project` 私域进度资产应刷新为：
  - 只使用 `orders / contracts / milestones`
    作为当前 in-scope trade truth 输入
  - `formalCompletionStatus`
    只由 `orderStatus == completed` 推导
  - `evaluationStatus`
    只保留 `eligible / not_eligible`
    的当前 in-scope 语义
- 当前不得再沿用旧盘点单里的结论：
  - `my-project` 仍混入 `ratings / disputes`

## 8. Still-missing Or Still-blocked Assets

- 当前仍然缺失或继续 blocked 的资产包括：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/withdraw`
  - payment / billing / settlement / tax
  - 任何交易后治理后台
- 当前必须继续明确：
  - 这些对象没有因为 reentry 就自动回流
  - 这些对象没有因为旧盘点单曾出现过就重新变成 current scope

## 9. Refresh Meaning

- 当前 refresh 的唯一正确含义是：
  - 让下一轮 truth-boundary authoring
    基于“Package 2-4 已落地后的真实 repo 现状”
    而不是基于旧版、带有 dead-family 残留的盘点单
- 当前明确不是：
  - 订单与履约实现已经可以开始
  - dispatch send 已恢复
  - exception unlock 已通过

## 10. Formal Conclusion

- `Go for refreshed truth boundary freeze authoring`
- `No-Go for Phase 0 implementation exception unlock`
- `No-Go for implementation dispatch send`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 11. Next Unique Action

- 下一步唯一动作：
  - 输出《订单承接与履约承接主链 refreshed truth boundary freeze》

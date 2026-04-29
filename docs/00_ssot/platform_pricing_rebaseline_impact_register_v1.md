---
owner: Codex 总控
status: frozen
purpose: >
  Record the first-round impact register for the 2026-04-29 platform pricing
  rebaseline, separating the current pricing master, superseded historical
  documents, retained-but-not-enabled packages, and the downstream documents
  that must be rewritten before implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-29
inputs_canonical:
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md
  - docs/00_ssot/payment_mvp_scope_ruling_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_rules_freeze_addendum.md
  - docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md
---

# 平台收费重基线影响清单 V1

## 0. 总结论

本清单只做一件事：

- 把 `2026-04-29` 收费重基线之后，哪些文书是当前真相、哪些只是历史记录、哪些暂时保留但不得误当现行真相、哪些必须进入下一轮重写，统一写清楚。

## 1. 当前唯一收费母文件

当前唯一收费母文件：

- [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md)

当前所有收费施工、评审、追问、改稿，默认都应先服从本文件。

## 2. 已被覆盖的历史文书

以下文书保留，但不再作为当前收费真相指挥施工：

1. [exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md)
2. [payment_mvp_scope_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/payment_mvp_scope_ruling_v1.md)
3. [exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md)

这些文书现在只保留三类用途：

1. 审计回溯
2. 差异比对
3. 下游重写时的迁移参考

## 3. 保留但暂不开通

以下文书继续保留，但不得被误读成当前收费执行主线：

1. [membership_direct_purchase_rules_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_direct_purchase_rules_v1.md)
2. [my_building_v20_membership_entitlement_and_quota_rules_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md)
3. [my_building_v22_payment_billing_rules_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v22_payment_billing_rules_freeze_addendum.md)

当前正式解释固定如下：

1. `会员直购` 不是当前收费主线
2. `我的会员` 不是当前收费执行真相 owner
3. `支付与账单状态` 不是当前收费执行真相 owner

## 4. 下一轮必须重写

首轮 `L2 contracts`、`L3 backend truth`、`L4 BFF surface` 与 `L5 Flutter consumption` 已完成，companion-truth completion 也已完成，当前如果继续按新收费母文件施工，已进入 implementation dispatch 准备阶段。

当前新增并已冻结的 implementation authoring 文书包括：

1. [platform_pricing_implementation_unlock_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_implementation_unlock_addendum.md)
2. [platform_pricing_bounded_implementation_dispatch_draft_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_bounded_implementation_dispatch_draft_addendum.md)
3. [platform_pricing_server_implementation_dispatch_draft_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_server_implementation_dispatch_draft_addendum.md)
4. [platform_pricing_bff_implementation_dispatch_draft_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_bff_implementation_dispatch_draft_addendum.md)
5. [platform_pricing_frontend_implementation_dispatch_draft_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_frontend_implementation_dispatch_draft_addendum.md)
6. [platform_pricing_implementation_dispatch_send_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_implementation_dispatch_send_stage_gate_checklist_addendum.md)
7. [platform_pricing_sp1_server_implementation_dispatch_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_sp1_server_implementation_dispatch_addendum.md)

当前如果要继续推进，不再是补新的下游真相，而是进入：

1. implementation unlock assessment
2. runtime drift register
3. pre-implementation gate review
4. implementation dispatch bundle authoring

当前已明确受冲击的代表文件包括：

1. [platform_pricing_backend_truth_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md)
2. [platform_pricing_bff_surface_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/platform_pricing_bff_surface_master_v1.md)
3. [platform_pricing_frontend_consumption_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md)
4. [platform_pricing_rebaseline_pre_implementation_stage_gate_checklist_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rebaseline_pre_implementation_stage_gate_checklist_addendum.md)
5. [platform_pricing_contracts_companion_patch_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/platform_pricing_contracts_companion_patch_v1.md)
6. [platform_pricing_persistence_migration_truth_addendum_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md)
7. [platform_pricing_audit_truth_addendum_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_audit_truth_addendum_v1.md)
8. [platform_pricing_implementation_unlock_assessment_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_implementation_unlock_assessment_addendum.md)
9. [platform_pricing_runtime_drift_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_runtime_drift_register_v1.md)
10. `apps/mobile / apps/bff / apps/server` 的实现切片清单

## 5. 当前禁止动作

在当前 SP-1 send gate 生效后，当前禁止：

1. 发送 `SP-2 / SP-3 / SP-4 / SP-5`
2. 发送 BFF `P1-P4`
3. 发送 Flutter `FP1-FP4`
4. 直接按新收费母文件修改云端 runtime
5. 直接在 Flutter 本地硬改收费文案并绕开 contracts / backend truth / BFF surface / frontend consumption
6. 同时保留旧 `3%` 真相与新 `200 / 4000 / 阶梯费率` 双轨运行
7. 物理删除所有旧文书而不留下 supersede 链

## 6. 下一轮唯一动作

当前 SP-1 implementation dispatch 已发出，下一轮唯一动作固定为：

1. 执行 `SP-1 Server Pricing Kernel & Persistence Normalization`
2. 收集 `SP-1 execution receipt`
3. 基于 SP-1 回执再重提 `SP-2` send gate

当前明确不再是：

1. 继续补 companion truth
2. 继续补新的收费母文件
3. 发送全链路实现包

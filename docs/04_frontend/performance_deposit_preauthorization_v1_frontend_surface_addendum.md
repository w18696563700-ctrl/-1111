---

## Pricing Mainline Override Note

本文件继续保留 `payment MVP / 履约保证金预授权` 的独立保留位意义。

但自 [platform_pricing_frontend_consumption_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md) 生效后，本文件不得再被误读为当前展览收费执行主线的 Flutter authority。

当前正式解释固定如下：

1. 履约保证金不是当前展览收费最小闭环的一部分
2. 本文件不是当前 `200 / 4000 / deal confirmation` 收费主线 owner
3. 当前如需施工履约保证金，必须走独立 reopen，不得借当前展览收费主线顺带解锁
owner: Codex 总控
status: frozen
purpose: Freeze the first execution-oriented L3 frontend surface for `payment MVP / 履约保证金预授权`, including only bounded current-offer, order-create, freeze-init, order-status, appeal, and controlled-failure consumption under `我的信用与约束`, without unlocking implementation, integration, release-prep, or launch.
layer: L3 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/payment_mvp_frontend_surface_freeze_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/03_bff/performance_deposit_preauthorization_v1_bff_surface_addendum.md
  - docs/02_backend/performance_deposit_preauthorization_v1_backend_truth_addendum.md
  - docs/01_contracts/performance_deposit_preauthorization_v1_contracts_addendum.md
  - docs/04_frontend/credit_deposit_transaction_guarantee_v1_frontend_surface_addendum.md
---

# `payment MVP / 履约保证金预授权` Frontend Surface Addendum V1

## A. Current Object

- 本文只适用于：
  - `payment MVP / 履约保证金预授权`
  - execution-oriented `docs/04_frontend` package
- 本文只冻结：
  - current-offer consume surface
  - order-create consume surface
  - freeze-init consume surface
  - order-status consume surface
  - appeal consume surface
  - controlled-failure / fail-closed surface
- 本文当前不代表：
  - implementation unlock
  - runtime freeze success
  - launch approval

## B. Current Frontend-surface Meaning

- 当前 frontend-surface package 只服务于：
  - bounded consume
  - bounded page-state
  - controlled failure
  - non-magical retry / handoff
- Flutter 当前只允许：
  - consume canonical app-facing path
  - display bounded freeze / release / deduction / appeal result
- Flutter 当前不得：
  - 本地判定冻结成功即项目主链已过 gate
  - 本地补写金额真相
  - 本地裁定责任归属
  - 自动切组织掩盖 channel / truth 偏差

## C. Entry And Page-family Rule

- 当前 execution-oriented deposit surface 只允许继续挂在：
  - `我的楼 / 我的信用与约束`
- 当前允许的最小 page family 只限：
  - 冻结方案页
  - 订单确认页
  - 冻结发起承接页
  - 订单结果页
  - 申诉发起页
- 当前 hard rules：
  - 不得挤掉 `我的项目 / 我的论坛 / 设置`
  - 不得把 `我的楼` 变成保证金中心
  - 不得把 `我的信用与约束` 变成 trade cockpit / governance console

## D. Current-offer Consume Surface

- current-offer 页只允许消费和展示：
  - `depositRequirementStatus`
  - `depositEligibilityStatus`
  - `depositTierCode`
  - `freezeAmount`
  - `currency`
  - `bindingReference`
  - `channelCandidates`
  - `updatedAt`
- 当前 hard rules：
  - `bindingReference` 只保持 candidate binding 语义
  - 不得展示成项目主链当前已依赖冻结成功

## E. Order-create / Confirm Surface

- 订单确认页只允许消费和展示：
  - `depositOrderId`
  - `orderStatus`
  - `freezeAmount`
  - `currency`
  - `channelCandidates`
  - `expiresAt`
  - `updatedAt`
- 当前 hard rules：
  - 不得本地推导金额真相
  - 不得本地决定 tier truth
  - 不得伪造 create success 掩盖 backend rejection

## F. Freeze-init Surface

- 冻结发起承接页只允许消费和展示：
  - `freezeInitStatus`
  - `depositOrderId`
  - `paymentReferenceId`
  - `channelActionType`
  - `channelPayload`
  - `callbackAwaiting`
  - `expiresAt`
  - `updatedAt`
- 当前 hard rules：
  - `alipay_preauthorization_candidate` 只保持 candidate 语义
  - `wechat_deposit_pending_verification` 只保持 pending-verification 语义
  - provider private payload 只作为通道承接所需数据，不是前端真相根

## G. Order-status Surface

- 订单结果页只允许消费和展示：
  - `depositOrderId`
  - `orderStatus`
  - `freezeStatus`
  - `releaseStatus`
  - `deductionStatus`
  - `appealStatus`
  - `bindingReference`
  - `amountSummary`
  - `channelSummary`
  - `updatedAt`
- 当前 hard rules：
  - 不得显示成项目主链当前已依赖这些状态推进
  - unknown critical fields / states 必须 fail-closed

## H. Appeal Surface

- 申诉页只允许消费和展示：
  - `appealRequestId`
  - `appealApplyStatus`
  - `depositOrderId`
  - `updatedAt`
- 当前 hard rules：
  - evidence 只保留引用语义
  - 不得展开成完整治理后台细节

## I. Controlled Failure / Fail-closed Rule

- 当前 frontend 必须支持：
  - `DEPOSIT_REQUIREMENT_UNAVAILABLE`
  - `DEPOSIT_ORDER_CREATE_REJECTED`
  - `DEPOSIT_ORDER_NOT_FOUND`
  - `DEPOSIT_FREEZE_INIT_REJECTED`
  - `DEPOSIT_ORDER_RESULT_UNAVAILABLE`
  - `DEPOSIT_APPEAL_APPLY_REJECTED`
  - `CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION`
  - `AUTH_*`
- 当前 hard rules：
  - 不得 hide route drift behind fake success
  - 不得 rewrite unavailable into fake empty state
  - 不得自动续跳到项目主链

## J. Retained No-Go

- 当前继续明确 `No-Go`：
  - generic deposit center UI
  - wallet / balance / offline transfer UI
  - settlement / clearing UI
  - invoice / tax UI
  - finance-admin UI
  - implementation unlock
  - runtime implementation

## K. Formal Conclusion

- 当前正式结论如下：
  - `performance_deposit_preauthorization_v1_frontend_surface_addendum` 已冻结为 `payment MVP / 履约保证金预授权` 的第一份 execution-oriented `L3` frontend surface
  - 当前 package 只冻结最小 current-offer / order-create / freeze-init / order-status / appeal consume surface
  - 当前 package 不改写既有 `credit_deposit_transaction_guarantee_v1_frontend_surface_addendum` 的 bounded posture surface，也不授予 implementation unlock

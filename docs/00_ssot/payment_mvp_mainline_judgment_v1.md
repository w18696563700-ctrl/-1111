---
owner: Codex 总控
status: frozen
purpose: Freeze the payment-MVP mainline judgment for the current commercial-execution planning object, deciding only what the next lawful planning mainline is inside the payment family, without overriding the platform-wide current mainline or unlocking implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/current_stage_and_unique_mainline_ruling_v1.md
  - docs/00_ssot/payment_mvp_stage_gate_checklist_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
---

# 《payment MVP 主线裁决单 V1》

## 1. Current Object

- 当前对象只限：
  - `payment MVP`
  - commercial-execution planning mainline
- 当前对象不等于：
  - 当前平台唯一主线
  - 当前 implementation mainline
  - 当前 integration mainline

## 2. Current Top Judgment

- 当前正式裁决如下：
  - 在 payment 相关 family 内，下一条合法 planning mainline 固定为：
    - `payment MVP`
- 该主线当前最小 planning object 固定为：
  - `会员直购`
  - `履约保证金预授权`
- 当前不接受的候选主线如下：
  - wallet / balance first
  - finance-admin first
  - invoice / tax first
  - settlement / clearing first
  - 只做 profile status 包继续扩写

## 3. Why Current Next Planning Mainline Is Payment MVP

- 原因 1：
  - `我的会员` 当前已是成立的 bounded read package，
    但总表已写死：
    - 购买、续费、支付、账单不在本包
    - 下次开启条件是 `支付 MVP 主线解锁`
- 原因 2：
  - `我的信用与约束` 当前已是成立的 bounded posture package，
    但总表已写死：
    - 不承接真实保证金缴纳、资金冻结、支付执行或结算
    - 下次开启条件是 `支付/账单执行闭环解锁`
- 原因 3：
  - `支付与账单状态` 当前已完成 bounded read-only closure，
    但母文件与总表都已写死：
    - 当前只是 `status / explanation / handoff / dependency`
    - 未来执行主线仍待单独正式解锁
- 因此当前最合理的下一对象不是继续讨论“状态包有没有做完”，而是：
  - 正式判断 payment execution 的最小 planning mainline 应该是什么

## 4. What This Mainline Means

- `payment MVP` 当前只意味着：
  - 为真实商业执行闭环挑出最小可定义对象
  - 为后续 rules / contracts / backend / BFF / frontend 文书链提供上位主线
  - 把 `会员直购` 与 `履约保证金预授权` 从当前旁路 read/posture family 中区分出来
- `payment MVP` 当前不意味着：
  - 当前平台唯一主线已切换到 payment
  - 当前已经获得 implementation unlock
  - 当前已经获得 integration / `release-prep` / launch 许可

## 5. Platform-wide Mainline Non-overwrite Rule

- 当前必须再次写死：
  - 本文不改写 [current_stage_and_unique_mainline_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/current_stage_and_unique_mainline_ruling_v1.md)
- 因此当前只能理解为：
  - `payment MVP` 是 payment family 的下一条 planning mainline
  - 不是平台范围的当前唯一 active implementation mainline

## 6. Rejected Alternatives

- 当前不接受：
  - 继续把 `支付与账单状态` 扩成 payment center
  - 继续把 `我的信用与约束` 扩成真保证金执行系统
  - 先做 wallet / balance / coins
  - 先做 split settlement / finance-admin
  - 先做 invoice / tax full system
  - 先把 payment / deposit execution 接入项目主链

## 7. Current Stage Meaning

- 当前允许含义：
  - 总控可以继续 author：
    - `payment MVP scope ruling`
    - payment-specific rules drafts
    - later contracts/backend/BFF/frontend freezes
- 当前不允许含义：
  - 不能直接开始写 payment code
  - 不能直接下发后端/BFF/前端 execution dispatch
  - 不能写成“项目主链已经接入 payment/deposit gate”

## 8. Next Unique Action

- 下一轮唯一动作：
  - 在本主线下输出：
    - `membership_direct_purchase_rules_v1`
    - `performance_deposit_preauthorization_rules_v1`
  - 上述文书当前状态应保持：
    - `frozen-draft`
    - 或 `pending-gate`
    - 不得直接写成现行 execution SSOT

## 9. Formal Conclusion

- 当前正式结论如下：
  - `payment MVP` 已被裁决为 payment family 的下一条合法 planning mainline
  - 当前最小 planning object 固定为：
    - `会员直购`
    - `履约保证金预授权`
  - 本裁决不改写平台级当前唯一主线
  - 本裁决只放行 planning truth，不放行 implementation

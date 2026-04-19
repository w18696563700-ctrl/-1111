---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded scope ruling for the current `payment MVP` planning object, deciding only what belongs to the MVP object, what stays outside, and how channel constraints must be treated, without unlocking implementation or rewriting current profile-side bounded packages.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/payment_mvp_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_mvp_mainline_judgment_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
---

# 《payment MVP 范围裁决单 V1》

## 1. Scope

- 本单只裁决：
  - `payment MVP` 当前 planning object 的范围
- 本单不裁决：
  - execution rules freeze
  - contracts freeze
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - implementation unlock

## 2. Current In-scope

- 当前 `payment MVP` 只允许纳入以下两类对象：
  - `会员直购`
  - `履约保证金预授权`

### 2.1 `会员直购`

- 当前范围只允许包含：
  - membership SKU
  - membership direct-purchase order
  - payment transaction
  - callback verification
  - entitlement granting
  - payment result / entitlement result readback
- 当前正式语义只允许是：
  - organization-scope commercial entitlement execution
- 当前不得被解释成：
  - wallet recharge
  - balance deduction
  - stored-value system
  - guarantee payment

### 2.2 `履约保证金预授权`

- 当前范围只允许包含：
  - deposit tier / requirement truth
  - preauthorization freeze
  - release / deduction / appeal minimal flow
  - result readback
  - audit and evidence linkage
- 当前正式语义只允许是：
  - trade-performance guarantee execution candidate
- 当前不得被解释成：
  - platform income
  - membership fee
  - platform balance
  - unlimited compensation pool

## 3. Shared Truth Families Inside The MVP

- 当前若进入后续文书链，只允许围绕：
  - payment order
  - payment transaction
  - callback result
  - entitlement write result
  - deposit freeze / release / deduction result
  - appeal / audit linkage
- 当前不得顺手扩入：
  - invoice
  - tax
  - split settlement
  - finance-admin
  - platform treasury / wallet

## 4. Current Out-of-scope

- 当前明确排除：
  - wallet
  - balance
  - coins
  - recharge
  - withdrawal
  - manual transfer reconciliation
  - membership and deposit mixed payment
  - project payment / order payment
  - split settlement / clearing
  - invoice / tax full system
  - finance-admin
  - generic payment center
  - generic billing center

## 5. Relationship With Current Profile Packages

- 当前必须写死：
  - `我的会员` 仍是 bounded read package
  - `我的信用与约束` 仍是 bounded posture package
  - `支付与账单状态` 仍是 bounded read-only package
- `payment MVP` 当前只是：
  - 它们未来 execution mainline 的 planning 上位件
- 当前不得把本单写成：
  - 已经回写并替代上述三包的现行真源

## 6. Relationship With Project Mainline

- 当前必须继续遵守：
  - 会员未接入项目主链
  - 支付 / 账单未接入项目主链
  - 保证金未接入项目主链执行真值
- 因此当前不得把 `payment MVP` 写成：
  - project publish gate
  - current bid gate
  - current contract gate
- 若未来接线，仍必须服从既有上位裁决：
  - membership 最早只可能作为软特权候选
  - payment / deposit 的最早接线位点必须另行冻结

## 7. Channel-constraint Rule

- 当前必须写死：
  - 外部支付渠道规则不自动等于平台内部真源
- 因此当前对以下内容只允许写成：
  - `channel constraint`
  - `operational assumption`
  - `pending verification`
- 当前不得直接冻结为平台永久真源的内容包括：
  - 某一支付渠道的默认结算时效细节
  - 某一支付渠道对特定商户类型的长期准入口径
  - 某一支付渠道未来不变的产品策略

## 8. Sequencing Rule

- 当前最小 sequencing 固定为：
  - 先有 `payment MVP` 上位 planning truth
  - 再 author package-level rules drafts
  - 再判断是否进入 contracts/backend/BFF/frontend 文书链
  - 最后才可能评估 implementation unlock
- 当前不得：
  - 省略中间层
  - 直接从 planning 跳到 coding

## 9. Next Unique Action

- 下一轮唯一动作：
  - 在本范围内 author：
    - `membership_direct_purchase_rules_v1`
    - `performance_deposit_preauthorization_rules_v1`
  - 如需引用渠道产品限制，再单独 author：
    - `payment_channel_constraints_assumptions_v1`

## 10. Formal Conclusion

- 当前正式结论如下：
  - `payment MVP` 的 planning scope 已冻结为：
    - `会员直购`
    - `履约保证金预授权`
  - wallet / balance / settlement / invoice / finance-admin 等对象全部在当前范围外
  - 外部渠道规则当前只能作为 constraint / assumption，不得直接冻结成平台内核真源
  - 本单只冻结范围，不放行 implementation

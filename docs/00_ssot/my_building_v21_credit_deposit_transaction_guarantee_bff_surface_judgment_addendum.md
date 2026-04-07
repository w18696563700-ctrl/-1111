---
owner: 总控文书冻结
status: frozen
purpose: Freeze the BFF-surface judgment for `我的楼 V2.1 信用 / 保证金 / 交易保障`, deciding only whether the current package may enter BFF surface freeze and what bounded app-facing shaping, normalize, route, and dependency-reference families may be frozen next, without entering BFF-surface body, frontend freeze, implementation unlock, or runtime implementation.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/my_building_effective_truth_baseline_ruling_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_package_boundary_judgment_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_minimum_package_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_rules_freeze_judgment_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_rules_freeze_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_contracts_judgment_addendum.md
  - docs/01_contracts/credit_deposit_transaction_guarantee_v1_contracts_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_backend_truth_judgment_addendum.md
  - docs/02_backend/credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md
---

# 《我的楼 V2.1 信用 / 保证金 / 交易保障 BFF-surface judgment》

## A. Current Object

- 当前对象：
  - `我的楼专项开发主线`
  - `V2.1 信用 / 保证金 / 交易保障`
- 当前裁决类型：
  - BFF-surface judgment only

## B. Current Prerequisite Intake

- 当前 prerequisite intake 已成立如下：
  - `package boundary judgment` 已完成
  - `minimum package boundary freeze` 已完成
  - `rules-freeze judgment` 已完成
  - `rules freeze` 已完成
  - `contracts judgment` 已完成
  - `contracts freeze` 已完成
  - `backend-truth judgment` 已完成
  - `backend truth freeze` 已完成
- 当前 package 已经明确：
  - `V2.0` 只解决 membership commercial family
  - `V2.1` 只停在 constraint / deposit posture / guarantee posture family
  - `V2.2` 才承接真实 payment / billing / funds execution
- 当前仍未进入：
  - BFF surface freeze 正式文书
  - frontend surface freeze
  - implementation
  - payment runtime
  - governance console runtime

## C. Current Judgment

- 当前 judgment：
  - `通过`
- 当前正式判断如下：
  - `V2.1` 已具备进入 `BFF surface freeze` 的合法前提
  - 当前只表示：
    - `当前可进入 BFF surface freeze`
  - 当前不表示：
    - `BFF surface freeze 已完成`
    - BFF ready
    - implementation ready
    - payment ready

## D. Current Allowed BFF Surface Families

- 如果进入 `BFF surface freeze`，当前最多只允许冻结以下 app-facing families：
  - 私域 `status / explanation / handoff` shaping family
  - 信用约束状态 shaping family
  - 保证金 `requirement / eligibility / restriction / status` shaping family
  - 交易保障 `eligibility / restriction / handoff` shaping family
  - 与 `V2.2` 的 dependency reference shaping family
- 上述 families 当前只允许停在：
  - read-only app-facing shaping layer
  - normalize layer
  - controlled error-family layer
  - explanation / handoff projection layer
- 上述 families 当前不得越级变成：
  - runtime funds execution layer
  - payment / billing runtime layer
  - governance-console surface layer
  - implementation unlock basis by themselves
- 当前 shell / profile side BFF surface 最多只允许承接：
  - bounded private status summary
  - explanation projection
  - handoff projection
  - dependency reference projection

## E. Current Allowed BFF Route Direction

- 当前最小 route family 方向只允许：
  - `/api/app/profile/credit-and-constraints/*`
- 当前最小读路径只允许：
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`
- 当前 round 只允许读路径：
  - no write commands
  - no command-side execution handoff
- 当前明确禁止：
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/settlement/*`
  - 路由漂到 `messages`
  - 路由漂到 `exhibition`
  - 路由漂到 hidden building

## F. Current Retained No-Go

- 当前仍然 `No-Go`：
  - 具体金额 surface
  - payment / billing / settlement runtime surface
  - funds execution surface
  - dispute-detail surface
  - admin console surface
  - implementation unlock
- 当前也仍然 `No-Go`：
  - BFF surface freeze 正式文书以外的 runtime funds shaping
  - frontend surface freeze body
  - runtime implementation

## G. V2.0 Split Stability

- 当前写死：
  - `V2.0` 与 `V2.1` 的边界已稳定到可进入 BFF surface freeze
- 当前稳定边界如下：
  - `V2.0` 继续只解决：
    - membership commercial family
    - 商业权益
    - 费率
    - quota
    - upgrade guidance
  - `V2.1` 继续只解决：
    - constraint family
    - 交易约束
    - 履约约束
    - 保证金 posture
    - 交易保障 posture
- 当前仍然明确禁止：
  - 会员等级 = 交易资格
  - 会员状态 = 保证金已缴
  - 会员权益 = 交易保障已生效

## H. V2.2 Dependency Stability

- 当前写死：
  - `V2.1` 可以冻结 dependency reference shaping
  - 但不得冻结 funds execution shaping
- 所有真实资金动作当前仍需：
  - `V2.2 payment/billing package`
- 因此当前 BFF surface freeze 最多只允许冻结：
  - dependency required flag shaping
  - dependency explanation shaping
  - dependency handoff shaping
  - dependency family-key shaping
- 当前不得冻结：
  - payment execution shaping
  - billing execution shaping
  - settlement execution shaping
  - funds movement shaping

## I. Drift Guard

- 当前继续写死：
  - `我的楼` 不得漂成第二 dashboard
  - `我的楼` 不得漂成交易运营台
  - `我的楼` 不得漂成治理后台
  - `我的项目 / 我的论坛 / 设置` 现有家族不得被抹掉或降级
  - `我的信用与约束` 仍只是 bounded entry direction，不是 runtime final IA truth
- 当前也继续写死：
  - `我的项目` 继续承接项目资产与推进
  - 公域交易继续承接交易对象与交易主流程
  - 不得把 `我的项目` 主链吞并进 `V2.1`

## J. Formal Conclusion

- `V2.1 信用 / 保证金 / 交易保障 BFF-surface judgment 已完成`
- `当前可进入 V2.1 BFF surface freeze`
- 当前不代表：
  - BFF ready
  - implementation ready
  - payment ready
  - launch ready

## K. Next Unique Action

- 下一轮唯一动作：
  - 输出《我的楼 V2.1 信用 / 保证金 / 交易保障 BFF surface freeze》

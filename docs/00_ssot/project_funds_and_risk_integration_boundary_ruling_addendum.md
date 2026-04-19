---
owner: Codex 总控
status: frozen
purpose: >
  Freeze how certification, membership, payment, billing, credit constraints,
  deposit, and transaction guarantee relate to the current project mainline,
  including what is already a hard gate, what remains bounded profile posture,
  and when future integration is allowed.
layer: L0 SSOT
freeze_date_local: 2026-04-10
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/s1_r03_certification_upload_submit_resubmit_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/s1_r04_certification_minimal_review_ops_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md
  - docs/00_ssot/my_building_v20_paid_membership_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_minimum_package_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_v21_credit_deposit_transaction_guarantee_bounded_implementation_review_conclusion_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_minimum_package_boundary_freeze_addendum.md
  - docs/00_ssot/my_building_v22_payment_billing_bounded_implementation_review_conclusion_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md
  - docs/01_contracts/membership_entitlement_v1_contracts_addendum.md
  - docs/01_contracts/credit_deposit_transaction_guarantee_v1_contracts_addendum.md
  - docs/01_contracts/payment_billing_v1_contracts_addendum.md
  - docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md
  - docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md
  - docs/02_backend/credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md
  - docs/02_backend/payment_billing_v1_backend_truth_addendum.md
  - docs/03_bff/account_and_enterprise_certification_rules_v1_bff_surface_addendum.md
  - docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md
  - docs/03_bff/credit_deposit_transaction_guarantee_v1_bff_surface_addendum.md
  - docs/03_bff/payment_billing_v1_bff_surface_addendum.md
  - docs/04_frontend/account_and_enterprise_certification_rules_v1_frontend_surface_addendum.md
  - docs/04_frontend/membership_entitlement_v1_frontend_surface_addendum.md
  - docs/04_frontend/credit_deposit_transaction_guarantee_v1_frontend_surface_addendum.md
  - docs/04_frontend/payment_billing_v1_frontend_surface_addendum.md
  - apps/server/src/modules/membership/membership.controller.ts
  - apps/server/src/modules/payment_billing/payment-billing.controller.ts
  - apps/server/src/modules/credit_constraints/credit-constraints.controller.ts
  - apps/bff/src/routes/profile/profile-membership.service.ts
  - apps/bff/src/routes/profile/profile-payment-billing-status.service.ts
  - apps/bff/src/routes/profile/profile-credit-constraints.service.ts
  - apps/mobile/lib/features/profile/data/profile_membership_consumer_layer.dart
  - apps/mobile/lib/features/profile/data/profile_payment_billing_consumer_layer.dart
  - apps/mobile/lib/features/profile/data/profile_credit_constraints_consumer_layer.dart
  - apps/mobile/test/profile_payment_billing_contract_test.dart
---

# 《项目资金与风控接线边界裁决单》

## 1. Scope

本单只裁决：

- 认证
- 会员
- 支付 / 账单
- 信用约束 / 保证金 / 交易保障

这些对象与当前项目主线之间的关系。

本单不做：

- 真实支付执行设计
- 账单/发票/结算全链设计
- 具体金额 / 费率 / 扣罚 / 赔付规则
- 任何业务代码改动

## 2. 当前总裁决

当前正式关系冻结如下：

- 认证：**已进入项目主链，且是发布与竞标的硬 gate**
- 会员：**未进入项目主链硬 gate；当前只允许保持在 `profile/membership/*` bounded commercial read package**
- 支付 / 账单：**当前只允许保持在 `profile/payment-and-billing-status/*` bounded status / explanation / handoff package**
- 信用约束 / 保证金 / 交易保障：**当前只允许保持在 `profile/credit-and-constraints/*` bounded posture / status / handoff package**

因此当前必须承认：

- 认证已经进入项目主链
- 会员没有进入项目主链
- 支付 / 账单没有进入项目主链
- 信用 / 保证金 / 交易保障没有进入项目主链

## 3. 主链依赖矩阵

| 对象 | 当前与项目主链关系 | 当前状态 | 未来最早允许接入点 | 当前结论 |
|---|---|---|---|---|
| 认证 | 已接入 | 发布硬 gate；bid guard 也要求 `certificationStatus=approved` | 已在 `发布前 / bid前` 生效 | 已进入主链 |
| 会员 | 未接入 | `profile/membership/*` read-first commercial package | 最早仅可在 `发布前` 以软特权方式接入，且不得替代认证/保证金 | 当前必须停留旁路 |
| 支付 | 未接入 | `payment-status / handoff / explanation` bounded package | 最早 `成交前`，且必须在交易骨架与风险 gate 定位完成之后 | 当前必须停留旁路 |
| 账单 | 未接入 | `billing-reference / explanation / handoff` bounded package | 最早 `合同后`，作为 obligation/reference family 接入 | 当前必须停留旁路 |
| 信用约束 | 未接入 | 约束 posture / status / handoff | 最早 `成交前`，作为 bid->order 或 order->contract gate | 当前必须停留旁路 |
| 保证金 | 未接入 | requirement / eligibility / restriction / status posture | 最早 `成交前 / 合同前`，作为硬 gate 接入 | 当前必须停留旁路 |
| 交易保障 | 未接入 | eligibility / restriction / handoff posture | 最早 `成交前 / 合同前`，作为硬 gate 接入 | 当前必须停留旁路 |

## 4. 硬前置 / 软前置 / 未接入 / 未来接入点表

| 对象 | 当前分类 | 说明 |
|---|---|---|
| 认证 | 硬前置 | 当前发布资格真源已收口到 Server eligibility/policy；当前 publish/bid release 依赖认证通过 |
| 会员 | 软前置候选，当前未接入 | 当前只承接商业权益、费率档位、quota 与升级引导；不得作为交易资格 gate |
| 支付 | 未接入 | 当前只有 status / explanation / handoff，不是 payment execution |
| 账单 | 未接入 | 当前只有 billing-reference / explanation / handoff，不是账单中心 |
| 信用约束 | 未接入 | 当前只有 posture/status，不是项目主线 gate |
| 保证金 | 未接入 | 当前只有 requirement/eligibility/restriction/status posture，不是已缴纳真值 |
| 交易保障 | 未接入 | 当前只有 posture/handoff，不是已生效执行真值 |

## 5. 未来接入点冻结规则

### 5.1 认证

- 已经是当前主链的硬前置。
- 当前接入点固定为：
  - `发布前`
  - `bid前`
- 不得降级为：
  - 仅 UI 提示
  - 仅 shell 摘要
  - 仅 workbench 布尔值

### 5.2 会员

- 当前只能作为：
  - 商业权益层
  - read-first private package
- 当前不得作为：
  - 发布 gate
  - bid gate
  - 保证金已缴语义
  - 交易保障已生效语义
- 若未来要接入项目主链，最早只能是：
  - `发布前` 的软特权层
- 未来也不得替代：
  - 认证
  - 信用约束
  - 保证金

### 5.3 信用约束 / 保证金 / 交易保障

- 当前只允许作为：
  - posture / status / explanation / handoff
- 当前不得作为：
  - 已缴费
  - 已冻结资金
  - 已完成赔付
  - 已可成交
- 未来若接入项目主链，最早接入点固定为：
  - `成交前`
  - 更具体地说，是 `bid -> order` 或 `order -> contract` 的硬 gate
- 当前不得前移到：
  - `project/create`
  - `project/list`
  - `project/detail`
  的真源语义

### 5.4 支付 / 账单

- 当前只允许作为：
  - status
  - explanation
  - handoff
  - dependency reference
- 当前不得作为：
  - payment execution
  - billing center
  - settlement / clearing
  - finance-admin
- 未来接入点冻结为：
  - 支付最早 `成交前`
  - 账单最早 `合同后`
- 在那之前不得把 profile bounded status 页解释成：
  - 当前项目主链已具备资金执行能力

## 6. 当前禁止误判清单

- 不得把 `profile/payment-and-billing-status/*` 当成支付执行能力。
- 不得把 `profile/payment-and-billing-status/*` 当成账单中心、发票中心、清结算中心。
- 不得把 `profile/credit-and-constraints/*` 当成交易 gate 已成立。
- 不得把 `我的信用与约束` 的 posture/status 页当成“保证金已缴、交易保障已生效”的执行真值。
- 不得把 `membership/current`、`membership/quota`、`membership/upgrade-guide` 当成项目主链放行条件。
- 不得把 Package 1 `membershipStatus` 当成 paid membership truth。
- 不得把 paid membership 当成认证替代物。
- 不得把认证之外的 profile posture/status 家族偷偷接成当前 publish gate。

## 7. 对项目主链的当前影响结论

当前与项目主链真实相连的只有：

- `Server` eligibility / policy
- current session
- organization scope
- role
- approved certification

当前**没有**真实相连的对象是：

- paid membership
- payment execution
- billing execution
- deposit paid truth
- transaction guarantee active truth
- finance-admin or settlement truth

因此当前不得说：

- “项目主线已经带上资金链”
- “项目主线已经带上保证金 gate”
- “项目主线已经带上信用/约束硬 gate”

## 8. Formal Conclusion

本单正式写死：

- 认证是当前唯一已经进入项目主链的资金/风控/资格相关硬前置对象。
- 会员当前仍必须停留在旁路商业 read package。
- 支付 / 账单当前仍必须停留在旁路 status/handoff package。
- 信用约束 / 保证金 / 交易保障当前仍必须停留在旁路 posture/status/handoff package。
- 下一阶段不得先做资金链。
- 下一阶段若要接这几类对象，必须先完成交易骨架，并先决定它们各自接在：
  - `发布前`
  - `成交前`
  - `合同前/后`
  的哪一个唯一位置。

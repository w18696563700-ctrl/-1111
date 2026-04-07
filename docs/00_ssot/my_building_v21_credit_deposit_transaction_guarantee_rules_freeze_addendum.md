---
owner: 总控文书冻结
status: frozen
purpose: Freeze the bounded rule families for `我的楼 V2.1 信用 / 保证金 / 交易保障`, fixing only the current rule-and-status, explanation, handoff, and dependency rules without entering contracts freeze, implementation unlock, or runtime implementation.
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
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/01_contracts/blacklist_whitelist_and_permanent_ban_rules_v1_contracts_addendum.md
  - docs/02_backend/blacklist_whitelist_and_permanent_ban_rules_v1_backend_truth_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
---

# 《我的楼 V2.1 信用 / 保证金 / 交易保障 rules freeze》

## A. Current Object

- 当前对象：
  - `我的楼专项开发主线`
  - `V2.1 信用 / 保证金 / 交易保障`
- 当前裁决类型：
  - `rules freeze`

## B. Current Rule-layer Meaning

- 当前 rules freeze 只冻结：
  - `rule-and-status layer`
  - `explanation layer`
  - `handoff layer`
  - bounded `dependency rules`
- 当前 rules freeze 的 formal meaning 只到：
  - 信用约束 posture 规则
  - 保证金 requirement / eligibility / restriction / status posture 规则
  - 交易保障 eligibility / restriction / handoff posture 规则
  - 私域 status / rule explanation / handoff 规则
- 当前明确不得进入：
  - runtime funds execution
  - runtime payment / billing
  - governance console detail
  - implementation unlock

## C. Allowed Rule Families

- 当前允许冻结的规则族写死如下：
  - 信用约束状态规则
  - 保证金 `requirement / eligibility / restriction / status` 规则
  - 交易保障 `eligibility / restriction / handoff` 规则
  - 私域 `status / rule explanation / handoff` 规则
  - 与 `V2.2` 的 dependency rules
- 上述规则族当前的冻结上限写死如下：
  - 只冻结规则语义
  - 只冻结状态表达
  - 只冻结解释文案方向
  - 只冻结 handoff 条件与 handoff 指向
- 上述规则族当前不得被扩写成：
  - 资金动作执行规则
  - 运营台操作规则
  - admin console 流程规则

## D. Credit Constraint Rules

- 当前信用规则最多只冻结：
  - 什么情形构成信用约束 posture
  - 什么情形构成履约约束 posture
  - 什么情形构成限制状态
  - 什么情形构成提示状态
  - 什么情形构成不可执行状态
  - 这些状态如何以私域 status / rule explanation 形式存在
- 当前信用规则只允许表达：
  - 资格受限
  - 履约受限
  - 规则提示
  - 需补足前置条件后再进入后续流程
- 当前信用规则明确不得冻结：
  - 评分引擎
  - 算法权重
  - 自动风控执行
  - 对外部交易主流程的自动处置编排
- `blacklist / whitelist / permanent-ban` 当前只允许作为：
  - 约束语义参考素材
  - 治理边界素材
  - not current `V2.1` package truth itself

## E. Deposit Requirement / Eligibility / Restriction / Status Rules

- 当前保证金规则最多只冻结：
  - requirement posture
  - eligibility posture
  - restriction posture
  - status posture
  - handoff posture
- 当前保证金 status 规则只允许表达：
  - 当前是否要求保证金前置
  - 当前是否满足进入后续阶段的资格前置
  - 当前是否因保证金相关约束而受限
  - 当前应 handoff 到何种后续依赖 family
- 当前保证金规则明确不得冻结：
  - 具体金额
  - 金额档位
  - 金额计算公式
  - 资金冻结执行
  - 扣罚执行
  - 赔付执行
  - 退款执行
  - 清算执行

## F. Transaction Guarantee Eligibility / Restriction / Handoff Rules

- 当前交易保障规则最多只冻结：
  - eligibility posture
  - restriction posture
  - handoff posture
  - rule explanation posture
- 当前交易保障规则只允许表达：
  - 当前是否具备保障资格
  - 当前是否受到保障限制
  - 当前需补足何种规则前置
  - 当前应从 `我的楼` handoff 到何种后续能力 family
- 当前交易保障规则明确不得冻结：
  - dispute 细则
  - admin 裁定台
  - 治理后台操作流
  - 项目/订单/合同的执行性裁决流

## G. Private Status / Rule Explanation / Handoff Rules

- 当前 `我的楼` 下只允许冻结：
  - bounded private status visibility rules
  - bounded rule explanation rules
  - bounded handoff rules
- 当前唯一允许持续承接的 bounded entry direction 是：
  - `我的信用与约束`
- 当前不冻结为：
  - `我的保证金`
- 原因继续写死如下：
  - `我的保证金` 语义过窄
  - 容易滑向 funds semantics
  - 不符合当前 `rule-and-status` 最小 package meaning
- 上述 entry direction 当前只表示：
  - bounded entry direction
  - not runtime final IA truth

## H. V2.0 Split Rules

- `V2.0 paid membership` 继续只解决：
  - 商业权益
  - 费率
  - quota
  - upgrade guidance
- `V2.1` 继续只解决：
  - 交易约束
  - 履约约束
  - 保证金 posture
  - 交易保障 posture
- 当前继续明确禁止：
  - 会员等级 = 交易资格
  - 会员状态 = 保证金已缴
  - 会员权益 = 交易保障已生效
- 当前也继续禁止：
  - 用 membership 规则回写交易约束真相
  - 用 `V2.1` 规则回写 commercial entitlement truth

## I. V2.2 Dependency Rules

- 所有真实资金动作当前继续只能标记为：
  - `requires V2.2 payment/billing package dependency`
- 上述真实资金动作包括：
  - 冻结
  - 扣罚
  - 赔付
  - 退款
  - 代收
  - 清算
  - 结算
- 当前 rules freeze 只允许冻结：
  - requirement dependency
  - eligibility dependency
  - restriction dependency
  - handoff dependency
- 当前 rules freeze 明确不得把 dependency rule 写成：
  - funds execution rule
  - payment execution rule
  - billing execution rule
  - settlement execution rule

## J. Truth-owner Rules

- 当前 truth-owner 规则写死如下：
  - 入口 owner 可以归 `我的楼 / profile`
  - truth owner 不自动归 `profile`
- 若未来存在 `信用 / 保证金 / 交易保障` truth：
  - 仍应由 `Server` 侧相应业务 family 持有
- 当前明确禁止：
  - `BFF` 持有信用真相
  - `BFF` 持有保证金真相
  - `BFF` 持有交易保障真相
- 当前也明确禁止：
  - 把旧治理基线直接偷换成 `V2.1 package truth`

## K. Drift Guard

- `我的楼` 不得因为 `V2.1` 漂成：
  - 第二 dashboard
  - 交易运营台
  - 治理后台
- `我的项目 / 我的论坛 / 设置` 现有家族不得被抹掉或降级。
- 当前不得把 `我的项目` 主链吞并进 `V2.1`。
- `V2.1` 若未来进入 `我的楼`，当前也只允许作为：
  - bounded status / rule handoff family
  - not a second operations console

## L. Retained No-Go

- 当前继续明确 `No-Go`：
  - 具体金额冻结
  - 具体金额扣罚 / 赔付
  - 实际资金冻结 / 退款 / 代收 / 清算
  - 账单 / 发票 / 结算
  - 风控评分引擎
  - dispute 细则
  - admin console 细则
  - frontend IA 定稿
  - contracts freeze
  - implementation unlock
  - runtime implementation
- 当前也继续明确 `No-Go`：
  - backend truth freeze
  - BFF surface freeze
  - frontend surface freeze
  - payment runtime
  - billing runtime
  - settlement runtime

## M. Formal Conclusion

- `V2.1 信用 / 保证金 / 交易保障 rules freeze 已完成`
- `当前可进入 contracts judgment`
- 当前不代表：
  - contracts ready
  - implementation ready
  - payment ready
  - launch ready

## N. Next Unique Action

- 下一轮唯一动作：
  - 输出《我的楼 V2.1 信用 / 保证金 / 交易保障 contracts judgment》

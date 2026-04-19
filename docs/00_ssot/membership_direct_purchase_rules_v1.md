---
owner: Codex 总控
status: frozen-draft
purpose: Freeze the next-mainline rules draft for `会员直购` under the current `payment MVP` planning object, without making it current effective execution truth or unlocking contracts, implementation, integration, release-prep, or launch.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/payment_mvp_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_mvp_mainline_judgment_v1.md
  - docs/00_ssot/payment_mvp_scope_ruling_v1.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
---

# 《会员直购规则 V1》

## 1. Current Position

- 本文当前只作为：
  - `payment MVP`
  - `会员直购`
  的 next-mainline rules draft
- 本文当前不是：
  - 现行 execution SSOT
  - contracts freeze
  - implementation unlock
  - release-ready 文书

## 2. Scope

- 本文只服务于：
  - 会员直购最小执行闭环规则草案
  - membership direct-purchase order 规则草案
  - payment success -> entitlement granting 规则草案
- 本文不服务于：
  - wallet
  - balance
  - stored value
  - membership 与 deposit 混扣
  - invoice / tax full system
  - finance-admin
  - split settlement / clearing

## 3. Current Draft Judgment

- 当前 draft judgment 固定如下：
  - 会员直购可作为 `payment MVP` 当前第一执行对象之一
  - 会员费必须与履约保证金严格分离
  - 会员费不是押金
  - 会员费不是平台余额
  - 会员费不可提现
  - 当前最小支付模式只讨论：
    - direct purchase
  - 当前不讨论：
    - wallet recharge
    - balance deduction
    - coins deduction
    - manual transfer reconciliation

## 4. Commercial Subject Rule

- 当前 draft subject baseline 固定为：
  - membership entitlement 按 organization scope 生效
- 当前购买主体 draft 规则固定为：
  - 当前 actor 已登录
  - 当前 organization 已确定
  - 当前 organization 具备合法购买主体资格
- 当前不得写成：
  - actor 私人零钱会员
  - 同一订单对多个 organization 同时生效
  - membership entitlement 与个人余额账户绑定

## 5. SKU Rule

- 当前 membership direct-purchase draft 至少需要以下 truth family：
  - `skuCode`
  - `skuName`
  - `membershipLevel`
  - `durationDays` 或 `durationMonths`
  - `priceAmount`
  - `currency`
  - `entitlementSnapshot`
  - `isRenewable`
  - `isUpgradable`
  - `displayOrder`
  - `status`
- 当前真相 owner 继续固定为：
  - `Server.membership / payment`
- 当前继续明确禁止：
  - Flutter 本地硬编码价格真相
  - BFF 本地维护第二 SKU 真相

## 6. Payment Path Draft Rule

- 当前 draft payment path 固定为：
  - membership order create
  - pay
  - callback verify
  - order status transition
  - entitlement write
  - result readback
- 当前 draft channel direction 只允许写成：
  - `微信支付 / 支付宝直付 candidate`
- 上述 channel direction 当前只表示：
  - planning candidate
  - not platform-internal permanent truth
- 若需冻结更细的渠道限制、商户准入、时效、结算差异：
  - 必须进入单独的 `payment_channel_constraints_assumptions` 文书

## 7. Pre-pay Validation Rule

- 当前 draft pre-pay validation 至少包括：
  - actor 已登录
  - current organization 已确定
  - SKU 当前可售
  - 当前 organization 未命中禁止购买规则
  - 当前订单未重复创建
  - 当前请求未命中幂等冲突

## 8. Order-state Draft Rule

- 当前 membership order draft 状态固定为：
  - `created`
  - `pending_pay`
  - `paying`
  - `paid`
  - `granting`
  - `active`
  - `closed`
  - `failed`
  - `refunded`
  - `refund_partially_processed`
  - `refund_completed`
- 当前状态语义固定为：
  - `paid` 只表示 payment transaction success
  - `active` 才表示 entitlement 已写入并生效
  - `failed` 不得开通任何 entitlement
  - refund 相关状态不得跳过 entitlement 修正

## 9. Entitlement Activation Rule

- 当前 draft activation 规则固定为：
  - entitlement 生效唯一依据仍在 Server
  - payment success 弹窗不构成 entitlement truth
  - callback verify success + order transition success + entitlement write success 才构成最终生效
- 当前续费 / 升级规则只允许先冻结到：
  - 续费可顺延
  - 升级必须有单独补差价规则
- 若升级补差价规则未冻结：
  - 升级入口最多只允许展示，不得开放执行

## 10. Refund Draft Rule

- 当前 refund 规则草案只允许表达：
  - 支付成功但 entitlement 未实际生效时，可进入全额退款候选
  - entitlement 已生效后的退款，必须服从单独公示的会员服务规则
  - 退款、拒退、部分退款都必须留痕
- 当前不得出现：
  - 无订单退款
  - 客服口头退款即生效
  - 先退钱后补状态
  - 不留痕回收 entitlement

## 11. Owner And System Boundary

- 以下真相 owner 当前继续固定为：
  - `Server.membership`
  - `Server.payment`
- BFF 当前只允许：
  - shaping
  - auth consolidation
  - controlled failure normalization
- BFF 当前不得：
  - 持有第二 membership-order 状态机
  - 本地判定 entitlement 是否已生效
- Flutter 当前只允许：
  - 发起 app-facing 请求
  - 展示支付状态
  - 展示 entitlement 结果
  - 展示失败与重试引导
- Flutter 当前不得：
  - 直接信任前端支付完成态为最终真相
  - 本地补写 entitlement 生效状态
  - 本地缓存长期支付真相

## 12. Explicit Non-goals

- 当前明确不做：
  - wallet
  - balance
  - recharge
  - withdrawal
  - coins
  - membership 与 deposit 混付
  - membership 与 trade payment 混付
  - invoice / tax full system
  - split settlement / clearing
  - finance-admin

## 13. Formal Draft Conclusion

- 当前正式结论如下：
  - `会员直购规则 V1` 已作为 `payment MVP` 的 next-mainline rules draft 冻结
  - 会员费与履约保证金必须严格分离
  - payment success 不等于 entitlement 已生效，最终真相仍以 Server 写入成功为准
  - 当前文书只构成后续 contracts/backend/BFF/frontend 文书链的 planning 输入
  - 当前文书不改写 `我的会员` 现行 bounded read package，也不授予 execution implementation unlock

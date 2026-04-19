---
owner: Codex 总控
status: frozen
purpose: Freeze the current external payment-channel constraint and assumption register for the `payment MVP` planning object, separating mutable channel-side and regulatory constraints from platform-internal permanent truth, without unlocking contracts, implementation, integration, release-prep, or launch.
layer: L0 SSOT
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/payment_mvp_stage_gate_checklist_v1.md
  - docs/00_ssot/payment_mvp_mainline_judgment_v1.md
  - docs/00_ssot/payment_mvp_scope_ruling_v1.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/performance_deposit_preauthorization_rules_v1.md
external_reference_urls:
  - https://huabei.open.alipay.com/channel/huabei/lease.htm
  - https://huabei.open.alipay.com/channel/huabei/hbxx.htm
  - https://pay.wechatpay.cn/doc/v2/partner/4011986476
  - https://www.npc.gov.cn/zgrdw/npc/xinwen/2018-08/31/content_2060172.htm
  - https://www.samr.gov.cn/zw/zfxxgk/fdzdgknr/fgs/art/2026/art_85b474fc5a08494bb60ca6a280b98d7d.html
---

# 《payment channel constraints / assumptions V1》

## 1. Current Position

- 本文当前只作为：
  - `payment MVP`
  - 外部支付通道约束与假设登记件
- 本文当前只冻结：
  - 当前 planning 阶段如何理解和使用外部支付通道事实
  - 哪些内容只能作为 `channel constraint / operational assumption / pending verification`
- 本文当前不是：
  - 平台内部永久真相
  - contracts freeze
  - implementation unlock
  - channel capability 向用户的正式承诺文书

## 2. Classification Rule

- 当前必须写死：
  - 支付渠道的产品能力、商户准入、时效、费率、结算路径、资质限制，首先属于外部通道事实
  - 外部通道事实不自动等于平台内部永久真相
- 因此当前只能按以下三类口径入库：
  - `channel constraint`
  - `operational assumption`
  - `pending verification`
- 当前不得直接冻结成平台永久真相的内容包括：
  - 某通道未来长期不变的准入口径
  - 某通道未来长期不变的结算时效
  - 某通道对所有商户类型一体适用的能力结论

## 3. Current Verified External Baseline

### 3.1 Alipay Current Baseline

- 截至 `2026-04-14 CST`，支付宝公开材料可稳定支持以下 planning baseline：
  - 存在预授权 / 冻结额度后再转支付的公开能力描述
  - 存在解冻冻结额度转支付至商家账户的公开能力描述
- 因此当前 planning 上允许冻结为：
  - 支付宝可以作为 `履约保证金预授权` 的优先 candidate channel
- 但当前不得从上述公开材料直接推导为平台永久真相的内容包括：
  - 所有商户类型都必然可接入
  - 默认结算时效恒定不变
  - 默认费率、结算账户、资金清分路径恒定不变
  - 所有业务场景都能直接复用同一能力

### 3.2 WeChat Current Baseline

- 截至 `2026-04-14 CST`，微信支付公开合作伙伴材料可稳定支持以下 planning baseline：
  - 押金能力存在公开方案说明
  - 该类方案存在服务商白名单与商户授权前提
  - 公开材料明确写到小微商户不支持押金功能
- 因此当前 planning 上必须冻结为：
  - 微信押金能力只能作为 `strategic hold / pending verification`
  - 当前不得把微信押金写成 `payment MVP` 已放行且稳定可用的现行路径

### 3.3 Membership Direct Purchase Channel Baseline

- 截至当前 planning 阶段：
  - `会员直购` 仍可保留为 `微信支付 + 支付宝直付` 双 candidate 方向
- 但在进入 contracts/backend/BFF/frontend 文书链前，必须再次核验至少以下对象：
  - 当前商户主体与通道准入是否成立
  - App / H5 / 小程序等承载形态下的拉起路径是否成立
  - 支付成功回调、退款、对账、异常关闭路径是否成立
  - 当前环境下的组织主体与通道签约方式是否成立

## 4. Regulatory Baseline

- 当前可稳定写入的监管基线只包括：
  - 若向消费者收取押金，应当明示退还方式和程序，不得设置不合理退还条件
  - 平台规则制定、修改时，应遵守适用的显著公示与提前通知义务；当前公开监管规则口径包含“至少在实施前七日予以公示”
- 上述监管基线当前只用于：
  - 约束平台后续规则文书表达
  - 约束保证金退还 / 解冻 / 扣划的公示方式
- 当前不得把监管基线偷换成：
  - 已完成全部法务审查
  - 已完成对所有渠道条款的法律适配

## 5. Planning Assumptions Frozen For Current Stage

- 当前 `payment MVP` 的 channel planning assumptions 冻结如下：
  - `会员直购` 可以继续保留双 channel candidate 叙述
  - `履约保证金预授权` 只允许把支付宝写成优先 candidate
  - `微信押金` 只允许保留为战略扩展位，不得写成当前承诺能力
- 当前还必须继续写死：
  - 任何实际接入范围都必须服从最新准入核验结果
  - 若真实准入结果缩窄，平台范围必须跟着缩窄，不得反向强迫真相适配叙事

## 6. Reverification Gates

- 以下时点必须重新核验外部通道约束：
  - 进入 contracts freeze 前
  - 进入 backend truth freeze 前
  - 进入 BFF / frontend surface freeze 前
  - 云上 integration 前
  - release-prep / launch 前
- 出现以下情况时也必须重新核验：
  - 商户主体类型变化
  - 支付渠道产品文档变化
  - 渠道准入答复变化
  - 结算、费率、退款、资质要求变化

## 7. Explicit Non-goals

- 当前本文明确不做：
  - 冻结精确费率真相
  - 冻结精确结算 SLA 真相
  - 冻结永久有效的商户准入白名单判断
  - 冻结详尽法条逐条解释
  - 冻结渠道产品未来长期路线图

## 8. Formal Conclusion

- 当前正式结论如下：
  - `payment_channel_constraints_assumptions_v1` 已冻结为 `payment MVP` 的外部通道约束与假设登记件
  - 支付宝预授权能力当前足以支持其作为 `履约保证金预授权` 的优先 planning candidate
  - 微信押金能力当前只能写成 `strategic hold / pending verification`
  - 会员直购当前仍可保留双 channel candidate 方向，但不得跳过后续准入复核
  - 上述内容当前只构成后续 contracts/backend/BFF/frontend 文书链的 planning 输入，不构成 implementation unlock

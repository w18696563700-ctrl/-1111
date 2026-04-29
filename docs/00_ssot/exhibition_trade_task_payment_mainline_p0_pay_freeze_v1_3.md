---
owner: Codex 总控
status: superseded
purpose: >
  Historical P0-Pay freeze retained for audit and migration comparison only.
  This file no longer serves as the current platform pricing master after
  platform_pricing_rules_master_v1.
layer: L0 SSOT
freeze_date_local: 2026-04-24
version: V1.3
effective_scope: exhibition_trade_task_p0_pay
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_funds_and_risk_integration_boundary_ruling_addendum.md
  - docs/00_ssot/payment_mvp_scope_ruling_v1.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_implementation_unlock_addendum.md
  - docs/01_contracts/exhibition_bid_submit_full_version_contract_freeze_addendum.md
---

# 展览平台任务发布与交易收费规则母资料 V1.3｜P0-Pay 冻结版

## Supersede Note

自 `2026-04-29` 起，本文件不再作为当前收费母文件使用。

当前唯一收费母文件改为：

- [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md)

本文件仅保留为历史 `P0-Pay` 冻结记录，用于：

1. 审计回溯
2. 差异对比
3. 后续 contracts / backend / BFF / Flutter 重基线时的迁移参考

以下旧结论不再作为当前收费施工真相继续指挥：

1. `询价报价单 200 元发单诚意金` 作为唯一 `200 元` 收费对象
2. `固定 3%` 作为当前唯一平台服务费规则
3. `按报价金额动态预授权` 作为当前唯一预授权额度模型

## 0. 总裁决

平台当前阶段正式冻结为：

- 明价竞标单
- 询价报价单
- 平台服务费预授权
- 询价报价单 200 元发单诚意金
- 成交后平台服务费
- 项目真实性保障
- 消息楼交易承接
- Server 支付真相
- BFF 只读聚合
- Flutter 只消费 BFF

P0-Pay 不启用履约保证金。

履约保证金作为 P1/P2 增强能力预留，不进入本轮实现。

核心原则：

- P0 做轻商业闭环。
- P1 再做履约保证金治理。
- 平台不做钱包、不做余额、不做金币、不做资金池。
- 平台不经手履约保证金。
- 平台不默认裁判大额履约争议。
- 发布方、竞标工厂、中标工厂不需要提前绑定支付宝、微信或银行卡。
- 资金动作按订单级支付、订单级预授权、订单级退款、订单级释放处理。
- Server 是资金状态和业务状态唯一真相。
- BFF 只做认证汇聚、聚合、裁剪、展示整形和轻幂等。
- 消息楼是信息中枢，不是支付执行台、资金裁判台或完整争议处理台。

本版本对旧真相的关系：

- `payment_mvp_scope_ruling_v1.md` 的旧 planning 口径曾把项目支付排除在当前 MVP 外。
- 本文件作为 2026-04-24 新冻结的 `exhibition_trade_task_p0_pay` 主线，只在展览任务 P0-Pay 边界内有界覆盖旧口径。
- 覆盖范围仅限：
  - 明价竞标单的平台服务费预授权
  - 询价报价单的发单诚意金
  - 成交后平台服务费
  - 相关支付订单、回调、释放、退款和审计真相
- 不覆盖、不打开：
  - 会员直购
  - profile 支付状态页
  - 履约保证金
  - 通用支付中心
  - 通用账单中心
  - 钱包 / 余额 / 金币 / 资金池
  - 清分结算 / 发票 / 财务后台

当前更稳的方案：

- 先做 P0-Pay 轻闭环，再做 P1 履约保证金。

当前更省成本的方案：

- 复用支付宝、微信或其他合规支付通道的订单级支付 / 预授权能力，不做平台钱包和支付账户绑定。

当前阶段最适合的方案：

- 明价竞标单平台服务费预授权 + 询价报价单发单诚意金 + 成交后平台服务费 + 消息楼只读承接。

风险更大的方案：

- P0 同时做履约保证金、争议裁判、钱包、资金池、律师协助和复杂赔付计算。

## 1. 当前最小闭环

P0-Pay 只做最小商业闭环：

1. 明价竞标单。
2. 询价报价单。
3. 明价竞标单平台服务费预授权。
4. 询价报价单 200 元发单诚意金。
5. 成交后平台服务费。
6. 项目真实性保障。
7. 发布方处理时限。
8. 信用扣分。
9. 合同确认。
10. 履约节点展示。
11. 验收入口。
12. 评价入口。
13. 争议入口。
14. 消息楼交易沟通、摘要、证据、附件查看、合同确认 handoff。

P0-Pay 不做：

1. 履约保证金冻结。
2. 履约保证金扣除。
3. 保证金争议协商。
4. 平台自动扣保证金。
5. AI 自动判责。
6. 律师团队介入。
7. 平台钱包。
8. 平台余额。
9. 金币账户。
10. 平台资金池。
11. 复杂赔偿计算。
12. 泛私信。
13. 群聊。
14. 全局未读治理。
15. 支付账户绑定模块。

### 1.1 明价竞标单

适用场景：

1. 发布方已有明确预算。
2. 成交意图强。
3. 项目范围相对明确。
4. 有图纸、效果图、清单或展位信息。
5. 需要工厂正式报价竞标。
6. 平台可在成交后收取服务费。

核心流程：

发布方发布明价竞标单
-> 工厂提交报价和方案
-> 工厂完成平台服务费预授权
-> 报名竞标成功
-> 发布方选择中标工厂
-> 未中标工厂释放预授权
-> 中标工厂进入合同确认
-> 双方确认最终成交金额
-> 平台正式扣取成交后平台服务费
-> 进入履约节点
-> 验收
-> 评价 / 争议

核心规则：

1. 不按发布预算直接抽成。
2. 平台服务费按最终成交确认金额计算。
3. 工厂报名时只做平台服务费预授权，不是真实扣平台服务费。
4. 未中标工厂必须自动释放预授权。
5. 中标后不立即扣费，进入合同确认待扣。
6. 合同确认生效后，正式扣取平台服务费。
7. 发布方毁约，释放或退回工厂相关费用，并扣发布方信用。
8. 工厂中标后无故拒签，可按竞标违约规则处理，但不等同于平台服务费。

工厂报名字段：

- 报价金额
- 报价有效期
- 是否含税
- 是否含运输
- 是否含安装
- 施工方案
- 材料说明
- 工艺说明
- 搭建流程
- 交付节点
- 风险说明
- 报价附件
- 平台服务费预授权确认

平台服务费预授权文案：

```text
平台服务费预授权
你的本次报价：____ 元
平台服务费率：3%
预计服务费：____ 元

说明：
本次费用仅为预授权，不代表平台已实际收取。
未中标将自动释放。
中标并完成合同确认后，平台将按最终成交确认金额收取平台服务费。
如最终成交金额变化，服务费将按最终确认金额重新计算。

确认项：
[ ] 我已阅读并同意平台服务费规则
[ ] 我知晓未中标自动释放，中标并合同确认后正式扣款
[ ] 我知晓发布方毁约或项目条件重大变化时，预授权应按规则释放

按钮：
[确认预授权并报名竞标]
```

### 1.2 询价报价单

适用场景：

1. 发布方还没给客户最终报价。
2. 发布方只是想拿工厂报价参考。
3. 项目不一定成交。
4. 工厂提供价格、方案、施工判断。
5. 平台重点防止空询价、套报价、不处理。

核心流程：

发布方发布询价报价单
-> 发布方缴纳 200 元发单诚意金
-> 系统开放 5 个报价席位
-> 工厂提交报价和方案
-> 报价截止
-> 发布方必须处理结果
-> 选择工厂 / 合规关闭 / 取消说明
-> 如成交，进入合同确认
-> 平台按最终成交确认金额收取平台服务费

核心规则：

1. 200 元叫“发单诚意金”，不叫押金。
2. 目的不是赚钱，而是防止空询价、套报价、不处理。
3. P0 不向工厂收询价报价费，避免打击供给。
4. 默认 5 个报价席位，席位满后关闭报价入口。
5. 发布方必须在报价截止后处理结果。
6. 发布方合规处理后，发单诚意金退回。
7. 逾期不处理、恶意询价、绕单成立，可扣发单诚意金并信用扣分。

## 2. 需要保留但暂不开通

以下能力必须保留产品位、数据位或后续文书位，但 P0-Pay 不开通：

1. 履约保证金。
2. 保证金冻结、解冻、扣除、退还。
3. 保证金争议协商。
4. 平台人工争议处理服务。
5. 外部律师争议协助。
6. 节点付款。
7. 验收付款。
8. 平台担保交易。
9. 高金额项目人工审核。
10. 清分结算。
11. 发票系统。
12. 财务后台。
13. 通用支付中心。

## 3. 后续扩展位

P1 履约保证金增强：

1. 工厂可选择是否提供本项目专项履约保证金。
2. 明价竞标单支持保证金冻结。
3. 询价报价单只记录“中选后愿意提供保证金”的承诺。
4. 点击保证金选项前必须阅读保证金规则。
5. 保证金通过支付宝、微信等合规支付通道冻结。
6. 平台不收、不存、不碰保证金。
7. 双方确认完工后自动释放。
8. 发布方超时不处理时自动释放。
9. 有争议时双方线上协商。
10. 协商不成进入争议挂起。
11. 可选平台人工争议处理服务。
12. 可选律师团队争议协助。

P2 重交易系统：

1. 更复杂保证金档位。
2. 高金额项目专项担保。
3. 第三方调解机构接入。
4. 司法确认指引。
5. 仲裁 / 诉讼服务入口。
6. 在线签署调解协议。
7. 节点付款。
8. 验收付款。
9. 平台担保交易。
10. 高金额项目人工审核。

## 4. 四种钱的性质

| 钱的类型 | 谁交 | 目的 | 阶段建议 |
|---|---|---|---|
| 平台服务费 | 中标工厂 | 平台撮合成交后的抽成 | P0 做 |
| 平台服务费预授权 | 明价竞标工厂 | 防止乱占竞标席位，提前确认服务费支付能力 | P0 做 |
| 发单诚意金 | 询价发布方 | 防止空询价、套报价、不处理 | P0 做 |
| 履约保证金 | 工厂或双方 | 保障合同履约、违约处理 | P1/P2 做 |

核心判断：

- P0 做交易撮合的钱。
- P1/P2 再做履约担保的钱。
- “平台服务费预授权”不得再写成“竞标服务费预授权”。
- 它不是竞标费、报名费、席位费，而是中标并合同确认后平台服务费的预授权。

## 5. 平台服务费规则

收费时点：

- 报名竞标时：预授权 / 预冻结。
- 未中标：自动释放。
- 中标后：进入待确认。
- 合同确认生效后：正式扣平台服务费。
- 发布方毁约：释放 / 退回。
- 工厂无故拒签：按竞标违约规则处理。

标准流程：

1. 工厂填写报价。
2. 系统按报价金额计算预计平台服务费。
3. 工厂完成平台服务费预授权。
4. 工厂报名成功。
5. 发布方选择中标工厂。
6. 未中标工厂自动释放预授权。
7. 中标工厂进入合同确认。
8. 双方确认最终成交金额。
9. 系统按最终成交确认金额重新计算平台服务费。
10. 正式扣取平台服务费。
11. 订单进入履约。

计算公式：

```text
平台服务费 = 最终成交确认金额 × 服务费率
```

不得以下列金额作为最终收费真值：

1. 发布预算。
2. 工厂初始报价。
3. 发布方口头估价。
4. 未确认的报价区间。

最终收费真值：

- 合同确认金额。
- 中标确认金额。
- 最终成交确认金额。

P0 统一服务费率：

```text
平台服务费率：3%
```

后续可与会员体系联动，但 P0-Pay 不实现会员费率：

| 主体状态 | 服务费率 |
|---|---:|
| 普通工厂 | 3% |
| 认证工厂 | 2.5% |
| 会员工厂 | 2% |
| 高级会员工厂 | 1.5% |

预授权金额：

```text
预授权金额 = 工厂报价金额 × 当前服务费率
```

示例：

- 工厂报价：80,000 元。
- 服务费率：3%。
- 预授权金额：2,400 元。
- 最终成交确认金额：92,000 元。
- 最终平台服务费：2,760 元。
- 系统执行多退少补或重新确认。

未中标处理：

- 未中标 -> 100% 自动释放预授权。
- 平台不得向未中标工厂收取平台服务费。

中标后处理：

- 中标 -> 预授权进入待确认状态。
- 合同确认生效 -> 正式扣平台服务费。
- 中标不等于立即成交。
- 合同确认才是正式扣款节点。

发布方毁约：

适用：

1. 发布方选择工厂后无正当理由取消。
2. 发布方拒绝进入合同确认。
3. 发布方重大变更项目条件导致无法成交。

处理：

1. 释放工厂平台服务费预授权。
2. 如已扣款，应退回。
3. 发布方信用扣分。
4. 项目标记为发布方毁约。
5. 后续限制发布高金额项目。

### 5.1 工厂中标后无故拒签

适用：

1. 项目条件未发生重大变化。
2. 发布方已选择该工厂。
3. 工厂无正当理由拒绝合同确认。
4. 工厂超时不处理。
5. 工厂恶意低价竞标后反悔。

处理原则：

1. 不得默认全额扣取平台服务费预授权。
2. 可按竞标违约规则部分处理。
3. 记录信用扣分。
4. 限制后续竞标权限。
5. 该扣除属于竞标违约处理 / 占位违约处理，不等同于平台服务费。

参考上限：

| 情况 | 处理 |
|---|---:|
| 首次轻微拖延，未造成影响 | 警告或 0% - 10% |
| 超过 48 小时未确认 | 10% - 20% |
| 明确拒签，导致发布方重新选择 | 20% - 30% |
| 恶意低价竞标后拒签 | 30% - 50% |

## 6. 发单诚意金规则

金额：

```text
200 元
```

名称：

```text
发单诚意金
```

不得使用：

- 押金。
- 罚款。
- 保证金。
- 平台扣款。

用途是防止：

1. 假项目。
2. 空询价。
3. 套报价。
4. 拿工厂报价压原供应商。
5. 发布后不处理。
6. 绕开平台成交。
7. 恶意重复发布。

报价席位：

1. P0 默认 5 个报价席位。
2. 最多 5 家工厂可提交报价。
3. 席位满后关闭报价入口。
4. 发布方可以查看报价和方案。
5. 报价截止后必须处理结果。

退还规则：

退还：

1. 发布方选择一家工厂进入合同确认。
2. 发布方合规关闭并说明原因。
3. 发布方取消项目且说明合理原因。

可扣除：

1. 发布方逾期不处理。
2. 发布方恶意套报价。
3. 发布方虚假发布。
4. 发布方绕单成立。
5. 发布方多次不选、不说明。
6. 被多家工厂投诉且平台判定成立。

发布方处理时限：

| 节点 | 处理 |
|---|---|
| 报价截止后 48 小时内 | 必须处理 |
| 超过 48 小时 | 系统提醒 |
| 超过 72 小时 | 标记异常 |
| 超过 7 天未处理 | 扣发单诚意金并记录信用 |

处理方式：

1. 选择一家进入合同确认。
2. 暂不成交，但必须说明原因。
3. 取消项目，但必须说明原因。

推荐文案：

```text
发单诚意金用于约束发布方完成结果处理。
发布方完成选择、关闭说明或合规取消后退回。
发布方逾期不处理、恶意询价、虚假发布、绕单或被投诉成立的，可按平台规则扣除并记录信用影响。
```

## 7. 项目真实性保障

发布主体要求：

1. 已登录。
2. 已绑定手机号。
3. 已完成企业认证或组织认证。
4. 账号无严重违规。
5. 未被限制发布。

未认证主体：

- 只能保存草稿。
- 不能公开发布明价竞标单。
- 询价单进入低可信状态或平台审核状态。

项目必填字段：

- 项目名称
- 项目城市
- 项目类型
- 展会 / 活动名称
- 施工面积
- 搭建时间
- 撤展时间
- 需求说明
- 预算金额或预算区间
- 报价截止时间
- 联系人

项目真实性材料至少上传一种：

- 效果图
- 施工图
- 平面图
- 展位图
- 客户需求截图
- 客户委托说明
- 招标文件
- 展馆信息
- 主办方信息
- 历史项目照片
- 其他能证明项目真实存在的材料

项目真实性等级：

| 等级 | 定义 | P0-Pay 状态 |
|---|---|---|
| T0 草稿项目 | 信息不完整，不公开 | 做 |
| T1 基础真实 | 主体已认证，字段完整 | 做 |
| T2 材料真实 | 上传有效项目材料 | 做 |
| T3 强真实 | 有客户委托、合同、招标文件等强证明 | 预留 |
| T4 平台核验 | 人工审核通过 | 预留 |

真实性声明：

```text
[ ] 我确认本项目需求真实存在
[ ] 我确认已获得发布该项目需求的授权
[ ] 我确认不会以套取报价、恶意比价、绕开平台交易为目的发布项目
[ ] 我确认发布后会在规定时间内处理报价或竞标结果
[ ] 我知晓违规发布将影响企业信用，并可能限制后续发布权限
```

## 8. 消息楼信息中枢规则

消息楼是交易信息中枢，只承接：

1. 交易沟通。
2. 沟通摘要。
3. 系统种子消息。
4. 证据材料查看。
5. 附件查看。
6. 报价 / 竞标摘要只读展示。
7. 平台服务费预授权状态只读展示。
8. 发单诚意金状态只读展示。
9. 合同确认 handoff。
10. 履约节点 handoff。
11. 验收 / 评价 / 争议入口 handoff。

消息楼不得承接：

1. 支付执行。
2. 资金状态真相。
3. 扣费裁判。
4. 履约保证金裁判。
5. 完整争议处理台。
6. 泛私信。
7. 群聊。
8. 全局未读治理。
9. 第二套交易状态机。
10. 第二套聊天状态机。

资金状态展示边界：

- 消息楼展示资金相关状态时，只能读取 Server/BFF 聚合后的只读状态。
- 消息楼不得产生、修改或裁定资金状态。
- 消息楼不得保存支付回调真相。
- 消息楼不得绕过合同确认直接触发扣费。

## 9. 支付与资金边界

P0-Pay 必须采用：

1. 支付通道订单级支付。
2. 支付通道订单级预授权。
3. 支付通道订单级退款。
4. 支付通道订单级释放。
5. Server 保存支付真相。
6. BFF 聚合只读状态。
7. Flutter 只触发订单创建、跳转和状态轮询。

平台不得：

1. 建立钱包。
2. 建立余额。
3. 建立金币。
4. 建立资金池。
5. 保存用户资金账户控制权。
6. 代管履约保证金。
7. 用平台账户承接履约保证金。
8. 将支付通道约束直接写成永久业务真理。

支付通道约束处理：

- 支付宝、微信或其他合规支付通道的准入、预授权、回调、退款、释放能力是 channel constraint。
- 具体通道限制必须在 L2/L3 冻结前重新核验。
- 通道文档、商户资质、回调域名、App 支付能力和预授权能力不满足时，排期顺延。
- 不得为了抢进度改做平台钱包或资金池。

### 9.1 支付通道与账户绑定边界

平台不要求发布方、竞标工厂、中标工厂提前绑定支付宝、微信或银行卡。

P0-Pay 所有资金动作均采用：

1. 订单级支付。
2. 订单级预授权。
3. 订单级退款。
4. 订单级释放。

用户点击支付或预授权时：

1. Flutter 通过 BFF 请求创建支付 / 预授权订单。
2. BFF 转发并整形 Server 返回结果，不保存资金真相。
3. Server 生成支付订单。
4. Flutter 跳转支付宝、微信或其他合规支付通道。
5. 用户在支付通道内完成确认。
6. 支付通道回调 Server。
7. Server 验签、幂等处理、更新订单状态和审计日志。
8. Flutter 通过 BFF 轮询或读取 Server 聚合后的状态。

平台只保存：

- 支付通道
- 商户订单号
- 支付 / 授权订单号
- 交易状态
- 回调结果
- 退款 / 释放状态
- 审计日志

平台不得保存：

- 支付宝账号
- 微信账号
- 银行卡号
- 支付密码
- 短信验证码
- 用户资金账户控制权
- 长期自动扣款授权

后续如启用履约保证金：

- 也只采用项目级冻结订单。
- 不绑定用户支付宝或微信账户。
- 不建设平台保证金账户。

## 10. 状态建议

### 10.1 平台服务费状态

| 状态 | 含义 |
|---|---|
| `not_required` | 无需预授权 |
| `pending_authorization` | 待预授权 |
| `authorized` | 已预授权 |
| `authorization_released` | 预授权已释放 |
| `pending_contract_confirm` | 待合同确认 |
| `charged` | 已扣取 |
| `refund_pending` | 退款中 |
| `refunded` | 已退回 |
| `breach_hold` | 违约挂起 |
| `cancelled` | 已取消 |

### 10.2 发单诚意金状态

| 状态 | 含义 |
|---|---|
| `pending_payment` | 待支付 |
| `paid` | 已支付 |
| `refund_pending` | 待退还 |
| `refunded` | 已退还 |
| `deducted` | 已扣除 |
| `dispute_hold` | 争议挂起 |
| `cancelled` | 已取消 |

### 10.3 履约保证金状态

履约保证金状态只作为 P1/P2 预留词表，P0-Pay 不实现：

| 状态 | 含义 |
|---|---|
| `not_provided` | 未提供 |
| `committed` | 已承诺，中选后提供 |
| `pending_freeze` | 待冻结 |
| `frozen` | 已冻结 |
| `completion_requested` | 工厂申请完工 |
| `publisher_confirmed` | 发布方确认完工 |
| `factory_confirmed` | 工厂确认完工 |
| `auto_release_pending` | 待自动释放 |
| `released` | 已释放 |
| `rectification_requested` | 发布方要求整改 |
| `dispute_opened` | 争议已发起 |
| `negotiation_pending` | 协商中 |
| `settlement_proposed` | 处理方案已提出 |
| `settlement_confirmed` | 双方已确认处理方案 |
| `partial_deducted` | 部分扣除 |
| `full_deducted` | 全额扣除 |
| `refund_pending` | 退款中 |
| `refund_failed` | 退款失败 |
| `cancelled` | 已取消 |

## 11. 最小数据模型

```yaml
tradeTask:
  taskId: string
  taskType: fixed_price_bid | inquiry_quote
  publisherOrganizationId: string
  projectName: string
  cityCode: string
  projectType: string
  exhibitionName: string
  area: number
  buildStartAt: string
  dismantleAt: string
  requirementDescription: string
  budgetAmount: number
  budgetRange: string
  quoteDeadlineAt: string
  contactId: string
  authenticityLevel: T0 | T1 | T2 | T3 | T4
  status: draft | published | quoting | bid_closed | selected | contract_pending | contract_confirmed | performing | completed | cancelled | disputed

platformServiceFee:
  feeId: string
  taskId: string
  bidId: string
  factoryOrganizationId: string
  quotedAmount: number
  finalConfirmedAmount: number
  feeRate: number
  estimatedFeeAmount: number
  finalFeeAmount: number
  paymentChannel: alipay | wechat | other
  merchantOrderId: string
  authorizationOrderId: string
  chargeOrderId: string
  status: not_required | pending_authorization | authorized | authorization_released | pending_contract_confirm | charged | refund_pending | refunded | breach_hold | cancelled
  ruleVersion: string
  ruleSnapshotHash: string
  agreementTextSnapshot: string
  authorizedAt: string
  releasedAt: string
  chargedAt: string
  refundedAt: string
  auditLogId: string

inquiryDeposit:
  depositId: string
  taskId: string
  publisherOrganizationId: string
  amount: 200
  paymentChannel: alipay | wechat | other
  merchantOrderId: string
  paymentOrderId: string
  status: pending_payment | paid | refund_pending | refunded | deducted | dispute_hold | cancelled
  paidAt: string
  refundedAt: string
  deductedAt: string
  deductionReason: string
  ruleVersion: string
  ruleSnapshotHash: string
  auditLogId: string

paymentOrder:
  paymentOrderId: string
  businessType: platform_service_fee_authorization | platform_service_fee_charge | inquiry_deposit_payment | inquiry_deposit_refund
  businessId: string
  payerOrganizationId: string
  amount: number
  currency: CNY
  channel: alipay | wechat | other
  merchantOrderId: string
  channelOrderId: string
  status: created | pending_user_confirm | succeeded | failed | cancelled | closed | refund_pending | refunded | release_pending | released
  callbackVerified: boolean
  callbackPayloadHash: string
  createdAt: string
  updatedAt: string
  auditLogId: string

performanceGuarantee:
  guaranteeId: string
  taskId: string
  bidId: string
  quotationId: string
  providerOrganizationId: string
  publisherOrganizationId: string
  amount: number
  currency: CNY
  paymentChannel: alipay | wechat | other
  channelFreezeOrderId: string
  status: not_provided | committed | pending_freeze | frozen | completion_requested | publisher_confirmed | factory_confirmed | auto_release_pending | released | rectification_requested | dispute_opened | negotiation_pending | settlement_proposed | settlement_confirmed | partial_deducted | full_deducted | refund_pending | refund_failed | cancelled
  ruleVersion: string
  ruleSnapshotHash: string
  agreedAt: string
  frozenAt: string
  releasedAt: string
  deductedAmount: number
  releasedAmount: number
  disputeId: string
  auditLogId: string
```

## 12. P1 履约保证金独立规则包索引

履约保证金不并入 P0-Pay。

本轮不得实现：

1. 履约保证金实缴。
2. 履约保证金冻结。
3. 履约保证金扣除。
4. 履约保证金释放。
5. 履约保证金争议协商。
6. 平台人工争议处理。
7. 律师争议协助。

后续如启动 P1，必须先单独冻结以下规则：

1. 本项目专项履约保证金规则。
2. 履约保证金释放与扣除规则。
3. 履约保证金争议协商规则。
4. 支付通道冻结与解冻边界规则。
5. 平台人工争议处理服务费规则。
6. 外部律师争议协助规则。

在上述规则冻结前，任何 Agent 不得进入：

1. 履约保证金实缴。
2. 冻结。
3. 扣除。
4. 释放。
5. 争议协商。
6. 人工处理。
7. 律师协助实现。

## 13. 禁止项

任何 Agent 不得设计：

1. 平台自有资金池。
2. 平台钱包承接保证金。
3. 金币替代保证金。
4. 保证金购买排名。
5. 按保证金金额默认排序。
6. 平台单方面自动扣保证金。
7. 无证据扣保证金。
8. 人工服务费默认从保证金扣。
9. 律师团队直接控制资金。
10. 律师团队直接修改信用分。
11. 律师团队绕过双方确认。
12. 律师意见包装成法院判决或仲裁裁决。
13. 询价阶段默认冻结工厂保证金。
14. 报名竞标时真实扣取平台服务费。
15. 按发布预算直接抽平台服务费。
16. 未中标工厂被收平台服务费。
17. 要求用户提前绑定支付宝、微信或银行卡。
18. 保存支付宝账号、微信账号、银行卡号、支付密码、短信验证码。
19. BFF 保存资金真相。
20. Flutter 直连 Server。
21. 消息楼产生、修改或裁定资金状态。

## 14. 阶段门禁核查表

本文件提交后，当前阶段门禁结论如下。

已通过门禁：

1. `L0 SSOT` 总裁决已冻结。
2. P0-Pay 当前最小闭环已冻结。
3. P1/P2 保证金边界已冻结为暂不开通。
4. 平台服务费预授权命名已统一。
5. 工厂拒签扣预授权比例上限已冻结。
6. 消息楼交易承接边界已冻结。
7. 支付通道与账户绑定边界已冻结。
8. 平台不做钱包、余额、金币、资金池已冻结。
9. Server/BFF/Flutter 责任边界已冻结。

未通过门禁：

1. P0-Pay `L2 Contracts` 尚未冻结。
2. P0-Pay `L3 Server truth and persistence` 尚未冻结。
3. P0-Pay `L4 BFF surface` 尚未冻结。
4. P0-Pay `L5 Flutter consumption` 尚未冻结。
5. 支付通道商户资质、App 支付、预授权、退款、释放和回调域名尚未完成当前轮核验。
6. 云上 BFF / Server 支付主线尚未完成 implementation receipt。
7. Flutter 端支付跳转、状态轮询和消息楼只读状态承接尚未完成 implementation receipt。
8. 隧道端到端 smoke 尚未完成。

保留否决门禁：

1. 未冻结 L2/L3/L4/L5 前，不得直接进入重实现。
2. BFF 不得拥有业务真相、资金真相或第二状态机。
3. Flutter 不得直连 Server。
4. Server 必须是支付订单、回调、状态、审计唯一真相。
5. 不得在 P0-Pay 打开履约保证金。
6. 不得建设钱包、余额、金币、资金池或支付账户绑定模块。
7. 不得把消息楼改成支付执行台或争议裁判台。

下一阶段结论：

- `Go`：进入 P0-Pay `L2 Contracts` 冻结编写。
- `No-Go`：直接进入代码实现、云上发布或生产切流。

## 15. 精确到天的完整工期任务步骤表

工期口径：

- 以自然日计算。
- D0 为 2026-04-24。
- 默认从 2026-04-24 当天完成本文件冻结开始。
- BFF 和 Server 在阿里云，本地只做前端与文书 / 合约 / 调度核查。
- 云上服务默认通过本地隧道核验：

```bash
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

排期结论：

- 稳妥版完整工期：29 个自然日。
- 最早可在 2026-05-21 进入生产发布门禁。
- 最早可在 2026-05-22 完成首轮上线观察闭环。
- 若支付通道商户资质、预授权能力、App 支付能力或回调域名审核阻塞，整体顺延。

| 天数 | 日期 | 任务 | 产物 | 门禁 |
|---:|---|---|---|---|
| D0 | 2026-04-24 | 冻结 P0-Pay V1.3 母资料，登记 source map | 本文件 | Go for L2 authoring |
| D1 | 2026-04-25 | 编写 P0-Pay L2 contracts：任务发布、平台服务费预授权、发单诚意金、只读状态 | `docs/01_contracts/*p0_pay*` 草案 | No-Go for code |
| D2 | 2026-04-26 | 合同评审和冻结：错误码、幂等键、回调状态、BFF app-facing 路径 | L2 contract freeze | Go for L3 authoring |
| D3 | 2026-04-27 | 编写 Server truth：TradeTask、PlatformServiceFee、InquiryDeposit、PaymentOrder、Audit | L3 Server truth 草案 | No-Go for backend code |
| D4 | 2026-04-28 | 冻结 Server persistence / state machine / audit / idempotency / callback truth | L3 Server freeze | Go for L4 authoring |
| D5 | 2026-04-29 | 编写 BFF surface：创建订单、预授权、状态读取、消息楼只读聚合 | L4 BFF surface 草案 | No-Go for BFF code |
| D6 | 2026-04-30 | 冻结 BFF surface：不保存资金真相、不二次状态机、不直连绕路 | L4 BFF freeze | Go for L5 authoring |
| D7 | 2026-05-01 | 编写 Flutter consumption：发布页、竞标页、询价诚意金、消息楼状态 | L5 Frontend 草案 | No-Go for Flutter code |
| D8 | 2026-05-02 | 冻结 Flutter consumption：支付跳转、轮询、失败态、只读 handoff | L5 Frontend freeze | Go for implementation unlock review |
| D9 | 2026-05-03 | 编写 implementation unlock addendum 和阶段门禁核查 | unlock addendum | Go/No-Go 决策 |
| D10 | 2026-05-04 | Server 实现支付基础模型、迁移、幂等、审计骨架 | Server patch 1 | 本地/云上可构建 |
| D11 | 2026-05-05 | Server 实现明价竞标单平台服务费预授权创建、释放、待合同确认 | Server patch 2 | 单元测试通过 |
| D12 | 2026-05-06 | Server 实现询价报价单发单诚意金支付、退回、扣除状态 | Server patch 3 | 单元测试通过 |
| D13 | 2026-05-07 | Server 实现支付通道适配、回调验签、幂等回调、状态读模型 | Server patch 4 | 回调模拟通过 |
| D14 | 2026-05-08 | Server 实现合同确认后平台服务费正式扣取、多退少补或重新确认 | Server patch 5 | 状态机测试通过 |
| D15 | 2026-05-09 | Server 集成测试：未中标释放、发布方毁约、工厂拒签比例上限 | Server receipt draft | Go for BFF code |
| D16 | 2026-05-10 | BFF 实现 app-facing 路由、请求整形、轻幂等、错误映射 | BFF patch 1 | BFF tests pass |
| D17 | 2026-05-11 | BFF 实现消息楼资金状态只读聚合、任务详情只读状态聚合 | BFF patch 2 | tunnel curl pass |
| D18 | 2026-05-12 | Flutter 实现任务发布类型选择、真实性材料、询价诚意金支付入口 | Flutter patch 1 | Flutter analyze pass |
| D19 | 2026-05-13 | Flutter 实现明价竞标报价、平台服务费预授权确认和跳转 | Flutter patch 2 | widget/golden smoke |
| D20 | 2026-05-14 | Flutter 实现支付结果页、状态轮询、失败态、重新拉起支付 | Flutter patch 3 | app smoke |
| D21 | 2026-05-15 | Flutter 实现项目详情和消息楼只读资金状态、合同确认 handoff | Flutter patch 4 | app smoke |
| D22 | 2026-05-16 | 云上联调：隧道、发布询价、支付诚意金、报价席位、合规退回 | E2E receipt 1 | blocker list |
| D23 | 2026-05-17 | 云上联调：明价竞标、预授权、未中标释放、中标待合同确认 | E2E receipt 2 | blocker list |
| D24 | 2026-05-18 | 云上联调：合同确认扣服务费、发布方毁约退回、工厂拒签挂起 | E2E receipt 3 | Go for UAT |
| D25 | 2026-05-19 | UAT 第 1 轮：发布方、工厂双账号完整链路；记录问题 | UAT report 1 | fixes only |
| D26 | 2026-05-20 | 修复 UAT 问题，补齐文书回执、OpenAPI diff、状态截图证据 | fix receipt | Go for release gate |
| D27 | 2026-05-21 | 生产发布门禁：回滚点、开关、支付通道回调、日志与告警核查 | release gate checklist | Go/No-Go |
| D28 | 2026-05-22 | 灰度发布和首日观察：交易、支付、退款/释放、消息楼展示 | day-1 observation receipt | Close or extend |

关键风险和顺延规则：

1. 支付通道预授权能力未开通：至少顺延 2-5 天。
2. 支付通道 App 支付或回调域名审核未通过：至少顺延 3-7 天。
3. 云上 BFF / Server 无法稳定回写代码或发布：至少顺延 2-4 天。
4. 双账号 UAT 缺少真实商户支付环境：至少顺延 2-3 天。
5. 若临时加入履约保证金，当前 P0-Pay 排期作废，必须重开 P1 文书链。

## 16. 最终冻结口径

平台交易任务分为明价竞标单和询价报价单。

P0-Pay 阶段不启用履约保证金，先通过明价竞标单的平台服务费预授权、询价报价单的 200 元发单诚意金、成交后的平台服务费、项目真实性材料、发布方处理时限、消息楼交易承接和信用扣分，完成轻量商业闭环。

明价竞标单用于预算明确、成交意图强的项目。工厂报名时提交报价和方案，并按报价金额完成平台服务费预授权。预授权不等于平台已收款。未中标自动释放；中标后进入合同确认；合同确认生效后，平台按最终成交确认金额和服务费率正式扣取平台服务费。发布方毁约或项目条件重大变化导致合同未确认的，应释放或退回工厂预授权；工厂中标后无正当理由拒签的，可按竞标违约规则处理，但不等同于平台服务费。

询价报价单用于发布方获取报价参考。发布方缴纳 200 元发单诚意金，默认开放 5 个报价席位。报价截止后，发布方必须完成选择、关闭说明或取消说明。发布方合规处理后，发单诚意金退回；逾期不处理、恶意询价、虚假发布、绕单成立的，可按规则扣除发单诚意金并记录信用。

消息楼是 P0-Pay 的信息中枢，只承接交易沟通、摘要、证据、附件查看、资金状态只读展示和合同确认 handoff。消息楼不得执行支付、产生资金真相、修改资金状态、裁定扣费、裁定履约保证金或承接完整争议处理台。

支付执行采用订单级支付、订单级预授权、订单级退款和订单级释放。发布方、竞标工厂、中标工厂不需要提前绑定支付宝、微信或银行卡。平台只保存支付通道、商户订单号、支付 / 授权订单号、交易状态、回调结果、退款 / 释放状态和审计日志；不得保存支付宝账号、微信账号、银行卡号、支付密码、短信验证码、用户资金账户控制权或长期自动扣款授权。

履约保证金作为 P1/P2 增强能力预留。后续如启用，必须采用支付宝、微信或其他合规支付通道冻结，平台不收取、不保管、不沉淀、不挪用保证金。保证金不得用于购买排名，不得作为平台服务费、广告费、会员费或平台收入。正常完工由双方确认后自动释放，有争议时优先双方线上协商，协商不成进入争议挂起。平台不默认人工裁判，不自动判责，不自动扣款。复杂争议后续可接入平台人工争议处理或外部律师团队协助，但律师团队不碰资金、不直接裁判、不绕过双方确认。

一句话结论：

```text
P0-Pay 做轻闭环赚钱：明价竞标单平台服务费预授权 + 询价单发单诚意金 + 成交后平台服务费。
P1 再做履约保证金：支付通道冻结 + 双方确认释放 + 协商争议处理。
平台始终不碰保证金、不建资金池、不自动裁判。
```
